#Slang::SQL

Quick little SQL SLang for perl6 to embed SQL into the language.  Design goals were:

* accept parameters
* not have to quote your sql 
* treat SQL statements that return something as loops
* have optional parameters/callback
* nested SQLs
* loop control ```last```, ```next``` ..

What it doesn't do [yet]

* interpolate variables in the SQL
* verify your SQL syntax is correct
* handle your DB connection (currently depends on DBIish)
* auto parameters based on SQL (PerlJam's suggestion, it's a cool idea)

#Use

```perl6
use Slang::SQL;
use DBIish;

my $*DB = DBIish.connect('SQLite', :database<sqlite.sqlite3>);

sql drop table if exists stuff; #runs 'drop table if exists stuff';

sql create table if not exists stuff (
      id  integer,
      sid varchar(32)
    );

for 0..5 {
  sql insert into stuff (id, sid) 
    values (?, ?); with ($_, ('A'..'Z').pick(16).join(''));
}

sql select * from stuff order by id asc; do -> $row {
  $*STATEMENT.say if $row<id> == 0;
  "id\tsid".say   if $row<id> == 0;
  "{$row<id>}\t{$row<sid>}".say;
};
```

Output:

```
select * from stuff order by id asc
id      sid
0       WSNPLYBHJRMVXKFQ
1       UYNZMXFSABRCOLKP
2       MIQVEDTNXBWGHZFL
3       KFNJWXLSRQEUGBZA
4       VDOMIUYCWQZHGRPF
5       TMRDZOKJQNWFGBUP
```

##Equivalent Code Slang vs. Only DBIish

###Example Above

####Slang::SQL

```perl6
use Slang::SQL;
use DBIish;

my $*DB = DBIish.connect('SQLite', :database<sqlite.sqlite3>);

sql drop table if exists stuff; #runs 'drop table if exists stuff';

sql create table if not exists stuff (
      id  integer,
      sid varchar(32)
    );

for 0..5 {
  sql insert into stuff (id, sid) 
    values (?, ?); with ($_, ('A'..'Z').pick(16).join(''));
}

sql select * from stuff order by id asc; do -> $row {
  $*STATEMENT.say if $row<id> == 0;
  "id\tsid".say   if $row<id> == 0;
  "{$row<id>}\t{$row<sid>}".say;
};
```

####DBIish

```perl6
use DBIish;

my $db = DBIish.connect('SQLite', :database<sqlite.sqlite3>);

$db.do('drop table if exists stuff;');

$db.do('create table if not exists stuff (
          id  integer,
          sid varchar(32)
        )');

for 0..5 {
  $db.do('insert into stuff (id, sid) 
            values(?,?);', ($_, ('A'..'Z').pick(16).join('')));
}

my $sql  = 'select * from stuff order by id asc';
my $stmt = $db.prepare($sql);

$stmt.execute();
while (my $row = $stmt.fetchrow_hashref) {
  $sql.say if $row<id> == 0;
  "id\tsid".say; if $row<id> == 0;
  "{$row<id>}\t{$row<sid>}".say;
}
$stmt.finish;
```

###Nested SQL

####Slang::SQL

```perl6
use Slang::SQL;
use DBIish;

my $*DB = DBIish.connect('SQLite', :database<sqlite.sqlite3>);

sql select * from stuff order by id asc; do -> $row1 {
  sql select * from stuff where id > ?; with ($row1<id>) do -> $row2 {
    #do something with $row1 or $row2!
  };
};
```

####DBIish

```perl6
use DBIish;

my $db = DBIish.connect('SQLite', :database<sqlite.sqlite3>);

my $sql1 = 'select * from stuff order by id asc';
my $sql2 = 'select * from stuff where id > ?';
my $stm1 = $db.prepare($sql1);
my $stm2 = $db.prepare($sql2);

$stm1.execute();
while (my $row1 = $stm1.fetchrow_hashref) {
  $stm2.execute($row1<id>);
  while (my $row2 = $stm2.fetchrow_hashref) {
    #do something here
  }
}

```

##Mo Better Examples

Check out ```t/01_basic.t```
