#changegenus.pl

#this script reads in $input1 a line at a time and match the number in each line with the OTU designation in $input2
#and changes the OTU designation in $input2 to the matched OTU name in $input1 

#USAGE: perl changegenus.pl inputfile1 inputfile2 outputfile1
#inputfile1 = edited BLAST hit summary file (.txt)
#inputfile2 = rep_set_tax_assignments.txt
#outputfile = new rep_set_tax_assignments.txt with clusters in inputfile1 replacing those names in inputfile2

use strict;
use warnings;
my $count;
my $changes;

#my $file = 'numsonly.txt';
#my $file2= 'rep_set_tax_assignments.txt';
#open my $out, '>', "$file.new" or die "Can't write new file: $!";
#open my $info, $file or die "Could not open $file: $!";

#should read in arg0 as the filename containing ID numbers to match and genus or OTHER ALL CAPS designations
# to parse and take a name (arg2) for the output file
my ($input1, $input2, $output) = @ARGV;
#open in the input file or die trying
open(my $fh, $input || die "Could not open file1.");
open (my $fh2, $input2 || die "could not open file2.");

#some variables used below
my @line;
my @line2;
my @array;
my $a = 1;
my $counter = 0;

#go line by line through the input text file, parse each line by tabs, store the parsed data
#in a multi-dimensional array (@@array) where the first value is the line number, second value
#is a name, either in all CAPS or in normal caps for the genus.

while ( (<$fh>) )
{
   	my $m = 1;
   	#remove newline from end of line
   	chomp $_;
   	@line = split(/\t/,$_);
    #print $line[0];
    #store ID
    $array[$a][$m]=$line[0];
  	$m++;
  	#print $line[1];
    #store NAME
    $array[$a][$m]=$line[1];
	$a++;
	#print $m."\n";
}

#define variables used below
my $id1;
my $gs1;
my $pid1;
my $qcov1;

#reset $a and store the total number of elements in $total
my $total = $a;
my $a = 1;
print "$total lines read into the search...\n";

while ($a != $total)
{
	for $i ( $a ) 
	{
    	$row = $array[$i];
  		{ 	
  			$id = $row->[1];
  			$gs = $row->[2];
		}
	} 

	my $holder;	
	#loop through each row of file2 searching for a match to $id and place values into a $holder variable...
	while (my $line2 = <$fh2>) 
	{
    	$count = 0;
    	#grab the OTU number at the beginning of the first line in the second file
    	
	    $line2 =~ m{(\d+)\s*};
    					
		#if a successful match is found between the ID in $file and an OTU id in file2
		if ($1 == $id) 
    		{
    			#save the line from file 2
    			my $seq = $line2;
    							
    			#and manipulate the taxonomy string to incorporate the new designation 
    			chomp $seq;
   				@line2 = split(/\t/,$seq);
   				
   				#if the name in $line2 matches an uppercase designation
   				if ($gs =~ /^[_\p{Uppercase}]+$/) 
   				{
    					#just simply use it to replace the taxonomy call from qiime
    					$line2[1] = $gs;
				}
   				
   				#if the name is an actual genus name either replace unassigned or the blank taxonomy g__ variable
   				else
   				{
    				if ($line2[1] eq "Unassigned")
    				{
    					#just simply replace it
    					$line2[1] = "g__$gs;";
    				}
    				else 
    				{
		   				#Else, figure out the genus designation and replace with the found name $gs
    					$line2[1] =~ s/{g__\w*}/{g__$gs}/;
   					}
   				}
   					
    		#output this line to the file with the edit.
			open (my $fh3, '>>', $output) or die "Could not open file '$output' $!";
  			$holder = $line2[0]."\t".$line2[1]."\t".$line2[2]."\t".$line2[3]."\n";
  			print $fh3 "$holder"; 
  			close ($fh3);
    	
    		$count = 1;
    		$changes++;
    		}
   
    	#if not matched, output this line to file intact.
		if ($count == 0) 
		{
			open (my $fh3, '>>', $output) or die "Could not open file '$output' $!";
			print $fh3 $line2;
			close ($fh3);
		}									
	}
}
	
print "$changes found and made in the file";
close ($fh);
close ($fh2);