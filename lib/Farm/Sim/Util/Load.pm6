use v6;

sub require_strict(Str $module) is export {
    say "::require-strict [$module] ..";
    require $module;
    my $class = eval($module);
    die "no class definition found for $module" if $class ~~ Failure;
    for <trade accept> -> $method {
        die "$module does not have a .$method method"
            unless $class.can($method);
        die ".$method method in $module has wrong arity"
            unless $class.^methods.grep($method)[0].arity
            == { trade => 3, accept => 4 }{$method};
    }
}

