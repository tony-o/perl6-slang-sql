use QAST:from<NQP>;

sub perform(Str $statement, @args?, $cb?) is export {
  $*DB.do($statement, @args), return if !defined $cb;
  return if !defined $cb;
  my $*STATEMENT ::= $statement;
  my $sth = $*DB.prepare($statement);# or die $!;
  $sth.execute(@args);
  while (my @*ROW = $sth.fetchrow) {
    $cb();
  }
  $sth.finish;
}

sub EXPORT(|) {
  role SQL::Grammar {
    rule statement_control:sym<exec> {
      <sym>  
      <sql>
      [
        | ''
        | ';'
          'with'
          '('
            <arglist>
          ')'
      ]
      [ 
        | ''
        | 'do'
          <block>
      ]
    }
    token sql {
      .+? <before <eosql>> 
    }
    token eosql {
      ';' 
      [ 'with' || 'do' || $$ ]
    }
  }
  role SQL::Actions {
    sub lk(Mu \h, \k) {
      nqp::atkey(nqp::findmethod(h, 'hash')(h), k)
    }
    method statement_control:sym<exec>(Mu $/ is rw) {
      my $sql   := lk($/, 'sql');
      #my $args  := lk($/, 'arglist').ast;
      say('SQL');
      say($sql.Str);
      say('/SQL');
      #say(lk($/, 'arglist').Str);
      #my $cb    := lk($/, 'blockoid');
      #$args.name('&infix:<,>');
      #my $block := QAST::Op.new(
      #               :op<call>, 
      #               :name<&perform>, 
      #               QAST::SVal.new(:value($sql)),
      #               $args,
      #               defined($cb) ?? $cb.made !! QAST::IVal.new(:value(0))
      #             );
      #$/.'!make'($block);
    }
  }
  nqp::bindkey(%*LANG, 'MAIN', %*LANG<MAIN>.HOW.mixin(%*LANG<MAIN>, SQL::Grammar));
  nqp::bindkey(%*LANG, 'MAIN-actions', %*LANG<MAIN-actions>.HOW.mixin(%*LANG<MAIN-actions>, SQL::Actions));
  {}
}

