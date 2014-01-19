package Event::Schema::Result::Venue;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('venues');
__PACKAGE__->load_components('InflateColumn::DateTime');
__PACKAGE__->add_columns(
    id => {
        data_type => 'varchar',
        size => 255,
    },
    name => {
        data_type => 'varchar',
        size => 255,
    },
    latitude => {
        data_type => 'float',
        is_nullable => 1,
    },
    longitude => {
        data_type => 'float',
        is_nullable => 1,
    },
    address => {
        data_type => 'text',
        is_nullable => 1,
    },
    last_verified => {
        data_type => 'datetime',
        default_value => \'CURRENT_TIMESTAMP',
    },
    );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint('name' => ['name']);
__PACKAGE__->has_many('events', 'Event::Schema::Result::Event', 'venue_id');

1;
