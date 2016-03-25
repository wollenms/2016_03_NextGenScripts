#perl grabotus.pl

#read a file a line at a time, search for the particular string in each line, return the OTU number if the string matches.

#You'll have to populate this with your infile name (usually a rep_set_tax_assignments.txt type file) - this is not a fancy or particularly user friendly script. You'll have to send its output to another file as so below...

# $prompt$ grabotus.pl > outfile.txt

use strict;
use warnings;
my $count;

my $file = '***YOUR INFILE***';

open my $info, $file or die "Could not open $file: $!";

while( my $line = <$info>)  
	{   
		#if the SEARCH TERM is found
    	if (index($line, '***INSERT SOMETHING TO SEARCH ON HERE***') != -1) 
    		{
    			#match the OTU number at the beginning of the line
    			$line =~ m{(\d+)\s*};
    			print "$1\n";
				#$count=$count+1;				
			}
    
	}
#print $count;
close $info;