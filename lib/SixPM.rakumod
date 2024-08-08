#!raku
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

sub EXPORT($find-path? --> Map()) {
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

=begin pod

=head1 🕕 - 6pm

6pm is a NPM for raku

=head2 Create META6.json

=begin code :lang<bash>

$ mkdir TestProject
$ cd TestProject/
$ 6pm init
Project name [TestProject]:
Project tags:
raku version [6.*]:

=end code

=head2 Locally install a Module

=begin code :lang<bash>

$ 6pm install Heap
===> Searching for: Heap
===> Testing: Heap:ver('0.0.1')
===> Testing [OK]: Heap:ver('0.0.1')
===> Installing: Heap:ver('0.0.1')

=end code

=head2 Locally install a Module and add it on depends of META6.json

=begin code :lang<bash>

$ 6pm install Heap --save
===> Searching for: Heap
===> Testing: Heap:ver('0.0.1')
===> Testing [OK]: Heap:ver('0.0.1')
===> Installing: Heap:ver('0.0.1')

=end code

=head2 Run code using the local dependencies

=begin code :lang<bash>

$ 6pm exec -- raku -MHeap -e 'say Heap.new: <q w e r>'
Heap.new: [e r q w]

=end code

=head2 Run a file using the local dependencies

=begin code :lang<bash>

$ echo "use Heap; say Heap.new: <q w e r>" > bla.p6
$ 6pm exec-file bla.p6
Heap.new: [e r q w]

=end code

=head2 Make your code always use 6pm

=begin code :lang<bash>

$ echo "use SixPM; use Heap; say Heap.new: <q w e r>" > bla.p6
$ raku bla.p6
Heap.new: [e r q w]

=end code

=head2 Running scripts

Add your script at your META6.json scripts field and run it with:

=begin code :lang<bash>

$ cat META6.json
{
  "name": "TestProject",
  "source-url": "",
  "perl": "6.*",
  "resources": [

  ],
  "scripts": {
    "test": "zef test .",
    "my-script": "raku -MHeap -e 'say Heap.new: ^10'"
  },
  "depends": [

  ],
  "test-depends": [
    "Test",
    "Test::META"
  ],
  "provides": {

  },
  "tags": [

  ],
  "version": "0.0.1",
  "authors": [
    "fernando"
  ],
  "description": ""
}
$ 6pm run my-script
Heap.new: [0 1 2 3 4 5 6 7 8 9]

=end code

=end pod
