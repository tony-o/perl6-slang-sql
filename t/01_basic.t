#!/usr/bin/env perl6

use lib 'lib';
use Slang::SQL;
use DBIish;

my $*DB = DBIish.connect(
  'SQLite', 
  :database<sqlite.sqlite3>,
);

my @a = 5, 50;

with () create table stuff (integer id) { }

with (@a) select * from stuff where id >= ? {
  'hello'.say;
}

with (25..50) select * from stuff where
                id >= ?
            AND id <= ? {

}

'done'.say;
