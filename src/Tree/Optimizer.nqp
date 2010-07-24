class Tree::Optimizer;

INIT {
    pir::load_bytecode('Tree/Optimizer/Pass.pbc');
}

has @!passes;

method new () {
    my $self := pir::new__PP(self.HOW.get_parrotclass(self));
    $self.BUILD();
    $self;
}

# The BUILD method is necessary to initialize @!passes. If we only used
# indexing to accessing @!passes, it would be auto-vivified. Since we use
# push instead, we must manually initialize it.
method BUILD () {
    @!passes := [];
}

method find-pass ($name) {
    my $result;
    for @!passes -> $pass {
        if $pass.name eq $name {
            $result := $pass;
        }
    }
    $result;
}

method register ($transformation, *%adverbs) {
    @!passes.push(Tree::Optimizer::Pass.new($transformation, |%adverbs));
}

method run ($tree) {
    my $result := $tree;
    for @!passes -> $pass {
        $result := $pass.transformation($result);
    }
    $result;
}
