package DBIx::Class::ResultClass::HashRefInflator::UTF8;

use strict;
use warnings;
use utf8;

use Scalar::Util qw( looks_like_number );

# ABSTRACT: Get raw hashrefs from a resultset with utf-8 flag

=head1 NOTE

This module should be used to force UTF8 on your results in case your DBI/DBD/lib-$protocol pipeline does not support unicode natively (similar to the higher-level L<DBIx::Class::ForceUTF8>.

=cut

# VERSION

=head1 SYNOPSIS

 use DBIx::Class::ResultClass::HashRefInflator::UTF8;
 my $rs = $schema->resultset('CD');
 $rs->result_class('DBIx::Class::ResultClass::HashRefInflator::UTF8');
 while (my $hashref = $rs->next) {
   ...
 }
  OR as an attribute:
 my $rs = $schema->resultset('CD')->search({}, {
   result_class => 'DBIx::Class::ResultClass::HashRefInflator::UTF8',
 });
 while (my $hashref = $rs->next) {
   ...
 }

=head1 DESCRIPTION

DBIx::Class is faster than older ORMs like Class::DBI but it still isn't
designed primarily for speed. Sometimes you need to quickly retrieve the data
from a massive resultset, while skipping the creation of fancy result objects.
Specifying this class as a C<result_class> for a resultset will change C<< $rs->next >>
to return a plain data hash-ref (or a list of such hash-refs if C<< $rs->all >> is used).
There are two ways of applying this class to a resultset:

=over

=item *

Specify C<< $rs->result_class >> on a specific resultset to affect only that
resultset (and any chained off of it); or

=item *

Specify C<< __PACKAGE__->result_class >> on your source object to force all
uses of that result source to be inflated to hash-refs - this approach is not
recommended.

=back

=cut

use parent qw( DBIx::Class::ResultClass::HashRefInflator );

=head1 METHODS

=head2 inflate_result

Inflates the result and prefetched data into a hash-ref (invoked by L<DBIx::Class::ResultSet>)

=cut

sub inflate_result {
    my ( $self, @args ) = @_;
    my $res =  $self->SUPER::inflate_result( @args );
    return $res  if ref($res) ne 'HASH';

    for ( keys %$res ) {
        my $val = $res->{$_};
        utf8::decode( $res->{$_} )  if defined($val) && !ref($val) && !looks_like_number( $val );
    }

    return $res;
}

1;


__END__

=head1 CAVEATS

=over

=item *

This will not work for relationships that have been prefetched. Consider the
following:

 my $artist = $artitsts_rs->search({}, {prefetch => 'cds' })->first;

 my $cds = $artist->cds;
 $cds->result_class('DBIx::Class::ResultClass::HashRefInflator::UTF8');
 my $first = $cds->first;

C<$first> will B<not> be a hashref, it will be a normal CD row since
HashRefInflator::UTF8 only affects resultsets at inflation time, and prefetch causes
relations to be inflated when the master C<$artist> row is inflated.

=item *

Column value inflation, e.g., using modules like
L<DBIx::Class::InflateColumn::DateTime>, is not performed.
The returned hash contains the raw database values.

=back

=head1 FURTHER QUESTIONS?

Check the list of L<additional DBIC resources|DBIx::Class/GETTING HELP/SUPPORT>.
