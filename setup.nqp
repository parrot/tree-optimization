#!/usr/bin/env parrot-nqp

sub MAIN() {
    # Load distutils library
    pir::load_bytecode('distutils.pbc');

    # ALL DISTUTILS CONFIGURATION IN THIS HASH
    my %cfg := hash(
        # metadata
        setup               => 'setup.nqp',
        name                => 'tree-optimization',
        abstract            => 'Library for analysis, pattern-matching, and transformation of Trees.',
        keywords            => < parrot optimization pattern pct >,
        license_type        => 'Artistic License 2.0',
        license_uri         => 'http://www.perlfoundation.org/artistic_license_2_0',
        copyright_holder    => 'Tyler L. Curtis',
        authority           => 'http://github.com/ekiru',
        checkout_uri        => 'git://github.com/ekiru/tree-optimization.git',
        browser_uri         => 'http://github.com/ekiru/tree-optimization',
        project_uri         => 'http://github.com/ekiru/tree-optimization',
        description         => 'A library for analysis, pattern-matching, and transformation of trees.',

        # build
        pir_nqp             => unflatten(
            'build/PAST/Optimizer.pir',                   'src/PAST/Optimizer.nqp',
            'build/PAST/Optimizer/CombinedPass.pir',    'src/PAST/Optimizer/CombinedPass.nqp',
            'build/PAST/Optimizer/Pass.pir',            'src/PAST/Optimizer/Pass.nqp',
            'build/PAST/Optimizer/Transformers.pir',    'src/PAST/Optimizer/Transformers.nqp',
            'build/PAST/Pattern.pir',                   'src/PAST/Pattern.nqp',
            'build/PAST/Pattern/Transformer.pir',       'src/PAST/Pattern/Transformer.nqp',
            'build/PAST/Transformer.pir',               'src/PAST/Transformer.nqp',
            'build/PAST/Transformer/Dynamic.pir',       'src/PAST/Transformer/Dynamic.nqp',
            'build/PAST/Walker.pir',                    'src/PAST/Walker.nqp',
            'build/PAST/Walker/Dynamic.pir',            'src/PAST/Walker/Dynamic.nqp',
            'build/PCT/Pattern.pir',                    'src/PCT/Pattern.nqp',
            'build/POST/Pattern.pir',                   'src/POST/Pattern.nqp',
            'build/Tree/Optimizer.pir',                 'src/Tree/Optimizer.nqp',
            'build/Tree/Optimizer/CombinedPass.pir',    'src/Tree/Optimizer/CombinedPass.nqp',
            'build/Tree/Optimizer/Pass.pir',            'src/Tree/Optimizer/Pass.nqp',
            'build/Tree/Optimizer/Transformers.pir',    'src/Tree/Optimizer/Transformers.nqp',
            'build/Tree/Pattern.pir',                   'src/Tree/Pattern.nqp',
            'build/Tree/Pattern/Any.pir',               'src/Tree/Pattern/Any.nqp',
            'build/Tree/Pattern/Closure.pir',           'src/Tree/Pattern/Closure.nqp',
            'build/Tree/Pattern/Constant.pir',          'src/Tree/Pattern/Constant.nqp',
            'build/Tree/Pattern/Match.pir',             'src/Tree/Pattern/Match.nqp',
            'build/Tree/Pattern/Transformer.pir',       'src/Tree/Pattern/Transformer.nqp',
            'build/Tree/Transformer.pir',               'src/Tree/Transformer.nqp',
            'build/Tree/Walker.pir',                    'src/Tree/Walker.nqp',
        ),
        pbc_pir             => unflatten(
            'build/PAST/Optimizer.pbc',                 'build/PAST/Optimizer.pir',
            'build/PAST/Optimizer/CombinedPass.pbc',    'build/PAST/Optimizer/CombinedPass.pir',
            'build/PAST/Optimizer/Pass.pbc',            'build/PAST/Optimizer/Pass.pir',
            'build/PAST/Optimizer/Transformers.pbc',    'build/PAST/Optimizer/Transformers.pir',
            'build/PAST/Pattern.pbc',                   'build/PAST/Pattern.pir',
            'build/PAST/Pattern/Transformer.pbc',       'build/PAST/Pattern/Transformer.pir',
            'build/PAST/Transformer.pbc',               'build/PAST/Transformer.pir',
            'build/PAST/Transformer/Dynamic.pbc',       'build/PAST/Transformer/Dynamic.pir',
            'build/PAST/Walker.pbc',                    'build/PAST/Walker.pir',
            'build/PAST/Walker/Dynamic.pbc',            'build/PAST/Walker/Dynamic.pir',
            'build/PCT/Pattern.pbc',                    'build/PCT/Pattern.pir',
            'build/POST/Pattern.pbc',                   'build/POST/Pattern.pir',
            'build/Tree/Optimizer.pbc',                 'build/Tree/Optimizer.pir',
            'build/Tree/Optimizer/CombinedPass.pbc',    'build/Tree/Optimizer/CombinedPass.pir',
            'build/Tree/Optimizer/Pass.pbc',            'build/Tree/Optimizer/Pass.pir',
            'build/Tree/Optimizer/Transformers.pbc',    'build/Tree/Optimizer/Transformers.pir',
            'build/Tree/Pattern.pbc',                   'build/Tree/Pattern.pir',
            'build/Tree/Pattern/Any.pbc',               'build/Tree/Pattern/Any.pir',
            'build/Tree/Pattern/Closure.pbc',           'build/Tree/Pattern/Closure.pir',
            'build/Tree/Pattern/Constant.pbc',          'build/Tree/Pattern/Constant.pir',
            'build/Tree/Pattern/Match.pbc',             'build/Tree/Pattern/Match.pir',
            'build/Tree/Pattern/Transformer.pbc',       'build/Tree/Pattern/Transformer.pir',
            'build/Tree/Transformer.pbc',               'build/Tree/Transformer.pir',
            'build/Tree/Walker.pbc',                    'build/Tree/Walker.pir',
        ),

        # test
        test_exec           => get_parrot() ~ ' --library build '
                                            ~ get_libdir() ~ '/library/nqp-rx.pbc',
        test_files          => 't/*.t',

        # smoke
        smolder_url         => 'http://smolder.parrot.org/app/projects/process_add_report/9',
        smolder_comments    => 'tree-optimization',
        smolder_tags        => get_tags(),
        prove_archive       => 'report.tar.gz',

        # install
        inst_lib            => <
            build/PAST/Optimizer.pbc
            build/PAST/Optimizer/CombinedPass.pbc
            build/PAST/Optimizer/Pass.pbc
            build/PAST/Optimizer/Transformers.pbc
            build/PAST/Pattern.pbc
            build/PAST/Pattern/Transformer.pbc
            build/PAST/Transformer.pbc
            build/PAST/Transformer/Dynamic.pbc
            build/PAST/Walker.pbc
            build/PAST/Walker/Dynamic.pbc
            build/PCT/Pattern.pbc
            build/POST/Pattern.pbc
            build/Tree/Optimizer.pbc
            build/Tree/Optimizer/CombinedPass.pbc
            build/Tree/Optimizer/Pass.pbc
            build/Tree/Optimizer/Transformers.pbc
            build/Tree/Pattern.pbc
            build/Tree/Pattern/Any.pbc
            build/Tree/Pattern/Closure.pbc
            build/Tree/Pattern/Constant.pbc
            build/Tree/Pattern/Match.pbc
            build/Tree/Pattern/Transformer.pbc
            build/Tree/Transformer.pbc
            build/Tree/Walker.pbc 
        >,

        # dist
        manifest_includes   => glob('examples/*.pir examples/*.nqp'),
        doc_files           => glob('README docs/*/*.pod docs/*/*/*.pod'),
    );

    # Boilerplate; should not need to be changed
    my @*ARGS := pir::getinterp__P()[2];
       @*ARGS.shift;

    setup(@*ARGS, %cfg);
}

# Work around minor nqp-rx limitations
sub hash     (*%h ) { %h }
sub unflatten(*@kv) { my %h; for @kv -> $k, $v { %h{$k} := $v }; %h }

sub get_tags() {
    my $r := get_config();
    $r<osname> ~ ', ' ~ $r<archname> ~ ', tree-optimizations'
}

# Start it up!
MAIN();
