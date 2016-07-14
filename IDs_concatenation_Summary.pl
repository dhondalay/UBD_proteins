# /usr/bin/perl -w

use strict;
use warnings;
use Path::Class::Rule;
use Cwd;

# Summary file creation

my $output3 = "IDs_concatinated_summary.txt"; # Summary file for IDs concatenation.


my $rule2 = Path::Class::Rule->new; # match anything

$rule2->file->name('IPR*.txt');

my $next = $rule2->iter( my @dirs );
  
open ( OUTPUT3, '>', $output3 ) or die "Could not open output file: $!";

while ( my $file = $next->() ) {
    
    my $ids = 0;

    open (my $fh, '<:encoding(UTF-8)', $file) or die "Could not open file : '$file' $!"; 
	    print "Reading file : $file\n";
    	$ids++ while (<$fh>);
    close $fh;
    
    print OUTPUT3 "$file\t:$ids\n";
       
}
close OUTPUT3;