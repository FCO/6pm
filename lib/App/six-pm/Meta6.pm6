use JSON::Class;

unit class App::six-pm::Meta6 does JSON::Class;

has IO::Path $.file handles <f e d x>;

has Str     $.meta6                 is json-skip-null is rw;
has Str     $.perl                  is json-skip-null is rw    = "v6.*";
has Str     $.name                  is json-skip-null is rw    = ".".IO.resolve.basename;
has Str     $.version               is json-skip-null is rw    = "0.0.1";
has Str     $.description           is json-skip-null is rw    = "";
has Str     @.authors               is json-skip-null is rw    = [%*ENV<USER>];
has Str     %.provides              is json-skip-null is rw;
has Str     @.depends               is json-skip-null is rw;
has Str     %.emulates              is json-skip-null is rw;
has Str     %.supersedes            is json-skip-null is rw;
has Str     %.superseded-by         is json-skip-null is rw;
has Str     %.excludes              is json-skip-null is rw;
has Str     @.build-depends         is json-skip-null is rw;
has Str     @.test-depends          is json-skip-null is rw;
has Str     %.resources             is json-skip-null is rw;
has Str     %.support               is json-skip-null is rw;
has Bool    $.production            is json-skip-null is rw    = False;
has Str     $.license               is json-skip-null is rw    = "https://opensource.org/licenses/Artistic-2.0";
has Str     @.tags                  is json-skip-null is rw;

has Str         %.scripts           is json-skip-null is rw    = {
    test => "zef test ."
}

method new(IO::Path:D $file) {
    do if $file.f {
        ::?CLASS.from-json: $file.slurp
    } else {
        ::?CLASS.bless(:$file)
    }
}

method save() {$!file.spurt: $.to-json; self}

method add-dependency(*@dep) {
    $.depends.append: @dep;
    $.depends .= unique;
}

method Bool(--> Bool()) {self.?f}
