#remote blast perl script: parsefile.pl
#use: parsefile.pl arg0 arg1 
#arg0: input fasta file
#arg1: output file name

#SCRIPT: Read in an input text file (arg0). For each line in that fasta file: 
#(1) read in the line and parse it using tabs into a multi-dimensional array
#(2) compare the first three sequence IDs in the multidimensional array
#(3) if same, compare genus and species and output most common genus call
#(4) if different, figure out if first two are same, if same, see (3) above
#(5) if only one unique, output that genus
#(6) also include the percentage ID and percentage query cover as either an average or one value 
#(7) so, ideally each record has three entries, and is parsed down to a single line in the output file arg1 as
# ID GENUS AvgPercentID AvgPercentCoverage with all four values separated by tabs. Final two values are trimmed to 2 decimal places.

#Script creation and commenting by MSWollenberg 2015.Dec
#script was rigged together from snippets found online

#should read in arg0 as the filename containing fasta sequences
# to parse and take a name (arg1) for the output file
my ($input, $output) = @ARGV;
#open in the input file or die trying
open(my $fh, $input || die "Could not open the file");

#some variables used below
my @line;
my @array;
my $a = 1;

#go line by line through the input text file, parse each line by tabs, store the parsed data
#in a multi-dimensional array (array1) where the first value is the line number, second value
#is a number indexing tabs 1 = ID; 2 = Genus/species; 3 = % identity
while ( (<$fh>) )
{
   	my $m = 1;
   	#remove newline from end of line
   	chomp $_;
   	@line = split(/\t/,$_);
    #print $line[0];
    $array[$a][$m]=$line[0];
  	$m++;
  	#print $line[1];
    $array[$a][$m]=$line[1];
    $m++;
    #print $line[2]."\n";
    $array[$a][$m]=$line[2];
	$m++;
	#print $line[3]."\n";
	$array[$a][$m]=$line[3];
	$m++;
	$a++;
	#print $m."\n";
}

#TO CHECK:loop that iterates through every element in the multi-dimensional array array1
#for $i ( 1 .. $#array1) {
#    $row = $array1[$i];
#    for $j ( 1 .. $#{$row} ) {
#        print "element $i $j is $row->[$j]\n";
#    }
#}

#define a bunch of variables used below
my $id1;
my $id2;
my $id3;

my $pid1;
my $pid2;
my $pid3;

my $gs1;
my $gs2;
my $gs3;

my $qcov1;
my $qcov2;
my $qcov3;

#reset $a and store the total number of elements in $total
my $total = $a;
my $a = 1;

