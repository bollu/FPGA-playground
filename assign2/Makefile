testbench:
	mkdir -p buildDir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions TestBench.bsv

singlecycleadder: testbench
	mkdir -p bin
	bsc -sim -e mkTestSingleCycleMultiplier -bdir buildDir -info-dir buildDir -simdir buildDir -o bin/testSinglecycleMultiplier buildDir/*.ba
