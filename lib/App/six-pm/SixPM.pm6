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
	method get-project-tags  { prompt("Project tags (separated by space): ") }
	method get-raku-version { prompt "raku version [{$!meta.perl}]: " }

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
				if $.get-raku-version -> $perl {
					$!meta.perl = $perl
				}
			}

			if ".git/config".IO.e {
			    my $git-config = ".git/config".IO.slurp;
			    $!meta.source-url = ($git-config ~~  m{ \[remote \s+ \"origin\"\] \s+ url \s+ \= \s+ <(\S*)> }).Str;
                        }		    
			$!meta.save
		}
	}

	method install-deps(Bool :f(:$force)) {
		%*ENV<RAKULIB> = "inst#{$!default-to.absolute}";
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
		%*ENV<RAKULIB> = "inst#{$!default-to.absolute}";
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
		%*ENV<RAKULIB> = "inst#{$inst}";
		%*ENV<PATH>    ~= ":{$inst}/bin";
		run |@argv
	}

	method run(Str() $script) {
		%*ENV<RAKULIB> = "inst#{$!default-to.absolute}";
		%*ENV<PATH>    ~= ":{$!default-to.absolute}/bin";
		shell $_ with $!meta.scripts{$script}
	}
}