while ($a != $total)
{
	#loop through three rows and place values into a $holder variable...
	my $holder;
	for $i ( $a .. ($a+2) ) 
	{
    	$row = $array[$i];
  		if ($i == $a) 
  		{ 	
  			$id1 = $row->[1];
  			$gs1 = $row->[2];
  			$pid1 = $row->[3];
			$qcov1 = $row->[4];
			#if there is a value here, grab it and store, otherwise assign a value of 1.0
			if ($row->[4])
				{
				$qcov1 = $row->[4];
				}
			else
				{
				$qcov1 = 1;
				}
		}
  		if ($i == ($a+1)) 
  		{ 	
  			$id2 = $row->[1];
  			$gs2 = $row->[2];
  			$pid2 = $row->[3];
  			if ($row->[4])
				{
				$qcov2 = $row->[4];
				}
			else
				{
				$qcov2 = 1;
				}
  		}
  		if ($i == ($a+2)) 
  		{ 	
  			$id3 = $row->[1];
			$gs3 = $row->[2];
  			$pid3 = $row->[3];
  			if ($row->[4])
				{
				$qcov3 = $row->[4];
				}
			else
				{
				$qcov3 = 1;
				}
		}
	}
	
	#make sure there are THREE  records and the three record IDs MATCH
	if ($id1 == $id2 && $id1 == $id3) 
	{
		#print "THREE ids are the same for id $id1 \n";
		#check $pid and see if all three are above 97% 
		if ( ($pid1 >= 0.97) && ($pid2 >= 0.97) && ($pid3 >= 0.97) )
		{
			#save a representative genus name only - create a subroutine
			#average the pid values 
			my $pidavg = ($pid1+$pid2+$pid3)/3;
			#enter the subroutine below to return the GENUS name
			my $name = getName($gs1, $gs2, $gs3, 3);
			my $qcovavg = ($qcov1+$qcov2+$qcov3)/3;
			$pidavg = sprintf "%.2f", $pidavg;
			$qcovavg = sprintf "%.2f", $qcovavg;
			$holder = $id1."\t".$name."\t".$pidavg."\t".$qcovavg."\n";
			
		}
		
		elsif ( ($pid1 >= 0.95) && ($pid2 >= 0.95) && ($pid3 >= 0.95) )
		{
			#average the pid values 
			my $pidavg = ($pid1+$pid2+$pid3)/3;
			my $name = getName($gs1, $gs2, $gs3, 3);
			my $qcovavg = ($qcov1+$qcov2+$qcov3)/3;
			$pidavg = sprintf "%.2f", $pidavg;
			$qcovavg = sprintf "%.2f", $qcovavg;
			$holder = $id1."\t".$name."\t".$pidavg."\t".$qcovavg."\n";
		}	
		
		else
		{
			#average the pid values 
			my $pidavg = ($pid1+$pid2+$pid3)/3;
			my $name = getName($gs1, $gs2, $gs3, 3);
			my $qcovavg = ($qcov1+$qcov2+$qcov3)/3;
			$pidavg = sprintf "%.2f", $pidavg;
			$qcovavg = sprintf "%.2f", $qcovavg;
			$holder = $id1."\t".$name."\t".$pidavg."\t".$qcovavg."\n";
		}
		$a = $a+3;
	}
	#if there's only ONE matching record
	elsif ($id1 != $id2)
	{ 
		my $pidavg = ($pid1);
		$a = $a+1;
		my $name = getName($gs1, "blank", "blank", 1);
		my $qcovavg = $qcov1;
		$pidavg = sprintf "%.2f", $pidavg;
		$qcovavg = sprintf "%.2f", $qcovavg;
		$holder = $id1."\t".$name."\t".$pidavg."\t".$qcovavg."\n";
	}
	#if there's only TWO matching records
	elsif ($id1 != $id3)
	{ 
		my $pidavg = ($pid1+$pid2)/2;
		$a = $a+2;
		my $name = getName($gs1, $gs2, "blank", 2);
		my $qcovavg = ($qcov1+$qcov2)/2;
		$pidavg = sprintf "%.2f", $pidavg;
		$qcovavg = sprintf "%.2f", $qcovavg;
		$holder = $id1."\t".$name."\t".$pidavg."\t".$qcovavg."\n";
	}
	open (my $fh, '>>', $output) or die "Could not open file '$output' $!";
  	print $fh "$holder"; 
  	close ($fh);
}

#A subroutine that takes in three strings and returns a string
#returns the name PHAGE if the word "phage" appears in any of the record IDs for a particular set
#of sequences; if phage does not appear, the subroutine determines if any of the first words match in the name string
#if they do, it spits out that name, if not, it truncates the first word of each record together, separated by a space, and outputs that string

sub getName
{
	#THREE names
	if ($_[3] == 3)
	{
		if ($_[0] =~ /phage/ || $_[1] =~ /phage/ || $_[2] =~ /phage/)
		{
			return "PHAGE";
		}
		else 
		{
			#print "NOTPHAGE\n"; 
			my @name1 = split / /, $_[0];
			my @name2 = split / /, $_[1];
			my @name3 = split / /, $_[2];
			if ($name1[0] eq $name2[0] && $name1[0] eq $name3[0])
				{
				#print "Same Genus: ".$name1[0]."\n";
				return $name1[0];}
			elsif ($name1[0] eq $name2[0] && $name1[0] ne $name3[0])
				{
				#print "Two Genus Match: ".$name1[0]."\n";
				return $name1[0];}	
			elsif ($name1[0] ne $name2[0] && $name2[0] eq $name3[0])
				{
				#print "Two Genus Match: ".$name2[0]."\n";
				return $name2[0];}
			elsif ($name1[0] eq $name3[0] && $name2[0] ne $name3[0])
				{
				#print "Two Genus Match: ".$name1[0]."\n";
				return $name1[0];}
			else
				{
				#print "No Genus Match: \n";
				return $name1[0]." ".$name2[0]." ".$name3[0];
				}						
		}
	} 
	#TWO names
	elsif ($_[3] == 2)
	{
		if ($_[0] =~ /phage/ || $_[1] =~ /phage/ )
		{
			return "PHAGE";
		}
		else 
		{
			#print "NOTPHAGE\n"; 
			my @name1 = split / /, $_[0];
			my @name2 = split / /, $_[1];
			if ($name1[0] eq $name2[0])
				{#print "Same Genus: ".$name1[0]."\n";
				return $name1[0];}	
			else
				{#print "No Genus Match: \n";
				return $name1[0]." ".$name2[0];}						
		}
	
	}
	#ONE name
	elsif ($_[3] == 1)
	{
		if ($_[0] =~ /phage/)
		{
			return "PHAGE";
		}
		else 
		{
			#print "NOTPHAGE\n"; 
			my @name1 = split / /, $_[0];
			#print "Genus: ".$name1[0]."\n";
			return $name1[0];					
		}
	}
}