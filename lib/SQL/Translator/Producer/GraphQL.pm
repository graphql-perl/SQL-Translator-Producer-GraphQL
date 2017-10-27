package SQL::Translator::Producer::GraphQL;
use 5.008001;
use strict;
use warnings;
use SQL::Translator::Producer::DBIx::Class::File;
use GraphQL::Schema;

our $VERSION = "0.01";

my %TYPEMAP = (
  guid => 'String',
  wlongvarchar => 'String',
  wvarchar => 'String',
  wchar => 'String',
  bigint => 'Int',
  bit => 'Int',
  tinyint => 'Int',
  longvarbinary => 'String',
  varbinary => 'String',
  binary => 'String',
  longvarchar => 'String',
  unknown_type => 'String',
  all_types => 'String',
  char => 'String',
  numeric => 'Float',
  decimal => 'Float',
  integer => 'Int',
  smallint => 'Int',
  float => 'Float',
  real => 'Float',
  double => 'Float',
  datetime => 'DateTime',
  date => 'DateTime',
  interval => 'Int',
  time => 'DateTime',
  timestamp => 'DateTime',
  varchar => 'String',
  boolean => 'Boolean',
  udt => 'String',
  udt_locator => 'String',
  row => 'String',
  ref => 'String',
  blob => 'String',
  blob_locator => 'String',
  clob => 'String',
  clob_locator => 'String',
  array => 'String',
  array_locator => 'String',
  multiset => 'String',
  multiset_locator => 'String',
  type_date => 'DateTime',
  type_time => 'DateTime',
  type_timestamp => 'DateTime',
  type_time_with_timezone => 'DateTime',
  type_timestamp_with_timezone => 'DateTime',
  interval_year => 'Int',
  interval_month => 'Int',
  interval_day => 'Int',
  interval_hour => 'Int',
  interval_minute => 'Int',
  interval_second => 'Int',
  interval_year_to_month => 'Int',
  interval_day_to_hour => 'Int',
  interval_day_to_minute => 'Int',
  interval_day_to_second => 'Int',
  interval_hour_to_minute => 'Int',
  interval_hour_to_second => 'Int',
  interval_minute_to_second => 'Int',
  # not DBI SQL_* types
  int => 'Int',
  text => 'String',
);

sub _dbicsource2pretty {
  my ($source) = @_;
  $source = $source->source_name || $source;
  $source =~ s#.*::##;
  join '', map ucfirst, split /_+/, $source;
}

sub _apply_modifier {
  my ($modifier, $typespec) = @_;
  return $typespec if !$modifier;
  [ $modifier, { type => $typespec } ];
}

sub _type2input {
  my ($name, $fields, $pk21, $fk21) = @_;
  +{
    kind => 'input',
    name => "${name}Input",
    fields => {
      map { ($_ => $fields->{$_}) }
        grep !$pk21->{$_} && !$fk21->{$_}, keys %$fields
    },
  };
}

sub schema_dbic2graphql {
  my ($dbic_schema) = @_;
  my @ast = ({kind => 'scalar', name => 'DateTime'});
  my (%name2type, %name2columns, %name2pk21, %name2fk21);
  for my $source (map $dbic_schema->source($_), $dbic_schema->sources) {
    my $name = _dbicsource2pretty($source);
    my %fields;
    my $columns_info = $source->columns_info;
    $name2pk21{$name} = +{ map { ($_ => 1) } $source->primary_columns };
    my %rel2info = map {
      ($_ => $source->relationship_info($_))
    } $source->relationships;
    for my $column (keys %$columns_info) {
      my $info = $columns_info->{$column};
      $fields{$column} = +{
        type => $TYPEMAP{ lc $info->{data_type} },
      };
      $name2fk21{$name}->{$column} = 1 if $info->{is_foreign_key};
      push @{ $name2columns{$name} }, $column;
    }
    push @ast, _type2input($name, \%fields, $name2pk21{$name}, $name2fk21{$name});
    for my $rel (keys %rel2info) {
      my $info = $rel2info{$rel};
      my $type = _dbicsource2pretty($info->{source});
      $rel =~ s/_id$//; # dumb heuristic
      $rel .= '1' if grep $_ eq $rel, @{ $name2columns{$name} };
      $type = _apply_modifier('list', $type) if $info->{attrs}{accessor} eq 'multi';
      $fields{$rel} = +{
        type => $type,
      };
    }
    my $spec = +{
      kind => 'type',
      name => $name,
      fields => \%fields,
    };
    $name2type{$name} = $spec;
    push @ast, $spec;
  }
  push @ast, {
    kind => 'type',
    name => 'Query',
    fields => {
      map {
        my $name = $_;
        my $type = $name2type{$name};
        map {
          (lc($name).'By'.ucfirst($_) => {
            type => _apply_modifier(!$name2pk21{$name}->{$_} && 'list', $name),
            args => {
              $_ => { type => _apply_modifier('non_null', $type->{fields}{$_}{type}) }
            },
          })
        } @{$name2columns{$name}}
      } keys %name2type
    },
  };
  GraphQL::Schema->from_ast(\@ast);
}

my $dbic_schema_class_track = 'CLASS00000';
sub produce {
  my $translator = shift;
  my $schema = $translator->schema;
  my $dbic_schema_class = ++$dbic_schema_class_track;
  my $dbic_translator = bless { %$translator }, ref $translator;
  $dbic_translator->producer_args({ prefix => $dbic_schema_class });
  eval SQL::Translator::Producer::DBIx::Class::File::produce($dbic_translator);
  die "Failed to make DBIx::Class::Schema: $@" if $@;
  my $graphql_schema = schema_dbic2graphql($dbic_schema_class->connect);
  $graphql_schema->to_doc;
}

=encoding utf-8

=head1 NAME

SQL::Translator::Producer::GraphQL - GraphQL schema producer for SQL::Translator

=begin markdown

# PROJECT STATUS

| OS      |  Build status |
|:-------:|--------------:|
| Linux   | [![Build Status](https://travis-ci.org/graphql-perl/SQL-Translator-Producer-GraphQL.svg?branch=master)](https://travis-ci.org/graphql-perl/SQL-Translator-Producer-GraphQL) |

[![CPAN version](https://badge.fury.io/pl/SQL::Translator::Producer::GraphQL.svg)](https://metacpan.org/pod/SQL::Translator::Producer::GraphQL)

=end markdown

=head1 SYNOPSIS

  use SQL::Translator;
  use SQL::Translator::Producer::GraphQL;
  my $t = SQL::Translator->new( parser => '...' );
  $t->producer('GraphQL');
  $t->translate;

=head1 DESCRIPTION

This module will produce a L<GraphQL::Schema> from the given
L<SQL::Translator::Schema>. It does this by first
turning it into a L<DBIx::Class::Schema> using
L<SQL::Translator::Producer::DBIx::Class::File>, and introspecting it.

Its C<Query> type represents a guess at what fields are suitable, based
on providing a lookup for each type (a L<DBIx::Class::ResultSource>)
by each of its columns.

=head1 ARGUMENTS

Currently none.

=head1 AUTHOR

Ed J, C<< <etj at cpan.org> >>

Based heavily on L<SQL::Translator::Producer::DBIxSchemaDSL>.

=head1 LICENSE

Copyright (C) Ed J

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
