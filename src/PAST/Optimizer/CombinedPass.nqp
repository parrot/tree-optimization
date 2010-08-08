class PAST::Optimizer::CombinedPass is Tree::Optimizer::CombinedPass;

method transformer-class () {
    PAST::Optimizer::Transformer::Combined;
}
