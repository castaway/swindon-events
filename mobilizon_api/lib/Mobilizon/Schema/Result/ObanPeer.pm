use utf8;
package Mobilizon::Schema::Result::ObanPeer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mobilizon::Schema::Result::ObanPeer

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

=head1 TABLE: C<oban_peers>

=cut

__PACKAGE__->table("oban_peers");

=head1 ACCESSORS

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 node

  data_type: 'text'
  is_nullable: 0

=head2 started_at

  data_type: 'timestamp'
  is_nullable: 0

=head2 expires_at

  data_type: 'timestamp'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "name",
  { data_type => "text", is_nullable => 0 },
  "node",
  { data_type => "text", is_nullable => 0 },
  "started_at",
  { data_type => "timestamp", is_nullable => 0 },
  "expires_at",
  { data_type => "timestamp", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("name");


# Created by DBIx::Class::Schema::Loader v0.07053 @ 2025-04-05 14:08:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:B6AJPkLPVqnUm6Ttla6Dgg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
