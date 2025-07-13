use utf8;
package Mobilizon::Schema::Result::Application;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Application

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

=head1 TABLE: C<applications>

=cut

__PACKAGE__->table("applications");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'applications_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 client_id

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 client_secret

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 redirect_uris

  data_type: 'character varying[]'
  is_nullable: 0
  size: 255

=head2 scope

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 website

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 owner_type

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 owner_id

  data_type: 'integer'
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
    sequence          => "applications_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "client_id",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "client_secret",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "redirect_uris",
  { data_type => "character varying[]", is_nullable => 0, size => 255 },
  "scope",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "website",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "owner_type",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "owner_id",
  { data_type => "integer", is_nullable => 1 },
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

=head2 application_device_activations

Type: has_many

Related object: L<Mobilizon::Schema::Result::ApplicationDeviceActivation>

=cut

__PACKAGE__->has_many(
  "application_device_activations",
  "Mobilizon::Schema::Result::ApplicationDeviceActivation",
  { "foreign.application_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 application_tokens

Type: has_many

Related object: L<Mobilizon::Schema::Result::ApplicationToken>

=cut

__PACKAGE__->has_many(
  "application_tokens",
  "Mobilizon::Schema::Result::ApplicationToken",
  { "foreign.application_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LjUqbue7GT96uhPS5igUPQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
