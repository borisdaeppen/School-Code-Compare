# Autor: Boris Däppen, 2015-2017
# No guarantee given, use at own risk and will

use strict;
use warnings;
use v5.22;
use utf8;
use feature 'say';

use File::Slurp;
use Getopt::Args;
use Template;
use DateTime;

use School::Code::Compare;
use School::Code::Simplify;
use School::Code::Compare::Out::Template::Path;

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

##################
# PREPARING DATA #
##################

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

say 'reading and preparing files...';

# simplify all file content and store it together with the path
my @files = ();

foreach my $filepath ( @FILE_LIST ) {
    chomp( $filepath );

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

say 'comparing ' . @files . ' files...';

# measure Levenshtein distance within all possible file combinations
my @result = ();

for (my $i=0; $i < @files - 1; $i++) {
    for (my $j=$i+1; $j < @files; $j++) {

        my $comparison = $comparer->measure( $files[$i]->{clean_content},
                                             $files[$j]->{clean_content}
                                           );

        $comparison->{file1} = $files[$i]->{path};
        $comparison->{file2} = $files[$j]->{path};

        push @result, $comparison;
    }
}

####################
# RENDERING OUTPUT #
####################

my $format = 'CSV';
given ($output_format) {
	$format = 'CSV'  when /^csv/;
	$format = 'HTML' when /^html/;
	$format = 'TAB'  when /^tab/;
}

my $tt     = Template->new;
my $tt_dir = School::Code::Compare::Out::Template::Path->get();

# sort by ratio, but make sure undef values are "big" (meaning, bottom/last)
my @result_sorted = sort { return  1 if (not defined $a->{ratio});
                           return -1 if (not defined $b->{ratio});
                           return $a->{ratio} <=> $b->{ratio};
                         } @result;

# we render all rows, appending it to one string
my $rendered_data_rows = '';

foreach my $comparison (@result_sorted) {
    my $vars = {
        ratio        => $comparison->{ratio},
        distance     => $comparison->{distance},
        delta_length => $comparison->{delta_length},
        file1        => $comparison->{file1},
        file2        => $comparison->{file2},
        comment      => $comparison->{comment},
    };

    $tt->process("$tt_dir/$format.tt", $vars, \$rendered_data_rows)
        || die $tt->error(), "\n";
}

my $now = DateTime->now;
my $filename =    'code-comparison_'
                . $now->ymd() . '_'
                . $now->hms('-')
                . '.'
                . lc $format;

# render again, this time merging the rendered rows into the wrapping body
$tt->process(   "$tt_dir/Body$format.tt",
                { data => $rendered_data_rows },
                $filename
            )   || die $tt->error(), "\n";

say 'done. see file "'. $filename . '" for the result';
