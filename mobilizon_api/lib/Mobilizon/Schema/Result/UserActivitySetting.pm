use utf8;
package Mobilizon::Schema::Result::UserActivitySetting;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::UserActivitySetting

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

=head1 TABLE: C<user_activity_settings>

=cut

__PACKAGE__->table("user_activity_settings");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'user_activity_settings_id_seq'

=head2 key

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 method

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 enabled

  data_type: 'boolean'
  is_nullable: 0

=head2 user_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "user_activity_settings_id_seq",
  },
  "key",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "method",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "enabled",
  { data_type => "boolean", is_nullable => 0 },
  "user_id",
  { data_type => "bigint", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<user_activity_settings_user_id_key_method_index>

=over 4

=item * L</user_id>

=item * L</key>

=item * L</method>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "user_activity_settings_user_id_key_method_index",
  ["user_id", "key", "method"],
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
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:08:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hYXJpF3T5iJghwWIBh3Vfg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
