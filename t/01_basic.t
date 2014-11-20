#!/usr/bin/env perl6

use lib 'lib';
use Slang::SQL;
use DBIish;
use Test;

&Slang::SQL::sql('dead');
exit;
my $optout;

my $*DB = DBIish.connect(
  'SQLite', 
  :database<sqlite.sqlite3>,
) or $optout = 1;

if $optout == 1 {
  plan 1;
  ok True, 'Able to \'use\'';
  exit;
}

plan 32;

my @a     = 5;
my $count = 0; 

sql drop table if exists stuff; 
ok True, 'dropped table';
sql create table if not exists stuff (id integer, sid varchar(32));
ok True, 'created table';

for 1..100 {
  sql insert into stuff (id, sid) values (?, ?); with ($_, "SID $_");
}
ok True, 'insert didn\'t die, checking val count';

sql select * from stuff where id >= ?; with (@a) do -> $row {
  ok 'select * from stuff where id >= ?' eq $*STATEMENT, '$*STATEMENT set correctly' if $count++ == 0;
};
ok $count == 96, 'inserted record count is good';

$count = 25;
sql select * from stuff where
           id >= ?
       AND id <= ?; with (25,50) do -> $ROW {
  ok $ROW<id> eq $count && $ROW<sid> eq "SID $count", "row $count good";
  $count++;
};

$count = 0;
sql select * from stuff where sid like '%;%'; do -> $a {
  $count++;
};
ok $count == 0, 'no call back on something with no rows returned';

