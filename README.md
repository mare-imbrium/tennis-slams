# tennis-slams

This directory contains winners of men's slam events taken from wiki 
and converted to tsv. 

the directory ~/Downloads/tennis_atp-master/ contains detailed tennis
results and queries

## PROGRAMS

`slam.sh` is a simple guery program. 
Enter various key words and it will report rows that match those keys.

./slam.sh 2001 FO 
./slam.sh 2012
./slam.sh Nadal
./slam.sh USO 199

# As a simple hack, if the first arg is wta then the wtaslams.tsv is searched.

./slam wta Serena

`command.sh` is a program with various commands for download, extract, and conversion of the wikipedia
page to the tsv. this should not be required any longer.

## NOTES

all.csv has data sorted by year and event_num
do a cut -f1-7 to avoid that last column

The names contain unicode chars so use unidecode.rb to make them ascii
or else tail and sed can give errors esp if you pass them through
csvlook.

i need to clean up this list each time 
and the data in FO has a different format.
We can manually add the result each year if we need to.

In tbl/fo.tbl, go past the headers are replace <th with <td for all
lines till the end. then it works

this data also has too many other things like symbols stars etc.

maybe we can just concat this file sorted by year and event_num which i
need to insert at end. then i can query. but then i can just generate
this from the atp database


## Others
This is on github under https://github.com/mare-imbrium/tennis-slams
