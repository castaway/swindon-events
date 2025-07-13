use utf8;
package Mobilizon::Schema::Result::GuardianToken;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::GuardianToken

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

=head1 TABLE: C<guardian_tokens>

=cut

__PACKAGE__->table("guardian_tokens");

=head1 ACCESSORS

=head2 jti

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 aud

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 typ

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 iss

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 sub

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 exp

  data_type: 'bigint'
  is_nullable: 1

=head2 jwt

  data_type: 'text'
  is_nullable: 1

=head2 claims

  data_type: 'jsonb'
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
  "jti",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "aud",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "typ",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "iss",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "sub",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "exp",
  { data_type => "bigint", is_nullable => 1 },
  "jwt",
  { data_type => "text", is_nullable => 1 },
  "claims",
  { data_type => "jsonb", is_nullable => 1 },
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

=item * L</jti>

=item * L</aud>

=back

=cut

__PACKAGE__->set_primary_key("jti", "aud");


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ueu/TdX3yg3I+LiZhGFkDA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
