#!/usr/bin/perl

use Log::Any '$log', default_adapter => 'Stdout';
use Log::Any::Adapter ('Stdout', log_level => 'debug' );
use strict;
use warnings;
use DateTime;
use feature "switch";

my $MAX_VERSES = 5;

# parse a verse reference and resolve it to verses
sub lookup_reference {
    my $ref = lc(shift);
    # e.g. 2 kings 1:1-3
    my ($book, $chapter, $verse, $end) = $ref =~ /([\dI]*\s*[^\d]+)\s(\d+):(\d+)-?(\d*)/;
    return if !$book ||
              $chapter <= 0 ||
              $verse <= 0 ||
              ($end && $end < $verse);
    $log->debug("Looking up $book $chapter:$verse");
    $end = $verse if not $end;
    $end = $verse + $MAX_VERSES - 1 if $end - $verse > $MAX_VERSES;

    my @found;
    open my $bookfile, "<", "books/$book" or $log->info("Failed to open book '$book'");
    for my $line (<$bookfile>) {
        # The books contain lines prefixed with their chapter and verse, so we just
        # need to find lines with the right prefixes.
        if ($line =~ /^\s*$chapter:$verse/) {
            # strip whitespace and newline
            $line =~ s/\s*$//;
            $log->debug($line);
            push @found, $line;
            last if ++$verse > $end;
        }
    }
    close $bookfile;
    return @found if @found;
}

# Get all verses referenced in a message.
sub get_verses {
    my ($message) = @_;
    my @response;
    while ($message =~ /\[([^\]]+)\]/g) {
        push @response, lookup_reference($1);
    }
    $log->debug(join( ":", @response));
    @response;
}

#
# Class for subclassing BasicBot
#
package BotOfEndor {
use base qw(Bot::BasicBot);
use Log::Any '$log', default_adapter => 'Stdout';
use Log::Any::Adapter ('Stdout', log_level => 'info' );

    # callback for when someone says something
    sub said {
        my ($self, $message) = @_;
        my $is_private = $message->{channel} eq "msg";
        my @response = get_verses($message->{body});
        for my $line (@response) {
            if ($is_private) {
                $self->say(channel => 'msg', who => $message->{who}, body => $line);
            } else {
                $self->say(channel => $message->{channel}, body => $line);
            }
        }
        undef;
    }

    # callback on connection - use this to identify ourselves to nickserv
    sub connected {
        my $self = shift;
        if ($BotOfEndor::pwd !~ /none/) {
            $log->info("Identifying");
            $self->say(channel => "msg", who => "nickserv", body => "IDENTIFY $BotOfEndor::nick $BotOfEndor::pwd");
        }
        $log->info("Connected");
    }

    sub newBot {
        my ($server, $channel, $nick) = @_;
        BotOfEndor->new(
          server => $server,
          channels => [ '#'.$channel ],
          nick => $nick,
        );
    }

    sub run {
        our ($server, $channel, $nick, $pwd) = @ARGV;
        die "Usage: botofendor.pl <server> <channel> <nick> <pwd>\n" if !($server && $channel && $nick && $pwd);
        newBot($server, $channel, $nick)->run();
    }

}
1;
