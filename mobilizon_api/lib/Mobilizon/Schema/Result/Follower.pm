use utf8;
package Mobilizon::Schema::Result::Follower;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Follower

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

=head1 TABLE: C<followers>

=cut

__PACKAGE__->table("followers");

=head1 ACCESSORS

=head2 approved

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=head2 actor_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 target_actor_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

=head2 id

  data_type: 'uuid'
  is_nullable: 0
  size: 16

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

=head2 notify

  data_type: 'boolean'
  default_value: true
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "approved",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
  "actor_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "target_actor_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
  "id",
  { data_type => "uuid", is_nullable => 0, size => 16 },
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
  "notify",
  { data_type => "boolean", default_value => \"true", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<followers_actor_target_actor_unique_index>

=over 4

=item * L</actor_id>

=item * L</target_actor_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "followers_actor_target_actor_unique_index",
  ["actor_id", "target_actor_id"],
);

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
    on_delete     => "CASCADE",
    on_update     => "NO ACTION",
  },
);

=head2 target_actor

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "target_actor",
  "Mobilizon::Schema::Result::Actor",
  { id => "target_actor_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9x8USEni5I3n5iTmxKfGJw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
