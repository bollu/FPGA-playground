#Answers

To run, run `make test`, which builds and runs all the files with the
tests

- `Single.bsv` contains the implementation of the single-cycle
   fully unrolled adder. This circuit is wasteful
   (I should implement a wallace tree, but it's OK for now).

- `PipeElastic` `PipeInElastic` contain the other versions of the implementations.

- Tests are in `TestBench.bsv`, which runs 10000 tests on the
  given module by generating numbers in sequence. We can make this
  random, or generate "somewhat random" bits using an LSFR, but this
  is more principled in any case...

  Run `make run_singlecyclemult` to run the single cycle file.


## Testing the pipeline

For whatever reason, It seems that `mkSizedFIFO` only works till we push
2 elements into the pipeline (not sure why). Trying to push more that 2
causes it to stall. So, currently, I test the pipeline by pushing 2
numbers to be multiplied and then gathering the clock cycle numbers.

**TODO: figure out why this is the case! (Pipeline > 2 not working)**

We have a similar test cradle for elastic and inelastic case.

## LFSR for randomness
  We generate a random stream of numbers using an LFSR with hardcoded
  seeds of 10, 20 for the two numbers. 
  
  I tried using the supposed i_rand to seed the LFSR
  that allows one to pull random numbers, but it did not work.


  In theory, one can open `/dev/random` and then use that to feed the pipeline,
  but that's WAY too much work

  Link: http://wiki.bluespec.com/Home/Experienced-Users/Generating-Random-Test-Patterns

#Given Question
The code and the test bench for the multi-cycle multiplier is supplied.
Read how the entire bsv specification of the circuit is organized. Next,
analyze which rules are getting fired in each clock cycle and make sure
it is making sense.
 
Design a single cycle (purely combinational), elastic and inelastic 
pipelined multiplier
circuits. You should respect the Multiplier_IFC interface in your 
implementation. The module for single cycle multiplier should be mkSingle
and should be written in the file Single.bsv. 

The module for elastic pipelined multiplier should be mkElasticPipe and should
be written in the file PipeElastic.bsv. 

The module for inelastic pipelined multiplier should be mkInElasticPipe and
should be written in the file PipeInElastic.bsv.

You should test your circuit designs by writting your own test benches.
Writing good test benches is extremely important. So your submission
will also be evaluated based on the quality of the test bench you have
developed. We will test your design using a separate test bench not 
provided to you. 

Challenge Problem: For the multi-cycle design, compute the average 
number of cycles required on random operands and check if it matches
the theoretically computed values. 
