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
#      REVISION:  2016-02-14 20:41
#===============================================================================

file=all.tsv

if [  $# -eq 0 ]; then
    echo -e "Please pass one or more search terms such as 2009 AO/WO/USO or Name of player" 1<&2
    exit 1
fi
if [[ "$1" = "wta" ]]; then
    # ln this file from wta dir
    file="wtaslam.tsv"
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
echo -e "$text" 
