INIT {
    pir::load_bytecode('PAST/Transformer.pbc');
    pir::load_bytecode('Tree/Pattern/Transformer.pbc');
}

class PAST::Pattern::Transformer is Tree::Pattern::Transformer {
    PAST::Pattern::Transformer.HOW.add_parent(PAST::Pattern::Transformer,
                                              PAST::Transformer);
}
