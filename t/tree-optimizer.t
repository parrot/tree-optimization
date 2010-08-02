#!/usr/bin/env parrot-nqp

pir::load_bytecode('Tree/Optimizer.pbc');

plan(23);

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
    ok($opt.run(5) == -5,
       'Tree::Optimizer.run works repeatedly.');
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
        ok($opt.run(2) == -4,
           'Repeated correct order when registering a pass after its dependency.');
    }
    {
        my $opt := Tree::Optimizer.new;
        $opt.register(&negate, :depends-on<square>);
        $opt.register(&square, :name<square>);
        ok($opt.run(2) == -4,
           'Correct order when registering a pass after its dependency.');
        ok($opt.run(2) == -4,
           'Repeated correct order when registering a pass after its dependency.');
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

{
    class Even {
        method ACCEPTS ($n) {
            if $n % 2 == 0 {
                $n / 2;
            } else {
                0;
            }
        }
    }
    my &inc := sub ($n) { 2 * $n + 1; };
    {
        my $opt := Tree::Optimizer.new;
        $opt.register(&inc, :when(Even.new));
        ok($opt.run(2) == 3,
           'A pass with :when runs correctly when matching.');
    }
    {
        my $opt := Tree::Optimizer.new;
        $opt.register(&inc, :when(Even.new));
        ok($opt.run(1) == 1,
           'A pass with :when correctly does nothing when not matching.');
    }
}

pir::load_bytecode('PCT.pbc');
pir::load_bytecode('PAST/Pattern.pbc');
{
    my $past := PAST::Stmts.new(PAST::Val.new(:value(6)));
    my &inc := sub transform ($node) {
        if $node.match(PAST::Pattern::Val.new, :exact(1)) {
            $node.value($node.value + 1);
        }
        $node;
    };
    {
        my $target :=
          PAST::Pattern::Stmts.new(PAST::Pattern::Val.new(:value(6)));
        my $opt := Tree::Optimizer.new;
        $opt.register(&inc);
        ok($opt.run($past.clone) ~~ $target,
           'A pass without :recursive does not recurse.');
    }
    {
        my $target :=
          PAST::Pattern::Stmts.new(PAST::Pattern::Val.new(:value(7)));
        my $opt := Tree::Optimizer.new;
        $opt.register(&inc, :recursive(1));
        ok($opt.run($past.clone) ~~ $target,
           'A pass with :recursive correctly recurses.');
    }
}

{
    my $past := PAST::Stmts.new(PAST::Val.new(:value(6)));
    my &inc := sub ($/) {
        $/.orig.value($/.orig.value + 1);
        $/.orig;
    };
    my $pattern := PAST::Pattern::Val.new;
    {
        my $target :=
          PAST::Pattern::Stmts.new(PAST::Pattern::Val.new(:value(6)));
        my $opt := Tree::Optimizer.new;
        $opt.register(&inc, :when($pattern));
        ok($opt.run($past.clone) ~~ $target,
           ':when patterns do not recurse unless :recursive is supplied.');
    }
    {
        my $target :=
          PAST::Pattern::Stmts.new(PAST::Pattern::Val.new(:value(7)));
        my $opt := Tree::Optimizer.new;
        $opt.register(&inc, :when($pattern), :recursive(1));
        ok($opt.run($past.clone) ~~ $target,
           ':when patterns do recurse with :recursive.');
    }
}

{
    class TransformCounter {
        has $!count;
        has $!pattern;

        our multi method count ($count) { $!count := $count; }
        our multi method count () { $!count; }

        our multi method pattern ($pattern) { $!pattern := $pattern; }
        our multi method pattern () { $!pattern; }

        method transformer_class () {
            $!count++;
            $!pattern.transformer_class;
        }

        method ACCEPTS(*@_, *%_) {
            $!pattern.ACCEPTS(|@_, |%_);
        }
    }
    sub countTransforms ($pattern) {
        my $ret := TransformCounter.new;
        $ret.count(0);
        $ret.pattern($pattern);
        $ret;
    }
    my $opt := Tree::Optimizer.new;
    my &inc := sub ($/) {
        $/.orig.value($/.orig.value + 1);
        $/.orig;
    };
    my &double := sub ($/) {
        $/.orig.value($/.orig.value * 2);
        $/.orig;
    }
    my $pattern := countTransforms(PAST::Pattern::Val.new);
#    my $pattern := PAST::Pattern::Val.new;
    $opt.register(&inc, :name<inc>,
                  :when($pattern), :recursive(1));
    $opt.register(&double, :depends-on<inc>,
                  :when($pattern), :recursive(1));

    my $past := PAST::Val.new(:value(6));
    my $target := PAST::Pattern::Val.new(:value(14));
    ok($opt.run($past.clone) ~~ $target,
       ':combine test optimizer runs correctly without combine.');
    ok($pattern.count == 2,
       'Without :combine, the test optimizer calls .transform twice.');
    ok($opt.run($past.clone, :combine(1)) ~~ $target,
       ':combine produces same result as without it.');
    ok($pattern.count == 2,
       'With :combine, .transform is not called.');
    
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
