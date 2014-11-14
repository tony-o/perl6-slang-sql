#!/usr/bin/env perl6

use lib 'lib';
use Slang::SQL;

my @a = 5;
with (@a) select * from stuff where id >= ? {
  'hello'.say;
};

