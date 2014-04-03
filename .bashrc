# source file via `. ~/.bashrc` to get a local::lib environment for debugging.
# in production all Perl scripts should be executed via Carton instead!
if [ $SHLVL -eq 1 ]; then && \
    if [ ! -e ~/perl5/lib/perl5/local/lib.pm ]; then
       cpanm --local-lib=~/perl5 local::lib
    fi
    eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)
fi    
