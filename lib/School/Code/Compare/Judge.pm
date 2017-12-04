package School::Code::Compare::Judge;
# ABSTRACT: guess if two strings are so similary, that it's maybe cheating

use strict;
use warnings;


sub new {
    my $class = shift;

    my $self = {
                    suspicious_ratio        => 40,
                    highly_suspicious_ratio => 20,
               };
    bless $self, $class;

    return $self;
}

sub set_suspicious_ratio {
    my $self = shift;

    $self->{suspicious_ratio} = shift;

    return $self;
}

sub set_highly_suspicious_ratio {
    my $self = shift;

    $self->{highly_suspicious_ratio} = shift;

    return $self;
}

sub look {
    my $self       = shift;
    my $comparison = shift;

    $comparison->{suspicious}        = 0;
    $comparison->{highly_suspicious} = 0;

    return () unless (defined $comparison->{ratio});

    if ($comparison->{ratio} <= $self->{suspicious_ratio}) {
        $comparison->{suspicious} = 1;
        if ($comparison->{ratio} <= $self->{highly_suspicious_ratio}) {
            $comparison->{suspicious} = 2;
        }
    }
}

1;
