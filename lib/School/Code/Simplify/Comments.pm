package School::Code::Simplify::Comments;

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

    my @cleaned = ();

    foreach my $row (@{$lines_ref}) {
      next if ($row =~ /^#/);
      $row = $1 if ($row =~ /(.*)#.*/);
      $row =~ s/\s*//g;
      next if ($row eq '');
      push @cleaned, $row;
    }

    return @cleaned;
}

sub slashy {
    my $self      = shift;
    my $lines_ref = shift;

    my @lines = @{$lines_ref};

    my @cleaned = ();

    foreach my $row (@lines) {
      next if ($row =~ m!^/!);
      $row = $1 if ($row =~ m!(.*)//.*!);
      $row = $1 if ($row =~ m!(.*)/\*.*!);
      $row =~ s/\s*//g;
      next if ($row eq '');
      push @cleaned, $row;
    }

    return @cleaned;
}

sub html {
    my $self      = shift;
    my $lines_ref = shift;

    my @cleaned = ();

    foreach my $row (@{$lines_ref}) {
      next if ($row =~ m/^<!--/);
      $row = $1 if ($row =~ m/(.*)<!--.*/);
      $row =~ s/\s*//g;
      next if ($row eq '');
      push @cleaned, $row;
    }

    return @cleaned;
}

sub txt {
    my $self      = shift;
    my $lines_ref = shift;

    my @cleaned = ();

    foreach my $row (@{$lines_ref}) {
      $row =~ s/\s*//g;
      next if ($row eq '');
      push @cleaned, $row;
    }

    return @cleaned;
}

1;
