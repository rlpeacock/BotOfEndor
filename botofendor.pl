#!/usr/bin/perl

package Bot;
use base qw(Bot::BasicBot);
use strict;
use warnings;

# Mapping of book number to name.  Each number corresponds to a file in the bible's directory.
# This map was lifted from versebot's source, which is why it's actually reversed from what I actually need.
# I'm too lazy to actually reverse it manually.
my %TITLES = reverse(
    1=>'genesis', 1=>'gen', 
    2=>'exodus', 2=>'ex',
    3=>'leviticus', 3=>'lev',
    4=>'numbers', 4=>'num',
    5=>'deuteronomy', 5=>'deut',
    6=>'joshua', 6=>'josh',
    7=>'judges', 7=>'jud',
    8=>'ruth',
    9=>'1 samuel', 9=>'1 sam',
    10=>'2 samuel', 10=>'2 sam',
    11=>'1 kings', 12=>'2 kings',
    13=>'1 chronicles', 13=>'1 chron', 13=>'1 chr',
    14=>'2 chronicles', 14=>'2 chron', 14=>'2 chr',
    15=> 'ezra',
    16=>'nehemiah', 16=>'neh', 16=>'nehem',
    17=>'esther', 17=>'est',
    18=>'job', 
    19=>'psalms', 
    20=>'proverbs', 
    21=>'ecclesiastes', 21=>'eccl', 21=>'ecc',
    22=>'song of songs', 22=>'song', 22=>'sos', 22=>'song of soloman',
    23=>'isaiah', 23=>'isa',
    24=>'jeremiah', 24=>'jer',
    25=>'lamentations', 25=>'lamen', 25=>'lam',
    26=>'ezekiel', 26=>'eze',
    27=>'daniel', 27=>'dan',
    28=>'hosea', 28=>'hos',
    29=>'joel', 
    30=>'amos',
    31=>'obadiah', 31=>'oba', 31=>'obd',
    32=>'jonah', 32=>'jon', 
    33=>'micah', 33=>'mic',
    34=>'nahum', 34=>'nah',
    35=>'habakkuk', 35=>'hab',
    36=>'zephaniah', 36=>'zep', 36=>'zeph',
    37=>'haggai', 37=>'hag', 37=>'hagg',
    38=>'zechariah', 38=>'zec', 38=>'zech',
    39=>'malachi', 39=>'mal', 39=>'mala', 
    40=>'matthew', 40=>'matt', 40=>'mat',
    41=>'mark', 41=>'mar',
    42=>'luke', 42=>'luk',
    43=>'john', 
    44=>'acts', 
    45=>'romans', 45=>'rom',
    46=>'1 corinthians', 46=>'1 cor', 46=>'1 corin', 46=>'1 corinth',
    47=>'2 corinthians', 47=>'2 cor', 47=>'2 corin', 47=>'2 corinth',
    48=>'galatians', 48=>'galat', 48=>'gala', 48=>'gal',
    49=>'ephesians', 49=>'ephes', 49=>'eph',
    50=>'philippians', 50=>'philip', 50=>'phili', 50=>'phil', 50=>'phi',
    51=>'colossians', 51=>'colos', 51=>'col',
    52=>'1 thessalonians', 52=>'1 thessal', 52=>'1 thessa', 52=>'1 thess', 52=>'1 thes', 52=>'1 the',
    53=>'2 thessalonians', 53=>'2 thessal', 53=>'2 thessa', 53=>'2 thess', 53=>'2 thes', 53=>'2 the',
    54=>'1 timothy', 54=>'1 tim',
    55=>'2 timothy', 55=>'2 tim',
    56=>'titus', 56=>'tit',
    57=>'philemon', 57=>'phile', 57=>'phl',
    58=>'hebrews', 58=>'heb',
    59=>'james', 59=>'jam',
    60=>'1 peter', 60=>'1 pet',
    61=>'2 peter', 61=>'2 pet',
    62=>'1 john', 
    63=>'2 john', 
    64=>'3 john', 
    65=>'jude', 65=>'jud',
    66=>'revelation', 66=>'rev',
    67=>'judith', 67=>'judi',
    68=>'wisdom of solomon', 68=>'wos',
    69=>'tobit', 69=>'tob',
    70=>'ecclesiasticus', 
    71=>'baruch', 71=>'bar',
    72=>'1 maccabees', 72=>'1 macc', 72=>'1 mac',
    73=>'2 maccabees', 73=>'2 macc', 73=>'2 mac',
    74=>'prayer of azariah', 74=>'azariah', 74=>'aza',
    75=>'additions to esther', 
    76=>'prayer of manasseh', 
    77=>'3 maccabees', 
    78=>'4 maccabees', 
    80=>'1 esdras', 
    81=>'2 esdras', 
    87=>'susanna', 
    88=>'bel and the dragon'
    );

my %TERMS;
my %HIST;

