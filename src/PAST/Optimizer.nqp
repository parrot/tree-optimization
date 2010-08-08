INIT {
    pir::load_bytecode('Tree/Optimizer.pbc');
    pir::load_bytecode('PAST/Optimizer/Pass.pbc');
    pir::load_bytecode('PAST/Optimizer/CombinedPass.pbc');
    pir::load_bytecode('PAST/Optimizer/Transformers.pbc');
}

class PAST::Optimizer is Tree::Optimizer;

method pass-class () {
    PAST::Optimizer::Pass;
}

method combine-passes (*@passes) {
    PAST::Optimizer::CombinedPass.new(@passes);
}
