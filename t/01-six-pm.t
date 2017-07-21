use Test;
use Test::Mock;
use App::six-pm::Meta6;
use App::six-pm::Installer;
use App::six-pm::ZefInstaller;
use lib "lib";

plan 8;

use-ok "App::six-pm::SixPM";

sub name is rw { state $a }

{
	use App::six-pm::SixPM;

	subtest {
		my $meta = mocked(App::six-pm::Meta6,
			returning => {
				"Bool" => True
			}
		);

		my $_6pm = SixPM.new: :$meta;

		$_6pm.init;

		check-mock $meta,
			*.called('Bool', :1times, with => :())
		;
	}

	subtest {
		my $meta = mocked(App::six-pm::Meta6,
			returning => {
				"Bool" => False,
			},
		);

		my $_6pm = SixPM.new: :$meta;
		$_6pm does role :: {
				has $.get-project-name  is rw = "my_test";
				has $.get-project-tags  is rw = "bla ble bli";
				has $.get-perl6-version is rw = "v6.*";
		};

		$_6pm.init;

		check-mock $meta,
			*.called('Bool', :1times),
			*.called('name', :1times),
			*.called('tags', :1times),
			*.called('perl', :1times),
			*.called('save', :1times),
		;

		is $meta.name, "my_test";
		is-deeply $meta.tags, <bla ble bli>;
		is $meta.perl, "v6.*";
	}

	subtest {
		my $meta = mocked(App::six-pm::Meta6,
			returning => {
				"Bool" => False,
			},
		);

		my $_6pm = SixPM.new: :$meta;

		$_6pm.init: :name<bla>:tags<a b c>:perl-version<v6.z.42>;

		check-mock $meta,
			*.called('Bool', :1times),
			*.called('name', :1times),
			*.called('tags', :1times),
			*.called('perl', :1times),
			*.called('save', :1times),
		;
	}

	subtest {
		my $meta = mocked(App::six-pm::Meta6,
			returning => {
				"Bool" => False,
			},
		);

		my $_6pm = SixPM.new: :$meta;
		dies-ok {
			$_6pm.install-deps;
		}
	}

	subtest {
		my $meta = mocked(App::six-pm::Meta6,
			returning => {
				"Bool"    => True,
				"depends" => [<A B C>]
			},
		);

		my $_6pm = SixPM.new: :$meta;

		$_6pm does role :: {
			method install(*@mod, :$save) {
				is-deeply @mod, [<A B C>];
				nok $save;
			}
		}

		lives-ok {
			$_6pm.install-deps;
		}
	}

	subtest {
		my $meta = mocked(App::six-pm::Meta6,
			returning => {
				"Bool"    => True,
				"depends" => [<A B C>]
			},
		);

		my $_6pm = SixPM.new: :$meta;

		$_6pm does role :: {
			method install(+@mod, :$force, :$save) {
				is-deeply @mod, [<A B C>];
				ok $force;
				nok $save;
			}
		}

		lives-ok {
			$_6pm.install-deps: :force;
		}
	}

	# TODO: Test::Mock doesn't work with roles
	subtest {
		my $installer = mocked(ZefInstaller, computing => {
				install => -> |c {say c; True}
		});

		my $_6pm = SixPM.new: :$installer;

		$_6pm.install: "Bla";

		check-mock $installer,
			*.called: "install", :1time, with => :("Bla", :$to!, :$force)
		;
	}

}
