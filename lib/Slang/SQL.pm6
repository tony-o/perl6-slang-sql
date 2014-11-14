use QAST:from<NQP>;

sub perform(Str $statement, Mu $args?, $cb?) is export {
  "performing: $statement".say;
  @$args.perl.say;
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
      my $args  := lk($/, 'arglist');
      my $block := QAST::Op.new(
                     :op<call>, 
                     :name<&perform>, 
                     QAST::SVal.new(:value(lk($/, 'sql'))),
                     QAST::Var.new(:name(lk($/, 'arglist')), :scope<lexical>)
                   );
      $/.'!make'($block);
    }
  }
  nqp::bindkey(%*LANG, 'MAIN', %*LANG<MAIN>.HOW.mixin(%*LANG<MAIN>, SQL::Grammar));
  nqp::bindkey(%*LANG, 'MAIN-actions', %*LANG<MAIN-actions>.HOW.mixin(%*LANG<MAIN-actions>, SQL::Actions));
  {}
}

