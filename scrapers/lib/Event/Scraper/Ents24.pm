package Event::Scraper::Ents24;

use strict;
use warnings;

use Moo;
use LWP::Simple 'get';
use LWP::UserAgent;
use Data::Dumper;
use DateTime::Format::Strptime;
use JSON;

has service => (is => 'ro', default => sub { 'ents24' });
has ua => (is => 'ro', default => sub { LWP::UserAgent->new() });
has token => (is => 'rw');

my $api_base = 'https://api.ents24.com/';

sub get_events {
    my ($self, $config, $keyconf) = @_;
    my $access_token = $self->authenticate($keyconf);
    my $events = $self->fetch('event/list?radius_distance=5&distance_unit=mi&location=geo:'.$config->{centre}{lat}.','.$config->{centre}{lng});
    # print Dumper($events);

    my @events;
    my $formatter = DateTime::Format::Strptime->new(pattern => '%y-%m-%d %I:%M%p');
    my $alt_formatter = DateTime::Format::Strptime->new(pattern => '%y-%m-%d %H:%M');
    my $iso_formatter = DateTime::Format::Strptime->new(pattern => '%y-%m-%dT%H:%M:%S%z');
    foreach my $s_event (@{ $events }) {
        # T&C asks us to not store longer than an hour, so we'll have
        # to fetch them more often than that..
        if(!$s_event->{venue} || $s_event->{isCancelled}
           || $s_event->{isPostponed} || !$s_event->{startTimeString}
            || !$s_event->{title}) {
            next;
        }
        print Dumper($s_event);
        my %event = ();
        $event{event_id} = $s_event->{id};
        $event{event_name} = $s_event->{title};
        $event{event_url} = $s_event->{webLink};
        $event{event_desc} = $s_event->{description};
        $event{updated_time} = $iso_formatter->parse_datetime($s_event->{lastUpdate});
        $event{venue} = {
            name     => $s_event->{venue}{name},
            city     => $s_event->{venue}{address}{town},
            latitude => $s_event->{venue}{location}{lat},
            longitude => $s_event->{venue}{location}{lon},
            street    => join(',', @{ $s_event->{venue}{address}{streetAddress} }),
            country   => 'United Kingdom',
        };
        my $start_time = $formatter->parse_datetime($s_event->{startDate} . ' ' . $s_event->{startTimeString});
        if (!$start_time) {
            # usually 8:00pm but sometimes 19:00 !
            $start_time = $alt_formatter->parse_datetime($s_event->{startDate} . ' ' . $s_event->{startTimeString});
        }
        if (!$start_time) {
            print "Can't get start_time from: $s_event->{startDate} . ' ' . $s_event->{startTimeString}";
            next;
        }
        # print STDERR Dumper($s_event);
        my $end_time;
        if($s_event->{endTimeString} && $s_event->{endDate}) {
            $end_time = $formatter->parse_datetime($s_event->{endDate} . ' ' . $s_event->{endTimeString});
        }
        $event{times} = [{
            start => $start_time,
            $end_time ? ( end => $end_time ) : (),
                         }];
        push @events, \%event;
    }

    return \@events;
}

sub post {
    my ($self, $path, $content) = @_;
    my $uri = "$api_base$path";
    my $resp = $self->ua->post($uri, $content);
    if($resp->is_success) {
        return decode_json($resp->decoded_content);
    }
    print $resp->status_line;
    print $resp->decoded_content;
}

sub fetch {
    my ($self, $path) = @_;
    my $uri = "$api_base$path";
    my $resp = $self->ua->get($uri, Authorization => $self->token);
    if($resp->is_success) {
        return decode_json($resp->decoded_content);
    }
    print $resp->status_line;
    print $resp->decoded_content;
}

sub authenticate {
    my ($self, $keys) = @_;

    my $auth = $self->post('auth/token', { client_id => $keys->{client_id}, client_secret => $keys->{secret} });

    if(!$auth) {
        print "Failed to authenticate Ents24";
        return;
    }
    $self->token($auth->{access_token});    
}

1;
