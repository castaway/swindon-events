use utf8;
package Mobilizon::Schema::Result::AdminSettingsMedia;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::AdminSettingsMedia

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

=head1 TABLE: C<admin_settings_medias>

=cut

__PACKAGE__->table("admin_settings_medias");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'admin_settings_medias_id_seq'

=head2 group

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 media_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 1

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
    sequence          => "admin_settings_medias_id_seq",
  },
  "group",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "media_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 1 },
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

=head2 C<admin_settings_medias_group_name_index>

=over 4

=item * L</group>

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("admin_settings_medias_group_name_index", ["group", "name"]);

=head1 RELATIONS

=head2 media

Type: belongs_to

Related object: L<Mobilizon::Schema::Result::Media>

=cut

__PACKAGE__->belongs_to(
  "media",
  "Mobilizon::Schema::Result::Media",
  { id => "media_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0s8duOlvrtjtA1liT7vtDQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
