# NAME

SQL::Translator::Producer::GraphQL - GraphQL specific producer for SQL::Translator

# SYNOPSIS

    use SQL::Translator;
    use SQL::Translator::Producer::GraphQL;

    my $t = SQL::Translator->new( parser => '...' );
    $t->producer('GraphQL');
    $t->translate;

# DESCRIPTION

This module will produce text output of the schema suitable for GraphQL.

# ARGUMENTS

- `default_not_null`

    Enables `default_not_null` in DSL.

- `default_unsigned`

    Enables `default_unsigned` in DSL.

# AUTHOR

Ed J, `<etj at cpan.org>`

Based heavily on [SQL::Translator::Producer::DBIxSchemaDSL](https://metacpan.org/pod/SQL::Translator::Producer::DBIxSchemaDSL).

# LICENSE

Copyright (C) Ed J

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
