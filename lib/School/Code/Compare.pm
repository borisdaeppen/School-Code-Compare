package School::Code::Compare;

use strict;
use warnings;

use Text::Levenshtein qw(distance);

sub new {
    my $class = shift;

    my $self = {
                    max_char_diff  => 70,
                    min_char_total => 20,
               };
    bless $self, $class;

    return $self;
}

sub set_max_char_difference {
    my $self = shift;

    $self->{max_char_diff} = shift;

    # make this chainable in OO-interface
    return $self;
}

sub set_min_char_total {
    my $self = shift;

    $self->{min_char_total} = shift;

    # make this chainable in OO-interface
    return $self;
}

sub measure {
    my $self = shift;

    my $str1 = shift;
    my $str2 = shift;

    my $length_str1 = length($str1);
    my $length_str2 = length($str2);


    if ($self->{min_char_total} > $length_str1
     or $self->{min_char_total} > $length_str2) {
        return (
            undef,
            undef,
            "skipped because one file is smaller equals "
            . $self->{min_char_total}
        );
    }

    my $diff = $length_str1 - $length_str2;

    $diff = $diff * -1 if ($diff < 0);

    if ($diff > $self->{max_char_diff}) {
        return (
            undef,
            undef,
            "skipped, because of large difference in chars: $diff");
    }
    else {
        my $distance = distance($str1, $str2);

        my $total_chars = $length_str1 + $length_str2;
        my $proportion_chars_changes = int(($distance / ($total_chars / 2))*100);

        return ($distance, $proportion_chars_changes, $diff);
    }
}

1;
