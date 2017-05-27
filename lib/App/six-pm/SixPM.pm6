use App::six-pm::Meta6;
class SixPM {
	has IO::Path           $.base-dir   = ".".IO.resolve;
	has IO::Path           $.default-to = $!base-dir.child: "perl6-modules";
	has App::six-pm::Meta6 $!meta      .= create: $!base-dir.child: "META6.json";

	has Bool $.DEBUG = True;

	method init {
		unless $!meta {
			if prompt "Project name [{$!meta.name}]: " -> $name {
				$!meta.name = $name
			}
			if prompt "Project tags: " -> $tags {
				$!meta.tags = $tags.split(/\s/).grep: *.elems > 0
			}
			if prompt "perl6 version [{$!meta.perl}]: " -> $_ {
				$!meta.perl = $_ if /^ 'v6' ['.' <[a..z]>+] $/
			}
			$!meta.save
		}
	}

	method install-deps(Bool :f(:$force)) {
		if $!meta and $!meta.depends.elems > 0 {
			$.install(|$!meta.depends, :$force)
		} else {
			die "Deu ruim";
		}
	}

	method install(+@modules, Bool :f(:$force), Bool :$save) {
		if $.run-zef("install", |@modules, :to($!default-to.path), :$force) {
			if $save {
				$!meta.add-dependency: @modules;
				$!meta.save
			}
		} else {
			die "Deu ruim"
		}
	}

	method exec(+@argv) {
		%*ENV<PERL6LIB> = "inst#{$!default-to.path}";
		%*ENV<PATH>    ~= ":{$!default-to.path}/bin";
		run |@argv
	}

	method run(Str() $script) {
		%*ENV<PERL6LIB> = "inst#{$!default-to.path}";
		%*ENV<PATH>    ~= ":{$!default-to.path}/bin";
		shell $_ with $!meta.scripts{$script}
	}

	method run-zef(+@argv, :$to = $!default-to.path, *%pars) {
		my @pars = %pars.kv.map: -> $k, $v {
			my $par = $k.chars == 1 ?? "-" !! "--";
			do if $v ~~ Bool {
				"{$par}{$v ?? "" !! "/"}$k" if $v.DEFINITE
			} else {
				"$par$k=$v"
			}
		}
		my $cmd = "zef --to=inst#$to @pars[] @argv[]";
		note $cmd if $!DEBUG;
		shell $cmd
	}
}
