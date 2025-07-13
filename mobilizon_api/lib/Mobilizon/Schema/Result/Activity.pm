use utf8;
package Mobilizon::Schema::Result::Activity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Activity

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

=head1 TABLE: C<activities>

=cut

__PACKAGE__->table("activities");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'activities_id_seq'

=head2 priority

  data_type: 'integer'
  is_nullable: 0

=head2 type

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 author_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 group_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 subject

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 subject_params

  data_type: 'jsonb'
  is_nullable: 0

=head2 message

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 message_params

  data_type: 'jsonb'
  is_nullable: 1

=head2 object_type

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 object_id

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 inserted_at

  data_type: 'timestamp'
  is_nullable: 0
  set_on_create: 1
  size: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "activities_id_seq",
  },
  "priority",
  { data_type => "integer", is_nullable => 0 },
  "type",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "author_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "group_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
  "subject",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "subject_params",
  { data_type => "jsonb", is_nullable => 0 },
  "message",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "message_params",
  { data_type => "jsonb", is_nullable => 1 },
  "object_type",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "object_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "inserted_at",
  { data_type => "timestamp", is_nullable => 0, set_on_create => 1, size => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 author

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "author",
  "Mobilizon::Schema::Result::Actor",
  { id => "author_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 group

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->belongs_to(
  "group",
  "Mobilizon::Schema::Result::Actor",
  { id => "group_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:f1VW97RKcreQJPiRb/B8CA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
