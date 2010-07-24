class Tree::Optimizer;

has @!passes;

method register ($transformation) {
    @!passes.push($transformation);
}

method run ($tree) {
    my $result := $tree;
    for @!passes -> $pass {
        $result := $pass($result);
    }
    $result;
}
