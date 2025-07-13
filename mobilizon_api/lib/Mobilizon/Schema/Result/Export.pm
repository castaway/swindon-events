use utf8;
package Mobilizon::Schema::Result::Export;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Export

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

=head1 TABLE: C<exports>

=cut

__PACKAGE__->table("exports");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'exports_id_seq'

=head2 file_path

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 file_size

  data_type: 'integer'
  is_nullable: 1

=head2 file_name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 reference

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 format

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

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "exports_id_seq",
  },
  "file_path",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "file_size",
  { data_type => "integer", is_nullable => 1 },
  "file_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "reference",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "format",
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
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<exports_file_path_index>

=over 4

=item * L</file_path>

=back

=cut

__PACKAGE__->add_unique_constraint("exports_file_path_index", ["file_path"]);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6d1jN+UZIj0XLJomlgtyag


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
