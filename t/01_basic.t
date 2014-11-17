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

exec drop table stuff;
exec create table if not exists stuff (id integer, sid varchar(32));
for 1..100 {
  exec insert into stuff (id, sid) values (?, ?); with ($_);
}
exec select * from stuff where id >= ?; with (@a) do {
  say $*STATEMENT if $count++ == 0;
}
exec select * from stuff where
           id >= ?
       AND id <= ?; with (25,50) do {

};

exec select * from stuff where sid like '%;%'; do {

};

say $count == 96;

#with () select * from stuff where sid like '%{%' {
#  'here'.say;
#};

'done'.say;
