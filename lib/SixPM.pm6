no precompilation;
my $cwd = $*PROGRAM.resolve.parent;
while $cwd.resolve.absolute !~~ "/" {
	last if $++ > 10;
	my $p6m = $cwd.child("perl6-modules");
	if $p6m.d {
		use MONKEY-SEE-NO-EVAL;
		EVAL "use lib '{$p6m.absolute}'";
		last
	}
	$cwd .= parent
}
