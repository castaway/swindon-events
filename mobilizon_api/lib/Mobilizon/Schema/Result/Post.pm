use utf8;
package Mobilizon::Schema::Result::Post;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Post

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

=head1 TABLE: C<posts>

=cut

__PACKAGE__->table("posts");

=head1 ACCESSORS

=head2 id

  data_type: 'uuid'
  is_nullable: 0
  size: 16

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 slug

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 body

  data_type: 'text'
  is_nullable: 1

=head2 draft

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 local

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=head2 visibility

  data_type: 'enum'
  default_value: 'public'
  extra: {custom_type_name => "post_visibility",list => ["public","unlisted","restricted","private"]}
  is_nullable: 1

=head2 publish_at

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=head2 author_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 attributed_to_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 picture_id

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

=head2 language

  data_type: 'varchar'
  default_value: 'und'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "uuid", is_nullable => 0, size => 16 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "slug",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "body",
  { data_type => "text", is_nullable => 1 },
  "draft",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "local",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "visibility",
  {
    data_type => "enum",
    default_value => "public",
    extra => {
      custom_type_name => "post_visibility",
      list => ["public", "unlisted", "restricted", "private"],
    },
    is_nullable => 1,
  },
  "publish_at",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
  "author_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "attributed_to_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "picture_id",
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
  "language",
  {
    data_type => "varchar",
    default_value => "und",
    is_nullable => 1,
    size => 255,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<posts_url_index>

=over 4

=item * L</url>

=back

=cut

__PACKAGE__->add_unique_constraint("posts_url_index", ["url"]);

=head1 RELATIONS

=head2 attributed_to

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "attributed_to",
  "Mobilizon::Schema::Result::Actor",
  { id => "attributed_to_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "NO ACTION",
  },
);

=head2 author

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "author",
  "Mobilizon::Schema::Result::Actor",
  { id => "author_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "NO ACTION",
  },
);

=head2 picture

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Media>

=cut

__PACKAGE__->belongs_to(
  "picture",
  "Mobilizon::Schema::Result::Media",
  { id => "picture_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "NO ACTION",
  },
);

=head2 posts_medias

Type: has_many

Related object: L<Mobilizon::Schema::Result::PostsMedia>

=cut

__PACKAGE__->has_many(
  "posts_medias",
  "Mobilizon::Schema::Result::PostsMedia",
  { "foreign.post_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 posts_tags

Type: has_many

Related object: L<Mobilizon::Schema::Result::PostsTag>

=cut

__PACKAGE__->has_many(
  "posts_tags",
  "Mobilizon::Schema::Result::PostsTag",
  { "foreign.post_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 medias

Type: many_to_many

Composing rels: L</posts_medias> -> media

=cut

__PACKAGE__->many_to_many("medias", "posts_medias", "media");

=head2 tags

Type: many_to_many

Composing rels: L</posts_tags> -> tag

=cut

__PACKAGE__->many_to_many("tags", "posts_tags", "tag");


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1PwOUjIBbi4JgF85uRUgkw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
