package PubBoards::Schema::Result::OSCodes;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('oscodes');
__PACKAGE__->add_columns(
    code => {
        data_type => 'varchar',
        size => 8,
    },
    latitude => {
        data_type => 'float',
    },
    longitude => {
        data_type => 'float',
    }
    );

__PACKAGE__->set_primary_key('code');

1;
