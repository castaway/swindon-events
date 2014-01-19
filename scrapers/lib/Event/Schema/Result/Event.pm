package Event::Schema::Result::Event;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('events');
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
    description => {
        data_type => 'text',
        is_nullable => 1,
    },
    start_time => {
        data_type => 'datetime',
        is_nullable => 1,
    },
    venue_id => {
        data_type => 'integer',
        is_nullable => 1,
    },
    url => {
        data_type => 'varchar',
        size => '1024',
        is_nullable => 1,
    },
    );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to('venue', 'Event::Schema::Result::Venue', 'venue_id', { join_type => 'left'});
__PACKAGE__->has_many('event_acts', 'Event::Schema::Result::ActEvents', 'event_id');

sub start_hour {
    my ($self) = @_;

    return sprintf("%02d:%02d",
                  $self->start_time->hour,
                  $self->start_time->minute);
}

1;
