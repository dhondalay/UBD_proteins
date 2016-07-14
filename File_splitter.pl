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

my $length = 50; # is the threshold maintained since the Iprscan will not handle more than 100 IDs at a time.
# my $file = "Combined_uniques.txt";

my $file = shift || warn "Provide Input file!!\n";

my ($name,$path,$suffix) = fileparse($file,("\.txt"));
my $file_name = $name . "_splits";

open(my $fh,$file) || die "$file $!";

mkdir $file_name;
chdir $file_name;

my $lc=0;
my $outfh=undef;
while(<$fh>) {
    if (($lc % $length) == 0) {
            my $n=int($lc/$length)+1;
            open($outfh,">$file_name$n.txt") || warn "$file_name$n.txt $!";
            }
    $lc++;
    print $outfh $_;
}

#############
# my $dashes = '-' x 25 . "\n";
# print $dashes, "All done\n", $dashes ;