sub perform(Str $statement?, @args?, $cb?) {
  'here'.say;
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
    method statement_control:sym<with>(Mu $/) {
#      my $block = QAST::Block.new(
        QAST::Op.new( :op('say'), QAST::SVal.new( :value('Str') ) );
#      );
#      QAST::CompUnit.new(
#        $block,
#        :main(QAST::Stmts.new(
#          QAST::Op.new( :op('call'), QAST::BVal.new( :value($block) ) ) )
#        )
#      );
    }
  }
  nqp::bindkey(%*LANG, 'MAIN', %*LANG<MAIN>.HOW.mixin(%*LANG<MAIN>, SQL::Grammar));
  nqp::bindkey(%*LANG, 'MAIN-actions', %*LANG<MAIN>.HOW.mixin(%*LANG<MAIN-actions>, SQL::Actions));
  {}
}

