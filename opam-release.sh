#!/usr/bin/env bash
set -e
shopt -s nullglob

if [ "$DEBUG" = 1 ]; then
  set -x
fi

show_help(){
    cat <<EOF
Usage : opam-release (options)* (opam-files)*
--
opam-files: an opam file to push to opam-coq-archive
  * if no argument is provided, it lists *.opam files in the current directory
options:
  -u GITHUB_USER / --user GITHUB_USER:
    where GITHUB_USER is your github username,
    you must have a fork of coq/opam-coq-archive under
    https://github.com/$GITHUB_USER/opam-coq-archive
    for this command to work,
    * if not provided, tries "git config --get github.user"
      which you can set using "git config --global github.user GITHUB_SER"
  -p PROJECT / --project PROJECT:
    where PROJECT is a name of the project, without space,
    it is used solely for generating  the name of the branch and PR,
    * automatically infered from the name of the opam file,
      if only one was given.
  -e DEPTH / --depth DEPTH:
    sets the depth of the local clone of opam-coq-archive to $DEPTH
    * defaults to full clone, you may want to fix the DEPTH to save bandwidth and time
  -V VERSION / --version VERSION:
    where VERSION is the opam version number of
    the package to create,
    * if no version is provided, tries to find the latest tag,
    you may want to perform a "git remote update" to fetch all tags first
  -U URL / --url URL:
    where URL is the url of the archive associated
    with the version to release.
    * tries to infer it from the "dev-repo" section if one opam file is provided
  -x PREFIX / --version-prefix PREFIX: the tag of a version is equal to $PREFIX$VERSION
     *  default is ""
     ** this options is used only if URL is not provided
  -r / --local-opam-coq-archive LOCAL_OCA: where LOCAL_OCA is the path to
     a local copy of the opam-coq-archive repository to speed up downloads
  -d / --dev: pushes an update to extra-dev instead of releases
  -C / --no-check-upstream: tells opam lint not to check the sum online
  -c / --check-upstream: foce opam lint to check the sum online, (even
    if it was disable for some reason, e.g. incompatible opam version)
  -h / -? / --help: print this usage
  -s / --show-defaults: prints the default inferred setting and exists
  -v / --verbose: show debug information
  -L / --no-lint: do not run opam lint
    (not recommended but useful if you do not have opam installed)
  -l / --lint: force opam lint, (even if it was disabled for some reason)
  -n / --do-nothing: do not push anything
--
All above options can be set with the corresponding environment variable.
Additionally, one may use the DEBUG environement variable tuo turn on
debugging through options -x.
EOF
}

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# Checking git and opam are installed
if ! command -v git &> /dev/null; then
    die "ERROR: git cannot be found, you must install it."
fi
if ! command -v opam &> /dev/null; then
    die "ERROR: opam cannot be found, you must install it."
