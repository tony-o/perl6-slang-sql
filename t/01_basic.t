#!/usr/bin/env perl6

use lib 'lib';
use Slang::SQL;
use DBIish;

my $*DB = DBIish.connect(
  'SQLite', 
  :database<sqlite.sqlite3>,
);

my @a = 5;

with () drop table stuff { };
with () create table if not exists stuff (id integer, sid varchar(32)) { };

for 1..100 { 
  with ($_, "SID: $_") insert into stuff (id, sid) values (?, ?) { };
}

my $count = 0; 
with (@a) select * from stuff where id >= ? {
  $count++;
};

say $count == 96;

with (25,50) select * from stuff where
                id >= ?
            AND id <= ? {

};

'done'.say;
