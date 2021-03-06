#!/bin/bash
#
# This file is part of the GROMACS molecular simulation package.
#
# Copyright (c) 2020, by the GROMACS development team, led by
# Mark Abraham, David van der Spoel, Berk Hess, and Erik Lindahl,
# and including many others, as listed in the AUTHORS file in the
# top-level source directory and at http://www.gromacs.org.
#
# GROMACS is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License
# as published by the Free Software Foundation; either version 2.1
# of the License, or (at your option) any later version.
#
# GROMACS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with GROMACS; if not, see
# http://www.gnu.org/licenses, or write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA.
#
# If you want to redistribute modifications to GROMACS, please
# consider that scientific software is very special. Version
# control is crucial - bugs must be traceable. We will be happy to
# consider code for inclusion in the official distribution, but
# derived work must not be called official GROMACS. Details are found
# in the README & COPYING files - if they are missing, get the
# official version at http://www.gromacs.org.
#
# To help us fund GROMACS development, we humbly ask that you cite
# the research papers on the package. Check out http://www.gromacs.org.

# This script runs clang tidy checks on modified files and
# reports/applies the necessary changes.
#
# See `clang-tidy.sh -h` for a brief usage, and docs/dev-manual/code-formatting.rst
# for more details.

# Parse command-line arguments
function usage() {
    echo "usage: clang-tidy.sh [-f|--force] [--parallel=#Jobs] [--rev=REV]"
    echo "           [--format=(off|check)]"
    echo "           [--warnings=<file>] [<action>]"
    echo "<action>: (check*|diff|update)[-(index|workdir*)] (*=default)"
}

