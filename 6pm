#!/usr/bin/env perl6
use v6;
use App::six-pm::Meta6;
my $*MAIN-ALLOW-NAMED-ANYWHERE = True;

my $*DEBUG = so %*ENV<_6PM_DEBUG>;

my IO::Path $base-dir       = ".".IO.resolve;
my IO::Path $default-to     = $base-dir.child: "perl6-modules";
my App::six-pm::Meta6 $meta.= load: $base-dir.child: "META6.json";

sub run-zef(+@argv, :$to = $default-to.path, *%pars) {
    my @pars = %pars.kv.map: -> $k, $v {
        my $par = $k.chars == 1 ?? "-" !! "--";
        do if $v ~~ Bool {
            "{$par}{$v ?? "" !! "/"}$k" if $v.DEFINITE
        } else {
            "$par$k=$v"
        }
    }
    my $cmd = "zef --to=inst#$to @pars[] @argv[]";
    note $cmd if $*DEBUG;
    shell $cmd
}

multi MAIN("init") {
    unless $meta {
        if prompt "Project name [{$meta.name}]: " -> $name {
            $meta.name = $name
        }
        if prompt "Project tags: " -> $tags {
            $meta.tags = $tags.split(/\s/).grep: *.elems > 0
        }
        if prompt "perl6 version [{$meta.perl}]: " -> $_ {
            $meta.perl = $_ if /^ 'v6' ['.' <[a..z]>+] $/
        }
        $meta.save
    }
}

multi MAIN("install", Bool :f(:$force)) {
	if $meta {
        MAIN "install", |$meta.depends, :$force if $meta.depends.elems > 0
	} else {
		die "Deu ruim";
	}
}
multi MAIN("install", +@modules, Bool :f(:$force), Bool :$save) {
    if run-zef "install", |@modules, :to($default-to.path), :$force {
        if $save {
            $meta.add-dependency: @modules;
            $meta.save
        }
    } else {
        die "Deu ruim"
    }
}
multi MAIN("exec", +@argv, *%pars where *.elems >= 1) is hidden-from-USAGE {
    die "Please, use -- before the command"
}

multi MAIN("exec", +@argv) {
    %*ENV<PERL6LIB> = "inst#{$default-to.path}";
    %*ENV<PATH>    ~= ":{$default-to.path}/bin";
    run @argv
}
multi MAIN("run", Str() $script) {
    %*ENV<PERL6LIB> = "inst#{$default-to.path}";
    %*ENV<PATH>    ~= ":{$default-to.path}/bin";
    shell $_ with $meta.scripts{$script}
}
enum Scripts <test start stop>;
multi MAIN(Scripts $script) {
	MAIN "run", $script.key
}
