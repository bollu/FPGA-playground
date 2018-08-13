compile:
	mkdir -p buildDir
	bsc -u -sim -bdir buildDir -info-dir buildDir -simdir buildDir -vdir buildDir -aggressive-conditions TestBench.bsv

mux1simple: compile
	bsc -sim -e mkTbMux1Simple -bdir buildDir -info-dir buildDir -simdir buildDir -o simMux1Simple buildDir/*.ba

muxsimple: compile
	bsc -sim -e mkTbMuxSimple -bdir buildDir -info-dir buildDir -simdir buildDir -o simMuxSimple buildDir/*.ba

muxnsimple: compile
	bsc -sim -e mkTbMuxNSimple -bdir buildDir -info-dir buildDir -simdir buildDir -o simMuxNSimple buildDir/*.ba

add4simple: compile
	bsc -sim -e mkTbAdd4Simple -bdir buildDir -info-dir buildDir -simdir buildDir -o simAdd4Simple buildDir/*.ba

rcasimple: compile
	bsc -sim -e mkTbRCASimple -bdir buildDir -info-dir buildDir -simdir buildDir -o simRcaSimple buildDir/*.ba

csasimple: compile
	bsc -sim -e mkTbCSASimple -bdir buildDir -info-dir buildDir -simdir buildDir -o simCsaSimple buildDir/*.ba

all: mux1simple muxsimple add4simple rcasimple csasimple

clean:
	rm -rf buildDir sim*

.PHONY: clean all add compile
.DEFAULT_GOAL := all
