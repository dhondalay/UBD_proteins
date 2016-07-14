#!/usr/bin/env perl

# File : SUMO_v2.pl
#
# Version : v2
#
# Created by: Gopal Krishna R Dhondalay

##########################################################################################
#
# Description : 
#               
# Usage : 
# 
# Input : 
#
# Output : 
#
##########################################################################################

# Initialisations

use strict;
use warnings;
use LWP::Simple;
use Cwd;
use Path::Class::Rule;
use File::Basename;
use Getopt::Long;

my $dashes = '= ' x 60 . "\n";
my $pwd1;
my $pwd2;

my $input_file = shift || die "Please provide input file!!!\n";
print "\n\nYou have provided input file as : ", $input_file, "\n\n";
my $pwd = cwd();

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

# Creating output folder

# my $parent_dir = "/Users/gd8_admin/Desktop/Output"; # from laptop
my $parent_dir = "/Users/gopalkrishnadhodnalay/Desktop/Output"; # from desktop

mkdir $parent_dir unless -d $parent_dir; # Check if dir exists. If not create it.
chdir $parent_dir;

system("cp \'$pwd/$input_file' \'$parent_dir/'");

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

# InterPro_extract.pl

print $dashes, "\nAttempting to extract protein IDs and fastas from InterPro . . . . .\n\n";

$/ = undef;#set input record seperator to null[default \n]
my $extract_folder ="InterPro_extracts"; # defining a general output folder

open (IN, "<$input_file") || die "$! Can not open file\n";
my $content = <IN>; #Whole file content in a single scalar variable
close(IN);

mkdir $extract_folder unless -d $extract_folder; # Check if dir exists. If not create it.
chdir $extract_folder;

foreach my $id (split /\n/ ,$content) {
    
    my $pwd1 = cwd();
    
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
    # my $file_fasta = $id . "." . "fasta";
    # my $url_fasta = "http://www.ebi.ac.uk/interpro/entry/" . $id . "/proteins-matched?species=9606&export=fasta";
    # open (MYFILE_FASTA, ">$file_fasta");
    # print MYFILE_FASTA get $url_fasta;
    # close (MYFILE_FATSA);
 
    chdir $pwd1;
}

print "\nFinished extracting protein IDs and fastas from InterPro.\n\n";

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

# IDs_concatination.pl

chdir $parent_dir;

print $dashes, "\nAttempting to concatinate protein IDs . . . . .\n\n";

chdir "InterPro_extracts";

my $output1 = "Combined_all.txt"; # file containing all the concatenated ID list
my $output2 = "Combined_uniques.txt"; # file containing only unique IDs.

############

# to check if output files exists, if yes, delete them

if (-f $output1) { unlink glob $output1 };
if (-f $output2) { unlink glob $output2 };

############

# To iterate into subfolders scanning for *.txt files
# To concatenate the IDs list into Combined_all.txt

# print "Creating $output1 file . . . . .\n\n";

my $rule = Path::Class::Rule->new; # match anything

$rule->file->name('IPR*.txt');

my $next = $rule->iter( my @dirs );
  
open ( OUTPUT1, '>', $output1 ) or die "Could not open output file: $!";

while ( my $file = $next->() ) {
    
    my $ids_counts = 0;
    
    print "Reading file : $file\n";

    open (my $fh, '<:encoding(UTF-8)', $file) or die "Could not open file : '$file' $!";
    
    while (my $row = <$fh>) {
        # chomp $row;
        print $row, "\n";
        $ids_counts ++;
        print OUTPUT1 $row;
    }
    
    print "* * * * * * * * * = $ids_counts\n\n";
    close $fh;
       
}
close OUTPUT1;

print "\n$output1 . . . . . File created. \n\n";
############

# To remove duplicated IDs from Combined_all.txt file and stoere in Combined_uniques.txt

print "\nChecking for duplicate IDs . . . . . ";

my %a = ();

open(OUTPUT1, '<', $output1) or die "can't open : $!";
    
    open (OUTPUT2, '>', $output2) or die "Cant open: $!";
        while (<OUTPUT1>) {
            print OUTPUT2 unless $a{$_}++;
        }
    close OUTPUT2;
    
close OUTPUT1;

print "Done\n";

############

# To print the number of unique IDs in Combined_uniques.txt file

print "Creating $output2 . . . . .";

my $count = `wc -l <$output2`;
die "wc failed: $?" if $?;
chomp($count);

print "Done\n\n";

print "\nTotal unique IDs after duplicate removed =$count\n\n";

############

system("cp \'$output1' \'$parent_dir/$output1'");
system("cp \'$output2' \'$parent_dir/$output2'");


# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

# File_splitter.pl

chdir $parent_dir;

my $File_splitter = 'perl ~/OneDrive/scripts/perl/File_splitter.pl' . " " . $output2;
print `$File_splitter`;

# Removing empty lines from files

my @split_files = grep ( -f ,<*splits*.txt>);

foreach my $split_file (@split_files) {
    while (<>) {
        print if /\S/;
    }
}

print "File splitting is complete . . . . .\n";

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

# InterPro_multifasta_generation.pl

my $ipr_dir = $parent_dir. "/iprscan";

mkdir $ipr_dir;
mkdir $ipr_dir. "/txt";
mkdir $ipr_dir. "/multifastas";

system("cp \'$parent_dir/Combined_uniques_splits/'*.txt \'$ipr_dir/txt/'");
system("cp \'$parent_dir/Combined_uniques_splits/'*.txt \'$ipr_dir/multifastas/'");

print "Completed copying files . . . . .\n";

# Store only .txt-files in the @files array using glob
chdir $ipr_dir. "/multifastas";
    
my $multi_fasta = 'perl ~/OneDrive/scripts/perl/InterPro_multifasta_generation.pl';
print `$multi_fasta`;    

print "Completed writing multifasta file";

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

# iprscan_pileup.pl

mkdir $ipr_dir. "/extracts";
chdir $ipr_dir. "/extracts";
system("cp \'$ipr_dir/multifastas/'*.fasta \'$ipr_dir/extracts/'");

# Store only .fatsa-files in the @files array using glob
my @fasta_files = grep ( -f ,<*.fasta>);

foreach my $fasta_file (@fasta_files) {
	
	my $pwd = cwd();
    
    # Creates folder specific for each InterPro ID.
    my ($name, $path, $suffix) = fileparse($fasta_file,("\.fasta"));
    mkdir $name unless -d $name; # Check if dir exists. If not create it.
    chdir $name;
    
	system("cp \'$pwd/$fasta_file\' \'$pwd/$name/'"); 
    
    my $email = 'dhondalay_krishna@yahoo.com';
    my $iprscan = 'perl ~/OneDrive/scripts/perl/iprscan.pl';
    
    print `$iprscan $fasta_file --multifasta --email $email`;
    
    chdir $pwd;

	print "$fasta_file\n";
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

# Finishing everything