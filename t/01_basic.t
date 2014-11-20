#!/usr/bin/env perl6

use lib 'lib';
use Slang::SQL;
use DBIish;

my $*DB = DBIish.connect(
  'SQLite', 
  :database<sqlite.sqlite3>,
);

my @a     = 5;
my $count = 0; 

exec drop table if exists stuff; 
exec create table if not exists stuff (id integer, sid varchar(32));

for 1..100 {
  exec insert into stuff (id, sid) values (?, ?); with ($_, "SID $_");
}

exec select * from stuff where id >= ?; with (@a) do -> $row {
  $row.perl.say;
  say $*STATEMENT if $count++ == 0;
};

exec select * from stuff where
           id >= ?
       AND id <= ?; with (25,50) do -> $ROW {
  'here'.say;
  $ROW.perl.say;
};

exec select * from stuff where sid like '%;%'; do -> $ROW {
  $ROW.perl.say;
};

say $count == 96;

'done'.say;
