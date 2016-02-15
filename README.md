# tennis-slams

This directory contains winners of men's slam events taken from wiki 
and converted to tsv. 

the directory ~/Downloads/tennis_atp-master/ contains detailed tennis
results and queries

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
