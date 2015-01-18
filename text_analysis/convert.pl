#!/usr/bin/perl
use strict;
use Encode;
use utf8;

binmode(STDOUT,":encoding(utf-8)");

open(IN,"bad_bio/bad_bio_utf.txt") || die "ERROR: $!";
binmode(IN,":encoding(utf-8)");

open(OUT,">bad_bio/bad_bio.txt") || die "ERROR: $!";
binmode(OUT,":encoding(euc-jp)");

for my $in (<IN>)
{
	print "$in";
	print OUT "$in";
}
close(IN);
close(OUT);

# end of file
