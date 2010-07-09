#!/usr/bin/env parrot-nqp
# Copyright (C) 2010, Parrot Foundation.
# $Id$

pir::load_bytecode('PCT.pbc');
pir::load_bytecode('PAST/Transformer/Dynamic.pbc');
pir::load_bytecode('PAST/Pattern.pbc');

plan(3);
test_change_node_attributes();
test_change_node_types();
test_delete_nodes();

sub incVals ($walker, $node) {
    my $v := $node.'value'();
    $v++;
    $node.'value'($v);
    $node;
}

sub test_change_node_attributes () {
    my $past := 
      PAST::Block.new(PAST::Var.new(PAST::Val.new(:value(37))),
		      PAST::Val.new(:value(24)),
		      PAST::Block.new(PAST::Val.new(:value(5)),
				      PAST::Val.new(:value(12))));
    my $transformer := 
        PAST::Transformer::Dynamic.new();
    $transformer.'val'(incVals);
    my $result := $transformer.'walk'($past);
    my $target := PAST::Pattern::Block.new;
    $target[0] := PAST::Pattern::Var.new(PAST::Pattern::Val.new(:value(38)));
    $target[1] := PAST::Pattern::Val.new(:value(25));
    $target[2] := 
      PAST::Pattern::Block.new(PAST::Pattern::Val.new(:value(6)),
                               PAST::Pattern::Val.new(:value(13)));
    ok($result.match($target, :pos($result)),
       "Node attributes can be changed by PAST::Transformers.");
}

sub negate ($walker, $node) {
    my $v := $node.'value'();
    my $result;
    if ($v < 0) {
	$result := PAST::Op.new(PAST::Val.new(:value(-$v)),
				:pirop<neg>);
    }
    else {
	$result := $node;
    }
    $result;
}

sub test_change_node_types () {
    my $past :=
        PAST::Block.new(PAST::Val.new(:value(0)),
			PAST::Val.new(:value(-7)),
			PAST::Val.new(:value(5)),
			PAST::Val.new(:value(-32)));
    my $transformer := PAST::Transformer::Dynamic.new();
    $transformer.'val'(negate);
    my $result := $transformer.'walk'($past);

    my $target := PAST::Pattern::Block.new;
    $target[0] := PAST::Pattern::Val.new(:value(0));
    $target[1] := PAST::Pattern::Op.new(PAST::Pattern::Val.new(:value(7)),
                                        :pirop<neg>);
    $target[2] := PAST::Pattern::Val.new(:value(5));
    $target[3] := PAST::Pattern::Op.new(PAST::Pattern::Val.new(:value(32)),
                                        :pirop<neg>);
    ok($result.match($target, :pos($result)),
       "Node types can be changed by PAST::Transformers.")
}

sub trim ($walker, $node) {
    my $result;
    my $length := pir::elements__IP($node);
    if ($length <= 1) {
	$result := $node;
	my $children := Tree::Walker::walkChildren($walker, $node);
	Tree::Walker::replaceChildren($result, $children);
    }
    else {
	$result := null;
    }
    $result;
}

sub test_delete_nodes () {
    my $past :=
      PAST::Block.new(PAST::Stmts.new(PAST::Var.new(),
				      PAST::Block.new(PAST::Val.new()),
				      PAST::Block.new(PAST::Op.new(),
						      PAST::VarList.new()),
				      PAST::Block.new(PAST::Val.new(),
						      PAST::Val.new(),
						      PAST::Val.new())));
    my $transformer := PAST::Transformer::Dynamic.new();
    $transformer.'block'(trim);
    my $result := $transformer.'walk'($past);
    my $target := PAST::Pattern::Block.new;
    $target[0] := PAST::Pattern::Stmts.new;
    $target[0][0] := PAST::Pattern::Var.new;
    $target[0][1] := PAST::Pattern::Block.new(PAST::Pattern::Val.new);
    
    ok($result.match($target, :pos($result)),
       "Nodes can be deleted by PAST::Transformers.");
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
