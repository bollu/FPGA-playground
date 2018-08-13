compile:
	mkdir -p buildDir
	mkdir -p bscdir
	bsc -u -sim -simdir bscdir -bdir bscdir -info-dir bscdir -keep-fires -p .:%/Prelude:%/Libraries:./.:%/Libraries/BlueNoC -aggressive-conditions ./TestDriver.bsv

logicshifter: compile
	bsc -e mkTestLogicalBarrelShifter -sim -o ./logicshifter -simdir bscdir -p .:%/Prelude:%/Libraries:./.:%/Libraries/BlueNoC -bdir bscdir -keep-fires

arithmeticshifter: compile
	bsc -e mkTestArithmeticBarrelShifter -sim -o ./arithmeticshifter -simdir bscdir -p .:%/Prelude:%/Libraries:./.:%/Libraries/BlueNoC -bdir bscdir -keep-fires

leftshifter: compile
	bsc -e mkTestLogicalLeftBarrelShifter -sim -o ./leftshifter -simdir bscdir -p .:%/Prelude:%/Libraries:./.:%/Libraries/BlueNoC -bdir bscdir -keep-fires

all: logicshifter arithmeticshifter leftshifter run

clean:
	rm -rf buildDir sim* bscdir logicshifter logicshifter.* arithmeticshifter arithmeticshifter.* leftshifter leftshifter.*

run:
	./logicshifter
	./arithmeticshifter
	./leftshifter

.PHONY: clean all add compile run
.DEFAULT_GOAL := all
