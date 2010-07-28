class Tree::Optimizer;

INIT {
    pir::load_bytecode('Tree/Optimizer/Pass.pbc');
}

# %!passes is a Hash from pass names to corresponding Tree::Optimizer::Pass
# objects.
has %!passes;

method new () {
    my $self := pir::new__PP(self.HOW.get_parrotclass(self));
    $self.BUILD();
    $self;
}

# The BUILD method is necessary to initialize @!passes. If we only used
# indexing to accessing @!passes, it would be auto-vivified. Since we use
# push instead, we must manually initialize it.
method BUILD () {
    %!passes := pir::new__PP(Hash);
}

method find-pass ($name) {
    %!passes{$name};
}

method register ($transformation, *%adverbs) {
    my $pass := Tree::Optimizer::Pass.new($transformation, |%adverbs);
    %!passes{$pass.name} := $pass;
}

method run ($tree) {
    my $result := $tree;
    for self.pass-order -> $pass {
        $result := self.run-pass($pass, $result);
    }
    $result;
}

method run-pass ($pass, $tree) {
    $pass.run($tree);
}

method pass-order () {
    my @result;
    for %!passes {
        @result.push($_.value);
    }
    @result;
}
