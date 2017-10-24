use strict;
use v5.22;

use Test::More tests => 3;

use School::Code::Simplify::Comments;

my $simplifier = School::Code::Simplify::Comments->new();

my $code_perl = [
'use strict;',
'# Just a comment',
'say "Hi!"',
];

my $clean = $simplifier->hashy($code_perl);

#say $clean->{visibles};

is($clean->{visibles}, 'usestrict;say"Hi!"', 'miniperl_visibles');

is($clean->{signes}, ';"!"', 'miniperl_signes');

#say $clean->{signes_ordered};

is($clean->{signes_ordered}, '"!";', 'miniperl_signesordered');

