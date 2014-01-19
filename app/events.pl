#!/usr/bin/env perl
package Events::Web;

use local::lib '/usr/src/perl/libs/events/perl5';
use JSON;
use Template;
use Path::Class;
use Config::General;
use Web::Simple;

use lib '/mnt/shared/projects/events/scrapers/lib';
use Event::Schema;

has 'app_cwd' => ( is => 'ro', default => sub {'/mnt/shared/projects/events/app/'});
#has 'static_url' => ( is => 'ro', default => sub {'http://192.168.42.2:7778'});
has 'static_url' => ( is => 'ro', default => sub {'http://desert-island.me.uk/events'});
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

                     Event::Schema->connect($dsn);
                 });

sub _build_tt {
    my ($self) = @_;

    return Template->new({ 
        INCLUDE_PATH => dir($self->app_cwd)->subdir('templates')->stringify,
                         });
}

sub dispatch_request {
    my ($self) = @_;

    sub (GET + /) {
        print STDERR "Index page\n";
        return [ 200, [ 'Content-type', 'text/html' ], [ $self->get_homepage ] ];
    }
}

sub get_homepage {
    my ($self) = @_;
    my $output = '';

    my $schema = $self->schema;
    my $dtf = $schema->storage->datetime_parser;

    my $now = DateTime->now;
    my $start_date = DateTime->new(year => $now->year,
                                   month => $now->month,
                                   day => 1,
        );
    my $end_date = DateTime->new(year => $now->year,
                                 month => $now->month+1,
                                 day => 1,
        );
    
    my $start = $dtf->format_datetime($start_date);
    my $end = $dtf->format_datetime($end_date);

    my $events_rs = $schema->resultset('Event')->search({
                                                            start_time => {-between => [$start, $end]},
                                                        },
                                                        {
                                                            prefetch => ['venue', { event_acts => 'act' }],
                                                            order_by => [{ '-asc' => 'start_time' }],
                                                        });
    
    my %events;

    while (my $event_row = $events_rs->next) {
        push @{$events{$event_row->start_time->dmy}}, { 
            row => $event_row, 
            date => $event_row->start_time,
            ended => $event_row->start_time < DateTime->now,
            today => $event_row->start_time->ymd eq DateTime->now->ymd,
        };
    }

#    my $json = to_json(\%events) or die "Couldn't to_json?";

    $self->tt->process('homepage.tt', {
        static_uri => $self->static_url,
#        initial_caldata_json => to_json(\%events),
        events => \%events,
        start_date => $start_date,
                       }, \$output) || die $self->tt->error;

    print STDERR "Homepage: $output\n";
    return $output;
}

Events::Web->run_if_script();
