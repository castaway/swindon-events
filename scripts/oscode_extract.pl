use Geo::UK::Postcode::CodePointOpen;
use Data::Dumper;
use Storable 'nstore';
use strict;
use warnings;
 
my $code_point_open = Geo::UK::Postcode::CodePointOpen->new( path => "oscodes/" );
 
my $metadata = $code_point_open->metadata();

my %pc_data = ();
my $iterator = $code_point_open->read_iterator(include_lat_long => 1);
while ( my $pc = $iterator->() ) {
    print Dumper($pc);
    $pc_data{ $pc->{Postcode} } = [ $pc->{Latitude}, $pc->{Longitude} ];
}

nstore \%pc_data, 'oscodes.store';

 
