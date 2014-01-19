package Event::Schema::Result::Act;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('acts');
__PACKAGE__->load_components('InflateColumn::DateTime');
__PACKAGE__->add_columns(
    id => {
        data_type => 'integer',
        is_auto_increment => 1,
    },
    name => {
        data_type => 'varchar',
        size => 255,
    },
    description => {
        data_type => 'text',
        is_nullable => 1,
    },
    );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many('events', 'Event::Schema::Result::ActEvents', 'act_id');

1;
