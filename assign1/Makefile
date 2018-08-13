INPUT=4bitrca
MODULE=hello

build: ${INPUT}.bsv
	bsc -verilog ${INPUT}.bsv
	bsc -o sim -e mkHelloWorld mkHelloWorld.v

run: build
	./sim
