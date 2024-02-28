no precompilation;

sub find-sixpm-path($cwd is copy = $*PROGRAM.resolve.parent) {
	repeat {
		last if $++ > 10;
		my $p6m = $cwd.child("raku-modules");
		return $p6m.resolve if $p6m.d;
		$cwd .= parent
	} while $cwd.resolve.absolute !~~ "/";
	"./raku-modules".IO
}

sub EXPORT($find-path?) {
	unless $find-path {
		if find-sixpm-path() -> IO::Path $path {
			use MONKEY-SEE-NO-EVAL;
			EVAL "use lib 'inst#{$path.absolute}'";
		} else {
			die "'raku-modules' not found";
		}
	}

	{
		'&find-sixpm-path' => &find-sixpm-path
	}
}
