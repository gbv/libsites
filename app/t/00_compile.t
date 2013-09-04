use v5.14;
use Test::More;

for (split "\n", `find lib -iname '*.pm'`) {
    s{^lib/|\.pm$}{}g;
    s{/}{::}g;
    next if /Catmandu/; # skip
    use_ok $_;
}

done_testing;
