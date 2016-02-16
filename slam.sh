#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: slam.sh
# 
#         USAGE: ./slam.sh 
# 
#   DESCRIPTION: searches slam data and prints based on search terms which can be year player event
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 02/11/2016 12:38
#      REVISION:  2016-02-16 11:12
#===============================================================================

file=all.tsv
DELIM=$'\t'

OPT_VERBOSE=
OPT_DEBUG=
while [[ $1 = -* ]]; do
    case "$1" in
        -V|--verbose)   shift
            OPT_VERBOSE=1
            ;;
        -H|--header)   shift
            OPT_HEADER=1
            ;;
        -c|--count)   shift
            OPT_COUNT=1
            ;;
        --debug)        shift
            OPT_DEBUG=1
            ;;
        -h|--help)
            cat <<-! | sed 's|^     ||g'
            $0 Version: 1.0.0 Copyright (C) 2016 senti
            This program prints slam information using arguments as filtering criteria.
            It prints rows that match all criteria.

            Usage:
            $0 FO  Evert

            Options:
            -H, --header      Print header (for csvlook)
            -c, --count       Print rowcount at end
            -V, --verbose     Displays more information
                --debug       Displays debug information
!
            # no shifting needed here, we'll quit!
            exit
            ;;
        --edit)
            echo "this is to edit the file generated if any "
            exit
            ;;
        --source)
            echo "this is to edit the source "
            vim $0
            exit
            ;;
        *)
            echo "Error: Unknown option: $1" >&2   
            echo "Use -h or --help for usage" 1>&2
            exit 1
            ;;
    esac
done

if [  $# -eq 0 ]; then
    echo -e "Please pass one or more search terms such as 2009 AO/WO/USO or Name of player" 1<&2
    exit 1
fi
if [[ "$1" = "wta" ]]; then
    file="wta/wtaslam.tsv"
    shift
fi

# We are ANDing the search terms. all must be found.
# It would be better to do awk '/string1/ && /string3/' file
# I need to build that.
arg1=$1
shift
text=$( grep -h "$arg1" $file | cut -f1-7)
for var in "$@"
do
    text=$(echo "$text" | grep "$var")
done
if [[ -n "$OPT_HEADER" ]]; then
    echo "Event${DELIM}Year${DELIM}Country${DELIM}Winner${DELIM}Country${DELIM}Runner-up${DELIM}Score"
fi
echo -e "$text" 
if [[ -n "$OPT_COUNT" ]]; then
    echo -e "$text" | wc -l
fi
