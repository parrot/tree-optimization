class PAST::Optimizer::Transformer::Single
  is Tree::Optimizer::Transformer::Single { }

class PAST::Optimizer::Transformer::Combined
  is Tree::Optimizer::Transformer::Combined { }

INIT {
    pir::load_bytecode('PAST/Transformer.pbc');
    my $class := PAST::Optimizer::Transformer::Single;
    $class.HOW.add_parent($class,
                          PAST::Transformer);
    $class := PAST::Optimizer::Transformer::Combined;
    $class.HOW.add_parent($class,
                          PAST::Transformer);
}
