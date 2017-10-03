package School::Code::Compare;

use strict;
use warnings;

use Text::Levenshtein::XS qw(distance);

sub new {
    my $class = shift;

    my $self = {
                    max_char_diff  => 70,
                    min_char_total => 20,
                    max_distance   => 300,
                    suspicious_ratio        => 40,
                    highly_suspicious_ratio => 20,
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

sub set_max_distance {
    my $self = shift;

    $self->{max_distance} = shift;

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
        return {
            distance     => undef,
            ratio        => undef,
            delta_length => undef,
            comment      => 'skipped: smaller than '
                            . $self->{min_char_total},
        };
    }

    my $diff = $length_str1 - $length_str2;

    $diff = $diff * -1 if ($diff < 0);

    if ($diff > $self->{max_char_diff}) {
        return {
            distance     => undef,
            ratio        => undef,
            delta_length => $diff,
            comment      => 'skipped: delta in length bigger than '
                            . $self->{max_char_diff},
        };
    }
    else {
        my $distance = distance($str1, $str2, $self->{max_distance});

        if (defined $distance) {

            my $total_chars = $length_str1 + $length_str2;
            my $proportion_chars_changes =
                                    int(($distance / ($total_chars / 2))*100);

            return {
                distance     => $distance,
                ratio        => $proportion_chars_changes,
                delta_length => $diff,
                comment      => 'comparison done',
            };
        }
        else {
            return {
                distance     => undef,
                ratio        => undef,
                delta_length => $diff,
                comment      => 'skipped: distance higher than '
                                . $self->{max_distance},
            };
        }
    }
}

1;
