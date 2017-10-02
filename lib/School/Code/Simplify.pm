package School::Code::Simplify;

use strict;

sub new {
    my $class = shift;

    my $self = {
               };
    bless $self, $class;

    return $self;
}

sub hashy {
    my $self      = shift;
    my $lines_ref = shift;

    my $str1 = '';

    foreach my $row (@{$lines_ref}) {
      chomp $row;
      next if ($row =~ /^#/);
      $row = $1 if ($row =~ /(.*)#.*/);
      $str1 .= $row;
    }

    # Whitespace raus
    $str1 =~ s/\s*//g;

    return $str1;
}

sub slashy {
    my $self      = shift;
    my $lines_ref = shift;

    my @lines = @{$lines_ref};

    my $str1 = '';

    foreach my $row (@lines) {
      chomp $row;
      next if ($row =~ m!^/!);
      $row = $1 if ($row =~ m!(.*)//.*!);
      $row = $1 if ($row =~ m!(.*)/\*.*!);
      $str1 .= $row;
    }

    # Whitespace raus
    $str1 =~ s/\s*//g;

    return $str1;
}

sub html {
    my $self      = shift;
    my $lines_ref = shift;

    my $str1 = '';

    foreach my $row (@{$lines_ref}) {
      chomp $row;
      next if ($row =~ m/^<!--/);
      $row = $1 if ($row =~ m/(.*)<!--.*/);
      $str1 .= $row;
    }

    # Whitespace raus
    $str1 =~ s/\s*//g;

    return $str1;
}

sub txt {
    my $self      = shift;
    my $lines_ref = shift;

    my $str1 = '';

    foreach my $row (@{$lines_ref}) {
      chomp $row;
      $str1 .= $row;
    }

    # Whitespace raus
    $str1 =~ s/\s*//g;

    return $str1;
}

1;
