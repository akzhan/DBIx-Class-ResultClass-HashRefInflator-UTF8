package DBIx::Class::ResultClass::HashRefInflator::UTF8;

use strict;
use warnings;
use utf8;

use parent qw( DBIx::Class::ResultClass::HashRefInflator );

sub inflate_result {
    my ( $self, @args ) = @_;
    my $res =  $self->SUPER::inflate_result( @args );
    $res = {
        map {
            my $val = $res->{$_};
            utf8::decode($val)  if defined $val && !ref($val);
            ( $_ => $val );
        } keys %$res
    }  if ref($res) eq 'HASH';
    return $res;
}

1;

