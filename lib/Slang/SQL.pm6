use QAST:from<NQP>;

sub perform(Str $statement, @args?, $cb?) is export {
  $*DB.do($statement, @args), return if !defined $cb;
  $statement.perl.say;
  my $sth = $*DB.prepare($statement) or die $!;
  $sth.execute(@args);
  while (my @row = $sth.fetchrow) {
    $cb(@row);
  }
  $sth.finish;
}

sub EXPORT(|) {
  role SQL::Grammar {
    rule statement_control:sym<with> {
      <sym>
      '('
        <arglist>
      ')'
      <sql>
      <block> 
    }
    token sql {
      .*? <?before '{'>
    }
  }
  role SQL::Actions {
    sub lk(Mu \h, \k) {
      nqp::atkey(nqp::findmethod(h, 'hash')(h), k)
    }
    method statement_control:sym<with>(Mu $/ is rw) {
      my $sql   := lk($/, 'sql');
      my $args  := lk($/, 'arglist').ast;
      my $cb    := lk($/, 'block');
      $args.name('&infix:<,>');

      my $block := QAST::Op.new(
                     :op<call>, 
                     :name<&perform>, 
                     QAST::SVal.new(:value($sql)),
                     $args,
                     defined($cb) ?? $cb.made !! Mu
                   );
      $/.'!make'($block);
    }
  }
  nqp::bindkey(%*LANG, 'MAIN', %*LANG<MAIN>.HOW.mixin(%*LANG<MAIN>, SQL::Grammar));
  nqp::bindkey(%*LANG, 'MAIN-actions', %*LANG<MAIN-actions>.HOW.mixin(%*LANG<MAIN-actions>, SQL::Actions));
  {}
}

