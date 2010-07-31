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

module Tree::Walker {
    our multi walk (Tree::Optimizer::Transformer::Single $walker, $node) {
        my $result := $walker.transform()($node);
        replaceChildren($result, walkChildren($walker, $result));
        $result;
    }
}
