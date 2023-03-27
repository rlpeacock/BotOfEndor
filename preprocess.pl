#!/usr/bin/perl

use strict;
use warnings;

my $cur_book;

for my $line (<STDIN>) {
	if ($line =~ /^BOOK:(.*)$/) {
		my $book_name = lc($1);
		# roman numerals bad
		$book_name =~ s/^iii /3 /;
		$book_name =~ s/^ii /2 /;
		$book_name =~ s/^i /1 /;
		# get rid of trailing whitespace
		$book_name =~ s/\s*$//;
		close $cur_book if $cur_book;
		open $cur_book, ">", "$book_name" or die "Failed to open $book_name for writing";
	} else {
		if ($cur_book) {
			print $cur_book $line
		}
	}
}
close $cur_book if $cur_book;