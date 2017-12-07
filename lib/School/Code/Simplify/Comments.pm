package School::Code::Simplify::Comments;
# ABSTRACT: roughly trim whitespace, depending on commenting style

use strict;
use warnings;

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

    my $visibles      = '';
    my @signes_lines  = ();
    my $signes        = '';

    foreach my $row (@{$lines_ref}) {
      next if ($row =~ /^#/);
      $row = $1 if ($row =~ /(.*)#.*/);
      $row =~ s/\s*//g;
      next if ($row eq '');
      $visibles .= $row;
      $row =~ s/[a-zA-Z0-9]//g;
      $signes .= $row;
      push @signes_lines, $row;
    }

    my $sorted_sortedlines = join '', sort { $a cmp $b } @signes_lines;

    return  {
                visibles => $visibles,
                signes   => $signes,
                signes_ordered => $sorted_sortedlines,
            };
}

sub slashy {
    my $self      = shift;
    my $lines_ref = shift;

    my $visibles      = '';
    my @signes_lines  = ();
    my $signes        = '';

    foreach my $row (@{$lines_ref}) {
      next if ($row =~ m!^/!);
      next if ($row =~ m!^\s*\*!);
      $row = $1 if ($row =~ m!(.*)//.*!);
      $row = $1 if ($row =~ m!(.*)/\*.*!);
      $row =~ s/\s*//g;
      next if ($row eq '');
      $visibles .= $row;
      $row =~ s/[a-zA-Z0-9]//g;
      $signes .= $row;
      push @signes_lines, $row;
    }

    my $sorted_sortedlines = join '', sort { $a cmp $b } @signes_lines;

    return  {
                visibles => $visibles,
                signes   => $signes,
                signes_ordered => $sorted_sortedlines,
            };
}

sub html {
    my $self      = shift;
    my $lines_ref = shift;

    my $visibles      = '';
    my @signes_lines  = ();
    my $signes        = '';

    foreach my $row (@{$lines_ref}) {
      next if ($row =~ m/^<!--/);
      $row = $1 if ($row =~ m/(.*)<!--.*/);
      $row =~ s/\s*//g;
      next if ($row eq '');
      $visibles .= $row;
      $row =~ s/[a-zA-Z0-9]//g;
      $signes .= $row;
      push @signes_lines, $row;
    }

    my $sorted_sortedlines = join '', sort { $a cmp $b } @signes_lines;

    return  {
                visibles => $visibles,
                signes   => $signes,
                signes_ordered => $sorted_sortedlines,
            };
}

sub txt {
    my $self      = shift;
    my $lines_ref = shift;

    my $visibles      = '';
    my @signes_lines  = ();
    my $signes        = '';

    foreach my $row (@{$lines_ref}) {
      $row =~ s/\s*//g;
      next if ($row eq '');
      $visibles .= $row;
      $row =~ s/[a-zA-Z0-9]//g;
      $signes .= $row;
      push @signes_lines, $row;
    }

    my $sorted_sortedlines = join '', sort { $a cmp $b } @signes_lines;

    return  {
                visibles => $visibles,
                signes   => $signes,
                signes_ordered => $sorted_sortedlines,
            };
}

1;
