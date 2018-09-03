TARDIR=bhat-hw1
export GZIP=-9
rm -r $TARDIR
mkdir $TARDIR
cp -r *.bsv README

tar czf $TARDIR.tar.gz $TARDIR


