use utf8;
package Mobilizon::Schema::Result::EventsMedia;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::EventsMedia

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::UUIDColumns>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "UUIDColumns");

=head1 TABLE: C<events_medias>

=cut

__PACKAGE__->table("events_medias");

=head1 ACCESSORS

=head2 event_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 media_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "event_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "media_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</event_id>

=item * L</media_id>

=back

=cut

__PACKAGE__->set_primary_key("event_id", "media_id");

=head1 RELATIONS

=head2 event

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Event>

=cut

__PACKAGE__->belongs_to(
  "event",
  "Mobilizon::Schema::Result::Event",
  { id => "event_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 media

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Media>

=cut

__PACKAGE__->belongs_to(
  "media",
  "Mobilizon::Schema::Result::Media",
  { id => "media_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:08:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/jKOsJ8uLQWVHXPCpAZBAw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
