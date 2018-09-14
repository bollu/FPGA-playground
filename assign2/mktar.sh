set -e
TARDIR=20161105_Assignment1
export GZIP=-9
rm -r $TARDIR || true
mkdir $TARDIR
cp -r *.bsv README.md Makefile $TARDIR

zip -r $TARDIR.zip $TARDIR


