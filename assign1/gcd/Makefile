all: gcdsimple gcdseq lgcd gcdzero 

compile:
	mkdir -p buildDir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions -keep-fires -no-warn-action-shadowing TestBench.bsv
gcdsimple: compile
	bsc -sim -e mkTbGCDSimple -bdir buildDir -info-dir buildDir -simdir buildDir -aggressive-conditions -keep-fires -o simGCDSimple -show-range-conflict -no-warn-action-shadowing
 
 
gcdseq: compile
	bsc -sim -e mkTbGCDSeq -bdir buildDir -info-dir buildDir -simdir buildDir -aggressive-conditions -keep-fires -o simGCDSeq -show-range-conflict -no-warn-action-shadowing

gcdzero: compile
	bsc -sim -e mkTbGCDZero -bdir buildDir -info-dir buildDir -simdir buildDir -aggressive-conditions -keep-fires -o simGCDZero -show-range-conflict -no-warn-action-shadowing

lgcd: compile
	bsc -sim -e mkTbLGCD -bdir buildDir -info-dir buildDir -simdir buildDir -aggressive-conditions -keep-fires -o simLGCD -show-range-conflict -no-warn-action-shadowing

clean:
	rm -rf buildDir sim* gcd.vcd

.PHONY: clean all compile gcdsimple gcdseq gcdzero lgcd 
.DEFAULT_GOAL := all
