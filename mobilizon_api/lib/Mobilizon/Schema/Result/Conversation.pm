use utf8;
package Mobilizon::Schema::Result::Conversation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Conversation

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

=head1 TABLE: C<conversations>

=cut

__PACKAGE__->table("conversations");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'conversations_id_seq'

=head2 event_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 origin_comment_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 last_comment_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

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
    sequence          => "conversations_id_seq",
  },
  "event_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "origin_comment_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "last_comment_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
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

=head1 RELATIONS

=head2 comments

Type: has_many

Related object: L<Mobilizon::Schema::Result::Comment>

=cut

__PACKAGE__->has_many(
  "comments",
  "Mobilizon::Schema::Result::Comment",
  { "foreign.conversation_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 conversation_participants

Type: has_many

Related object: L<Mobilizon::Schema::Result::ConversationParticipant>

=cut

__PACKAGE__->has_many(
  "conversation_participants",
  "Mobilizon::Schema::Result::ConversationParticipant",
  { "foreign.conversation_id" => "self.id" },
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

=head2 last_comment

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Comment>

=cut

__PACKAGE__->belongs_to(
  "last_comment",
  "Mobilizon::Schema::Result::Comment",
  { id => "last_comment_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 origin_comment

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Comment>

=cut

__PACKAGE__->belongs_to(
  "origin_comment",
  "Mobilizon::Schema::Result::Comment",
  { id => "origin_comment_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:O6VGu/SiqnIMu94hWLd79w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