fi
# checking opam version
verle() {
    [ "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}
if verle "2.1.0" $(opam --version); then
  CHECKUPSTREAM="${CHECKUPSTREAM:---check-upstream}"
fi
#

# trying to retrieve github user
GITHUB_USER="${GITHUB_USER:-$(git config --default '' --get github.user)}"

if ! [ "$TAG" ]; then
    if (git describe --tags &> /dev/null) then
       TAG=$(git describe --tags --abbrev=0)
    fi
fi
VERSION="${VERSION:-$(echo $TAG | sed -e 's/[^0-9]*\(\([0-9]+|\.\)\)*/\1/')}"
PROJECT="${PROJECT:-}"
LINT="${LINT:-1}"
NOTHING="${NOTHING:-0}"
TARGET="${TARGET:-released}"
SHOWDEFAULTS="${SHOWDEFAULTS:-0}"
OPAM=()

while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit 0
            ;;
        -u|--user)
            if [ "$2" ]; then GITHUB_USER=$2; shift; shift
            else die 'ERROR: "--user" requires a non-empty argument, cf --help'
            fi
            ;;
        -p|--project)
            if [ "$2" ]; then PROJECT=$2; shift; shift
            else die 'ERROR: "--project" requires a non-empty argument, cf --help'
            fi
            ;;
        -V|--version)
            if [ "$2" ]; then VERSION=$2; shift; shift
            else die 'ERROR: "--version" requires a non-empty argument, cf --help'
            fi
            ;;
        -U|--url)
            if [ "$2" ]; then URL=$2; shift; shift
            else die 'ERROR: "--url" requires a non-empty argument, cf --help'
            fi
            ;;
        -e|--depth)
            if [ "$2" ]; then HDEPTH="$2"; DEPTH="--depth=$2"; shift; shift
            else die 'ERROR: "--depth" requires a non-empty argument, cf --help'
            fi
            ;;
        -x|--version-prefix)
            if [ "$2" ]; then PREFIX=$2; shift; shift
            else die 'ERROR: "--version-prefix" requires a non-empty argument, cf --help'
            fi
            ;;
        -r|--local-opam-coq-archive)
            if [ "$2" ]; then LOCAL_OCA=$2; shift; shift
            else die 'ERROR: "--local-opam-coq-archive" requires a non-empty argument, cf --help'
            fi
            ;;
        -l|--lint)
            LINT=1; shift
            ;;
        -L|--no-lint)
            LINT=0; shift
            ;;
        -d|--dev)
            TARGET="extra-dev"
            VERSION="dev"
            CHECKUPSTREAM=
            shift
            ;;
        -c|--check-upstream)
            CHECKUPSTREAM="--check-upstream"
            shift
            ;;
        -C|--no-check-upstream)
            CHECKUPSTREAM=
            shift
            ;;
        -v|--verbose)
            VERBOSE=1; shift
            ;;
        -s|--show-defaults)
            SHOWDEFAULTS=1; shift
            ;;
        -n|--do-nothing)
            NOTHING=1; shift
            ;;
        *)    # unknown option
            if ! [ "$*" ]; then
                break
            elif [ -f "$1" ]; then
                OPAM+=("$1")
                shift
            else die 'ERROR: positional argument must be an existing file.'
            fi
            ;;
    esac
done

if ! [ "$OPAM" ]; then
   OPAM=(); for opam in *.opam; do OPAM+=("$opam"); done
fi

eval set -- "${OPAM[@]}"

if ! [ "$GITHUB_USER" ]; then
    die 'ERROR: -u / --user argument is required, cf --help'
fi

if ! [ "$VERSION" ]; then
    die 'ERROR: -V / --version argument is required, cf --help'
fi

if [ "$PREFIX" ]; then
    TAG=$PREFIX$VERSION
fi

case "${#OPAM[@]}" in
    0)
        die 'ERROR: no opam file provided or found cf --help'
        ;;
    1)
        if ! [ "$PROJECT" ]; then
            PROJECT=$(basename "${OPAM[0]}" .opam)
        fi
        ;;
    *)
        if ! [ "$PROJECT" ]; then
            die 'ERROR: --project argument is required when more than one opam files are given, cf --help'
        fi
        ;;
esac

if ! [ "$URL" ]; then
    if [ "$TARGET" = "released" ]; then
        URL=$(opam show -f dev-repo --file "${OPAM[0]}" | sed -e "s/git+//" | sed -e "s+\.git+/archive/$TAG.tar.gz+")
    else
        URL="$(opam show -f dev-repo --file ${OPAM[0]})#master"
    fi
fi

if ! [ "$URL" ]; then
    die 'ERROR: --url argument cannot be inferred, please provide it manually, cf --help'
fi

if [ "$VERBOSE" = 1 ]; then
    echo "DEBUG=$DEBUG";
    echo "TAG=$TAG";
    echo "PREFIX=$PREFIX";
    echo "VERSION=$VERSION";
    echo "VERBOSE=$VERBOSE";
    echo "PROJECT=$PROJECT";
    echo "GITHUB_USER=$GITHUB_USER";
    echo "URL=$URL";
    echo "LINT=$LINT";
    echo "NOTHING=$NOTHING";
    echo "DEPTH=$DEPTH";
    echo "HDEPTH=$HDEPTH";
    echo "TARGET=$TARGET";
    echo "OPAM=$OPAM";
    echo "CHECKUPSTREAM=$CHECKUPSTREAM";
    echo "PREFIX=$PREFIX";
    echo "SHOWDEFAULTS=$SHOWDEFAULTS";
    echo "LOCAL_OCA=$LOCAL_OCA";
