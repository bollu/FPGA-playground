all: build_referencemult build_singlecyclemult run_singlecyclemult

testbench: TestBench.bsv
	mkdir -p buildDir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions TestBench.bsv

build_referencemult: testbench Multiplier.bsv
	mkdir -p bin
	bsc -sim -e mkTestReferenceMultiplier -bdir buildDir -info-dir buildDir -simdir buildDir -o bin/testReferenceMultiplier buildDir/*.ba

run_referencemult:
	./bin/testReferenceMultiplier

build_singlecyclemult: testbench Single.bsv
	mkdir -p bin
	bsc -sim -e mkTestSingleCycleMultiplier -bdir buildDir -info-dir buildDir -simdir buildDir -o bin/testSinglecycleMultiplier buildDir/*.ba

run_singlecyclemult:
	./bin/testSingleCycleMultiplier


#tester:
#	mkdir -p buildDir
#	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions Tester.bsv
