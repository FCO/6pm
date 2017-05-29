use App::six-pm::Meta6;
use App::six-pm::Installer;
use App::six-pm::ZefInstaller;
class SixPM {
	has IO::Path           $.base-dir   = ".".IO.resolve;
	has IO::Path           $.default-to = $!base-dir.child: "perl6-modules";
	has App::six-pm::Meta6 $.meta      .= create: $!base-dir.child: "META6.json";

	has Bool      $.DEBUG     = False;
	has Installer $.installer = ZefInstaller.new: :$!default-to, :$!DEBUG;

	method get-project-name  { prompt "Project name [{$!meta.name}]: " }
	method get-project-tags  { prompt "Project tags: " }
	method get-perl6-version { prompt "perl6 version [{$!meta.perl}]: " }

	method init(:$name, :@tags, :$perl-version) {
		unless $!meta {
			$!meta.name = $name // $.get-project-name;
			$!meta.tags = @tags || $.get-project-tags.words;
			$!meta.perl = $perl-version // $.get-perl6-version;
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
		if $.installer.install(|@modules, :to($!default-to.path), :$force) {
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
}
