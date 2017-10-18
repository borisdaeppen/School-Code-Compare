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

    my @lines  = ();
    my $string = '';

    foreach my $row (@{$lines_ref}) {
      next if ($row =~ /^#/);
      $row = $1 if ($row =~ /(.*)#.*/);
      $row =~ s/\s*//g;
      next if ($row eq '');
      push @lines, join '', sort { $a cmp $b } split //, $row;
      $string .= $row;
    }

    my $sorted_sortedlines = join '', sort { $a cmp $b } @lines;

    return { string => $string, string_sortedlines => $sorted_sortedlines };
}

sub slashy {
    my $self      = shift;
    my $lines_ref = shift;

    my @lines  = ();
    my $string = '';

    foreach my $row (@{$lines_ref}) {
      next if ($row =~ m!^/!);
      $row = $1 if ($row =~ m!(.*)//.*!);
      $row = $1 if ($row =~ m!(.*)/\*.*!);
      $row =~ s/\s*//g;
      next if ($row eq '');
      push @lines, join '', sort { $a cmp $b } split //, $row;
      $string .= $row;
    }

    my $sorted_sortedlines = join '', sort { $a cmp $b } @lines;

    return { string => $string, string_sortedlines => $sorted_sortedlines };
}

sub html {
    my $self      = shift;
    my $lines_ref = shift;

    my @lines  = ();
    my $string = '';

    foreach my $row (@{$lines_ref}) {
      next if ($row =~ m/^<!--/);
      $row = $1 if ($row =~ m/(.*)<!--.*/);
      $row =~ s/\s*//g;
      next if ($row eq '');
      push @lines, join '', sort { $a cmp $b } split //, $row;
      $string .= $row;
    }

    my $sorted_sortedlines = join '', sort { $a cmp $b } @lines;

    return { string => $string, string_sortedlines => $sorted_sortedlines };
}

sub txt {
    my $self      = shift;
    my $lines_ref = shift;

    my @lines  = ();
    my $string = '';

    foreach my $row (@{$lines_ref}) {
      $row =~ s/\s*//g;
      next if ($row eq '');
      push @lines, join '', sort { $a cmp $b } split //, $row;
      $string .= $row;
    }

    my $sorted_sortedlines = join '', sort { $a cmp $b } @lines;

    return { string => $string, string_sortedlines => $sorted_sortedlines };
}

1;
