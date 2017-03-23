#!/usr/bin/env perl6
use v6;
use JSON::Fast;

my IO::Path $base-dir   = ".".IO.resolve;
my IO::Path $to         = $base-dir.child: "perl6-modules";
my IO::Path $meta       = $base-dir.child: "META6.json";

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

sub read-meta(IO::Path :meta($_) = $meta) {
    do if .e {
        from-json .slurp
    } else {
		default-meta
    }
}

sub create-meta(\data, IO::Path :meta($_) = $meta) {
    .spurt: to-json data
}

sub run-zef(+@argv, :to($inst-to) = $to.path, *%pars) {
    my @pars = %pars.kv.map: -> $k, $v {
        my $par = $k.chars == 1 ?? "-" !! "--";
        do if $v ~~ Bool {
            "{$par}{$v ?? "" !! "/"}$k" if $v.DEFINITE
        } else {
            "$par$k=$v"
        }
    }
    my $cmd = "zef --to=inst#$inst-to @pars[] @argv[]";
    shell $cmd
}

multi MAIN("init") {
    my $m = read-meta;
    unless $meta.f {
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
        nextwith "install", |$m<depends>, :$force
	} else {
		die "Deu ruim";
	}
}
multi MAIN("install", *@modules, Bool :f(:$force), Bool :$save) {
    if run-zef "install", |@modules, :to($to.path), :$force {
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
multi MAIN("exec", *@argv) {
    %*ENV<PERL6LIB> = "inst#{$to.path}";
    %*ENV<PATH>    ~= ":{$to.path}/bin";
    run @argv
}
multi MAIN("run", $script) {
    %*ENV<PERL6LIB> = "inst#{$to.path}";
    %*ENV<PATH>    ~= ":{$to.path}/bin";
    shell $_ with read-meta.<scripts>{$script}
}
