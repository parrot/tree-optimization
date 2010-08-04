INIT {
    pir::load_bytecode('Tree/Transformer.pbc');
}

class Tree::Optimizer::Transformer::Single is Tree::Transformer {
    has $!transform;

    method new ($transform) {
        my $self := pir::new__PP(self.HOW.get_parrotclass(self));
        $self.BUILD($transform);
        $self;
    }

    method BUILD ($transform) { $!transform := $transform; }

    method transform () { $!transform; }
}

class Tree::Optimizer::Transformer::Combined is Tree::Transformer {
    has @!passes;

    method new (@passes) {
        my $self := pir::new__PP(self.HOW.get_parrotclass(self));
        $self.BUILD(@passes);
        $self;
    }

    method BUILD (@passes) { @!passes := @passes; }

    method passes () { @!passes; }
}

module Tree::Walker {
    our multi walk (Tree::Optimizer::Transformer::Single $walker, $node) {
        my $result := $walker.transform()($node);
        replaceChildren($result, walkChildren($walker, $result))
          unless pir::isnull__IP($result);
        $result;
    }

    our multi walk (Tree::Optimizer::Transformer::Combined $walker, $node) {
        my $result := $node;
        for $walker.passes -> $pass {
            my $/ := $pass.when.ACCEPTS($result, :exact(1));
            $result := $pass.transformation()($/) if $/;
            last if pir::isnull__IP($result);
        }
        replaceChildren($result, walkChildren($walker, $result))
          unless pir::isnull__IP($result);
        $result;
    }
}
