# Autor: Boris Däppen, 2015-2016
# No guarantee given, use at own risk and will

use strict;
use warnings;
use utf8;
use feature 'say';

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

if ( not defined $ARGV[0] or $ARGV[0] =~ /^-?-h/) {
    say 'You must define the Programming Language in the first argument.';
    say 'Supportet options are:';
    say '  - hashy:  python, perl, bash';
    say '  - slashy: php, js, c++, c#';
    say '  - html';
    say '  - txt';
    say '';
    say 'You can define an output format optionally as second argument:';
    say '  - tab';
    say '  - csv';
    exit 1;
}
my $lang = $ARGV[0];

my $output_format = 'tab';
if (defined $ARGV[1]) {
    $output_format = $ARGV[1];
}

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

my $delimiter = "\t";
if ($output_format eq 'csv') {
    $delimiter = ',';
}

say '# comparing ' . @files . ' files';
say '# edits over length' . $delimiter . 'edits needed' . $delimiter . 'delta length' . $delimiter . 'file1' . $delimiter . 'file2';

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
        elsif ($lang eq 'php'
         or $lang eq 'js'
         or $lang eq 'c++'
         or $lang eq 'c#'
         or $lang eq 'slashy'
         ) {
            ($cleaned_code1,
             $cleaned_code2) = $simplifier->slashy ( $files[$i],  $files[$j] );
        }
        elsif ($lang eq 'html') {
            ($cleaned_code1,
             $cleaned_code2) = $simplifier->html   ( $files[$i],  $files[$j] );
        }
        elsif ($lang eq 'txt') {
            ($cleaned_code1,
             $cleaned_code2) = $simplifier->txt   ( $files[$i],  $files[$j] );
        }

        my ($changes, $prop, $diff) =
                            $comparer->measure( $cleaned_code1, $cleaned_code2);
        say "$prop$delimiter$changes$delimiter$diff$delimiter$files[$i]$delimiter$files[$j]" if (defined $changes);

    }
}

