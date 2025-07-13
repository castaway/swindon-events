package Mobilizon::Schema::ResultSet::Address;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

sub new_result {
    my ($self, $col_data) = @_;

    #print STDERR "Changing geom\n";
    my $ll = $col_data->{geom};
    my ($lat, $lng) = split(/;/, $ll);
    
    if($lat && $lng) {
        $col_data->{geom} = \"st_setsrid(st_makepoint(${lng}::double precision, ${lat}::double precision), 4326)";
    }
    $self->next::method($col_data);
}

1;
