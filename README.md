# NAME

SQL::Translator::Producer::GraphQL - GraphQL schema producer for SQL::Translator

# PROJECT STATUS

| OS      |  Build status |
|:-------:|--------------:|
| Linux   | [![Build Status](https://travis-ci.org/graphql-perl/SQL-Translator-Producer-GraphQL.svg?branch=master)](https://travis-ci.org/graphql-perl/SQL-Translator-Producer-GraphQL) |

[![CPAN version](https://badge.fury.io/pl/SQL-Translator-Producer-GraphQL.svg)](https://metacpan.org/pod/SQL::Translator::Producer::GraphQL)

# SYNOPSIS

    use SQL::Translator;
    use SQL::Translator::Producer::GraphQL;
    my $t = SQL::Translator->new( parser => '...' );
    $t->producer('GraphQL');
    $t->translate;

# DESCRIPTION

This module will produce a [GraphQL::Schema](https://metacpan.org/pod/GraphQL::Schema) from the given
[SQL::Translator::Schema](https://metacpan.org/pod/SQL::Translator::Schema). It does this by first
turning it into a [DBIx::Class::Schema](https://metacpan.org/pod/DBIx::Class::Schema) using
[SQL::Translator::Producer::DBIx::Class::File](https://metacpan.org/pod/SQL::Translator::Producer::DBIx::Class::File), and introspecting it.

Its `Query` type represents a guess at what fields are suitable, based
on providing a lookup for each type (a [DBIx::Class::ResultSource](https://metacpan.org/pod/DBIx::Class::ResultSource))
by each of its columns.

The `Mutation` type is similar: one `create/update/delete(type)` per
"real" type.

# ARGUMENTS

Currently none.

# EXPORTS

## schema\_dbic2graphql

Takes as input a [DBIx::Class::Schema](https://metacpan.org/pod/DBIx::Class::Schema) object, returns a
[GraphQL::Schema](https://metacpan.org/pod/GraphQL::Schema) object. E.g.:

    perl -MSQL::Translator::Producer::GraphQL=schema_dbic2graphql \
      -MModule::Runtime=require_module \
      -e '
        my $dbic_class = shift;
        require_module $dbic_class;
        print schema_dbic2graphql($dbic_class->connect)->to_doc;
      ' \
      -It/lib-dbicschema Schema | less

# DEBUGGING

To debug, set environment variable `GRAPHQL_DEBUG` to a true value.

# AUTHOR

Ed J, `<etj at cpan.org>`

Based heavily on [SQL::Translator::Producer::DBIxSchemaDSL](https://metacpan.org/pod/SQL::Translator::Producer::DBIxSchemaDSL).

# LICENSE

Copyright (C) Ed J

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
