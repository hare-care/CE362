vec_sum benchmark

This benchmark is testing the load and store systems of the processor as well as potential parallel computation. 

Two vectors are specified in memory, and they will have a value added to each element. This addition should not rely on the previous addition, giving room for non-dependent operations which can be done in parallel. 

The two vectors should be the same length, as only one len variable is specified.
The values in the vectors are arbitrary, as well as the value being added to them.

If changing the length of the vectors, then the pointer to those vectors must be updated in the code, calculated manually.