#!/usr/bin/env parrot-nqp

pir::load_bytecode('Tree/Optimizer.pbc');

plan(2);

{
    my $opt := Tree::Optimizer.new;
    my $test-input := [];
    ok($test-input =:= $opt.run($test-input),
       'Tree::Optimizer without any registered passes returns the input.');
}

pir::load_bytecode('PCT.pbc');
pir::load_bytecode('PAST/Pattern.pbc');

{
    my sub build-past () {
        PAST::Val.new(:value(5));
    }
    my sub build-target () {
        PAST::Pattern::Val.new(:value(5));
    }
    my $opt := Tree::Optimizer.new;
    my &transform := sub ($v) {
        $v.value(-$v.value());
        $v;
    };
    $opt.register(&transform);
    ok($opt.run(build-past()) ~~ build-target(),
       'Simple Sub pass runs correctly.');
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
