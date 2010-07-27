#!/usr/bin/env parrot-nqp

pir::load_bytecode('Tree/Optimizer.pbc');

plan(10);

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

{
    my &square := sub ($x) {
        $x * $x;
    }
    my &negate := sub ($x) {
        -$x;
    }
    {
        my $opt := Tree::Optimizer.new;
        $opt.register(&square, :name<square>);
        $opt.register(&negate, :depends-on<square>);
        ok($opt.run(2) == -4,
           'Correct order when registering a pass after its dependency.');
    }
    {
        my $opt := Tree::Optimizer.new;
        $opt.register(&negate, :depends-on<square>);
        $opt.register(&square, :name<square>);
        ok($opt.run(2) == -4,
           'Correct order when registering a pass after its dependency.');
    }
    {
        my $opt := Tree::Optimizer.new;
        $opt.register(&negate, :name<negate>);
        $opt.register(&square, :depends-on<negate>);
        ok($opt.run(2) == 4,
           'Correct order is not coincidental.');
    }
}

{
    my &inc := sub ($n) { $n + 1; };
    my $opt := Tree::Optimizer.new;
    $opt.register(&inc);
    $opt.register(&inc);
    ok($opt.run(0) == 2,
       'Multipled unnamed passes are allowed.');
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
