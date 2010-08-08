class Tree::Optimizer::CombinedPass;

has $!transformer;

method new (@passes) {
    my $self := pir::new__PP(self.HOW.get_parrotclass(self));
    $self.BUILD(:passes(@passes));
    $self;
}

method BUILD (:@passes) {
    $!transformer := self.transformer-class.new(@passes)
}

method transformer-class () {
    Tree::Optimizer::Transformer::Combined;
}

method run ($tree) {
    $!transformer.walk($tree);
}
