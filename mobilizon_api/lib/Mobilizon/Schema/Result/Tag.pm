use utf8;
package Mobilizon::Schema::Result::Tag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Tag

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

=head1 TABLE: C<tags>

=cut

__PACKAGE__->table("tags");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'tags_id_seq'

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 slug

  data_type: 'varchar'
  is_nullable: 0
  size: 255

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

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "tags_id_seq",
  },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "slug",
  { data_type => "varchar", is_nullable => 0, size => 255 },
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
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<tags_slug_index>

=over 4

=item * L</slug>

=back

=cut

__PACKAGE__->add_unique_constraint("tags_slug_index", ["slug"]);

=head1 RELATIONS

=head2 comments_tags

Type: has_many

Related object: L<Mobilizon::Schema::Result::CommentsTag>

=cut

__PACKAGE__->has_many(
  "comments_tags",
  "Mobilizon::Schema::Result::CommentsTag",
  { "foreign.tag_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events_tags

Type: has_many

Related object: L<Mobilizon::Schema::Result::EventsTag>

=cut

__PACKAGE__->has_many(
  "events_tags",
  "Mobilizon::Schema::Result::EventsTag",
  { "foreign.tag_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 posts_tags

Type: has_many

Related object: L<Mobilizon::Schema::Result::PostsTag>

=cut

__PACKAGE__->has_many(
  "posts_tags",
  "Mobilizon::Schema::Result::PostsTag",
  { "foreign.tag_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tag_relations_links

Type: has_many

Related object: L<Mobilizon::Schema::Result::TagRelation>

=cut

__PACKAGE__->has_many(
  "tag_relations_links",
  "Mobilizon::Schema::Result::TagRelation",
  { "foreign.link_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tag_relations_tags

Type: has_many

Related object: L<Mobilizon::Schema::Result::TagRelation>

=cut

__PACKAGE__->has_many(
  "tag_relations_tags",
  "Mobilizon::Schema::Result::TagRelation",
  { "foreign.tag_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 comments

Type: many_to_many

Composing rels: L</comments_tags> -> comment

=cut

__PACKAGE__->many_to_many("comments", "comments_tags", "comment");

=head2 posts

Type: many_to_many

Composing rels: L</posts_tags> -> post

=cut

__PACKAGE__->many_to_many("posts", "posts_tags", "post");


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:666fh+7CQhI9Vnesnyn3kQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
