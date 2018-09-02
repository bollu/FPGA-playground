testbench:
	mkdir -p buildDir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions TestBench.bsv


referencemult: testbench
	mkdir -p bin
	bsc -sim -e mkTestReferenceMultiplier -bdir buildDir -info-dir buildDir -simdir buildDir -o bin/testReferenceMultiplier buildDir/*.ba

singlecyclemult: testbench
	mkdir -p bin
	bsc -sim -e mkTestSingleCycleMultiplier -bdir buildDir -info-dir buildDir -simdir buildDir -o bin/testSinglecycleMultiplier buildDir/*.ba
