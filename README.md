# 2016_03_NextGenScripts
A collection of Perl scripts for processing Illumina NextGen data, as well as a description of the pipeline of analysis with macqiime and Perl script commands.

Scripts included in this repository, in the order they are used, are the following:

0) 00_grabotus.pl

1) 01_matchotus.pl

2) 02_remoteblast.pl

3) 03_parsefile.pl

4) 04_changegenus.pl

NOTES   A. you will have to edit/modify infile and search strings in scripts 00 & 01 to use them 
        B. you will need to send the output of 01 and 02 to another .txt file when you use the script in your shell
        B. you will need to install bioperl to run 02 and 03
