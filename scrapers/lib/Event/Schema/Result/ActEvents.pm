package Event::Schema::Result::ActEvents;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('act_events');
__PACKAGE__->add_columns(
    event_id => {
        data_type => 'varchar',
        size => 255,
    },
    act_id => {
        data_type => 'integer',
    },
    position => {
        data_type => 'integer',
        is_nullable => 1,
    },
    );

__PACKAGE__->set_primary_key('event_id', 'act_id');
__PACKAGE__->belongs_to('event', 'Event::Schema::Result::Event', 'event_id');
__PACKAGE__->belongs_to('act', 'Event::Schema::Result::Act', 'act_id');


1;
