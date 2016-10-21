package School::Code::Simplify;

sub new {
    my $class = shift;

    my $self = {
               };
    bless $self, $class;

    return $self;
}

sub hashy {
    my $self = shift;

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

    return ($str1, $str2);
}

sub slashy {
    my $self = shift;

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

    return ($str1, $str2);
}

sub html {
    my $self = shift;

    my $f1 = shift;
    my $f2 = shift;

    open(my $fh1, '<:encoding(UTF-8)', $f1)
      or die "Could not open file '$f1' $!";

    open(my $fh2, '<:encoding(UTF-8)', $f2)
      or die "Could not open file '$f2' $!";

    my $str1 = '';
    while (my $row = <$fh1>) {
      chomp $row;
      next if ($row =~ m/^<!--/);
      $row = $1 if ($row =~ m/(.*)<!--.*/);
      $str1 .= $row
    }
    close $fh1;

    my $str2 = '';
    while (my $row = <$fh2>) {
      chomp $row;
      next if ($row =~ m/^<!--/);
      $row = $1 if ($row =~ m/(.*)<!--.*/);
      $str2 .= $row
    }
    close $fh2;

    # Whitespace raus
    $str1 =~ s/\s*//g;
    $str2 =~ s/\s*//g;

    return ($str1, $str2);
}

1;
