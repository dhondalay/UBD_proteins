#!/usr/bin/env perl

# File : file_splitter.pl
#
# Created by: Gopal Krishna R Dhondalay

##########################################################################################
#
# Description : This script reads an input (eg. Combined_duplicates_removed.txt) file,
#               
# Usage : perl file_splitter.pl
# 
# Input : .txt file with each InterPro IDs in separate line
#
# Output : The input file is split into multipel files with 100 lines per each file.
#
##########################################################################################

use strict;
use warnings;
use File::Basename;
use Cwd;

my $hashes = '# - ' x 50 . "\n";
my $pwd = cwd();

my $file = shift || die "Please provide input file!!!\n";
print "You have provided input file as : ", $file, "\n\n";

#### InterPro_extract.pl
print $hashes, "\nAttempting to extract protein IDs from InterPro\n\n";
my $InterPro_extract = 'perl ~/OneDrive/scripts/perl/InterPro_extract.pl' . " " . $file;
print `$InterPro_extract`;
print "\nFinished extracting protein IDs from InterPro\n\n";

#### IDs_concatenation.pl
print $hashes, "\nAttempting to concatinate protein IDs\n\n";
my $IDs_concatenation = 'perl ~/OneDrive/scripts/perl/IDs_concatenation.pl';
print `$IDs_concatenation`;
print "\nFinished concatenating protein IDs\n\n";

#### File_splitter.pl
print $hashes, "\nAttempting to split concatinated IDs\n\n";
my $File_splitter = 'perl ~/OneDrive/scripts/perl/File_splitter.pl';
print `$File_splitter`;
print "\nFinished splitting files\n\n";

#### InterPro_multifasta_generation.pl
print $hashes, "\nAttempting to create multifasta files\n\n";
my $InterPro_multifasta_generation = 'perl ~/OneDrive/scripts/perl/InterPro_multifasta_generation.pl';
print `$InterPro_multifasta_generation`;
print "\nFinished creating multifasta files\n\n";

#### iprscan_pileup.pl
chdir $pwd;
print $hashes, "\nAttempting to pileup iprscan\n\n";
my $iprscan_pileup = 'perl ~/OneDrive/scripts/perl/iprscan_pileup.pl';
print `$iprscan_pileup`;
print "\nFinished piling up iprscan\n\n";

#######################################

#### Finishing everything ####
my $dashes = '- - ' x 25 . "\n";
print $dashes, "All done\n", $dashes ;