action="check-workdir"
declare -a diffargs
baserev="HEAD"
force=
tidy_mode=check
warning_file=
concurrency=2
for arg in "$@" ; do
    if [[ "$arg" == "check-index" || "$arg" == "check-workdir" || \
          "$arg" == "diff-index" || "$arg" == "diff-workdir" || \
          "$arg" == "update-index" || "$arg" == "update-workdir" ]]
    then
        action=$arg
    elif [[ "$arg" == "check" || "$arg" == "diff" || "$arg" == "update" ]] ; then
        action=$arg-workdir
    elif [[ "$action" == diff-* ]] ; then
        diffargs+=("$arg")
    elif [[ "$arg" == --format=* ]] ; then
        tidy_mode=${arg#--format=}
        if [[ "$tidy_mode" != "off" && "$tidy_mode" != "check" ]] ; then
            echo "Unknown option: $arg"
            echo
            usage
            exit 2
        fi
    elif [[ "$arg" == "-f" || "$arg" == "--force" ]] ; then
        force=1
    elif [[ "$arg" == "--parallel=*" ]] ; then
        concurrency=${arg#--parallel=}
    elif [[ "$arg" == --rev=* ]] ; then
        baserev=${arg#--rev=}
    elif [[ "$arg" == --warnings=* ]] ; then
        warning_file=${arg#--warnings=}
    elif [[ "$arg" == "-h" || "$arg" == "--help" ]] ; then
        usage
        exit 0
    else
        echo "Unknown option: $arg"
        echo
        usage
        exit 2
    fi
done

# Check that format is present
if [[ "$tidy_mode" != "off" ]]
then
    if [ -z "$RUN_CLANG_TIDY" ]
    then
        RUN_CLANG_TIDY=`git config hooks.run_clang_tidypath`
    fi
    if [ -z "$RUN_CLANG_TIDY" ]
    then
        echo "Please set the path to run-clang-tidy using the git hook"
        echo "git config hooks.run_clang_tidypath /path/to/run-clang-tidy"
        echo "or by setting an environment variable, e.g."
        echo "RUN_CLANG_TIDY=/path/to/run-clang-tidy"
        exit 2
    fi
    if ! which "$RUN_CLANG_TIDY" 1>/dev/null
    then
        echo "run-clang-tidy not found: $RUN_CLANG_TIDY"
        exit 2
    fi
fi

# Switch to the root of the source tree and check the config file
srcdir=`git rev-parse --show-toplevel`
pushd $srcdir >/dev/null
admin_dir=$srcdir/admin

# Actual processing starts: create a temporary directory
tmpdir=`mktemp -d -t gmxclangtidy.XXXXXX`

# Produce a list of changed files
# Only include files that have proper filter set in .gitattributes
internal_diff_args=
if [[ $action == *-index ]]
then
    internal_diff_args="--cached"
fi
git diff-index $internal_diff_args --diff-filter=ACMR $baserev >$tmpdir/difflist
cut -f2 <$tmpdir/difflist | \
    git check-attr --stdin filter | \
    sed -e 's/.*: filter: //' | \
    paste $tmpdir/difflist - | \
    grep -E '(complete_formatting)$' >$tmpdir/filtered
cut -f2 <$tmpdir/filtered >$tmpdir/filelist_all
grep -E '(complete_formatting)$' <$tmpdir/filtered | \
    cut -f2 >$tmpdir/filelist_clangtidy
git diff-files --name-only | grep -Ff $tmpdir/filelist_all >$tmpdir/localmods

# Extract changed files to a temporary directory
mkdir $tmpdir/org
if [[ $action == *-index ]] ; then
    git checkout-index --prefix=$tmpdir/org/
else
    rsync -a $srcdir/src/ $tmpdir/org/src/
fi
# Need to have compilation database file available somewhere above where we are using it
rsync -a $srcdir/compile_commands.json $tmpdir/org
# Duplicate the original files to a separate directory, where all changes will
# be made.
cp -r $tmpdir/org $tmpdir/new

# Create output file for what was done (in case no messages get written)
touch $tmpdir/messages

# Run clang-tidy on the temporary directory
# Can only perform clang-tidy on a non-empty list of files
cd $tmpdir/new
if [[ $tidy_mode != "off" &&  -s $tmpdir/filelist_clangtidy ]] ; then
    $RUN_CLANG_TIDY `cat $tmpdir/filelist_clangtidy` -- -header-filter=.* -j $concurrency -fix -fix-errors --cuda-host-only -nocudainc -quiet >$tmpdir/clang-tidy.out 2>&1
    grep -v "clang-analyzer" $tmpdir/clang-tidy.out | grep -v "to display errors from all non" | grep -i "error|warning" - > $tmpdir/clang-tidy-errors.out
    if [ -s $tmpdir/clang-tidy-errors.out ]; then
        echo "Running code tidying failed. Check output below for errors:"
        cat $tmpdir/clang-tidy-errors.out
        rm -rf $tmpdir
        exit 2
    fi
    # Find the changed files if necessary
    if [[ $action != diff-* ]] ; then
        msg="needs formatting"
        if [[ $action == update-* ]] ; then
            msg="clang-tidy performed"
        fi
        git diff --no-index --name-only ../org/ . | \
            awk -v msg="$msg" '{sub(/.\//,""); print $0 ": " msg}' >> $tmpdir/messages
    fi
    # TODO: Consider checking whether rerunning clang-tidy causes additional changes
fi

cd $tmpdir

# If a diff was requested, show it and we are done
if [[ $action == diff-* ]] ; then
    git diff --no-index --no-prefix "${diffargs[@]}" org/ new/
    rm -rf $tmpdir
    exit 0
fi

# Find the changed files
git diff --no-index --name-only --exit-code org/ new/ | \
    sed -e 's#new/##' > $tmpdir/changed
changes=
if [[ -s $tmpdir/changed ]]
then
    changes=1
fi

# Check if changed files have changed outside the index
if grep -Ff $tmpdir/localmods $tmpdir/changed > $tmpdir/conflicts
then
    awk '{print $0 ": has changes in work tree"}' $tmpdir/conflicts \
        >> $tmpdir/messages
    if [[ ! $force && $action == update-* ]] ; then
        echo "Modified files found in work tree, skipping update. Use -f to override."
        echo "The following would have been done:"
        sort $tmpdir/messages
        rm -rf $tmpdir
        exit 2
    fi
fi

# Update the index/work tree if requested
if [[ $action == update-index ]] ; then
    grep -Ff $tmpdir/changed $tmpdir/filtered > $tmpdir/tohash
    cd $tmpdir/new
    IFS='
'
    for change in `cut -f2 $tmpdir/tohash | \
                   git --git-dir=$srcdir/.git hash-object -w --stdin-paths --no-filters | \
                   paste - $tmpdir/tohash`
    do
        # NOTE: the patterns below contain literal tabs
        sha1=${change%%	*}
        rest=${change#*	}
        mode=${rest:8:6}
        path=${rest#*	}
        path=${path%%	*}
        # Contains a literal tab
        echo "$mode $sha1	$path" >> $tmpdir/toindex
    done
    unset IFS
    git --git-dir=$srcdir/.git update-index --index-info < $tmpdir/toindex
elif [[ $action == update-workdir ]] ; then
    rsync --files-from=$tmpdir/changed $tmpdir/new/ $srcdir/
fi

# Get back to the original directory
popd >/dev/null

# Report what was done
sort $tmpdir/messages | tee $warning_file

rm -rf $tmpdir
exit $changes
