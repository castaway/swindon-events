use utf8;
package Mobilizon::Schema::Result::Actor;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Actor

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

=head1 TABLE: C<actors>

=cut

__PACKAGE__->table("actors");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'accounts_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 domain

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 preferred_username

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 summary

  data_type: 'text'
  is_nullable: 1

=head2 keys

  data_type: 'text'
  is_nullable: 1

=head2 suspended

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 url

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

=head2 inbox_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 outbox_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 following_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 followers_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 shared_inbox_url

  data_type: 'varchar'
  default_value: null
  is_nullable: 1
  size: 255

=head2 type

  data_type: 'enum'
  extra: {custom_type_name => "actor_type",list => ["Person","Application","Group","Organization","Service"]}
  is_nullable: 1

=head2 manually_approves_followers

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=head2 user_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 openness

  data_type: 'enum'
  default_value: 'moderated'
  extra: {custom_type_name => "actor_openness",list => ["invite_only","moderated","open"]}
  is_nullable: 1

=head2 visibility

  data_type: 'enum'
  default_value: 'private'
  extra: {custom_type_name => "actor_visibility",list => ["public","unlisted","restricted","private"]}
  is_nullable: 1

=head2 avatar

  data_type: 'jsonb'
  is_nullable: 1

=head2 banner

  data_type: 'jsonb'
  is_nullable: 1

=head2 last_refreshed_at

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=head2 members_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 resources_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 todos_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 posts_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 events_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 discussions_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 physical_address_id

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
    sequence          => "accounts_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "domain",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "preferred_username",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "summary",
  { data_type => "text", is_nullable => 1 },
  "keys",
  { data_type => "text", is_nullable => 1 },
  "suspended",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "url",
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
  "inbox_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "outbox_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "following_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "followers_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "shared_inbox_url",
  {
    data_type => "varchar",
    default_value => \"null",
    is_nullable => 1,
    size => 255,
  },
  "type",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "actor_type",
      list => ["Person", "Application", "Group", "Organization", "Service"],
    },
    is_nullable => 1,
  },
  "manually_approves_followers",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
  "user_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "openness",
  {
    data_type => "enum",
    default_value => "moderated",
    extra => {
      custom_type_name => "actor_openness",
      list => ["invite_only", "moderated", "open"],
    },
    is_nullable => 1,
  },
  "visibility",
  {
    data_type => "enum",
    default_value => "private",
    extra => {
      custom_type_name => "actor_visibility",
      list => ["public", "unlisted", "restricted", "private"],
    },
    is_nullable => 1,
  },
  "avatar",
  { data_type => "jsonb", is_nullable => 1 },
  "banner",
  { data_type => "jsonb", is_nullable => 1 },
  "last_refreshed_at",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
  "members_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "resources_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "todos_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "posts_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "events_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "discussions_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "physical_address_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<actors_preferred_username_domain_type_index>

=over 4

=item * L</preferred_username>

=item * L</domain>

=item * L</type>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "actors_preferred_username_domain_type_index",
  ["preferred_username", "domain", "type"],
);

=head2 C<actors_url_index>

=over 4

=item * L</url>

=back

=cut

__PACKAGE__->add_unique_constraint("actors_url_index", ["url"]);

=head1 RELATIONS

=head2 activities_authors

Type: has_many

Related object: L<Mobilizon::Schema::Result::Activity>

=cut

