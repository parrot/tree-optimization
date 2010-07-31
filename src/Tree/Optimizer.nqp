class Tree::Optimizer;

INIT {
    pir::load_bytecode('Tree/Optimizer/Pass.pbc');
    pir::load_bytecode('nqp-setting.pbc');
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
            @dependencies := pir::split__PSS(' ', $depends-on);
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

sub find (@array, $elem) {
    my $index := 0;
    my $found := 0;
    for @array {
        if $_ eq $elem {
            ++$found;
            last;
        }
        ++$index;
    }
    if $found {
        $index;
    } else {
        -1;
    }
}

method remove-dependency ($dependent, $dependency) {
    pir::die("Can't remove dependency: $dependent does not depend on $dependency.")
        unless %!predecessors{$dependent} && %!successors{$dependency};
    my $pred-index := find(%!predecessors{$dependent}, $dependency);
    my $succ-index := find(%!successors{$dependency}, $dependent);
    pir::die("Can't remove dependency: $dependent does not depend on $dependency.")
        if $pred-index == -1 || $succ-index == -1;
    if +%!predecessors{$dependent} != 1 {
        %!predecessors{$dependent}.delete($pred-index);
    } else {
        %!predecessors.delete($dependent);
    }
    if +%!successors{$dependency} != 1 {
        %!successors{$dependency}.delete($succ-index);
    } else {
        %!successors.delete($dependency);
    }
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
    my @no-preds;
    for %!passes {
        @no-preds.push($_.key) unless
          pir::exists__IQs(%!predecessors, $_.key);
    }
    my %old-preds := pir::clone__PP(%!predecessors);
    my %old-succs := pir::clone__PP(%!successors);
    while +@no-preds != 0 {
        my $name := @no-preds.pop;
        @result.push(self.find-pass($name));
        for %!successors{$name} -> $dependent {
            self.remove-dependency($dependent, $name);
            unless %!predecessors{$dependent} &&
              +%!predecessors{$dependent} != 0 {
                @no-preds.push($dependent);
            }
        }
    }
    if +%!successors || +%!predecessors {
        %!predecessors := %old-preds;
        %!successors := %old-succs;
        pir::die('Cyclical dependency graph.') 
    }
    %!predecessors := %old-preds;
    %!successors := %old-succs;
    @result;
}
