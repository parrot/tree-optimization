#!/usr/bin/env parrot-nqp

INIT {
    pir::load_bytecode('Tree/Optimizer.pbc');
}

plan(1);

{
    my $opt := Tree::Optimizer.new;
    my $test-input := [];
    ok($test-input =:= $opt.run($test-input),
       'Tree::Optimizer without any registered passes returns the input.');
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
