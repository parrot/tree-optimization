class Tree::Optimizer::CombinedPass;

has $!transformer;

method new (@passes) {
    my $self := pir::new__PP(self.HOW.get_parrotclass(self));
    $self.BUILD(:passes(@passes));
    $self;
}

method BUILD (:@passes) {
    $!transformer := Tree::Optimizer::Transformer::Combined.new(@passes)
}

method run ($tree) {
    $!transformer.walk($tree);
}
