cur: run_inelasticpipeline

test: run_referencemult run_singlecyclemult run_elasticpipeline run_inelasticpipeline

testbench: TestBench.bsv
	mkdir -p buildDir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions TestBench.bsv

# ------------
# REFERENCE
build_referencemult: testbench Multiplier.bsv
	mkdir -p bin
	bsc -sim -e mkTestReferenceMultiplier -bdir buildDir -info-dir buildDir -simdir buildDir -o bin/testReferenceMultiplier buildDir/*.ba

run_referencemult:  build_referencemult
	./bin/testReferenceMultiplier

# ------------
# SINGLE CYCLE
build_singlecyclemult: testbench Single.bsv
	mkdir -p bin
	bsc -sim -e mkTestSingleCycleMultiplier -bdir buildDir -info-dir buildDir -simdir buildDir -o bin/testSingleCycleMultiplier buildDir/*.ba

run_singlecyclemult: build_singlecyclemult
	./bin/testSingleCycleMultiplier


# ------------------
# ELASTIC PIPELINE
build_elasticpipeline: testbench PipeElastic.bsv
	mkdir -p bin
	bsc -sim -e mkTestElasticPipeline -bdir buildDir -info-dir buildDir -simdir buildDir -o bin/testElasticPipeline buildDir/*.ba

run_elasticpipeline: build_elasticpipeline
	./bin/testElasticPipeline


# ------------------
# INELASTIC PIPELINE
build_inelasticpipeline: testbench PipeInElastic.bsv
	mkdir -p bin
	bsc -sim -e mkTestInelasticPipeline -bdir buildDir -info-dir buildDir -simdir buildDir -o bin/testInelasticPipeline buildDir/*.ba

run_inelasticpipeline: build_inelasticpipeline
	./bin/testInelasticPipeline
tar:


#tester:
#	mkdir -p buildDir
#	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions Tester.bsv
