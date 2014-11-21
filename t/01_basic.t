#!/usr/bin/env perl6

use lib 'lib';
use Slang::SQL;
use DBIish;
use Test;


my $optout; #of testing because of no drivers.

my $*DB = DBIish.connect(
  'SQLite', 
  :database<sqlite.sqlite3>,
) or $optout = 1;

if $optout == 1 {
  plan 2;
  ok True, 'Able to \'use\'';
  ok True, 'Please install SQLite drivers for full test';
  exit;
}

plan 18;

my @a     = 5;
my $count = 0; 

sql drop table if exists stuff; 
ok True, 'dropped table';

sql create table if not exists stuff (id integer, sid varchar(32));
ok True, 'created table';

try {
  sql this statement will die;
  CATCH {
    default {
      ok True, 'contained a sql error';
      #$*DB.errstr.say;
    }
  }
};

for 1..100 {
  sql insert into stuff (id, sid) values (?, ?); with ($_, "SID $_");
}
ok True, 'insert didn\'t die, checking val count';

sql select * from stuff where id >= ?; with (@a) do -> $row {
  ok 'select * from stuff where id >= ?' eq $*STATEMENT, '$*STATEMENT set correctly' if $count++ == 0;
};
ok $count == 96, 'inserted record count is good';

$count = 0;
sql select * from stuff; do -> $row {
  $count++;
  last;
}
ok $count == 1, 'testing \'last\' keyword in sql loop';


my $truf = True;
my $s1   = '';
my $s2   = '';
sql select * from stuff order by id asc; do -> $row {
  $s1 = $*STATEMENT;
  sql select count(*) from stuff where id > ?; with ($row<id>) do -> $count {
    $s2 = $*STATEMENT;
    $truf = False if 100 - $row<id> != $count<count(*)>;
  };
};
ok $truf, 'Nested SQLs works!';
ok $s1 eq 'select * from stuff order by id asc', '$*STATEMENT is correct in nested sql';
ok $s2 eq 'select count(*) from stuff where id > ?', '$*STATEMENT is correct in nested sql';


$count = 25;
sql select * from stuff where
           id >= ?
       AND id <= ?; with (25,30) do -> $ROW {
  ok $ROW<id> eq $count && $ROW<sid> eq "SID $count", "row $count good";
  $count++;
};

$count = 0;
sql select * from stuff where sid like '%;%'; do -> $a {
  $count++;
};
ok True, 'A ; surrounded by \' didn\'t affect parsing';
ok $count == 0, 'no call back on something with no rows returned';

#this doesn't work:
#sql drop table if exists stuff;  if False;

