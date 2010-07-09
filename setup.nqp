#!/usr/bin/env parrot-nqp
pir::load_bytecode('distutils.pbc');

MAIN(get_args());

sub MAIN(@ARGS) {
    pir::shift__sP(@ARGS);
    my %tree-optimization :=
      hash(:name<tree-optimization>,
           :abstract('A library for analysis, pattern-matching, and ' ~
                     'transformation of Trees.'),
           :keywords<parrot optimization pattern pct>,
           :license_type('Artistic License 2.0'),
           :license_uri('http://www.perlfoundation.org/artistic_license_2_0'),
           :copyright_holder('Tyler L. Curtis'),
           :authority('http://github.com/ekiru'),
           :doc_files<README>,
           :checkout_uri('git://github.com/ekiru/tree-optimization.git'),
           :browser_uri('http://github.com/ekiru/tree-optimization'),
           :project_uri('http://github.com/ekiru/tree-optimization'),
           :test_exec('parrot --library build ' ~
                      get_libdir() ~ '/library/nqp-rx.pbc'),
          );

    %tree-optimization<pir_nqp-rx><build/PAST/Pattern.pir> :=
      <src/PAST/Pattern.nqp>;
    %tree-optimization<pir_nqp-rx><build/PAST/Transformer.pir> :=
      <src/PAST/Transformer.nqp>;
    %tree-optimization<pir_nqp-rx><build/PAST/Transformer/Dynamic.pir> :=
      <src/PAST/Transformer/Dynamic.nqp>;
    %tree-optimization<pir_nqp-rx><build/PAST/Walker.pir> :=
      <src/PAST/Walker.nqp>;
    %tree-optimization<pir_nqp-rx><build/PAST/Walker/Dynamic.pir> :=
      <src/PAST/Walker/Dynamic.nqp>;

    %tree-optimization<pbc_pir><build/PAST/Pattern.pbc> :=
      <build/PAST/Pattern.pir>;
    %tree-optimization<pbc_pir><build/PAST/Transformer.pbc> :=
      <build/PAST/Transformer.pir>;
    %tree-optimization<pbc_pir><build/PAST/Transformer/Dynamic.pbc> :=
      <build/PAST/Transformer/Dynamic.pir>;
    %tree-optimization<pbc_pir><build/PAST/Walker.pbc> :=
      <build/PAST/Walker.pir>;
    %tree-optimization<pbc_pir><build/PAST/Walker/Dynamic.pbc> :=
      <build/PAST/Walker/Dynamic.pir>;

    %tree-optimization<pir_nqp-rx><build/PCT/Pattern.pir> :=
      <src/PCT/Pattern.nqp>;
    %tree-optimization<pbc_pir><build/PCT/Pattern.pbc> :=
      <build/PCT/Pattern.pir>;

    %tree-optimization<pir_nqp-rx><build/POST/Pattern.pir> :=
      <src/POST/Pattern.nqp>;
    %tree-optimization<pbc_pir><build/POST/Pattern.pbc> :=
      <build/POST/Pattern.pir>;

    %tree-optimization<pir_nqp-rx><build/Tree/Pattern.pir> :=
      <src/Tree/Pattern.nqp>;
    %tree-optimization<pir_nqp-rx><build/Tree/Pattern/Any.pir> :=
      <src/Tree/Pattern/Any.nqp>;
    %tree-optimization<pir_nqp-rx><build/Tree/Pattern/Closure.pir> :=
      <src/Tree/Pattern/Closure.nqp>;
    %tree-optimization<pir_nqp-rx><build/Tree/Pattern/Constant.pir> :=
      <src/Tree/Pattern/Constant.nqp>;
    %tree-optimization<pir_nqp-rx><build/Tree/Pattern/Match.pir> :=
      <src/Tree/Pattern/Match.nqp>;
    %tree-optimization<pir_nqp-rx><build/Tree/Pattern/Transformer.pir> :=
      <src/Tree/Pattern/Transformer.nqp>;
    %tree-optimization<pir_nqp-rx><build/Tree/Transformer.pir> :=
      <src/Tree/Transformer.nqp>;
    %tree-optimization<pir_nqp-rx><build/Tree/Walker.pir> :=
      <src/Tree/Walker.nqp>;

    %tree-optimization<pbc_pir><build/Tree/Pattern.pbc> :=
      <build/Tree/Pattern.pir>;
    %tree-optimization<pbc_pir><build/Tree/Pattern/Any.pbc> :=
      <build/Tree/Pattern/Any.pir>;
    %tree-optimization<pbc_pir><build/Tree/Pattern/Closure.pbc> :=
      <build/Tree/Pattern/Closure.pir>;
    %tree-optimization<pbc_pir><build/Tree/Pattern/Constant.pbc> :=
      <build/Tree/Pattern/Constant.pir>;
    %tree-optimization<pbc_pir><build/Tree/Pattern/Match.pbc> :=
      <build/Tree/Pattern/Match.pir>;
    %tree-optimization<pbc_pir><build/Tree/Pattern/Transformer.pbc> :=
      <build/Tree/Pattern/Transformer.pir>;
    %tree-optimization<pbc_pir><build/Tree/Transformer.pbc> :=
      <build/Tree/Transformer.pir>;
    %tree-optimization<pbc_pir><build/Tree/Walker.pbc> :=
      <build/Tree/Walker.pir>;

    %tree-optimization<inst_lib> :=
      < build/PAST/Pattern.pbc
        build/PAST/Transformer.pbc
        build/PAST/Transformer/Dynamic.pbc
        build/PAST/Walker.pbc
        build/PAST/Walker/Dynamic.pbc
        build/PCT/Pattern.pbc
        build/POST/Pattern.pbc
        build/Tree/Pattern.pbc
        build/Tree/Pattern/Any.pbc
        build/Tree/Pattern/Closure.pbc
        build/Tree/Pattern/Constant.pbc
        build/Tree/Pattern/Match.pbc
        build/Tree/Pattern/Transformer.pbc
        build/Tree/Transformer.pbc
        build/Tree/Walker.pbc >;

    setup(|@ARGS, |%tree-optimization);
}

sub hash (*%hash) {
    %hash;
}

sub get_args () {
    pir::getinterp__P()[2];
}