__PACKAGE__->has_many(
  "activities_authors",
  "Mobilizon::Schema::Result::Activity",
  { "foreign.author_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 activities_groups

Type: has_many

Related object: L<Mobilizon::Schema::Result::Activity>

=cut

__PACKAGE__->has_many(
  "activities_groups",
  "Mobilizon::Schema::Result::Activity",
  { "foreign.group_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 admin_action_logs

Type: has_many

Related object: L<Mobilizon::Schema::Result::AdminActionLog>

=cut

__PACKAGE__->has_many(
  "admin_action_logs",
  "Mobilizon::Schema::Result::AdminActionLog",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bots

Type: has_many

Related object: L<Mobilizon::Schema::Result::Bot>

=cut

__PACKAGE__->has_many(
  "bots",
  "Mobilizon::Schema::Result::Bot",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 comments_actors

Type: has_many

Related object: L<Mobilizon::Schema::Result::Comment>

=cut

__PACKAGE__->has_many(
  "comments_actors",
  "Mobilizon::Schema::Result::Comment",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 comments_actors_2s

Type: has_many

Related object: L<Mobilizon::Schema::Result::Comment>

=cut

__PACKAGE__->has_many(
  "comments_actors_2s",
  "Mobilizon::Schema::Result::Comment",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 comments_attributed_to

Type: has_many

Related object: L<Mobilizon::Schema::Result::Comment>

=cut

__PACKAGE__->has_many(
  "comments_attributed_to",
  "Mobilizon::Schema::Result::Comment",
  { "foreign.attributed_to_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 conversation_participants

Type: has_many

Related object: L<Mobilizon::Schema::Result::ConversationParticipant>

=cut

__PACKAGE__->has_many(
  "conversation_participants",
  "Mobilizon::Schema::Result::ConversationParticipant",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 discussions_actors

Type: has_many

Related object: L<Mobilizon::Schema::Result::Discussion>

=cut

__PACKAGE__->has_many(
  "discussions_actors",
  "Mobilizon::Schema::Result::Discussion",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 discussions_creators

Type: has_many

Related object: L<Mobilizon::Schema::Result::Discussion>

=cut

__PACKAGE__->has_many(
  "discussions_creators",
  "Mobilizon::Schema::Result::Discussion",
  { "foreign.creator_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_contacts

Type: has_many

Related object: L<Mobilizon::Schema::Result::EventContact>

=cut

__PACKAGE__->has_many(
  "event_contacts",
  "Mobilizon::Schema::Result::EventContact",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events_attributed_to

Type: has_many

Related object: L<Mobilizon::Schema::Result::Event>

=cut

__PACKAGE__->has_many(
  "events_attributed_to",
  "Mobilizon::Schema::Result::Event",
  { "foreign.attributed_to_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events_organizer_actors

Type: has_many

Related object: L<Mobilizon::Schema::Result::Event>

=cut

__PACKAGE__->has_many(
  "events_organizer_actors",
  "Mobilizon::Schema::Result::Event",
  { "foreign.organizer_actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 feed_tokens

Type: has_many

Related object: L<Mobilizon::Schema::Result::FeedToken>

=cut

__PACKAGE__->has_many(
  "feed_tokens",
  "Mobilizon::Schema::Result::FeedToken",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 followers_actors

Type: has_many

Related object: L<Mobilizon::Schema::Result::Follower>

=cut

__PACKAGE__->has_many(
  "followers_actors",
  "Mobilizon::Schema::Result::Follower",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 followers_target_actors

Type: has_many

Related object: L<Mobilizon::Schema::Result::Follower>

=cut

__PACKAGE__->has_many(
  "followers_target_actors",
  "Mobilizon::Schema::Result::Follower",
  { "foreign.target_actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 instance_actors

Type: has_many

Related object: L<Mobilizon::Schema::Result::InstanceActor>

=cut

__PACKAGE__->has_many(
  "instance_actors",
  "Mobilizon::Schema::Result::InstanceActor",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 medias

Type: has_many

Related object: L<Mobilizon::Schema::Result::Media>

=cut

__PACKAGE__->has_many(
  "medias",
  "Mobilizon::Schema::Result::Media",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 members_actors

Type: has_many

Related object: L<Mobilizon::Schema::Result::Member>

=cut

__PACKAGE__->has_many(
  "members_actors",
  "Mobilizon::Schema::Result::Member",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 members_invited_by

Type: has_many

Related object: L<Mobilizon::Schema::Result::Member>

=cut

__PACKAGE__->has_many(
  "members_invited_by",
  "Mobilizon::Schema::Result::Member",
  { "foreign.invited_by_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 members_parents

Type: has_many

Related object: L<Mobilizon::Schema::Result::Member>

=cut

__PACKAGE__->has_many(
  "members_parents",
  "Mobilizon::Schema::Result::Member",
  { "foreign.parent_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 mentions

Type: has_many

Related object: L<Mobilizon::Schema::Result::Mention>

=cut

__PACKAGE__->has_many(
  "mentions",
  "Mobilizon::Schema::Result::Mention",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 participants

Type: has_many

Related object: L<Mobilizon::Schema::Result::Participant>

=cut

__PACKAGE__->has_many(
  "participants",
  "Mobilizon::Schema::Result::Participant",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 physical_address

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Address>

=cut

__PACKAGE__->belongs_to(
  "physical_address",
  "Mobilizon::Schema::Result::Address",
  { id => "physical_address_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 posts_attributed_to

Type: has_many

Related object: L<Mobilizon::Schema::Result::Post>

=cut

__PACKAGE__->has_many(
  "posts_attributed_to",
  "Mobilizon::Schema::Result::Post",
  { "foreign.attributed_to_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 posts_authors

Type: has_many

Related object: L<Mobilizon::Schema::Result::Post>

=cut

__PACKAGE__->has_many(
  "posts_authors",
  "Mobilizon::Schema::Result::Post",
  { "foreign.author_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 report_notes

Type: has_many

Related object: L<Mobilizon::Schema::Result::ReportNote>

=cut

__PACKAGE__->has_many(
  "report_notes",
  "Mobilizon::Schema::Result::ReportNote",
  { "foreign.moderator_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reports_managers

Type: has_many

Related object: L<Mobilizon::Schema::Result::Report>

=cut

__PACKAGE__->has_many(
  "reports_managers",
  "Mobilizon::Schema::Result::Report",
  { "foreign.manager_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reports_reported

Type: has_many

Related object: L<Mobilizon::Schema::Result::Report>

=cut

__PACKAGE__->has_many(
  "reports_reported",
  "Mobilizon::Schema::Result::Report",
  { "foreign.reported_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reports_reporters

Type: has_many

Related object: L<Mobilizon::Schema::Result::Report>

=cut

__PACKAGE__->has_many(
  "reports_reporters",
  "Mobilizon::Schema::Result::Report",
  { "foreign.reporter_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 resource_actors

Type: has_many

Related object: L<Mobilizon::Schema::Result::Resource>

=cut

__PACKAGE__->has_many(
  "resource_actors",
  "Mobilizon::Schema::Result::Resource",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 resource_creators

Type: has_many

Related object: L<Mobilizon::Schema::Result::Resource>

=cut

__PACKAGE__->has_many(
  "resource_creators",
  "Mobilizon::Schema::Result::Resource",
  { "foreign.creator_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sessions

Type: has_many

Related object: L<Mobilizon::Schema::Result::Session>

=cut

__PACKAGE__->has_many(
  "sessions",
  "Mobilizon::Schema::Result::Session",
  { "foreign.speaker_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 shares_actors

Type: has_many

Related object: L<Mobilizon::Schema::Result::Share>

=cut

__PACKAGE__->has_many(
  "shares_actors",
  "Mobilizon::Schema::Result::Share",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 shares_owner_actors

Type: has_many

Related object: L<Mobilizon::Schema::Result::Share>

=cut

__PACKAGE__->has_many(
  "shares_owner_actors",
  "Mobilizon::Schema::Result::Share",
  { "foreign.owner_actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 todo_lists

Type: has_many

Related object: L<Mobilizon::Schema::Result::TodoList>

=cut

__PACKAGE__->has_many(
  "todo_lists",
  "Mobilizon::Schema::Result::TodoList",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 todos_assigned_to

Type: has_many

Related object: L<Mobilizon::Schema::Result::Todo>

=cut

__PACKAGE__->has_many(
  "todos_assigned_to",
  "Mobilizon::Schema::Result::Todo",
  { "foreign.assigned_to_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 todos_creators

Type: has_many

Related object: L<Mobilizon::Schema::Result::Todo>

=cut

__PACKAGE__->has_many(
  "todos_creators",
  "Mobilizon::Schema::Result::Todo",
  { "foreign.creator_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tombstones

Type: has_many

Related object: L<Mobilizon::Schema::Result::Tombstone>

=cut

__PACKAGE__->has_many(
  "tombstones",
  "Mobilizon::Schema::Result::Tombstone",
  { "foreign.actor_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Mobilizon::Schema::Result::User",
  { id => "user_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "NO ACTION",
  },
);

=head2 events

Type: many_to_many

Composing rels: L</event_contacts> -> event

=cut

__PACKAGE__->many_to_many("events", "event_contacts", "event");


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+MeRWHjqrvIqzS0fUG8+uw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
