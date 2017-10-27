use strict;
use Test::More 0.98;

use SQL::Translator;
use File::Spec;

sub do_test {
  my ($parser) = @_;
  my $t = SQL::Translator->new();
  $t->parser($parser);
  $t->filename(File::Spec->catfile('t', 'schema', lc "$parser.sql")) or die $t->error;
  $t->producer('GraphQL');
  my $result = $t->translate or die $t->error;
  is $result, <<'EOD', $parser;
type Author {
  age: Int
  get_module: [Module]
  id: Int
  message: String
  name: String
}

input AuthorInput {
  age: Int
  message: String
  name: String
}

scalar DateTime

type Module {
  author: Author
  author_id: Int
  id: Int
  name: String
}

input ModuleInput {
  name: String
}

type Query {
  authorByAge(age: Int!): [Author]
  authorById(id: Int!): Author
  authorByMessage(message: String!): [Author]
  authorByName(name: String!): [Author]
  moduleByAuthor_id(author_id: Int!): [Module]
  moduleById(id: Int!): Module
  moduleByName(name: String!): [Module]
}
EOD
}

for my $type (qw(MySQL SQLite)) {
  subtest $type => sub {
    do_test($type);
  };
}

done_testing;
