sub perform(Str $statement?, @args?, $cb?) is export {
  'here'.say;
  $statement.say;
  @args.say;
}

sub EXPORT(|) {
  role SQL::Grammar {
    rule statement_control:sym<with> {
      <sym>
      '('
        <arglist>
      ')'
      <sql>
      <block=.block>
    }
    token sql {
      .*? <?before '{'>
    }
  }
  role SQL::Actions {
    method statement_control:sym<with>(Mu $/) {
      #make $<sym>;
      say(~$<sym>);
      #say($<args>);
      #QAST::Op.new(:op('call'), :name('&perform'), QAST::SVal.new(:value('sql')));
    }
  }
  nqp::bindkey(%*LANG, 'MAIN', %*LANG<MAIN>.HOW.mixin(%*LANG<MAIN>, SQL::Grammar));
  nqp::bindkey(%*LANG, 'MAIN-actions', %*LANG<MAIN>.HOW.mixin(%*LANG<MAIN-actions>, SQL::Actions));
  {}
}

