use utf8;
package Mobilizon::Schema::Result::Comment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Comment

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

=head1 TABLE: C<comments>

=cut

__PACKAGE__->table("comments");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'comments_id_seq'

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 text

  data_type: 'text'
  is_nullable: 1

=head2 actor_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 event_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 in_reply_to_comment_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 origin_comment_id

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

=head2 local

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=head2 uuid

  data_type: 'uuid'
  is_nullable: 1
  size: 16

=head2 attributed_to_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 visibility

  data_type: 'enum'
  extra: {custom_type_name => "comment_visibility",list => ["public","unlisted","private","moderated","invite"]}
  is_nullable: 1

=head2 deleted_at

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=head2 edits

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 discussion_id

  data_type: 'uuid'
  is_foreign_key: 1
  is_nullable: 1
  size: 16

=head2 published_at

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=head2 is_announcement

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 language

  data_type: 'varchar'
  default_value: 'und'
  is_nullable: 1
  size: 255

=head2 conversation_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "comments_id_seq",
  },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "text",
  { data_type => "text", is_nullable => 1 },
  "actor_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "event_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "in_reply_to_comment_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "origin_comment_id",
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
  "local",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "uuid",
  { data_type => "uuid", is_nullable => 1, size => 16 },
  "attributed_to_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "visibility",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "comment_visibility",
      list => ["public", "unlisted", "private", "moderated", "invite"],
    },
    is_nullable => 1,
  },
  "deleted_at",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
  "edits",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "discussion_id",
  { data_type => "uuid", is_foreign_key => 1, is_nullable => 1, size => 16 },
  "published_at",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
  "is_announcement",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "language",
  {
    data_type => "varchar",
    default_value => "und",
    is_nullable => 1,
    size => 255,
  },
  "conversation_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<comments_url_index>

=over 4

=item * L</url>

=back

=cut

__PACKAGE__->add_unique_constraint("comments_url_index", ["url"]);

=head1 RELATIONS

=head2 actor

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "actor",
  "Mobilizon::Schema::Result::Actor",
  { id => "actor_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 actor_2

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "actor_2",
  "Mobilizon::Schema::Result::Actor",
  { id => "actor_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "NO ACTION",
  },
);

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
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 comments_in_reply_to_comment

Type: has_many

Related object: L<Mobilizon::Schema::Result::Comment>

=cut

__PACKAGE__->has_many(
  "comments_in_reply_to_comment",
  "Mobilizon::Schema::Result::Comment",
  { "foreign.in_reply_to_comment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 comments_medias

Type: has_many

Related object: L<Mobilizon::Schema::Result::CommentsMedia>

=cut

__PACKAGE__->has_many(
  "comments_medias",
  "Mobilizon::Schema::Result::CommentsMedia",
  { "foreign.comment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 comments_origin_comments

Type: has_many

Related object: L<Mobilizon::Schema::Result::Comment>

=cut

__PACKAGE__->has_many(
  "comments_origin_comments",
  "Mobilizon::Schema::Result::Comment",
  { "foreign.origin_comment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 comments_tags

Type: has_many

Related object: L<Mobilizon::Schema::Result::CommentsTag>

=cut

__PACKAGE__->has_many(
  "comments_tags",
  "Mobilizon::Schema::Result::CommentsTag",
  { "foreign.comment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 conversation

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Conversation>

=cut

__PACKAGE__->belongs_to(
  "conversation",
  "Mobilizon::Schema::Result::Conversation",
  { id => "conversation_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "NO ACTION",
  },
);

=head2 conversations_last_comments

Type: has_many

Related object: L<Mobilizon::Schema::Result::Conversation>

=cut

__PACKAGE__->has_many(
  "conversations_last_comments",
  "Mobilizon::Schema::Result::Conversation",
  { "foreign.last_comment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 conversations_origin_comments

Type: has_many

Related object: L<Mobilizon::Schema::Result::Conversation>

=cut

__PACKAGE__->has_many(
  "conversations_origin_comments",
  "Mobilizon::Schema::Result::Conversation",
  { "foreign.origin_comment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 discussion

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Discussion>

=cut

__PACKAGE__->belongs_to(
  "discussion",
  "Mobilizon::Schema::Result::Discussion",
  { id => "discussion_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 discussions

Type: has_many

Related object: L<Mobilizon::Schema::Result::Discussion>

=cut

__PACKAGE__->has_many(
  "discussions",
  "Mobilizon::Schema::Result::Discussion",
  { "foreign.last_comment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Event>

=cut

__PACKAGE__->belongs_to(
  "event",
  "Mobilizon::Schema::Result::Event",
  { id => "event_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "NO ACTION",
  },
);

=head2 in_reply_to_comment

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Comment>

=cut

__PACKAGE__->belongs_to(
  "in_reply_to_comment",
  "Mobilizon::Schema::Result::Comment",
  { id => "in_reply_to_comment_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "NO ACTION",
  },
);

=head2 mentions

Type: has_many

Related object: L<Mobilizon::Schema::Result::Mention>

=cut

__PACKAGE__->has_many(
  "mentions",
  "Mobilizon::Schema::Result::Mention",
  { "foreign.comment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 origin_comment

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Comment>

=cut

__PACKAGE__->belongs_to(
  "origin_comment",
  "Mobilizon::Schema::Result::Comment",
  { id => "origin_comment_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "NO ACTION",
  },
);

=head2 reports_comments

Type: has_many

Related object: L<Mobilizon::Schema::Result::ReportsComment>

=cut

__PACKAGE__->has_many(
  "reports_comments",
  "Mobilizon::Schema::Result::ReportsComment",
  { "foreign.comment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 medias

Type: many_to_many

Composing rels: L</comments_medias> -> media

=cut

__PACKAGE__->many_to_many("medias", "comments_medias", "media");

=head2 tags

Type: many_to_many

Composing rels: L</comments_tags> -> tag

=cut

__PACKAGE__->many_to_many("tags", "comments_tags", "tag");


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:twh58x4uhp81Js49SQCYHw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
