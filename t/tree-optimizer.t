#!/usr/bin/env parrot-nqp

pir::load_bytecode('Tree/Optimizer.pbc');

plan(6);

{
    my $opt := Tree::Optimizer.new;
    my $test-input := [];
    ok($test-input =:= $opt.run($test-input),
       'Tree::Optimizer without any registered passes returns the input.');
}

{
    my $opt := Tree::Optimizer.new;
    my &transform := sub ($past) { $past; };
    $opt.register(&transform, :name<identity>);
    ok(1, 'A :name adverb can be supplied to Tree::Optimizer.register.');
    ok($opt.find-pass('identity') ~~ Tree::Optimizer::Pass,
       'Tree::Optimizer.find-pass returns a Tree::Optimizer::Pass, if found.');
    ok($opt.find-pass('identity').transformation =:= &transform,
       'Tree::Optimizer.find-pass returns a pass with correct .transformation.');

    ok(!pir::defined__IP($opt.find-pass('nonexistent-pass')),
       'Tree::Optimizer.find-pass with a non-existent name returns undef.');
}

{
    my $opt := Tree::Optimizer.new;
    my &transform := sub ($v) {
        -$v;
    };
    $opt.register(&transform);
    ok($opt.run(5) == -5,
       'Simple Sub pass runs correctly.');
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
