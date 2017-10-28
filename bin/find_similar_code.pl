# Autor: Boris Däppen, 2015-2017
# No guarantee given, use at own risk and will

use strict;
use warnings;
no warnings 'experimental'; # disable warnings from given/when
use v5.22;
use utf8;
use feature 'say';

use File::Slurp;
use Getopt::Args;
use DateTime;

use School::Code::Compare;
use School::Code::Simplify::Comments;
use School::Code::Compare::Judge;
use School::Code::Compare::Out;

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

my $opt_desc_file =
    "$s" . 'You can define a prefix to the filename:'
. "\n$s" . '  - any string to identifiy the output suiting your needs.'
. "\n$s" . '  - any path, to not store in local directory.';

my $opt_desc_algo =
    "$s" . 'Define one or more algorithms, used to compare the files:'
. "\n$s" . '  - visibles'
. "\n$s" . '  - signes'
. "\n$s" . '  - signes_ordered'
. "\n$s" . '  - any combination of above, comma separated';

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

opt file => (
    isa     => 'Str',
    alias   => 'f',
    default => '',
    comment => "file prefix\n" . $opt_desc_file,
);

opt algo => (
    isa     => 'Str',
    alias   => 'a',
    default => 'visibles,signes,signes_ordered',
    comment => "algorithm\n" . $opt_desc_algo,
);

my $o = optargs;

# try not to use outside interface further down in the code...
my $lang          = $o->{lang};
my $output_format = $o->{out};
my $file_prefix   = $o->{file};
my @algos         = split(',', $o->{algo});

# some input checking...
for my $algo (@algos) {
    if ($algo !~ /^visibles$|^signes$|^signes_ordered$/) {
        die("algorithm not supported\n$opt_desc_algo\n");
    }
}
if ($lang !~ /hashy|python|perl|bash|slashy|php|js|c\+\+|c#|html|txt/) {
    die("lang not supported\n$opt_desc_lang\n");
}

##################
# PREPARING DATA #
##################

my $comparer   = School::Code::Compare->new()
                                      ->set_max_char_difference(400)
                                      ->set_min_char_total     ( 20)
                                      ->set_max_distance       (400);
my $comparer2  = School::Code::Compare->new()
                                      ->set_max_char_difference(800)
                                      ->set_min_char_total     ( 20)
                                      ->set_max_distance       (800);
my $simplifier = School::Code::Simplify::Comments->new();

my @FILE_LIST = ();
if (defined $o->{in}) {
    @FILE_LIST = read_file( $o->{in}, binmode => ':utf8' );
}
else {
    @FILE_LIST = <STDIN>;
}

say 'reading and preparing files...';

# simplify all file content and store it together with the path
my @files = ();

foreach my $filepath ( @FILE_LIST ) {
    chomp( $filepath );

    my @content = read_file( $filepath, binmode => ':utf8' ) ;

    my $cleaned;

    if ($lang eq 'python'
     or $lang eq 'perl'
     or $lang eq 'bash'
     or $lang eq 'hashy'
     ) {
        $cleaned = $simplifier->hashy ( \@content );
    }
    elsif ($lang eq 'php'
     or $lang eq 'js'
     or $lang eq 'c++'
     or $lang eq 'c#'
     or $lang eq 'slashy'
     ) {
        $cleaned = $simplifier->slashy ( \@content );
    }
    elsif ($lang eq 'html') {
        $cleaned = $simplifier->html ( \@content );
    }
    elsif ($lang eq 'txt') {
        $cleaned = $simplifier->txt ( \@content );
    }

    push @files, {  path                => $filepath,
                    code_visibles       => $cleaned->{visibles},
                    code_signes         => $cleaned->{signes},
                    code_signes_ordered => $cleaned->{signes_ordered},
    };
}

#use Data::Dumper;
#say Dumper(\@files);

################################################
# DO THE ACTUAL WORK... COMPARING ALL THE DATA #
################################################

say 'comparing ' . @files . ' files...';

my $now = DateTime->now;

my %info = (
    visibles =>
        "All visible chars in normal order. Whitespace removed.",
    signes =>
        "Only special chars in normal order. Whitespace and english letters removed.",
    signes_ordered =>
        "Only special chars. Whitespace and english letters removed. Chars in lines keep order, but lines get ordered.",
);

# measure Levenshtein distance within all possible file combinations
for my $algo ( @algos ) {

    print "working on $algo... ";

    my @result = ();
    my $judge  = School::Code::Compare::Judge->new();
    my $count  = 0;

    for (my $i=0; $i < @files - 1; $i++) {
        for (my $j=$i+1; $j < @files; $j++) {
    
            # Levenshtein
            my $comparison = $comparer->measure( $files[$i]->{"code_$algo"},
                                                 $files[$j]->{"code_$algo"}
                                               );
    
            $comparison->{file1} = $files[$i]->{path};
            $comparison->{file2} = $files[$j]->{path};
    
            $judge->look($comparison);
    
            push @result, $comparison;
            $count++;
        }
    }
    
    say "made $count comparisons, rendering output";

    ####################
    # RENDERING OUTPUT #
    ####################
    
    my $format = 'CSV';
    given ($output_format) {
    	$format = 'CSV'  when /^csv/;
    	$format = 'HTML' when /^html/;
    	$format = 'TAB'  when /^tab/;
    }
    
    my $filename =    $file_prefix
                    . $now->ymd() . '_' 
                    . $now->hms('-') . '_'
                    . $algo
                    . '.' 
                    . lc $format;
    
    my $out = School::Code::Compare::Out->new();
    
    $out->set_name($filename)->set_format($format)->set_lines(\@result);
    $out->set_title($algo)->set_description($info{$algo});
    
    $out->write();
    
    say 'DONE! see file "'. $filename . '" for the result';
}
