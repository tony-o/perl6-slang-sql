#Slang::SQL

Quick little SQL SLang for perl6 to embed SQL into the language.  Design goals were:

* accept parameters
* not have to quote your sql 
* treat SQL statements that return something as loops
* have optional parameters/callback

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

