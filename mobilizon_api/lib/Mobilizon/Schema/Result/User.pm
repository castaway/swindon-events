use utf8;
package Mobilizon::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::User

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

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'users_id_seq'

=head2 email

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 password_hash

  data_type: 'varchar'
  is_nullable: 1
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

=head2 confirmed_at

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=head2 confirmation_sent_at

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=head2 confirmation_token

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 reset_password_sent_at

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=head2 reset_password_token

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 default_actor_id

  data_type: 'integer'
  is_nullable: 1

=head2 role

  data_type: 'enum'
  default_value: 'user'
  extra: {custom_type_name => "user_role",list => ["administrator","moderator","user"]}
  is_nullable: 1

=head2 locale

  data_type: 'varchar'
  default_value: 'en'
  is_nullable: 1
  size: 255

=head2 unconfirmed_email

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 disabled

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 provider

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 last_sign_in_at

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=head2 last_sign_in_ip

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 current_sign_in_ip

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 current_sign_in_at

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
    sequence          => "users_id_seq",
  },
  "email",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "password_hash",
  { data_type => "varchar", is_nullable => 1, size => 255 },
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
  "confirmed_at",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
  "confirmation_sent_at",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
  "confirmation_token",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "reset_password_sent_at",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
  "reset_password_token",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "default_actor_id",
  { data_type => "integer", is_nullable => 1 },
  "role",
  {
    data_type => "enum",
    default_value => "user",
    extra => {
      custom_type_name => "user_role",
      list => ["administrator", "moderator", "user"],
    },
    is_nullable => 1,
  },
  "locale",
  {
    data_type => "varchar",
    default_value => "en",
    is_nullable => 1,
    size => 255,
  },
  "unconfirmed_email",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "disabled",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "provider",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "last_sign_in_at",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
  "last_sign_in_ip",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "current_sign_in_ip",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "current_sign_in_at",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<index_unique_users_confirmation_token>

=over 4

=item * L</confirmation_token>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "index_unique_users_confirmation_token",
  ["confirmation_token"],
);

=head2 C<index_unique_users_reset_password_token>

=over 4

=item * L</reset_password_token>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "index_unique_users_reset_password_token",
  ["reset_password_token"],
);

=head2 C<users_email_index>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("users_email_index", ["email"]);

=head1 RELATIONS

=head2 actors

Type: has_many

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->has_many(
  "actors",
  "Mobilizon::Schema::Result::Actor",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 application_device_activations

Type: has_many

Related object: L<Mobilizon::Schema::Result::ApplicationDeviceActivation>

=cut

__PACKAGE__->has_many(
  "application_device_activations",
  "Mobilizon::Schema::Result::ApplicationDeviceActivation",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 application_tokens

Type: has_many

Related object: L<Mobilizon::Schema::Result::ApplicationToken>

=cut

__PACKAGE__->has_many(
  "application_tokens",
  "Mobilizon::Schema::Result::ApplicationToken",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bots

Type: has_many

Related object: L<Mobilizon::Schema::Result::Bot>

=cut

__PACKAGE__->has_many(
  "bots",
  "Mobilizon::Schema::Result::Bot",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 feed_tokens

Type: has_many

Related object: L<Mobilizon::Schema::Result::FeedToken>

=cut

__PACKAGE__->has_many(
  "feed_tokens",
  "Mobilizon::Schema::Result::FeedToken",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_activity_settings

Type: has_many

Related object: L<Mobilizon::Schema::Result::UserActivitySetting>

=cut

__PACKAGE__->has_many(
  "user_activity_settings",
  "Mobilizon::Schema::Result::UserActivitySetting",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_push_subscriptions

Type: has_many

Related object: L<Mobilizon::Schema::Result::UserPushSubscription>

=cut

__PACKAGE__->has_many(
  "user_push_subscriptions",
  "Mobilizon::Schema::Result::UserPushSubscription",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_setting

Type: might_have

Related object: L<Mobilizon::Schema::Result::UserSetting>

=cut

__PACKAGE__->might_have(
  "user_setting",
  "Mobilizon::Schema::Result::UserSetting",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:veF3t5JEMFGXZd/XGQc9jg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
