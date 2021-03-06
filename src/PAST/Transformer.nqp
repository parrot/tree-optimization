#!./parrot-nqp
# Copyright (C) 2010, Parrot Foundation.
# $Id$

INIT {
    pir::load_bytecode('Tree/Transformer.pbc');
}

class PAST::Transformer is Tree::Transformer {
    our multi method walkable ($node) { 0; }
    our multi method walkable (PAST::Node $node) { 1; }
}

module Tree::Walker {
    our multi sub walkChildren (PAST::Transformer $walker, Integer $str) { }
    our multi sub replaceChildren (Integer $str, $newChildren) { }
    our multi sub walkChildren (PAST::Transformer $walker, String $str) { }
    our multi sub replaceChildren (String $str, $newChildren) { }

    our multi sub walkChildren (PAST::Transformer $walker,
                                PAST::Block $block) {
        my $results := pir::new__PP(Capture);
        my $index := 0;
        my $max := pir::elements__IP($block);
        while ($index < $max) {
            $results[$index] := walk($walker, $block[$index]);
            $index++;
        }
        $results<control> := $walker.walk($block.control)
          if $walker.walkable($block.control);
        $results<loadinit> := $walker.walk($block.loadinit)
          if $walker.walkable($block.loadinit);
        $results;
    }

    our multi sub replaceChildren (PAST::Block $node, Capture $newChildren) {
        for $node.list {
            pir::pop($node);
        }
        for $newChildren.list -> $child {
            pir::push($node, $child);
        }
        for $newChildren.hash {
            $node.attr($_.key, $_.value, 1);
        }
    }

    our multi sub walkChildren (PAST::Transformer $walker, PAST::Var $var) {
        my $results := pir::new__PP(Capture);
        my $index := 0;
        my $max := pir::elements__IP($var);
        while ($index < $max) {
            $results[$index] := walk($walker, $var[$index]);
            $index++;
        }
        $results<viviself> := $walker.walk($var.viviself)
          if $walker.walkable($var.viviself);
        $results<vivibase> := $walker.walk($var.vivibase)
          if $walker.walkable($var.vivibase);
        $results;
    }

    our multi sub replaceChildren (PAST::Var $node, Capture $newChildren) {
        for $node.list {
            pir::pop($node);
        }
        for $newChildren.list -> $child {
            pir::push($node, $child);
        }
        for $newChildren.hash {
            $node.attr($_.key, $_.value, 1);
        }
    }
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
