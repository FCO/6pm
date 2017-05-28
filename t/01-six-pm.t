use Test;
use Test::Mock;
use App::six-pm::Meta6;
use lib "lib";

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
				"Bool"              => False,
			},
		);

		my $_6pm = SixPM.new: :$meta;
		$_6pm does role :: {
				has $.get-project-name  = "my_test";
				has $.get-project-tags  = "bla ble bli";
				has $.get-perl6-version = "v6.*";
		};

		$_6pm.init;

		check-mock $meta,
			*.called('Bool',             :1times),
			*.called('name',             :1times),
		;
	}
}
