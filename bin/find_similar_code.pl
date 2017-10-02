# Autor: Boris Däppen, 2015-2017
# No guarantee given, use at own risk and will

use strict;
use warnings;
use utf8;
use feature 'say';

use File::Slurp;
use Getopt::Args;

use School::Code::Compare;
use School::Code::Simplify;

# Kombinatorisches Verhalten
# -----------------------------------------------------------------------------
#
# Anzahl Vergleiche:
# n! / ((n - m)! * m!)
# wenn
# n = Anzahl Elemente   (Anzahl Code-Dateien die zu Vergleichen sind)
# m = gezogene Elemente (immer 2, da zwei Dateien miteinander verglichen werden)
#
# Bei 100 Skripte gibt das
# 100! / (98! * 2!) = 4950
#
# Rechner: http://de.numberempire.com/combinatorialcalculator.php

##################
# OPTION PARSING #
##################

my $s = '                   ';
my $opt_desc_lang =
    "$s" . 'Supportet options are:'
. "\n$s" . '  - hashy:  python, perl, bash'
. "\n$s" . '  - slashy: php, js, c++, c#'
. "\n$s" . '  - html'
. "\n$s" . '  - txt';

my $opt_desc_out =
    "$s" . 'You can define an output format:'
. "\n$s" . '  - tab'
. "\n$s" . '  - csv';

arg lang => (
    isa      => 'Str',
    required => 1,
    comment  => "language to parse\n" . $opt_desc_lang,
);

opt in => (
    isa     => 'Str',
    alias   => 'i',
    comment => 'file to read from (containing filepaths)' . "\n$s" . 'otherwise read from STDIN',
);

opt out => (
    isa     => 'Str',
    alias   => 'o',
    default => 'tab',
    comment => "output format\n" . $opt_desc_out,
);

my $o = optargs;

my $lang          = $o->{lang};
my $output_format = $o->{out};

unless ($lang =~ /hashy|python|perl|bash|slashy|php|js|c\+\+|c#|html|txt/) {
    die("lang not supported\n$opt_desc_lang\n");
}

#$| = 1;

##################
# PREPARING DATA #
##################

my @files = ();

my $comparer   = School::Code::Compare->new()
                                      ->set_max_char_difference(70)
                                      ->set_min_char_total     (20)
                                      ->set_max_distance      (300);
my $simplifier = School::Code::Simplify->new();

my @FILE_LIST = ();
if (defined $o->{in}) {
    @FILE_LIST = read_file( $o->{in}, binmode => ':utf8' );
}
else {
    @FILE_LIST = <STDIN>;
}

foreach my $filepath ( @FILE_LIST ) {
    chomp( $filepath );
#say "adding '$filepath' ...";

    my @content = read_file( $filepath, binmode => ':utf8' ) ;

    my $cleaned_content;

    if ($lang eq 'python'
     or $lang eq 'perl'
     or $lang eq 'bash'
     or $lang eq 'hashy'
     ) {
        $cleaned_content = $simplifier->hashy ( \@content );
    }
    elsif ($lang eq 'php'
     or $lang eq 'js'
     or $lang eq 'c++'
     or $lang eq 'c#'
     or $lang eq 'slashy'
     ) {
        $cleaned_content = $simplifier->slashy ( \@content );
    }
    elsif ($lang eq 'html') {
        $cleaned_content = $simplifier->html ( \@content );
    }
    elsif ($lang eq 'txt') {
        $cleaned_content = $simplifier->txt ( \@content );
    }

    push @files, { path => $filepath, clean_content => $cleaned_content };
}

################################################
# DO THE ACTUAL WORK... COMPARING ALL THE DATA #
################################################

my $delimiter = "\t";
if ($output_format eq 'csv') {
    $delimiter = ',';
}

say '# comparing ' . @files . ' files';
say '# edits over length' . $delimiter . 'edits needed' . $delimiter . 'delta length' . $delimiter . 'file1' . $delimiter . 'file2';

for (my $i=0; $i < @files - 1; $i++) {
    for (my $j=$i+1; $j < @files; $j++) {


        my ($changes, $prop, $diff) =
                            $comparer->measure( $files[$i]->{clean_content},
                                                $files[$j]->{clean_content}
                                              );
        say "$prop$delimiter$changes$delimiter$diff$delimiter".$files[$i]->{path}."$delimiter".$files[$j]->{path} if (defined $changes);

    }
}

