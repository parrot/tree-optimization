#!./parrot-nqp
# Copyright (C) 2010, Parrot Foundation.
# $Id$

class Tree::Walker {

    our multi sub walk (Tree::Walker $walker, Capture $node) {
        # By default, just walk the children of $node.
        walkChildren($walker, $node);
    }

    our multi sub walkChildren (Tree::Walker $walker, Capture $tree) {
        # We walk only the array part of the Capture by default, because
        # the attributes of PAST::Nodes, for example, can sometimes contain
        # cycles. In addition, in general, attributes are not used
        # for simple sub-trees.
        my $index := 0;
        my $len := pir::elements__iP($tree);
        while ($index < $len) {
            walk($walker, $tree[$index]);
            $index++;
        }
    }

    method walk ($node) {
        walk(self, $node);
    }

    method walkChildren ($node) {
        walkChildren(self, $node);
    }
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
