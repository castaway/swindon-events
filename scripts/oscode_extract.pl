#!/usr/bin/perl

use strict;
use warnings;

use local::lib '/usr/src/perl/libs/events/perl5';

use Geo::UK::Postcode::CodePointOpen;
use Data::Dumper;
use Config::General;
use Moo;
use Storable 'nstore';

use lib '/mnt/shared/projects/events/lib', '/usr/src/events/lib';
use PubBoards::Schema;

has 'app_cwd' => ( is => 'ro', default => sub { $ENV{EVENTS_HOME} || '/mnt/shared/projects/events' . '/scripts/'});
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
                     my $dbname = $self->config->{Setup}{dbname};
                     my $dbuser = $self->config->{Setup}{dbuser};
                     my $dbpass = $self->config->{Setup}{dbpass};

                     my $dsn = "dbi:$dbi:$dbname";

                     print "Trying to connect to dsn $dsn\n";

                     PubBoards::Schema->connect($dsn, $dbuser, $dbpass, { pg_enable_utf8 => 1});
                 });

my $self = main->new;
my $schema = $self->schema;
my $oscodes_rs = $schema->resultset('OSCodes');

my $code_point_open = Geo::UK::Postcode::CodePointOpen->new( path => $self->app_cwd . "../scrapers/oscodes/" );
 
my $metadata = $code_point_open->metadata();

my %pc_data = ();
my $iterator = $code_point_open->read_iterator(include_lat_long => 1);
while ( my $pc = $iterator->() ) {
    print Dumper($pc);
    next if !$pc->{Latitude}; # !?
    $pc->{Postcode} =~ s/\s+//g;
    $oscodes_rs->update_or_create({ code => uc($pc->{Postcode}),
                                    latitude => $pc->{Latitude},
                                    longitude => $pc->{Longitude} });
    next if $pc->{Postcode} !~ /^sn/i;
    $pc_data{ uc( $pc->{Postcode} ) } = [ $pc->{Latitude}, $pc->{Longitude} ];
}

nstore \%pc_data, 'oscodes.store';

 
