use v5.14.2;
use Test::More;

foreach (split "\n", `find lib -iname '*.pm'`) {
    s{^lib/|\.pm$}{}g;
    s{/}{::}g;
    use_ok "$_";
}

done_testing;
