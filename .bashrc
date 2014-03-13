# source file via `. ~/.bashrc` to get a local::lib environment for debugging.
# in production all Perl scripts should be executed via Carton instead!
[ $SHLVL -eq 1 ] && \
    cpanm --local-lib=~/perl5 local::lib && \
    eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)