fi

if [ "$SHOWDEFAULTS" = 1 ]; then
    echo "# this would call"
    echo "$0 \\"
    if [ "$VERBOSE" = 1 ]; then echo "-v \\"; fi
    echo "-u $GITHUB_USER \\"
    echo "-V $VERSION \\"
    echo "-p $PROJECT \\"
    echo "-U $URL \\"
    if [ "$LOCAL_OCA" ]; then echo "-r $LOCAL_OCA \\"; fi
    if [ "$LINT" = 0 ]; then echo "-L \\"; fi
    if [ "$NOTHING" = 1 ]; then echo "-n \\"; fi
    if [ "$HDEPTH" ]; then echo "-e $HDEPTH \\"; fi
    if [ "$TARGET" = "extra-dev" ]; then echo "--dev \\"; fi
    if ! [ "$CHECKUPSTREAM" ]; then echo "-C \\"; fi
    echo "${OPAM[@]}"
fi

if [ "$SHOWDEFAULTS" = 1 ]; then
    exit
fi

TMP_OCA=$(mktemp -d) # stands for Opam Coq Archive
if [ "$LOCAL_OCA" ]; then
  git clone $LOCAL_OCA $TMP_OCA -o local
  git -C $TMP_OCA remote add upstream git@github.com:coq/opam-coq-archive
  git -C $TMP_OCA fetch upstream master
  git -C $TMP_OCA reset --hard upstream/master
else
  git clone $DEPTH git@github.com:coq/opam-coq-archive $TMP_OCA -o upstream
fi
git -C $TMP_OCA remote add origin git@github.com:$GITHUB_USER/opam-coq-archive
BRANCH=$PROJECT.$VERSION
git -C $TMP_OCA checkout -b $BRANCH
PKGS=$TMP_OCA/$TARGET/packages

ARCHIVE=$(mktemp)
if [ "$TARGET" = "released" ]; then
   curl -L $URL -o $ARCHIVE
   SUM=$(sha256sum $ARCHIVE | cut -d " " -f 1)
fi

if [ "$VERBOSE" = 1 ]; then
    echo "TMP_OCA=$TMP_OCA"
    echo "BRANCH=$BRANCH"
    echo "PKGS=$PKGS"
    echo "ARCHIVE=$ARCHIVE"
    echo "SUM=$SUM"
fi

for opam in ${OPAM[@]}; do
    B=$(basename $opam .opam)
    P=$PKGS/$B/$B.$VERSION
    mkdir -p $P
    sed "/^version:.*/d" $opam > $P/opam
    sed -i -e '/^[ \t]*#/d' $P/opam
    echo "" >> $P/opam
    echo "url {" >> $P/opam
    echo "  src: \"$URL\"" >> $P/opam
    if [ "$TARGET" = "released" ]; then
        echo "  checksum: \"sha256=$SUM\"" >> $P/opam
    fi
    echo "}" >> $P/opam
    if [ "$LINT" = 1 ]; then
        opam lint $CHECKUPSTREAM $P/opam
    else
        echo "linting disabled (not recommended)"
    fi
    git -C $TMP_OCA add $P/opam
done

git -C $TMP_OCA commit -m "Update $PROJECT $VERSION"
if [ "$NOTHING" = 1 ]; then
    echo "**********************************************************************"
    echo "Dry run!"
    echo git -C $TMP_OCA push origin -f $BRANCH
    echo "if you want to see the diff, run"
    echo git -C $TMP_OCA diff HEAD~1
    echo "**********************************************************************"
else
    git -C $TMP_OCA push origin -f $BRANCH
    echo "**********************************************************************"
    echo "Create a pull request by visiting"
    echo "https://github.com/$GITHUB_USER/opam-coq-archive/pull/new/$BRANCH"
    echo "**** PLEASE CHECK CAREFULLY THE GENERATED CODE ***"
    echo "If you wish to delete the resulting branch, execute:"
    echo "git -C $TMP_OCA push origin --delete $BRANCH"
    echo "**********************************************************************"
fi
