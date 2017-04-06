First Use File Creation Guide

1. Get a copy of the crime stats from Statistics Canada from the link provided below.
2. Remove special characters ẻ, é and replace with e.
3. Copy crime stats file (example: 02520051-eng.csv) to main directory. (Same directory as generateAll.pl)
4. Run the command perl generateAll.pl <crime stats file>.
5. The tool will show progress on the creation of all 51 files.
   -> 1-48.csv
   -> locations_index.csv
   -> crimes_index.csv
   -> stats_index.csv
6. When the tool says Done. and returns control to you, you may run Crime_Query.pl to begin.

Crime stats file location:
http://www5.statcan.gc.ca/cansim/a26;jsessionid=E5ED400F7712D32B0C27C757B15C7025?lang=eng&retrLang=eng&id=2520051&tabMode=dataTable&srchLan=-1&p1=-1&p2=35#downloadTab
