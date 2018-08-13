INPUT=FirstAttempt
MODULE=hello

build: ${INPUT}.bsv
	bsc -verilog ${INPUT}.bsv
	bsc -o sim.out -e mkAttempt mkAttempt.v

run: build
	./sim.out
