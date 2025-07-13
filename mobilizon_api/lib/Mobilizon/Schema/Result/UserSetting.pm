use utf8;
package Mobilizon::Schema::Result::UserSetting;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::UserSetting

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

=head1 TABLE: C<user_settings>

=cut

__PACKAGE__->table("user_settings");

=head1 ACCESSORS

=head2 timezone

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 notification_on_day

  data_type: 'boolean'
  is_nullable: 1

=head2 notification_each_week

  data_type: 'boolean'
  is_nullable: 1

=head2 notification_before_event

  data_type: 'boolean'
  is_nullable: 1

=head2 user_id

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

=head2 notification_pending_participation

  data_type: 'integer'
  default_value: 10
  is_nullable: 1

=head2 notification_pending_membership

  data_type: 'integer'
  default_value: 10
  is_nullable: 1

=head2 location

  data_type: 'jsonb'
  is_nullable: 1

=head2 group_notifications

  data_type: 'integer'
  default_value: 10
  is_nullable: 0

=head2 last_notification_sent

  data_type: 'timestamp'
  is_nullable: 1
  size: 0

=cut

__PACKAGE__->add_columns(
  "timezone",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "notification_on_day",
  { data_type => "boolean", is_nullable => 1 },
  "notification_each_week",
  { data_type => "boolean", is_nullable => 1 },
  "notification_before_event",
  { data_type => "boolean", is_nullable => 1 },
  "user_id",
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
  "notification_pending_participation",
  { data_type => "integer", default_value => 10, is_nullable => 1 },
  "notification_pending_membership",
  { data_type => "integer", default_value => 10, is_nullable => 1 },
  "location",
  { data_type => "jsonb", is_nullable => 1 },
  "group_notifications",
  { data_type => "integer", default_value => 10, is_nullable => 0 },
  "last_notification_sent",
  { data_type => "timestamp", is_nullable => 1, size => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Mobilizon::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:l2EkScntMV76qq7Z/l9ZbA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
