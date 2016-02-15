#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: command.sh
# 
#         USAGE: ./command.sh download | extract | tsv | import
# 
#   DESCRIPTION: various tasks to fetch, convert and import wta slam data from wiki
#      JS has data from 1968 onwards but we want slam final data from first slam
#
#      WE REALLY SHOULD LEARN RAKE and stop this nonsense.
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#         TODO We should now freeze previous years and only append new ones, either from
#         JS's database (he takes time to update), or from wiki (this will be instantaneous).
#        AUTHOR: senti
#  ORGANIZATION: 
#       CREATED: 02/04/2016 23:46
#      REVISION:  2016-02-10 18:58
#===============================================================================

OUTFILE=wtaslam.tsv
_extract() {
    gsed -n '/<table class="sortable wikitable/,/<\/table>/p' $1 > $2
    gsed -n '/<table class="wikitable sortable/,/<\/table>/p' $1 > $2.tmp
    echo "In AO the pre-open era has wikitable sortable"
    echo " check that all files have amateur era since we already getting open era from JS's database"
}
extract() {

    mkdir tbl
    echo "Extracting the table of champions from the html files into tbl directory ..."
    _extract AO_W.html tbl/ao.tbl
    _extract FO_W.html tbl/fo.tbl
    _extract USO_W.html tbl/uso.tbl
    _extract WO_W.html tbl/wo.tbl
    ls -l tbl/
    echo "Please check these files for tables of other information like country totals. Remove other tables"
    echo "It is also possible that the HTML structure has changed"
    echo
    echo "fo.tbl contains th for winner of each row which needs to be replaced with td"

}
tsv() {
    # convert html file to TSV
    echo "Prior to running this please ensure that the correct tables are present in the "
    echo "  tbl files, and there are no extra tables such as country counts or player counts"
    echo

    for file in tbl/*.tbl ; do
        echo $file
        bn=$( basename $file )
        bn=$( echo "$bn" | sed 's|.tbl||' )
        out=$bn.tsv
        evnum=0
        # we need evnum for sorting the file once we combine all four into one
        case $bn in
            ao)
               evnum=1 ;;
            fo)
               evnum=2 ;;
            wo)
               evnum=3 ;;
            uso)
               evnum=4 ;;
           *)
               echo "wrong event name $bn"
               ;;
        esac
        echo $out
        ../html2csv.rb $file > $out.1
        # some cleanup
        grep -v '^$' $out.1 | grep -vi "No Competition" | grep -v '^[12][0-9][0-9][0-9]$' | grep -v '	—	—	—' > $out
        wc -l $out $out.1
        #diff $out $out.1
        echo adding event in first column
        EVEUC=$(echo $bn | tr '[a-z]' '[A-Z]' )
        sed "s|^|${EVEUC}	|;s|$|	${evnum}|" $out | sponge $out
        tail -1 $out

    done
    echo combining files into $OUTFILE
    wc -l *o.tsv
    sort -k2,2 -k8,8 -t$'\t' ao.tsv fo.tsv wo.tsv uso.tsv > $OUTFILE
    wc -l $OUTFILE

    echo conversion over
}
download() {
    echo "Downloading latest files for women"
    echo "Press Enter or C-c to abort"
    read
    curl "https://en.wikipedia.org/wiki/List_of_Wimbledon_ladies%27_singles_champions" > WO_W.html
    sleep 2
    curl "https://en.wikipedia.org/wiki/List_of_French_Open_women%27s_singles_champions" > FO_W.html
    sleep 3
    curl "https://en.wikipedia.org/wiki/List_of_Australian_Open_women%27s_singles_champions" > AO_W.html
    sleep 4
    curl "https://en.wikipedia.org/wiki/List_of_US_Open_women%27s_singles_champions" > USO_W.html
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
help() {
cat << EOF
    Download, and create TSV of slam data for finals of each slam from the first slam.
    Data taken from wikipedia pages.
    The final output goes to $OUTFILE

    Data contains names in unicode which can be an issue while searching using ascii or when 
      piping through csvlook and then using any other filter like tail pbcopy etc.
EOF
}
if [[ $1 =~ ^(extract|help|tsv|download|import)$ ]]; then
  "$@"
else
  echo "$0: Invalid subcommand $1" >&2
  echo 
  echo "Valid are : download extract tsv import help" >&2
  exit 1
fi
