use utf8;
package Mobilizon::Schema::Result::Session;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Session

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

=head1 TABLE: C<sessions>

=cut

__PACKAGE__->table("sessions");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'sessions_id_seq'

=head2 title

  data_type: 'text'
  is_nullable: 0

=head2 subtitle

  data_type: 'text'
  is_nullable: 1

=head2 short_abstract

  data_type: 'text'
  is_nullable: 1

=head2 long_abstract

  data_type: 'text'
  is_nullable: 1

=head2 language

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 slides_url

  data_type: 'text'
  is_nullable: 1

=head2 videos_urls

  data_type: 'text'
  is_nullable: 1

=head2 audios_urls

  data_type: 'text'
  is_nullable: 1

=head2 event_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 track_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 speaker_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 inserted_at

  data_type: 'timestamp'
  is_nullable: 0
  set_on_create: 1
  size: 0

=head2 updated_at

  data_type: 'timestamp'
  is_nullable: 0
  set_on_create: 1
  set_on_update: 1
  size: 0

=head2 begins_on

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=head2 ends_on

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "sessions_id_seq",
  },
  "title",
  { data_type => "text", is_nullable => 0 },
  "subtitle",
  { data_type => "text", is_nullable => 1 },
  "short_abstract",
  { data_type => "text", is_nullable => 1 },
  "long_abstract",
  { data_type => "text", is_nullable => 1 },
  "language",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "slides_url",
  { data_type => "text", is_nullable => 1 },
  "videos_urls",
  { data_type => "text", is_nullable => 1 },
  "audios_urls",
  { data_type => "text", is_nullable => 1 },
  "event_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "track_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "speaker_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "inserted_at",
  { data_type => "timestamp", is_nullable => 0, set_on_create => 1, size => 0 },
  "updated_at",
  {
    data_type => "timestamp",
    is_nullable => 0,
    set_on_create => 1,
    set_on_update => 1,
    size => 0,
  },
  "begins_on",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
  "ends_on",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

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

=head2 speaker

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "speaker",
  "Mobilizon::Schema::Result::Actor",
  { id => "speaker_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "NO ACTION",
  },
);

=head2 track

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Track>

=cut

__PACKAGE__->belongs_to(
  "track",
  "Mobilizon::Schema::Result::Track",
  { id => "track_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BMvgDA3vuXYoaoCQNX5r3A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
