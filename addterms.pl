#!/usr/bin/perl

use strict;
use warnings;

my %TERMS;

# load defintions from data file and put it in global TERMS map
sub load_definitions {
    open my $termfile, "<", "data/terms" or die "Unable to load term file";
    for my $line (<$termfile>) {
        my ($term, $def) = split /\|/, $line;
        chomp($def);
        $TERMS{$term} = $def;
    }
    close $termfile;
}
load_definitions();


my %NEWTERMS;

# load defintions from data file and put it in global TERMS map
sub load_new_definitions {
    my $file = shift;
    open my $termfile, "<", $file or die "Unable to load new term file";
    for my $line (<$termfile>) {
        my ($term, $def) = split /\|/, $line;
        chomp($def);
        $NEWTERMS{$term} = $def;
    }
    close $termfile;
}
my $file = shift || die "supply file name";
load_new_definitions($file);

for my $term (keys %NEWTERMS) {
    if (! $TERMS{$term}) {
        print "$term|$NEWTERMS{$term}\n";
    }
}

