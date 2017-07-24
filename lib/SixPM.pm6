no precompilation;

sub find-sixpm-path($cwd = $*PROGRAM.resolve.parent) is export<find-path> {
	repeat {
		last if $++ > 10;
		my $p6m = $cwd.child("perl6-modules");
		return "inst#{$p6m.resolve.absolute}" if $p6m.d;
		$cwd .= parent
	} while $cwd.resolve.absolute !~~ "/";
	Empty
}

if find-sixpm-path() -> $path {
	use MONKEY-SEE-NO-EVAL;
	EVAL "use lib '{$path}'";
} else {
	die "'perl6-modules' not found";
}
