#remote blast perl script: remoteblast.pl
#use: remoteblast.pl arg0 arg1 
#arg0: input fasta file
#arg1: output file name

#SCRIPT: Read in an input fasta file (arg0). For each sequence in that fasta file: remote blast
#search, record the first $totalhit number of hits from that search, collect the accession number
#for each hit (AC NUM) match that number with its record in the genbank nucleotide database, collect
# the GENUS and SPECIES (or just general organism name) linked to that accession (GS), determine the fraction
#of identical nucleotides shared between the two sequences (FRAC ID), and output these three values in tab
#delimited format for each of the top $totalhit hits as follows (AC NUM\tGS\t\FRAC ID\n) into a file
#with name defined as arg1 by the user. 

#Script creation and commenting by MSWollenberg 2015.Dec
#script was rigged together from snippets found at the bioperl wiki, and other place online

## DEPENDENCIES: BIOPERL!!!

use Bio::Tools::Run::RemoteBlast;
use Bio::DB::EUtilities;
use Bio::SearchIO;
use Bio::SeqIO;

#variable that holds a rough estimate of the time that BLAST search has been running
my $totaltime = 0;
#totalhit is a variable for the total number of hits that should be reported for each sequence
my $totalhit = 3;
#variable to hold tab-delimited string output for each hit
my $holder;

#variables for the blast search
my $prog='blastn';
my $db='nr';
my $e_val='1e-10';

#set up the remote blast object using the variables above
my @params = 
('-prog' =>  $prog, 
'-data' =>  $db, 
'-expect' => $e_val, 
'-readmethod' => 'SearchIO');

#should read in arg0 as the filename containing fasta sequences
# to blast and take a name (arg1) for the output file
my ($input, $output) =@ARGV;

my $factory = Bio::Tools::Run::RemoteBlast->new(@params);
$v = 1;
my $str = Bio::SeqIO->new(-file=>$input, '-format' => 'fasta' );

#This is the main control loop, which iterates over all fasta sequences found in the arg0 file
while (my @input2 = $str->next_seq())
{
	#for each sequence in the fasta file,
	foreach my $input2 (@input2)
	{
 		#Blast that sequence against the $db database defined above
  		my $r = $factory->submit_blast($input2);
  		#Tell the user the search is started
  		print STDERR "BLAST search $v for seq ", $input2->display_id, " started " if( $v > 0 );
  		while ( my @rids = $factory->each_rid ) 
  		{
      		foreach my $rid ( @rids ) 
    		{
  	  			#an internal clock to check for results on a five second delay.
  	  			my $rc = $factory->retrieve_blast($rid);
  	  			if( !ref($rc) ) 
  	  			{
  	      			if( $rc < 0 ) 
  	      			{ 		
  		      			$factory->remove_rid($rid);
  		  			}
  	      			#internal clock to measure the length of each search, also to stagger
  	      			#request for search data from NCBI
  	      			sleep 5; $totaltime = $totaltime+5;
  	      			print STDERR "." if ( $v > 0 );
  	  			} 
				#when the server gets back to our call and returns the search results
				else 
  	  			{ 
  	      			$factory->remove_rid($rid);
  	      			my $result = $rc->next_result;
  	      			#tell the user the search is finished
  	      			print "and ended; db was ", $result->database_name(), "\n";
					
					my $stop = 0;
  	      			#iterate through the search results and return the first $totalhit # of sequences
  	      			while( (my $hit = $result->next_hit) && ($stop < $totalhit) ) 
  	      			{		
  		  				$stop++;
  		  				my $hold = $input2->display_id;
  		  				$holder = "$hold\t";
  		  				#print "$holder\t";
  		  				#print "$stop\t";
  		  				#print "hit $stop name:", $hit->name, "\t";
  		  				#print "hit $stop name:", $hit->hit_name, "\t";
  		  				#most entries don't have the above field
 
						#For this hit, take the $hit_name (accession #), 	  	
						my $id = $hit->name;
						#print $hit->name;

						#use the Eutility 'efetch' to match the accession number in the 
						#nucleotide database and return an XML file of the output
						my $factory = Bio::DB::EUtilities->new(-eutil => 'efetch',
                                       							-email => 'mwollenb@kzoo.edu',
                                       							-db    => 'nuccore',
                                       							-rettype => 'fasta',
                                       							-retmode => 'xml',
                                       							-id    => $id);
						#$factory contains a file, but we need to get it out of factory,
						#this creates a placeholder file 'file.fasta' and pulls it out of
						#$factory with get_Response
						my $file = 'file.fasta';
						my $gs;  
						$factory->get_Response(-file => $file);
						
						#Here we open the XML result file and parse the results to save only
						#the TSeq_orgname information included in the file
						open FILE, "file.fasta" or die $!;
						while (<FILE>) 
						{
    						#'TSeq_orgname' is a pretty specific match term for this particular
    						#XML output file - this may need to be changed if other information
    						#from the output xml file is desired
    						if ( $_ =~ m/TSeq_orgname/ ) 
    						{
        						#print $_;
        						#print "found!\n";
        						
        						#I'm sure there is more efficient perl to do this, but it works and I'm lazy
        						#strips the Tseq_orgname tag from before and after the data we care about
        						$gs = $_;
								my ($first, $genus) = split (/>/), $gs;
								#print "$genus\n";
								$_ = $genus;
								my ($genusspecies, $last) = split (/</), $genus;
								#print "$genusspecies\t";
								$gs = $genusspecies;
    						}
   
						}  		  	
						#collect the genus and species (or the organism name) of the match and place in $holder
						$holder =  $holder."$gs\t";
   						#print "$holder";
    
    					#this should NOT loop more than once, so while loop was removed from original code
  		  				my $hsp = $hit->next_hsp; 
  		  				
  		      				#collect a value for fraction of identical bases between the sequences.
  		      				#store variable in holder and end with newline
  		      	    	my $hold2 = $hsp->frac_identical;
  		      				$holder = $holder."$hold2\n";
  		      				
  		      				#this print gives the user the final tab delimited data line that will be reported to arg1
  		      			print "$holder";	
  		      		
  		      				#other (unused) diagnostic variables for the search that may be included
  		      				#print "score is ", $hsp->score, "\t";
  		      				#print "frac identity", $hsp->frac_identical, "\t";
  		      				#print "E is ", $hsp->evalue, "\n";
						
  						#open the output file defined by usr (arg1), append the fasta name,
  						# matching genus and species (or organism name), and percent identity
  						# in a tab delimited line (stored in $holder) to that file, and close the file.
  						open (my $fh, '>>', $output) or die "Could not open file '$output' $!";
  						print $fh "$holder"; 
  						close ($fh);
  		
  						#print "$holder";
    	
  	      			}
  	      			my $totalmin = $totaltime/60;
  	      			#give the user a sense of the cumulative time taken for the search
  	      			print "Seq $v done. \tTotal time: $totalmin min. \n" ; $v++;
  	  			}
      		}
  		}
	}
}
