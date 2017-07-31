use App::six-pm::Meta6;
use App::six-pm::Installer;
use App::six-pm::ZefInstaller;
use SixPM True;
class SixPM {
	has IO::Path           $.base-dir   = ".".IO.resolve;
	has IO::Path           $.default-to = find-sixpm-path $!base-dir;
	has App::six-pm::Meta6 $.meta      .= create: $!base-dir.child: "META6.json";

	has Bool      $.DEBUG     = False;
	has Installer $.installer = ZefInstaller.new: :$!default-to, :$!DEBUG;

	method get-project-name  { prompt "Project name [{$!meta.name}]: " }
	method get-project-tags  { prompt("Project tags: ") }
	method get-perl6-version { prompt "perl6 version [{$!meta.perl}]: " }

	method init(:$name, :@tags, :$perl-version) {
		unless $!meta {
			with $name -> $name {
				$!meta.name = $name
			} else {
				if $.get-project-name -> $name {
					$!meta.name = $name
				}
			}
			$!meta.tags = @tags || $.get-project-tags.words;
			with $perl-version -> $perl {
				$!meta.perl = $perl
			} else {
				if $.get-perl6-version -> $perl {
					$!meta.perl = $perl
				}
			}
			$!meta.save
		}
	}

	method install-deps(Bool :f(:$force)) {
		%*ENV<PERL6LIB> = "inst#{$!default-to.absolute}";
		%*ENV<PATH>    ~= ":{$!default-to.absolute}/bin";
		if
			$!meta and
				(
					$!meta.depends.elems > 0
						or $!meta.test-depends.elems > 0
						or $!meta.build-depends.elems > 0
				)
		{
			$.install(flat(|$!meta.build-depends, |$!meta.test-depends, |$!meta.depends), :$force)
		} else {
			die "Deu ruim";
		}
	}

	method install(+@modules, Bool :f(:$force), Bool :$save, Bool :$save-test, Bool :$save-build) {
		%*ENV<PERL6LIB> = "inst#{$!default-to.absolute}";
		%*ENV<PATH>    ~= ":{$!default-to.absolute}/bin";
		if $.installer.install(|@modules, :to($!default-to.absolute), :$force) {
			if $save {
				$!meta.add-dependency: @modules;
				$!meta.add-test-dependency: @modules;
				$!meta.add-build-dependency: @modules;
				$!meta.save
			}
		} else {
			die "Deu ruim"
		}
	}

	method exec(+@argv, IO::Path :$path) {
		my $inst = do with $path {
			find-sixpm-path $path
		} else {
			$!default-to.absolute
		}
		%*ENV<PERL6LIB> = "inst#{$inst}";
		%*ENV<PATH>    ~= ":{$inst}/bin";
		run |@argv
	}

	method run(Str() $script) {
		%*ENV<PERL6LIB> = "inst#{$!default-to.absolute}";
		%*ENV<PATH>    ~= ":{$!default-to.absolute}/bin";
		shell $_ with $!meta.scripts{$script}
	}
}
