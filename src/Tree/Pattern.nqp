#!./parrot-nqp
# Copyright (C) 2010, Parrot Foundation.
# $Id$

INIT {
    pir::load_bytecode('Tree/Transformer.pbc');
}

class Tree::Pattern is Capture {
    sub patternize ($value) {
        if ($value ~~ Regex::Method) {
            # Regexes are subs, but we just want to treat them as a normal
            # pattern.
            $value;
        } elsif (pir::isa__IPP($value, Sub)) {
            # We have to check for Sub-ness before we check for ACCEPTs.
            # Otherwise, some HLLs may get weird results if they add an
            # ACCEPTS method to Sub.
            Tree::Pattern::Closure.new($value);
        } elsif (pir::can__IPS($value, 'ACCEPTS')) {
            # Things with accepts are treated as patterns.
            $value;
        } else {
            # If all else fails, let's try iseq.
            Tree::Pattern::Constant.new($value);
        }
    }

    method attr ($name, $value, $has_value) {
        my $result;
        if ($has_value) {
            self{$name} := $value;
        } else {
            $result := self{$name};
        }
        $result;
    }

    method transform ($node, $transform, *%adverbs) {
        my &transSub;
        if ($transform ~~ Tree::Transformer) {
            &transSub := sub ($/) { $transformer.walk($/.orig()); };
        } elsif (pir::does__iPS($transform, 'invokable')) {
            &transSub := $transform;
        } else {
            pir::die('$transform must be invokable or a PAST::Transformer.');
        }
        my $transformer :=
          self.transformer_class.new(self, &transSub, |%adverbs);
        $transformer.walk($node);
    }

    # .transformer_class is used so that subclasses can override the
    # behavior of the transformer.
    method transformer_class () {
        Tree::Pattern::Transformer;
    }

    method ACCEPTS ($node, *%opts) {
        # Find every match.
        my $global := ?%opts<g> || ?%opts<global>;
        # Only attempt to match an exact node.
        my $pos := %opts<p> || %opts<pos>;
        # New way of doing exacting matching.
        my $exact := %opts<exact> || 0;
        pir::die("ACCEPTS cannot take both :global and :pos modifiers.")
            if $global && $pos;
        pir::die("ACCEPTS cannot take both :exact and :Global modifiers")
            if $global && $exact;
        return self.ACCEPTSGLOBALLY($node) if $global;
        return self.ACCEPTSEXACTLY($pos) if $pos;
        return self.ACCEPTSEXACTLY($node) if $exact;
        my $/ := self.ACCEPTS($node, :exact(1));
        if (!$/ && pir::isa__iPP($node, Capture)) {
            my $index := 0;
            my $max := pir::elements__IP($node);
            until ($index == $max) {
                $/ := $node[$index] ~~ self;
                return $/ if $/;
                $index++;
            }
            $/ := Tree::Pattern::Match.new(0);
        }
        $/;
    }

    method ACCEPTSGLOBALLY ($node) {
        my $/;
        my $first := self.ACCEPTS($node, :exact(1));
        if (pir::isa__iPP($node, Capture)) {
            my $matches := ?$first;
            my $index := 0;
            my $max := pir::elements__IP($node);
            my $submatch;
            $/ := Tree::Pattern::Match.new(?$first);
            $/[0] := $first if $first;
            until ($index == $max) {
                $submatch := self.ACCEPTS($node[$index], :g);
                if ($submatch) {
                    $/.success(1) unless $matches;
                    if pir::defined__iP($submatch.from()) {
                        $/[$matches++] := $submatch;
                    }
                    else { # The submatch is a list of multiple matches.
                        my $subIndex := 0;
                        my $subMax := pir::elements__IP($submatch);
                        until ($subIndex == $subMax) {
                            $/[$matches++] := $submatch[$subIndex];
                            $subIndex++;
                        }
                    }
                }
                $index++;
            }
            $/ := $/[0] if $matches == 1;
        }
        else {
            $/ := $first;
        }
        $/;
    }
}

INIT {
    pir::load_bytecode('Tree/Pattern/Match.pbc');

    pir::load_bytecode('Tree/Pattern/Any.pbc');
    pir::load_bytecode('Tree/Pattern/Closure.pbc');
    pir::load_bytecode('Tree/Pattern/Constant.pbc');

    pir::load_bytecode('Tree/Pattern/Transformer.pbc');
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
