#!/usr/bin/env perl

# File : InterPro_extract.pl
#
# Created by: Gopal Krishna R Dhondalay

##########################################################################################
#
# Description : This script reads an input (eg. .txt) file, extracts their informations 
#               requested through InterPro site and stores in specific folders.
#
# Usage : perl InterPro_extract.pl <INPUT_FILE.txt>
# 
# Input : .txt file with each InterPro IDs in separate line
#
# Output : All into a folder called "InterPro_IDs" in which a folder specific for InterPro ID containing; 
#          1. .txt : Text file containing UniProt IDs of proteins matching the InterPro IDs in humans
#          2. .fasta : multifasta file containing the sequences of the proteins
#
# NOTE : .txt file generated from excel need to be confirmed for line specifications
#
##########################################################################################

use strict;
use warnings;
use LWP::Simple;
use Cwd;

$/ = undef;#set input record seperator to null[default \n]
my $folder ="InterPro_extracts"; # defining a general output folder

##### Script starts #####

my $input_file = shift || die "Please provide input file!!!\n";

open (IN, "<$input_file") || die "$! Can not open file\n";
my $content = <IN>; #Whole file content in a single scalar variable
close(IN);

mkdir $folder unless -d $folder; # Check if dir exists. If not create it.
chdir $folder;

foreach my $id (split /\n/ ,$content) {
    
    my $pwd = cwd();
    
    # Creates folder specific for each InterPro ID.
    my $dir = './' . $id;
    mkdir $dir unless -d $dir; # Check if dir exists. If not create it.
    chdir $dir;
    
    print "Fetching information for : ", $id, "\n";
    
    # Fetching IDs...
    my $file_id = $id. "." . "txt";
    my $url_ids = 'http://www.ebi.ac.uk/interpro/entry/' . $id . '/proteins-matched?species=9606&export=ids';
    open (MYFILE_IDS, ">$file_id");
    print MYFILE_IDS get $url_ids;
    close (MYFILE_IDS);

    # Fetching fasta...
    my $file_fasta = $id . "." . "fasta";
    my $url_fasta = "http://www.ebi.ac.uk/interpro/entry/" . $id . "/proteins-matched?species=9606&export=fasta";
    open (MYFILE_FASTA, ">$file_fasta");
    print MYFILE_FASTA get $url_fasta;
    close (MYFILE_FATSA);
 
    chdir $pwd;
}