#!/usr/bin/env parrot-nqp

INIT {
    pir::load_bytecode('PCT.pbc');
    pir::load_bytecode('PAST/Walker.pbc');
}

plan(6);
test_count_node_types();

class NodeCounter is PAST::Walker {
    has $!counts;

    method reset () {
        my %hash;
        for <blocks ops stmts vals vars varlists> {
            %hash{$_} := 0;
        }
        self.counts(%hash);
    }

    our multi method counts ($counts) {
        pir::setattribute(self, '$!counts', $counts);
    }
    our multi method counts () {
        pir::getattribute__PPS(self, '$!counts');
    }
}

module Tree::Walker {
    our multi sub walk (NodeCounter $walker, PAST::Block $block) {
        $walker.counts<blocks>++;
        walkChildren($walker, $block);
    }
    our multi sub walk (NodeCounter $walker, PAST::Op $op) {
        $walker.counts<ops>++;
        walkChildren($walker, $op);
    }
    our multi sub walk (NodeCounter $walker, PAST::Stmts $stmts) {
        $walker.counts<stmts>++;
        walkChildren($walker, $stmts);
    }
    our multi sub walk (NodeCounter $walker, PAST::Val $val) {
        $walker.counts<vals>++;
        walkChildren($walker, $val);
    }
    our multi sub walk (NodeCounter $walker, PAST::Var $var) {
        $walker.counts<vars>++;
        walkChildren($walker, $var);
    }
    our multi sub walk (NodeCounter $walker, PAST::VarList $varlist) {
        $walker.counts<varlists>++;
        walkChildren($walker, $varlist);
    }
}

sub test_count_node_types () {
    my $walker := NodeCounter.new;
    $walker.reset;
    my $past :=
      PAST::Block.new(PAST::Var.new(:vivibase(PAST::Op.new)),
                      PAST::Op.new(:pirop<call>,
                                   PAST::Var.new(:viviself(PAST::Block.new(PAST::Block.new))),
                                   PAST::Val.new),
                      PAST::Stmts.new(PAST::Op.new,
                                      PAST::Op.new,
                                      PAST::VarList.new,
                                      PAST::Block.new(:loadinit(PAST::Stmts.new))),
                      PAST::Stmts.new);

    $walker.walk($past);
    my %counts := $walker.counts;

    ok(%counts<blocks> == 4, "PAST::Block");
    ok(%counts<ops> == 4, "PAST::Op");
    ok(%counts<stmts> == 3, "PAST::Stmts");
    ok(%counts<vals> == 1, "PAST::Val");
    ok(%counts<vars> == 2, "PAST::Var");
    ok(%counts<varlists> == 1, "PAST::VarList");
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
