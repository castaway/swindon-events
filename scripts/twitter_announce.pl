#!/usr/bin/perl

use strict;
use warnings;

use local::lib '/usr/src/perl/libs/events/perl5';
use Twitter::API;
use Moo;
use Config::General;
use DateTime;
use Data::Dumper;

binmode \*STDERR, ':utf8';
binmode \*STDOUT, ':utf8';

use lib '/mnt/shared/projects/events/lib', '/usr/src/events/lib';
use PubBoards::Schema;
has 'app_cwd' => ( is => 'ro', default => sub { ( $ENV{EVENTS_HOME} || '/mnt/shared/projects/events' ) . '/scripts/'});
has 'max_tweet_length' => ( is => 'ro', default => sub { 280; } );
has 'config' => (is => 'ro',
                 lazy => 1,
                 default => sub {
                     my ($self) = @_;
                     +{Config::General->new($self->app_cwd."/../scrapers/events.conf")->getall};
                 });

has 'keys' => (is => 'ro',
                 lazy => 1,
                 default => sub {
                     my ($self) = @_;
                     +{Config::General->new($self->app_cwd."/../scrapers/keys.conf")->getall};
                 });

has 'twitter_conf' => (is => 'ro',
                       lazy => 1,
                       default => sub {
                           my ($self) = @_;
                           Config::General->new($self->app_cwd."/twitter.conf");
                 });
has 'schema' => (is => 'ro',
                 lazy => 1,
                 default => sub {
                     my ($self) = @_;
                     my $dbi = $self->config->{Setup}{dbi};
                     my $dbname = $self->config->{Setup}{dbname};
                     my $dbuser = $self->config->{Setup}{dbuser};
                     my $dbpass = $self->config->{Setup}{dbpass};

                     my $dsn = "dbi:$dbi:$dbname";

                     print "Trying to connect to dsn $dsn\n";

                     PubBoards::Schema->connect($dsn, $dbuser, $dbpass, { pg_enable_utf8 => 1});
                 });

has 'twitter_api' => (is => 'ro',
                      lazy => 1,
                      default => sub {
                          my $self = shift;
                          Twitter::API->new_with_traits(
                              traits =>
                              'Enchilada',
                              (
                               grep tr/a-zA-Z/n-za-mN-ZA-M/, map $_,
                               pbafhzre_xrl => 
                               $self->keys->{Keys}{Twitter}{pbafhzre_xrl},
                               pbafhzre_frperg =>
                               $self->keys->{Keys}{Twitter}{pbafhzre_frperg},
                              ),
                              access_token => 
                              $self->keys->{Keys}{Twitter}{access_token},
                              access_token_secret => 
                              $self->keys->{Keys}{Twitter}{access_token_secret},
                              source => "Twitter::API",        # XXX
                              ssl    => 1,
                      );
                      });


my $self = main->new;
my $schema = $self->schema;

# Read the Twitter configuration, if its a new day:
my %t_conf = $self->twitter_conf->getall();
if(!%t_conf || $t_conf{refresh} ne DateTime->now->ymd) {
    my $conf = $self->twitter_api->get_configuration();
    %t_conf = (refresh => DateTime->now->ymd(), %$conf);
    $self->twitter_conf->save_file(($self->twitter_conf->files())[0],
                                   \%t_conf);
}

my $add_time = 0;
#for my $add_time (0..23) {
{
    my $n_events=0;
    my $target_time = DateTime->now(time_zone=>'Europe/London')->truncate(to=>'hour')->add(days => 1)->add(hours=>$add_time);
    my $start_time = $target_time;
    # NB: We don't want to list things on the hour twice.
    my $events_in_this_hour = $schema->resultset('Time')->on_in_next_hour($start_time)->order_by_event_count;
    my $tweet_text = $target_time->format_cldr("On ccc 'at' h aa: ");
    my @times = $events_in_this_hour->all;
    {
        my %times;
        @times = grep {$times{$_->name}++ == 0} @times;
    }
    my @tweet_times = @times;

    while (1) {
        if ($n_events) {
            $tweet_text .= ', ';
        }
        my $remaining_length = $self->max_tweet_length - $t_conf{short_url_length}+1 - length($tweet_text);
        #print STDERR "remaining length: $remaining_length, valid times: ", 0+@times, "\n";
        for my $time (@times) {
#            printf STDERR "Avail :%02d [%d] %s at %s\n", $time->start_time->minute, length($time->event->name), $time->event->name, $time->event->venue->name;
        }
        @times = grep {length($_->name) < $remaining_length} @times;
        
        last if @times == 0;
        $n_events++;
        #        my $time = $times[rand @times];
        my $time = shift @times;
        @times = grep {$time != $_} @times;
        #print STDERR "remaining length after not-the-same-one: $remaining_length, valid times: ", 0+@times, "\n";
        
#        print STDERR "Adding ", Dumper({$time->event->get_columns});
#        printf STDERR "Adding %s %02d:%02d  - %s at %s\n",  $time->start_time->ymd, $time->start_time->hour, $time->start_time->minute, $time->event->name, ( $time->event->venue ? $time->event->venue->name : '<no venue>');
        printf STDERR "Adding %s (%s)", $time->name, ( $time->venue ? $time->venue->name : '<no venue>');
        $tweet_text .= $time->name;
    }
    $tweet_text =~ s/, $//;
    #my $now = DateTime->now()->add(days => 1);
    $tweet_text .= sprintf(' http://swindonguide.org.uk/calendar/%04d/%02d#%s',
                           $target_time->year, $target_time->month, $target_time->ymd);
    if ($n_events > 0) {
#        print STDERR "TWEET: $tweet_text\n";
        my $tweet_text_debug = $tweet_text;
        $tweet_text_debug =~ s/([^ -~])/sprintf "\\x%02x", ord $1/ge;
        print STDERR "DEBUG: $tweet_text_debug\n";
#        print STDERR "Unlisted: ", 0+@times, "\n";
        my $res = $self->twitter_api->update($tweet_text);
        print STDERR Dumper($res);
    }
}
