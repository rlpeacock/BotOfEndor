use strict;
use warnings;

while (<>) {
    my $line = $_;
    my @p = split;
    my @terms;
    for my $word (@p) {
        if ($word =~ /[a-z]/ || length($word) == 1) {
            last;
        } else {
            push @terms, $word 
        }
    }
    print join " ", @terms;
    print "|" . $line;
}