# load defintions from data file and put it in global TERMS map
sub load_definitions {
    open my $termfile, "<", "data/orthoterms" or die "Unable to load term file";
    for my $line (<$termfile>) {
        my ($term, $def) = split /\|/, $line;
        chomp($def);
        $TERMS{$term} = $def;
    }
    close $termfile;
}
load_definitions();

sub find_definition {
    my $term = shift;
    $TERMS{$term};
}

sub test_defs {
    while (<>) {
        my $term = $_;
        chomp($term);
        $term = uc($term);
        $term =~ s/^\?//;

        print find_definition($term);
        print "\n";
    }
}

sub lookup_bible_reference {
    my $ref = lc(shift);
    my ($book, $chapter, $verse, $end) = $ref =~ /(\d*\s*\w+)\s+(\d+):(\d+)-?(\d*)/;
    my $booknum = $TITLES{$book} if $book;
    return if !$booknum ||
              !$chapter ||
              !$verse ||
              $chapter <= 0 || 
              $chapter > 1000 || 
              $verse <= 0 || 
              $verse > 1000 || 
              ($end && $end < $verse) ||
              ($end && $end > $verse+4);

    $end = $verse if not $end;

    my @targets;
    for ($verse .. $end) {
        push @targets, "$chapter:$_";
    }

    my @found;
    open my $bookfile, "<", "data/nrsv/$booknum" or print "failed to open book $book ($booknum)\n";
    for my $line (<$bookfile>) {
        for my $target (@targets) {
            if ($target && $line =~ /^\s*$target/) {
                push @found, $line;
                $target = undef;
                last if @found == @targets;
            }
        }
    }
    close $bookfile;
    return @found if @found;
}

sub test_lookup_bible_reference {
    while (<STDIN>) {
        my @refs = lookup_bible_reference($_);
        for my $ref (@refs) {
            print $ref;
        }
    }
}

sub help {
    my $self = shift;
    my $message = shift;
    my @help = (
        "Got a question?  Why not consult the bot of Endor?",
        "Prefix a word with a question mark, and if I know what it means I will give the definition",
        "Reference a bible verse in this format: [<book> <chapter>:<verse>] and I will show that verse",
        "e.g. [1 Peter 2:1] or use a range e.g. [Ruth 1:1-10].  Translation is NRSV.  Sorry I don't do deuterocanonical books yet.",
        "I was created by JustDust in a fit of madness.  Now...whom shall I bring up for you?");
    $self->say(channel => $message->{channel}, body => $_) for (@help);
}

sub said {
    my $self = shift;
    my $message = shift;
    my $body = $message->{body};
    if ($body =~ /^\?(.+)$/) {
        my $term = uc($1);
        chomp($term);
        my $def = find_definition($term) if $term;
        $self->say(channel => $message->{channel}, body => $def) if $def;
        $self->log("doing line term");
    }
    elsif ($body =~ /\?(\w+)/) {
        my $def = find_definition(uc($1));
        $self->log("starting term");
        $self->say(channel => $message->{channel}, body => $def) if $def;
        $self->log("doing term");
    }
    if ($body =~ /\[(.+)\]/) {
        my @refs = lookup_bible_reference($1);
        for my $ref (@refs) {
            $self->log("starting refs");
            $self->say(channel => $message->{channel}, body => $ref) if $ref;
            $self->log("doing refs");
        }
    }
    if ($message->{address} && $body =~ /^raise\s(\w+)/) {
        my $raised = $1;
        if ($HIST{$raised}) {
            $self->log("starting raised");
            $self->say(channel => $message->{channel}, body => "the spirit of $raised says: $_") for (@{$HIST{$raised}});
            $self->log("doing raised");
        } else {
            my $msg = "Surely you know what Saul has done, how he has cut off the mediums and the wizards from the land. Why then are you laying a snare for my life to bring about my death?";
            $self->say(channel => $message->{channel}, body => $msg);
            $self->log("doing not raised");
        }
    }
    my $who = $message->{who};
    $HIST{$who} = [] if !$HIST{$who};
    push @{$HIST{$who}}, $body;
    shift @{$HIST{$who}} if @{$HIST{$who}} > 3;
    undef;
}

sub connected {
    my $self = shift;
    $self->log("Identifying");
    $self->say(channel => "msg", who => "nickserv", body => "identify BotOfEndor hermes");
    $self->log("Connected");
}

sub startbot {
    Bot->new(
      server => "irc.freenode.org",
      channels => [ '#reddit-Christianity' ],
      nick => 'BotOfEndor',
#      channels => [ '#test' ],
#      nick => 'WitchOfEndor',
    )->run();
}

my $mode = shift || "";
if ($mode =~ /run/) {
    startbot();
} elsif ($mode =~ /ref/) {
    test_lookup_bible_reference();
} elsif ($mode =~ /def/) {
    test_defs();
} else {
    print "orthobot.pl <run|ref|def>\n";
}
