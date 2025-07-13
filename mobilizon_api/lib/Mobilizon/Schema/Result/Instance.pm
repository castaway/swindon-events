use utf8;
package Mobilizon::Schema::Result::Instance;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::Instance

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

=head1 TABLE: C<instances>

=cut

__PACKAGE__->table("instances");

=head1 ACCESSORS

=head2 domain

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 person_count

  data_type: 'bigint'
  is_nullable: 1

=head2 group_count

  data_type: 'bigint'
  is_nullable: 1

=head2 event_count

  data_type: 'bigint'
  is_nullable: 1

=head2 followers_count

  data_type: 'bigint'
  is_nullable: 1

=head2 followings_count

  data_type: 'bigint'
  is_nullable: 1

=head2 reports_count

  data_type: 'bigint'
  is_nullable: 1

=head2 media_size

  data_type: 'bigint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "domain",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "person_count",
  { data_type => "bigint", is_nullable => 1 },
  "group_count",
  { data_type => "bigint", is_nullable => 1 },
  "event_count",
  { data_type => "bigint", is_nullable => 1 },
  "followers_count",
  { data_type => "bigint", is_nullable => 1 },
  "followings_count",
  { data_type => "bigint", is_nullable => 1 },
  "reports_count",
  { data_type => "bigint", is_nullable => 1 },
  "media_size",
  { data_type => "bigint", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:08:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hhoHneDELzMlQlo8ykyKOA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
