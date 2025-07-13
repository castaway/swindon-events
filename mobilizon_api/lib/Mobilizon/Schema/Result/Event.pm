use utf8;
package Mobilizon::Schema::Result::Event;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Event

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

=head1 TABLE: C<events>

=cut

__PACKAGE__->table("events");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'events_id_seq'

=head2 title

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 organizer_actor_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 physical_address_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 inserted_at

  data_type: 'timestamp with time zone'
  is_nullable: 0
  set_on_create: 1

=head2 updated_at

  data_type: 'timestamp with time zone'
  is_nullable: 0
  set_on_create: 1
  set_on_update: 1

=head2 url

  data_type: 'varchar'
  default_value: 'https://'
  is_nullable: 0
  size: 255

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

=head2 online_address

  data_type: 'text'
  is_nullable: 1

=head2 phone_address

  data_type: 'text'
  is_nullable: 1

=head2 visibility

  data_type: 'enum'
  default_value: 'public'
  extra: {custom_type_name => "event_visibility",list => ["public","unlisted","restricted","private"]}
  is_nullable: 0

=head2 status

  data_type: 'enum'
  extra: {custom_type_name => "event_status",list => ["tentative","confirmed","cancelled"]}
  is_nullable: 1

=head2 join_options

  data_type: 'enum'
  default_value: 'free'
  extra: {custom_type_name => "join_options",list => ["free","restricted","invite","external"]}
  is_nullable: 0

=head2 begins_on

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=head2 ends_on

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=head2 publish_at

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=head2 category

  data_type: 'text'
  is_nullable: 1

=head2 slug

  data_type: 'text'
  is_nullable: 1

=head2 picture_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 options

  data_type: 'jsonb'
  is_nullable: 1

=head2 draft

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=head2 participant_stats

  data_type: 'jsonb'
  is_nullable: 1

=head2 metadata

  data_type: 'jsonb'
  is_nullable: 1

=head2 language

  data_type: 'varchar'
  default_value: 'und'
  is_nullable: 1
  size: 255

=head2 external_participation_url

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "events_id_seq",
  },
  "title",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "organizer_actor_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "physical_address_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "inserted_at",
  {
    data_type     => "timestamp with time zone",
    is_nullable   => 0,
    set_on_create => 1,
  },
  "updated_at",
  {
    data_type     => "timestamp with time zone",
    is_nullable   => 0,
    set_on_create => 1,
    set_on_update => 1,
  },
  "url",
  {
    data_type => "varchar",
    default_value => "https://",
    is_nullable => 0,
    size => 255,
  },
  "local",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "uuid",
  { data_type => "uuid", is_nullable => 1, size => 16 },
  "attributed_to_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "online_address",
  { data_type => "text", is_nullable => 1 },
  "phone_address",
  { data_type => "text", is_nullable => 1 },
  "visibility",
  {
    data_type => "enum",
    default_value => "public",
    extra => {
      custom_type_name => "event_visibility",
      list => ["public", "unlisted", "restricted", "private"],
    },
    is_nullable => 0,
  },
  "status",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "event_status",
      list => ["tentative", "confirmed", "cancelled"],
    },
    is_nullable => 1,
  },
  "join_options",
  {
    data_type => "enum",
    default_value => "free",
    extra => {
      custom_type_name => "join_options",
      list => ["free", "restricted", "invite", "external"],
    },
    is_nullable => 0,
  },
  "begins_on",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
  "ends_on",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
  "publish_at",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
  "category",
  { data_type => "text", is_nullable => 1 },
  "slug",
  { data_type => "text", is_nullable => 1 },
  "picture_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "options",
  { data_type => "jsonb", is_nullable => 1 },
  "draft",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
  "participant_stats",
  { data_type => "jsonb", is_nullable => 1 },
  "metadata",
  { data_type => "jsonb", is_nullable => 1 },
  "language",
  {
    data_type => "varchar",
    default_value => "und",
    is_nullable => 1,
    size => 255,
  },
  "external_participation_url",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<events_url_index>

=over 4

=item * L</url>

=back

=cut

__PACKAGE__->add_unique_constraint("events_url_index", ["url"]);

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
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 comments

Type: has_many

Related object: L<Mobilizon::Schema::Result::Comment>

=cut

__PACKAGE__->has_many(
  "comments",
  "Mobilizon::Schema::Result::Comment",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 conversations

Type: has_many

Related object: L<Mobilizon::Schema::Result::Conversation>

=cut

__PACKAGE__->has_many(
  "conversations",
  "Mobilizon::Schema::Result::Conversation",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_contacts

Type: has_many

Related object: L<Mobilizon::Schema::Result::EventContact>

=cut

__PACKAGE__->has_many(
  "event_contacts",
  "Mobilizon::Schema::Result::EventContact",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_search

Type: might_have

Related object: L<Mobilizon::Schema::Result::EventSearch>

=cut

__PACKAGE__->might_have(
  "event_search",
  "Mobilizon::Schema::Result::EventSearch",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events_medias

Type: has_many

Related object: L<Mobilizon::Schema::Result::EventsMedia>

=cut

__PACKAGE__->has_many(
  "events_medias",
  "Mobilizon::Schema::Result::EventsMedia",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events_tags

Type: has_many

Related object: L<Mobilizon::Schema::Result::EventsTag>

=cut

__PACKAGE__->has_many(
  "events_tags",
  "Mobilizon::Schema::Result::EventsTag",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 mentions

Type: has_many

Related object: L<Mobilizon::Schema::Result::Mention>

=cut

__PACKAGE__->has_many(
  "mentions",
  "Mobilizon::Schema::Result::Mention",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 organizer_actor

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "organizer_actor",
  "Mobilizon::Schema::Result::Actor",
  { id => "organizer_actor_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "NO ACTION",
  },
);

=head2 participants

Type: has_many

Related object: L<Mobilizon::Schema::Result::Participant>

=cut

__PACKAGE__->has_many(
  "participants",
  "Mobilizon::Schema::Result::Participant",
  { "foreign.event_id" => "self.id" },
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

=head2 reports_events

Type: has_many

Related object: L<Mobilizon::Schema::Result::ReportsEvent>

=cut

__PACKAGE__->has_many(
  "reports_events",
  "Mobilizon::Schema::Result::ReportsEvent",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sessions

Type: has_many

Related object: L<Mobilizon::Schema::Result::Session>

=cut

__PACKAGE__->has_many(
  "sessions",
  "Mobilizon::Schema::Result::Session",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tracks

Type: has_many

Related object: L<Mobilizon::Schema::Result::Track>

=cut

__PACKAGE__->has_many(
  "tracks",
  "Mobilizon::Schema::Result::Track",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 actors

Type: many_to_many

Composing rels: L</event_contacts> -> actor

=cut

__PACKAGE__->many_to_many("actors", "event_contacts", "actor");

=head2 medias

Type: many_to_many

Composing rels: L</events_medias> -> media

=cut

__PACKAGE__->many_to_many("medias", "events_medias", "media");


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3zQkxqkxwb6ISl1drKmPMw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
