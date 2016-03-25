#perl matchotus.pl

# use this script to read in the output file from grabotus.pl and match those numbers with numbers contained in a .fna file and output the resulting matches in .fasta format with OTU number as the name. 

# Script Has some minimal bug protection in printing out the word "Duplicate" if a line matches more than one number (will happen in lines in the .fna file contain numbers that contain other numbers).

# Read in $file a line at a time, search for a matching number/line in $file2 and output a match in .fasta format followed by its associated sequence. Should send the output to another .fasta file as so:

#Usage $prompt$ matchotus.pl > otus.fasta


use strict;
my $count;

my $file = '***INFILE.TXT***';
my $file2= '***.FNA FILE***';
open my $info, $file or die "Could not open $file: $!";

while (my $line = <$info>)  
	{   
	
    	#match the OTU number at the beginning of the line
    		open my $info2, $file2 or die "Could not open $file2: $!";
    		while (my $line2 = <$info2>) 
    					{
    					
    						$line2 =~ m{(\d+)\s*};
    						#print "$1 = $line\n";
    				
							if ($1 == $line) 
    						{
    							my $seq = <$info2>;
    							print ">$1\n$seq\n";
    							#print "match $1 with $line";
    							$count = $count+1;
    							
    						}
    						
    						#print "$1 matches $templine\n";
							#$count=$count+1;				
							
						}
			if ($count >= 2)
    		{print "DUPLICATE\n";
    		$count = 0;}
    		else {$count = 0;}
	}
#print $count;
close $info;