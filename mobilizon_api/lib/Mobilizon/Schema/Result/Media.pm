use utf8;
package Mobilizon::Schema::Result::Media;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Media

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

=head1 TABLE: C<medias>

=cut

__PACKAGE__->table("medias");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'pictures_id_seq'

=head2 file

  data_type: 'jsonb'
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

=head2 actor_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 metadata

  data_type: 'jsonb'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "pictures_id_seq",
  },
  "file",
  { data_type => "jsonb", is_nullable => 1 },
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
  "actor_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "metadata",
  { data_type => "jsonb", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 actor

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "actor",
  "Mobilizon::Schema::Result::Actor",
  { id => "actor_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 admin_settings_medias

Type: has_many

Related object: L<Mobilizon::Schema::Result::AdminSettingsMedia>

=cut

__PACKAGE__->has_many(
  "admin_settings_medias",
  "Mobilizon::Schema::Result::AdminSettingsMedia",
  { "foreign.media_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 comments_medias

Type: has_many

Related object: L<Mobilizon::Schema::Result::CommentsMedia>

=cut

__PACKAGE__->has_many(
  "comments_medias",
  "Mobilizon::Schema::Result::CommentsMedia",
  { "foreign.media_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events_2s

Type: has_many

Related object: L<Mobilizon::Schema::Result::Event>

=cut

__PACKAGE__->has_many(
  "events_2s",
  "Mobilizon::Schema::Result::Event",
  { "foreign.picture_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events_medias

Type: has_many

Related object: L<Mobilizon::Schema::Result::EventsMedia>

=cut

__PACKAGE__->has_many(
  "events_medias",
  "Mobilizon::Schema::Result::EventsMedia",
  { "foreign.media_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 posts_2s

Type: has_many

Related object: L<Mobilizon::Schema::Result::Post>

=cut

__PACKAGE__->has_many(
  "posts_2s",
  "Mobilizon::Schema::Result::Post",
  { "foreign.picture_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 posts_medias

Type: has_many

Related object: L<Mobilizon::Schema::Result::PostsMedia>

=cut

__PACKAGE__->has_many(
  "posts_medias",
  "Mobilizon::Schema::Result::PostsMedia",
  { "foreign.media_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 comments

Type: many_to_many

Composing rels: L</comments_medias> -> comment

=cut

__PACKAGE__->many_to_many("comments", "comments_medias", "comment");

=head2 events

Type: many_to_many

Composing rels: L</events_medias> -> event

=cut

__PACKAGE__->many_to_many("events", "events_medias", "event");

=head2 posts

Type: many_to_many

Composing rels: L</posts_medias> -> post

=cut

__PACKAGE__->many_to_many("posts", "posts_medias", "post");


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3+9Atk09Cl2G7iCLUJGM9A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
