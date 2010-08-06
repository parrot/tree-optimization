class Tree::Optimizer;

INIT {
    pir::load_bytecode('Tree/Optimizer/Transformers.pbc');
    pir::load_bytecode('Tree/Optimizer/CombinedPass.pbc');
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
    my $pass;
    if $transformation ~~ Tree::Optimizer::Pass {
        $pass := $transformation.clone;
        if pir::exists__IQs(%adverbs, 'depends-on') {
            if pir::isa__IPP(%adverbs<depends-on>, String) {
                $pass.dependencies.push(%adverbs<depends-on>);
            } else {
                $pass.dependencies.append(%adverbs<depends-on>);
            }
        }
        $pass.name(%adverbs<name>) if pir::exists__IQs(%adverbs, 'name');
    } else {
        $pass := Tree::Optimizer::Pass.new($transformation, |%adverbs);
    }
    %!passes{$pass.name} := $pass;
    for $pass.dependencies -> $dependency {
        self.add-dependency($pass.name, $dependency);
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

method run ($tree, :$combine) {
    my $result := $tree;
    for self.pass-order(:combine($combine)) -> $pass {
        $result := self.run-pass($pass, $result);
    }
    $result;
}

method run-pass ($pass, $tree) {
    $pass.run($tree);
}

method combine-passes (*@passes) {
    Tree::Optimizer::CombinedPass.new(@passes);
}

method pass-order (:$combine) {
    my @result;
    my @no-preds;
    my @combine-buffer;
    for %!passes {
        @no-preds.push($_.key) unless
          pir::exists__IQs(%!predecessors, $_.key);
    }
    my %old-preds := pir::clone__PP(%!predecessors);
    my %old-succs := pir::clone__PP(%!successors);
    while +@no-preds != 0 {
        my $name := @no-preds.pop;
        my $pass := self.find-pass($name);
        if $combine {
            if pir::defined__IP($pass.when) && $pass.recursive {
                @combine-buffer.push($pass);
            } else {
                @result.push(self.combine-passes(|@combine-buffer));
                @combine-buffer := [];
                @result.push($pass);
            }
        } else {
            @result.push($pass);
        }
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
    @result.push(self.combine-passes(|@combine-buffer))
      if $combine && @combine-buffer;
    @result;
}
