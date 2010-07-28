class Tree::Optimizer;

INIT {
    pir::load_bytecode('Tree/Optimizer/Pass.pbc');
}

# %!passes is a Hash from pass names to corresponding Tree::Optimizer::Pass
# objects.
has %!passes;

# %!predecessors and %!successors are used to maintain the dependency graph
# of passes.
has %!predecessors;
has %!successors;

method new () {
    my $self := pir::new__PP(self.HOW.get_parrotclass(self));
    $self.BUILD();
    $self;
}

method BUILD () {
    %!passes := pir::new__PP(Hash);
    %!predecessors := pir::new__PP(Hash);
    %!successors := pir::new__PP(Hash);
}

method find-pass ($name) {
    %!passes{$name};
}

method register ($transformation, *%adverbs) {
    my $pass := Tree::Optimizer::Pass.new($transformation, |%adverbs);
    %!passes{$pass.name} := $pass;
    my $depends-on := %adverbs<depends-on>;
    if $depends-on {
        my @dependencies;
        if pir::isa__IPP($depends-on, String) {
            @dependencies := pir::split__PSS($depends-on, ' ');
        } else {
            @dependencies := $depends-on;
        }
        for @dependencies -> $dependency {
            self.add-dependency($pass.name, $dependency);
        }
    }
}

method add-dependency($dependent, $dependency) {
    %!predecessors{$dependent} := []
      unless pir::exists__IQS(%!predecessors, $dependent);
    %!predecessors{$dependent}.push($dependency);
    %!successors{$dependency} := []
      unless pir::exists__IQS(%!successors, $dependency);
    %!successors{$dependency}.push($dependent);
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
