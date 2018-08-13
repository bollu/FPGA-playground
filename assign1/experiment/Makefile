INPUT=Question
MODULE=question

build: ${INPUT}.bsv
	bsc -verilog ${INPUT}.bsv
	bsc -o sim.out -e question question.v

run: build
	./sim.out
