#!/usr/bin/env perl6

use lib 'lib';
use Slang::SQL;

my @a = 5, 50;
with (@a) select * from stuff where id >= ? {
  'hello'.say;
};

with (25,50) select * from stuff where
                id >= ?
            AND id <= ? {

}
