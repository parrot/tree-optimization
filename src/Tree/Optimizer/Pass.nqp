class Tree::Optimizer::Pass;

has @!dependencies;
has $!name;
has $!recursive;
has $!transformation;
has $!when;

our multi method dependencies () { @!dependencies; }
our multi method dependencies (@deps) { @!dependencies := @deps; }

our multi method name () { $!name; }
our multi method name ($name) { $!name := $name; }

our multi method recursive () { $!recursive; }
our multi method recursive ($recursive) { $!recursive := $recursive; }

our multi method transformation () { $!transformation; }
our multi method transformation ($tran) { $!transformation := $tran; }

our multi method when () { $!when; }
our multi method when ($when) { $!when := $when; }

method new ($trans, *%adverbs) {
    pir::die(" A pass' transformation must not be undefined.")
        unless pir::defined__IP($trans);
    my $self := pir::new__PP(self.HOW.get_parrotclass(self));
    $self.BUILD(:transformation($trans), |%adverbs);
    $self;
}

method clone () {
    self.new($!transformation, :name($!name), :recursive($!recursive),
             :when($!when), :depends-on(pir::clone__PP(@!dependencies)));
}

my $current-gen-name := 0;
sub gen-name () {
    '__unnamed_' ~ $current-gen-name++;
}
method BUILD (:$transformation, :$name, :$recursive, :$when, *%rest) {
    $!name := $name || gen-name();
    $!recursive := $recursive || 0;
    $!transformation := $transformation;
    $!when := $when;
    my $depends-on := %rest<depends-on>;
    if $depends-on {
        @!dependencies := (pir::isa__IPP($depends-on, String)
                           ?? [ $depends-on ] 
                           !! $depends-on);
    } else {
        @!dependencies := [];
    }
}

method run ($tree) {
    if $!recursive {
        self.generate-transformer.walk($tree);
    } elsif pir::defined__IPP($!when) {
        my $/ := $!when.ACCEPTS($tree, :exact(1));
        if $/ {
            $!transformation($/);
        } else {
            $tree;
        }
    } else {
        $!transformation($tree);
    }
}

method transformer-class () {
    Tree::Optimizer::Transformer::Single;
}

method generate-transformer () {
    if pir::defined__IP($!when) {
        $!when.transformer_class.new($!when, $!transformation);
    } else {
        self.transformer-class.new($!transformation);
    }
}
