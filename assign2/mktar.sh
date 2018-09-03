set -e
TARDIR=bhat-hw2
export GZIP=-9
rm -r $TARDIR || true
mkdir $TARDIR
cp -r *.bsv README $TARDIR

tar czf $TARDIR.tar.gz $TARDIR


