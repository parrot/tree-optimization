class PAST::Optimizer::Pass is Tree::Optimizer::Pass;

method transformer-class () {
    PAST::Optimizer::Transformer::Single;
}
