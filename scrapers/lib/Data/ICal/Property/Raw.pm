package Data::ICal::Property::Raw;
use strictures 1;

use base 'Data::ICal::Property';

sub _value_as_string {
    my $self  = shift;
    my $key   = shift;
    my $value = defined( $self->value() ) ? $self->value() : '';
 
    return $value;
}

'with a rusty spoon';
