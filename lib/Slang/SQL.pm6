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
      [ \'.*?\' || \".*?\" || .]*? )> <before ';'>
    }
  }
  role SQL::Actions {
    sub lk(Mu \h, \k) {
      nqp::atkey(nqp::findmethod(h, 'hash')(h), k)
    }
    method statement_control:sym<exec>(Mu $/ is rw) {
      my $sql   := lk($/, 'sql');
      my $args  := lk($/, 'arglist');
      my $cb    := lk($/, 'block');
      if $args.WHAT !~~ Mu {
        $args := $args.ast;
        $args.name('&infix:<,>');
      }
      my $args2 := Array; #QAST::Var.new(:name<Nil>, :scope<lexical>);
      my $block := QAST::Op.new(
                     :op<call>, 
                     :name<&perform>, 
                     QAST::SVal.new(:value($sql)),
                     $args2, #$args.WHAT !~~ Mu ?? $args !! $args2,
                     #$cb
                   );
      $/.'!make'($block);
    }
  }
  nqp::bindkey(%*LANG, 'MAIN', %*LANG<MAIN>.HOW.mixin(%*LANG<MAIN>, SQL::Grammar));
  nqp::bindkey(%*LANG, 'MAIN-actions', %*LANG<MAIN-actions>.HOW.mixin(%*LANG<MAIN-actions>, SQL::Actions));
  {}
}

