package School::Code::Compare;

sub new {
    my $class = shift;

    my $self = {
                    max_char_diff => 70,
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

sub measure {
    my $str1 = shift;
    my $str2 = shift;

    my $diff = length($str1) - length($str2);

    $diff = $diff * -1 if ($diff < 0);

    if ($diff > $self->{max_char_diff}) {
        return (-1, -1, $diff);
    }
    else {
        my $distance = distance($str1, $str2);

        my $total_chars = length($str1) + length($str2);
        my $proportion_chars_changes = int(($distance / ($total_chars / 2))*100);

        return ($distance, $proportion_chars_changes, $diff);
    }
}

1;
