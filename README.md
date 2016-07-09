# NAME

DBIx::Class::ResultClass::HashRefInflator::UTF8 - Get raw hashrefs from a resultset with utf-8 flag

[![Build Status](https://travis-ci.org/akzhan/DBIx-Class-ResultClass-HashRefInflator-UTF8.svg?branch=master)](https://travis-ci.org/akzhan/DBIx-Class-ResultClass-HashRefInflator-UTF8)

# VERSION

version 1.000001

# SYNOPSIS

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

# DESCRIPTION

DBIx::Class is faster than older ORMs like Class::DBI but it still isn't
designed primarily for speed. Sometimes you need to quickly retrieve the data
from a massive resultset, while skipping the creation of fancy result objects.
Specifying this class as a `result_class` for a resultset will change `$rs->next`
to return a plain data hash-ref (or a list of such hash-refs if `$rs->all` is used).
There are two ways of applying this class to a resultset:

- Specify `$rs->result_class` on a specific resultset to affect only that
resultset (and any chained off of it); or
- Specify `__PACKAGE__->result_class` on your source object to force all
uses of that result source to be inflated to hash-refs - this approach is not
recommended.

# METHODS

## inflate\_result

Inflates the result and prefetched data into a hash-ref (invoked by [DBIx::Class::ResultSet](https://metacpan.org/pod/DBIx::Class::ResultSet))

# CAVEATS

- This will not work for relationships that have been prefetched. Consider the
following:

        my $artist = $artitsts_rs->search({}, {prefetch => 'cds' })->first;

        my $cds = $artist->cds;
        $cds->result_class('DBIx::Class::ResultClass::HashRefInflator');
        my $first = $cds->first;

    `$first` will **not** be a hashref, it will be a normal CD row since
    HashRefInflator::UTF8 only affects resultsets at inflation time, and prefetch causes
    relations to be inflated when the master `$artist` row is inflated.

- Column value inflation, e.g., using modules like
[DBIx::Class::InflateColumn::DateTime](https://metacpan.org/pod/DBIx::Class::InflateColumn::DateTime), is not performed.
The returned hash contains the raw database values.

# FURTHER QUESTIONS?

Check the list of [additional DBIC resources](https://metacpan.org/pod/DBIx::Class#GETTING-HELP-SUPPORT).

# AUTHOR

Akzhan Abdulin <akzhan@cpan.org>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2016 by Akzhan Abdulin.

This is free software, licensed under:

    The MIT (X11) License
