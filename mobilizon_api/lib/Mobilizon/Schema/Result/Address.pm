use utf8;
package Mobilizon::Schema::Result::Address;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Address

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

=head1 TABLE: C<addresses>

=cut

__PACKAGE__->table("addresses");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'addresses_id_seq'

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 country

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 locality

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 region

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 postal_code

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 street

  data_type: 'text'
  is_nullable: 1

=head2 geom

  data_type: 'geometry'
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

=head2 url

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 origin_id

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 timezone

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "addresses_id_seq",
  },
  "description",
  { data_type => "text", is_nullable => 1 },
  "country",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "locality",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "region",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "postal_code",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "street",
  { data_type => "text", is_nullable => 1 },
  "geom",
  { data_type => "geometry", is_nullable => 1 },
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
  "url",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "origin_id",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "timezone",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<addresses_origin_id_index>

=over 4

=item * L</origin_id>

=back

=cut

__PACKAGE__->add_unique_constraint("addresses_origin_id_index", ["origin_id"]);

=head2 C<addresses_url_index>

=over 4

=item * L</url>

=back

=cut

__PACKAGE__->add_unique_constraint("addresses_url_index", ["url"]);

=head1 RELATIONS

=head2 actors

Type: has_many

Related object: L<Mobilizon::Schema::Result::Actor>

=cut

__PACKAGE__->has_many(
  "actors",
  "Mobilizon::Schema::Result::Actor",
  { "foreign.physical_address_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events

Type: has_many

Related object: L<Mobilizon::Schema::Result::Event>

=cut

__PACKAGE__->has_many(
  "events",
  "Mobilizon::Schema::Result::Event",
  { "foreign.physical_address_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:20:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zYldREx8QDd9t/y0MLX6Zw

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
