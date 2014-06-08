#!/usr/bin/env perl
package Events::Web;

use local::lib '/usr/src/perl/libs/events/perl5';
use JSON;
use Template;
use Path::Class;
use Config::General;
use Web::Simple;
use DateTime;
use Data::ICal;
use Data::ICal::Entry::Event;
use Date::ICal;

use lib '/mnt/shared/projects/events/scrapers/lib';
use lib '/usr/src/perl/pubboards/lib';
use PubBoards::Schema;

has 'app_cwd' => ( is => 'ro', default => sub {'/mnt/shared/projects/events/app/'});
#has 'static_url' => ( is => 'ro', default => sub {'http://192.168.42.2:7778'});
has 'base_uri' => (is  => 'ro', default => sub {'/events'});
has 'static_url' => ( is => 'ro', default => sub {'http://desert-island.me.uk/events/static'});
has 'tt' => (is => 'ro', lazy => 1, builder => '_build_tt');
has 'config' => (is => 'ro',
                 lazy => 1,
                 default => sub {
                     my ($self) = @_;
                     +{Config::General->new($self->app_cwd."/../scrapers/events.conf")->getall};
                 });
has 'schema' => (is => 'ro',
                 lazy => 1,
                 default => sub {
                     my ($self) = @_;
                     my $dbi = $self->config->{Setup}{dbi};
                     my $dbfile = $self->config->{Setup}{dbfile};

                     my $dsn = "dbi:$dbi:$dbfile";

                     print "Trying to connect to dsn $dsn\n";

                     PubBoards::Schema->connect($dsn);
                 });

sub _build_tt {
    my ($self) = @_;

    return Template->new({ 
        INCLUDE_PATH => dir($self->app_cwd)->subdir('templates')->stringify,
                         });
}

sub dispatch_request {
    my ($self) = @_;

    my $events_rs = $self->get_events_rs();
    sub (GET + /) {
        print STDERR "Index page\n";
        return [ 200, [ 'Content-type', 'text/html' ], [ $self->get_homepage($events_rs) ] ];
    },
    sub (GET + /calendar/*/*) {
        my ($self, $year, $month) = @_;
        print STDERR "Calendar: $year, $month\n";
        return [ 200, [ 'Content-type', 'text/html' ], [ $self->get_monthpage($events_rs, $year, $month) ] ];
    },
    sub (GET + /all.ical) {
        print STDERR "ICAL of events\n";
        return [ 200, [ 'Content-type', 'text/calendar' ], [ $self->get_ical($events_rs) ] ];
    },
    sub (GET + /venue/*) {
        my ($self, $url_part) = @_;

        my $venue = $self->get_venue($url_part);
        if($venue) {
            return  [ 200, [ 'Content-type', 'text/html' ], [ $self->get_venuepage($venue) ] ];
        } else {
            return  [ 404, [ 'Content-type', 'text/plain' ], [ 'No such venue' ] ];
        }
    },
}

sub get_venue {
    my ($self, $url_part) = @_;

    print STDERR "Part: $url_part\n";
    return $self->schema->resultset('Venue')->find({url_name => $url_part}, { key => 'url_name'});
}

sub get_events_rs {
    my ($self) = @_;

    my $events_rs = $self->schema->resultset('Event')->search(
        { 'times.start_time' => { "!=" => undef }}, 
        { prefetch => ['venue', 'times'] }
        );
}

sub get_ical {
    my ($self, $events_rs) = @_;

    my $ical = Data::ICal->new();

    while (my $event = $events_rs->next) {
#        print STDERR "E\n";
        my $times_rs = $event->times_rs;
        while (my $time = $times_rs->next) {
#            print STDERR "T\n";
            my $ical_event = Data::ICal::Entry::Event->new();
            $ical_event->add_properties(
                summary => $event->name,
                description => $event->description,
                dtstart => Date::ICal->new( epoch => $time->start_time->epoch)->ical,
                );

            $ical_event->add_properties(location => join(' ', $event->venue->name//'(no name)', $event->venue->address//'(no address)'))
                if $event->venue;

            ## geo data is bork! it backslashes the semi-colon
            $ical_event->add_properties(geo => join(";", ($event->venue->latitude, $event->venue->longitude)))
                if 0 and $event->venue && $event->venue->latitude;

            $ical_event->add_properties(url => $event->url)
                if ($event->url);
            
            $ical_event->add_properties(dtend => Date::ICal->new( epoch => $time->end_time->epoch)->ical)
                if $time->get_column('end_time');
            
            $ical->add_entry($ical_event);
        }
    }
    return $ical->as_string;
}

sub get_homepage {
    my ($self, $events_rs) = @_;

    my $now = DateTime->now();
    return $self->get_monthpage($events_rs, $now->year, $now->month);
}

sub get_monthpage {
    my ($self, $events_rs, $year, $month) = @_;
    my $output = '';

    my $schema = $self->schema;
    my $dtf = $schema->storage->datetime_parser;

    my $in_month = DateTime->now;
    $in_month->set( month => $month ) if($month && $month !~ /\D/);
    $in_month->set( year => $year ) if($year && $year !~ /\D/);
    
    my $start_date = DateTime->new(year => $in_month->year,
                                   month => $in_month->month,
                                   day => 1,
        );
    my $end_date = DateTime->new(year => $in_month->year,
                                 month => $in_month->month+1,
                                 day => 1,
        );
    
    my $start = $dtf->format_datetime($start_date);
    my $end = $dtf->format_datetime($end_date);

    $events_rs = $events_rs->search({
        'times.start_time' => {-between => [$start, $end]},
                                    },
                                    {
                                        prefetch => ['venue', { event_acts => 'act' }],
                                    });
    
#                                           order_by => [{ '-asc' => 'start_time' }],
#    my $json = to_json(\%events) or die "Couldn't to_json?";

    my $next_month = $end_date->clone->add(days => 1);
    my $prev_month = $start_date->clone->subtract(days => 1);
    $self->tt->process('monthpage.tt', {
        static_uri => $self->static_url,
        base_uri   => $self->base_uri,
        events => $events_rs->by_day,
        start_date => $start_date,
        prev_month => $prev_month,
        next_month => $next_month,
                       }, \$output) || die $self->tt->error;

    print STDERR "Homepage: $output\n";
    return $output;
}

sub get_venuepage {
    my ($self, $venue) = @_;

    print STDERR "Venue: ", $venue->name, "\n";

    my $output = '';
    $self->tt->process('venuepage.tt', {
        static_uri => $self->static_url,
        base_uri   => $self->base_uri,
        venue      => $venue,
                              }, \$output) || die $self->tt->error;
    return $output;
}

Events::Web->run_if_script();
