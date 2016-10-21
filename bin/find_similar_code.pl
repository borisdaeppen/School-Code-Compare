# Autor: Boris Däppen, 2015-2016
# No guarantee given, use at own risk and will

use strict;
use warnings;
use utf8;
use feature 'say';

use Text::Levenshtein qw(distance);

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

unless ( defined $ARGV[0] ) {
    say 'Please define Programming Language in the first argument.';
    say 'Supportet options are:';
    say '  - hashy:  python, perl, bash';
    say '  - slashy: php, c++, c#';
    say '  - html';
    exit 1;
}
my $lang = $ARGV[0];

$| = 1;

my @files = ();

my $comparer   = School::Code::Compare->new()
                                      ->set_max_char_difference(70)
                                      ->set_min_char_total     (20);
my $simplifier = School::Code::Simplify->new();

foreach my $filepath ( <STDIN> ) {
    chomp( $filepath );
    #say "adding '$filepath' ...";

    push @files, $filepath;
}

say '# comparing ' . @files . ' files';
say "#edits\tratio\tlength\tfile1\tfile2";

for (my $i=0; $i < @files - 1; $i++) {
    for (my $j=$i+1; $j < @files; $j++) {

        my ($cleaned_code1, $cleaned_code2);

        if ($lang eq 'python'
         or $lang eq 'perl'
         or $lang eq 'bash'
         or $lang eq 'hashy'
         ) {
            ($cleaned_code1,
             $cleaned_code2) = $simplifier->hashy  ( $files[$i],  $files[$j] );
        }
        if ($lang eq 'php'
         or $lang eq 'c++'
         or $lang eq 'c#'
         or $lang eq 'slashy'
         ) {
            ($cleaned_code1,
             $cleaned_code2) = $simplifier->slashy ( $files[$i],  $files[$j] );
        }
        if ($lang eq 'html') {
            ($cleaned_code1,
             $cleaned_code2) = $simplifier->html   ( $files[$i],  $files[$j] );
        }

        my ($res, $prop, $diff) =
                            $comparer->measure( $cleaned_code1,  $cleaned_code2);
        say "$res\t$prop\t$diff\t$files[$i]\t$files[$j]";
    }
}

