class Tree::Optimizer::Pass;

has $!name;
has $!transformation;

our multi method name () { $!name; }
our multi method name ($name) { $!name := $name; }

our multi method transformation () { $!transformation; }
our multi method transformation ($tran) { $!transformation := $tran; }

method new ($trans, *%adverbs) {
    pir::die(" A pass' transformation must not be undefined.")
        unless pir::defined__IP($trans);
    my $self := pir::new__PP(self.HOW.get_parrotclass(self));
    $self.BUILD(:transformation($trans), |%adverbs);
    $self.name(%adverbs<name> || '');
    $self;
}

method BUILD (:$transformation, :$name, *%ignored) {
    $!name := $name || '';
    $!transformation := $transformation;
}

method run ($tree) {
    $!transformation($tree);
}
