use App::six-pm::Installer;
class ZefInstaller does Installer {
	has $.DEBUG      = False;
	has $.default-to = "./perl6-modules".IO;
	method install(+@argv, :$to = $!default-to.path, *%pars) {
		$.run-zef("install", |@argv, :$to, |%pars)
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
