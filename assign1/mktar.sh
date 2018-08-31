TARDIR=bhat-hw1
export GZIP=-9
rm -r $TARDIR
mkdir $TARDIR
cp -r adders barrel gcd $TARDIR

tar czf $TARDIR.tar.gz $TARDIR


