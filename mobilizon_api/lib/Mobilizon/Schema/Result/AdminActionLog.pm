use utf8;
package Mobilizon::Schema::Result::AdminActionLog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::AdminActionLog

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

=head1 TABLE: C<admin_action_logs>

=cut

__PACKAGE__->table("admin_action_logs");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'admin_action_logs_id_seq'

=head2 action

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 target_type

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 target_id

  data_type: 'integer'
  is_nullable: 0

=head2 changes

  data_type: 'jsonb'
  is_nullable: 1

=head2 actor_id

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
    sequence          => "admin_action_logs_id_seq",
  },
  "action",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "target_type",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "target_id",
  { data_type => "integer", is_nullable => 0 },
  "changes",
  { data_type => "jsonb", is_nullable => 1 },
  "actor_id",
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

=head2 actor

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "actor",
  "Mobilizon::Schema::Result::Actor",
  { id => "actor_id" },
  { is_deferrable => 0, on_delete => "SET NULL", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zaair6HclASu+TN8LDQUwA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
