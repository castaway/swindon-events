use utf8;
package Mobilizon::Schema::Result::SchemaMigration;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::SchemaMigration

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

=head1 TABLE: C<schema_migrations>

=cut

__PACKAGE__->table("schema_migrations");

=head1 ACCESSORS

=head2 version

  data_type: 'bigint'
  is_nullable: 0

=head2 inserted_at

  data_type: 'timestamp'
  is_nullable: 1
  set_on_create: 1
  size: 0

=cut

__PACKAGE__->add_columns(
  "version",
  { data_type => "bigint", is_nullable => 0 },
  "inserted_at",
  { data_type => "timestamp", is_nullable => 1, set_on_create => 1, size => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</version>

=back

=cut

__PACKAGE__->set_primary_key("version");


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5/dhRigJO0p+/q5Adv8JBg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
