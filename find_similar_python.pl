use strict;
use warnings;
use utf8;
use feature 'say';

use Text::Levenshtein qw(distance);

unless ( defined $ARGV[0] ) {
    say "Please define Programming Language";
    exit 1;
}
my $lang = $ARGV[0];

$| = 1;

my $CHARDIFF = 70;

my @files = ();

foreach my $filepath ( <STDIN> ) {
    chomp( $filepath );
    #say "adding '$filepath' ...";

    push @files, $filepath;
}

say '# comparing ' . @files . ' files';
say "#edits\tlength\tfile1\tfile2";

for (my $i=0; $i < @files - 1; $i++) {
    for (my $j=$i+1; $j < @files; $j++) {

        my ($cleaned_code1, $cleaned_code2);

        if ($lang eq 'python') {
            ($cleaned_code1,
             $cleaned_code2) = prepare_python( $files[$i],  $files[$j] );
        }
        if ($lang eq 'php') {
            ($cleaned_code1,
             $cleaned_code2) = prepare_php   ( $files[$i],  $files[$j] );
        }

        my ($res, $diff) = measure( $cleaned_code1,  $cleaned_code2);
        say "$res\t$diff\t$files[$i]\t$files[$j]";
    }
}

sub prepare_python {
    my $f1 = shift;
    my $f2 = shift;

    open(my $fh1, '<:encoding(UTF-8)', $f1)
      or die "Could not open file '$f1' $!";
     
    open(my $fh2, '<:encoding(UTF-8)', $f2)
      or die "Could not open file '$f2' $!";
    
    my $str1 = '';
    while (my $row = <$fh1>) {
      chomp $row;
      next if ($row =~ /^#/);
      $row = $1 if ($row =~ /(.*)#.*/);
      $str1 .= $row
    }
    close $fh1;
    
    my $str2 = '';
    while (my $row = <$fh2>) {
      chomp $row;
      next if ($row =~ /^#/);
      $row = $1 if ($row =~ /(.*)#.*/);
      $str2 .= $row
    }
    close $fh2;

    # Whitespace raus
    $str1 =~ s/\s*//g;
    $str2 =~ s/\s*//g;

    #say $str1;
    #say $str2;

    return ($str1, $str2);
}

sub prepare_php {
    my $f1 = shift;
    my $f2 = shift;

    open(my $fh1, '<:encoding(UTF-8)', $f1)
      or die "Could not open file '$f1' $!";
     
    open(my $fh2, '<:encoding(UTF-8)', $f2)
      or die "Could not open file '$f2' $!";
    
    my $str1 = '';
    while (my $row = <$fh1>) {
      chomp $row;
      next if ($row =~ m!^/!);
      $row = $1 if ($row =~ m!(.*)//.*!);
      $row = $1 if ($row =~ m!(.*)/\*.*!);
      $str1 .= $row
    }
    close $fh1;
    
    my $str2 = '';
    while (my $row = <$fh2>) {
      chomp $row;
      next if ($row =~ m!^/!);
      $row = $1 if ($row =~ m!(.*)//.*!);
      $row = $1 if ($row =~ m!(.*)/\*.*!);
      $str2 .= $row
    }
    close $fh2;

    # Whitespace raus
    $str1 =~ s/\s*//g;
    $str2 =~ s/\s*//g;

    say $str1;
    say "\n";
    say $str2;
    say "\n";

    return ($str1, $str2);
}

sub measure {
    my $str1 = shift;
    my $str2 = shift;

    my $diff = length($str1) - length($str2);
    
    $diff = $diff * -1 if ($diff < 0);

    if ($diff > $CHARDIFF) {
        return (-1, $diff);
    }
    else {
        return (distance($str1, $str2), $diff);
    }
}
