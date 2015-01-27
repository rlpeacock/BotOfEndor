#!/usr/bin/perl

package BotOfEndor;
use base qw(Bot::BasicBot);
use strict;
use warnings;
use DateTime;
use feature "switch";

=head1 NAME

BotOfEndor - A bot for looking up bible references and other misc. functions


=cut


# set to 1 to enable debug logging for bible reference lookup
my $DEBUG_REF = 0;


#
# get a map of book name to book id number (which corresponds to the actual file name)
# loads it from a file in format <num>:<comma seperated list of names>
#
sub load_bookmap  {
    my %bookmap;
    open my $mapfile, "<", "data/bookmap" or die "Could not load book map";
    for my $line (<$mapfile>) {
        my ($num, $names) = split /:/, $line;
        for my $name (split /,/, $names) {
            $bookmap{$name} = $num;
        }
    }
    close $mapfile;
    %bookmap;
}


# static map of name/alias to book number/file name
my %BOOKMAP = load_bookmap();


#
# method which takes a bible citation and returns an array of the lines sited
# param:
#   $self: the object
#   $ref: a citation in the form of [<book> <chapt>:<verse or verse range>]
#
sub lookup_bible_reference {
    my $self = shift;
    my $ref = lc(shift);
    my ($book, $chapter, $verse, $end) = $ref =~ /(\d*\s*\w+)\s+(\d+):(\d+)-?(\d*)/;
    my $booknum = $BOOKMAP{$book} if $book;
    $self->log("$book => $booknum") if $DEBUG_REF;
    # validate citation looks plausible
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

    # build a list of <chapt>:<verse> strings for all in range (or just the single one if not a range)
    my @targets;
    for ($verse .. $end) {
        $self->log("$chapter:$_") if $DEBUG_REF;
        push @targets, "$chapter:$_";
    }

    my @found;
    open my $bookfile, "<", "data/nrsv/$booknum" or $self->log("failed to open book $book ($booknum)");
    # go through book line by line looking for lines which begin with the <chapt:verse> strings we are looking for
    # stop when we've found them all.  Yes, this is inefficient but it's easy and we really don't care at all
    # about performance
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


#
# parse a message, pulling out all bible references, looking them up and returning them as an array of strings
# param:
#    $self: the object
#    $message: the text
# returns:
#    list of verse strings
#
sub get_verses {
    my ($self, $message) = @_; 
    my @res;
    while ($message =~ /\[([^\]]+)\]/g) {
        my $citation = $1;
        push @res, $self->lookup_bible_reference($citation);
    }
    $self->log(join( ":", @res)) if $DEBUG_REF;
    @res;
}


#
# handle a message
# parameter:
#    $self: the object
#    $message: the text we received
#    $is_to_me: 1 if it's directed to us, either by direct message or by naming in public chat
#    $is_private: 1 if it was sent directly to us
# returns:
#    list of strings to send as response
#
sub process_message {
    my ($self, $message, $is_to_me, $is_private) = @_;
    $self->log("handling $message");
    my @res;
    for ($message) {
        when (/\[([^\]]+)\]/)  { @res = $self->get_verses($message) }
        default { }
    }
    @res;
}

#
# callback invoked when someone says something in a channel we're attached to, or someone
# sends us a message.
# parameters:
#    $self: the object
#    $message: message structure
#
# address is either 'msg' if it's private or 'AllEars' if addressed like "AllEars: test"
# chan will be '#reddit-Christianity' unless it's a direct message, in which case it's 'msg'
# to message a person, set who=>$who ...leave it out to send to channel
#
sub said {
    my $self = shift;
    my $message = shift;
    my $who = $message->{who};
    my $addr = $message->{address} || "-";
    my $chan = $message->{channel};
    my $body = $message->{body};
    my $is_to_me = $addr ne "-";
    my $is_private = $chan eq "msg";
    my @response = $self->process_message($body, $is_to_me, $is_private);
    for my $line (@response) {
        if ($addr eq "msg") {
            $self->say(channel => 'msg', who => $who, body => $line);
        } else {
            $self->say(channel => $chan, body => $line);
        }
    }
    undef;
}

#
# put a timestamp in front of each parameter and print it to stderr
#
sub log {
    my $self = shift;
    my $td = DateTime->now;
    for my $line (shift) {
        my $logline = $td->ymd . " " . $td->hms . " " . $line . "\n";
        print STDERR $logline;
    }
    undef;
}

#
# callback for when we connect
#
sub connected {
    my $self = shift;
    if ($BotOfEndor::pwd !~ /none/) {
        $self->log("Identifying");
        $self->say(channel => "msg", who => "nickserv", body => "IDENTIFY $BotOfEndor::nick $BotOfEndor::pwd");
    }
    $self->log("Connected");
}

# 
# callback for startup
#
sub init {
    my $self = shift;
}

#
# main routine
#
sub startbot {
    my ($nick, $channel) = @_;
    BotOfEndor->new(
      server => "irc.freenode.org",
      channels => [ '#'.$channel ],
      nick => $nick,
    )->run();
}

our ($nick, $pwd, $channel) = @ARGV;
die "Usage: botofendor.pl <nick> <pwd> <channel>\n" if !($nick && $pwd && $channel);
startbot($nick, $channel);
