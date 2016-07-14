/usr/bin/perl -w

# File : IDs_concatenation.pl
#
# Created by: Gopal Krishna R Dhondalay
##########################################################################################
# description : A script to mine .txt (one ID per line) files from subfolders and
#               concatenate the IDs list from those .txt file into one file.
#
# Usage : perl IDs_concatenation.pl
#
# Pre-requisite : A text file containing IDs one per line
#
# Output :  1. Combined_all.txt : A txt file containing all IDs
#           2. Combined_uniques.txt : txt file containing only uniques after duplicates removed.
#           STD_OUTPUT of the lists and the number of IDs present.
##########################################################################################

use strict;
use warnings;
use Path::Class::Rule;
use Cwd;

my $pwd = cwd();

chdir "InterPro_extracts";

my $output1 = "Combined_all.txt"; # file containing all the concatenated ID list
my $output2 = "Combined_uniques.txt"; # file containing only unique IDs.

####################

# to check if output files exists, if yes, delete them

if (-f $output1) { unlink glob $output1 };
if (-f $output2) { unlink glob $output2 };

#####################

# To iterate into subfolders scanning for *.txt files
# To concatenate the IDs list into Combined_all.txt

my $rule = Path::Class::Rule->new; # match anything

$rule->file->name('IPR*.txt');

my $next = $rule->iter( my @dirs );
  
open ( OUTPUT1, '>', $output1 ) or die "Could not open output file: $!";

while ( my $file = $next->() ) {
    
    my $ids = 0;

    open (my $fh, '<:encoding(UTF-8)', $file) or die "Could not open file : '$file' $!";
 
    print "Reading file : $file\n";
    
    $ids++ while (my $row = <$fh>) {
        chomp $row;
        print $row, "\n";
        # $ids ++;
        print OUTPUT1 $row, "\n";
    }
    
    close $fh;
    
    print "* * * * * * * * * $ids \n\n";
       
}
close OUTPUT1;

open (FILE, $ARGV[0]) or die "Can't open '$ARGV[0]': $!";
$lines++ while (<FILE>);
close FILE;
print "$lines\n";