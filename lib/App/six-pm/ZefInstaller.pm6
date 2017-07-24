use App::six-pm::Installer;
use SixPM True;
class ZefInstaller does Installer {
	has $.DEBUG      = False;
	has $.default-to = find-sixpm-path;
	method install(+@argv, :$to = $!default-to, *%pars) {
		$.run-zef("install", |@argv, :$to, |%pars)
	}

	method run-zef(+@argv, IO::Path :$to = $!default-to, *%pars) {
		my @pars = %pars.kv.map: -> $k, $v {
			my $par = $k.chars == 1 ?? "-" !! "--";
			do if $v ~~ Bool {
				"{$par}{$v ?? "" !! "/"}$k" if $v.DEFINITE
			} else {
				"$par$k=$v"
			}
		}
		my $cmd = "zef --to=inst#{$to.?absolute // $to} @pars[] @argv[]";
		note $cmd if $!DEBUG;
		shell $cmd, :err($*ERR), :out($*OUT)
	}
}
