#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: command.sh
# 
#         USAGE: ./command.sh 
# 
#   DESCRIPTION: various tasks to fetch, convert and import that data.
#
#      WE REALLY SHOULD LEARN RAKE and stop this nonsense.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 02/04/2016 23:46
#      REVISION:  2016-02-10 18:58
#===============================================================================

_extract() {
    gsed -n '/<table class="sortable wikitable/,/<\/table>/p' $1 > $2
}
extract() {

    echo "Extracting the table of champions from the html files into tbl directory ..."
    _extract AO_Mens_Champions.html tbl/ao.tbl
    _extract FO_Mens_Champions.html tbl/fo.tbl
    _extract USO_Mens_Champions.html tbl/uso.tbl
    _extract Wimbledon_Mens_Champions.html tbl/wo.tbl
    ls -l tbl/
    echo "Please check these files for tables of other information like country totals. Remove other tables"
    echo "It is also possible that the HTML structure has changed"
    echo
    echo "fo.tbl contains th for winner of each row which needs to be replaced with td"

}
tsv() {

    for file in tbl/*.tbl ; do
        echo $file
        bn=$( basename $file )
        bn=$( echo "$bn" | sed 's|.tbl||' )
        out=$bn.tsv
        echo $out
        ./html2csv.rb $file > $out.1
        # some cleanup
        grep -v '^$' $out.1 | grep -vi "No Competition" | grep -v '^[12][0-9][0-9][0-9]$' | grep -v '	—	—	—' > $out
        wc -l $out $out.1
        diff $out $out.1
        echo adding event in first column
        sed "s|^|${bn}	|" $out | sponge $out
        tail -1 $out

    done

}
download() {
    echo "Downloading latest files for men"
    echo "Press Enter or C-c to abort"
    read
    curl "https://en.wikipedia.org/wiki/List_of_French_Open_men%27s_singles_champions" > FO_Mens_Champions.html 
    sleep 2
    curl "https://en.wikipedia.org/wiki/List_of_Wimbledon_gentlemen%27s_singles_champions" > Wimbledon_Mens_Champions.html 
    sleep 3
    curl "https://en.wikipedia.org/wiki/List_of_US_Open_men%27s_singles_champions" > USO_Mens_Champions.html 
    sleep 4
    curl "https://en.wikipedia.org/wiki/List_of_Australian_Open_men%27s_singles_champions" > AO_Mens_Champions.html 
    echo " "
    echo "The next step is to extract the tables using extract"
}
import() {
    echo "Importing tsv files into sqlite"
    echo "drop table majors;" | sqlite3 majors.db
    echo "create table majors (event VARCHAR, year int, w_country VARCHAR(4), winner TEXT, l_country VARCHAR(4), loser TEXT, score TEXT);" | sqlite3 majors.db

for i in `ls *.tsv`
do
   sqlite3 majors.db << !
.mode tabs
.import $i majors
!
done
echo "select count(1) from majors;" | sqlite3 majors.db
echo "Majors Imported"
}
if [[ $1 =~ ^(extract|help|tsv|download|import)$ ]]; then
  "$@"
else
  echo "$0: Invalid subcommand $1" >&2
  echo 
  echo "Valid are : download extract tsv import help" >&2
  exit 1
fi
