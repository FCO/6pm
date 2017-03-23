#!/usr/bin/env perl6
use v6;
use JSON::Fast;

my $debug = so %*ENV<_6PM_DEBUG>;

my IO::Path $base-dir       = ".".IO.resolve;
my IO::Path $default-to     = $base-dir.child: "perl6-modules";
my IO::Path $default-meta   = $base-dir.child: "META6.json";

my \default-meta = {
	scripts       => {
		test => "zef test .",
	},
	perl          => "6.*",
	name          => $base-dir.basename,
	version       => "0.0.1",
	description   => "",
	authors       => [ "{%*ENV<USER>}" ],
	tags          => [ ],
	provides      => { },
	depends       => [ ],
	test-depends  => [
		"Test",
		"Test::META"
   ],
	resources     => [ ],
	source-url    => ""
};

sub read-meta(IO::Path :$meta = $default-meta) {
    do if $meta.e {
        from-json $meta.slurp
    } else {
		default-meta
    }
}

sub create-meta(\data, IO::Path :$meta = $default-meta) {
    $meta.spurt: to-json data
}

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
    note $cmd if $debug;
    shell $cmd
}

multi MAIN("init") {
    my $m = read-meta;
    unless $default-meta.f {
        if prompt "Project name [{$m<name>}]: " -> $name {
            $m<name> = $name
        }
        if prompt "Project tags: " -> $tags {
            $m<tags> = $tags.split(/\s/).grep: *.elems > 0
        }
        if prompt "perl6 version [{$m<perl>}]: " -> $_ {
            $m<perl> = $_ if /^ 'v6' ['.' <[a..z]>+] $/
        }
        create-meta $m
    }
}

multi MAIN("install", Bool :f(:$force)) {
	if read-meta() -> $m {
        MAIN "install", |$m<depends>, :$force if $m<depends>.elems > 0
	} else {
		die "Deu ruim";
	}
}
multi MAIN("install", +@modules, Bool :f(:$force), Bool :$save) {
    if run-zef "install", |@modules, :to($default-to.path), :$force {
        if $save {
            my $m = read-meta;
            $m<depends>.append: @modules;
            $m.<depends> .= unique;
            create-meta $m
        }
    } else {
        die "Deu ruim"
    }
}
multi MAIN("exec", +@argv) {
    %*ENV<PERL6LIB> = "inst#{$default-to.path}";
    %*ENV<PATH>    ~= ":{$default-to.path}/bin";
    run @argv
}
multi MAIN("run", Str $script) {
    %*ENV<PERL6LIB> = "inst#{$default-to.path}";
    %*ENV<PATH>    ~= ":{$default-to.path}/bin";
    shell $_ with read-meta.<scripts>{$script}
}
enum Scripts <test start stop>;
multi MAIN(Scripts $script) {
	MAIN "run", $script.key
}
