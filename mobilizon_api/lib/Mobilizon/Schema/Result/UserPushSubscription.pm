use utf8;
package Mobilizon::Schema::Result::UserPushSubscription;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::UserPushSubscription

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

=head1 TABLE: C<user_push_subscriptions>

=cut

__PACKAGE__->table("user_push_subscriptions");

=head1 ACCESSORS

=head2 id

  data_type: 'uuid'
  is_nullable: 0
  size: 16

=head2 user_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 digest

  data_type: 'text'
  is_nullable: 0

=head2 endpoint

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 auth

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 p256dh

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
  { data_type => "uuid", is_nullable => 0, size => 16 },
  "user_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "digest",
  { data_type => "text", is_nullable => 0 },
  "endpoint",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "auth",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "p256dh",
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

=head2 C<user_push_subscriptions_user_id_digest_index>

=over 4

=item * L</user_id>

=item * L</digest>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "user_push_subscriptions_user_id_digest_index",
  ["user_id", "digest"],
);

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Mobilizon::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+6jJArJqDteC19hN4R3Rjw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
