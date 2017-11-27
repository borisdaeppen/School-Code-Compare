package School::Code::Compare::Out::Template::Path;
# ABSTRACT: pseudo class to help locating the path of the template files


sub get {
    if (__FILE__ =~ m!^(.*)/[^/]+$!) {
        return $1;
    }
    else {
        die "Problem in path detection for templates";
    }
}

1;
