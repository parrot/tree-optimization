class Tree::Optimizer::Pass;

INIT {
    pir::load_bytecode('Tree/Optimizer/Transformers.pbc');
}

has $!name;
has $!recursive;
has $!transformation;
has $!when;

our multi method name () { $!name; }
our multi method name ($name) { $!name := $name; }

our multi method transformation () { $!transformation; }
our multi method transformation ($tran) { $!transformation := $tran; }

method new ($trans, *%adverbs) {
    pir::die(" A pass' transformation must not be undefined.")
        unless pir::defined__IP($trans);
    my $self := pir::new__PP(self.HOW.get_parrotclass(self));
    $self.BUILD(:transformation($trans), |%adverbs);
    $self;
}

my $current-gen-name := 0;
sub gen-name () {
    '__unnamed_' ~ $current-gen-name++;
}
method BUILD (:$transformation, :$name, :$recursive, :$when, *%ignored) {
    $!name := $name || gen-name();
    $!recursive := $recursive || 0;
    $!transformation := $transformation;
    $!when := $when;
}

method run ($tree) {
    if $!recursive {
        self.generate-transformer.walk($tree);
    } elsif pir::defined__IPP($!when) {
        my $/ := $tree ~~ $!when;
        if $/ {
            $!transformation($/);
        } else {
            $tree;
        }
    } else {
        $!transformation($tree);
    }
}

method generate-transformer () {
    if pir::defined__IP($!when) {
        $!when.transformer_class.new($!when, $!transformation);
    } else {
        Tree::Optimizer::Transformer::Single.new($!transformation);
    }
}
