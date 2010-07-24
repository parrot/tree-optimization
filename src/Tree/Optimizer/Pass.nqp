class Tree::Optimizer::Pass;

has $!name;
has $!transformation;

our multi method name () { $!name; }
our multi method name ($name) { $!name := $name; }

our multi method transformation () { $!transformation; }
our multi method transformation ($tran) { $!transformation := $tran; }

method new ($trans, *%adverbs) {
    my $self := pir::new__PP(self.HOW.get_parrotclass(self));
    $self.name(%adverbs<name> || '');
    $self.transformation($trans);
    $self;
}