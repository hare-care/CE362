import numpy as np
#import matplotlib.pyplot as plt
seed = 42
multiplier = 1664525
increment = 1013904223
bits = 32
max_value = 128
x = []

def lcg():
    global seed, x
    hold = (seed * multiplier) % (2**bits)
    hold = (hold + increment) % (2**bits)
    number = hold % max_value
    print(f"Generated number {number} using seed {seed}")
    seed = hold
    x.append(number)
    return number

def gen_distribution():
    for i in range(10000):
        lcg()
    plt.hist(x, bins=64)
    plt.show()

def branch_tester(iterations):
    start_value = 1
    lcg()
    for i in range(iterations):
        number = lcg()
        if number >= 100:
            start_value = start_value * -1
            print("multiplying by -1, value at ", start_value)
        elif number >= 80:
            start_value = start_value * 3
            print("multiplying by 3, value at ", start_value)
        elif number <= 8:
            start_value = start_value + 2047
            print("adding 2047, value at ", start_value)
        elif number <= 25:
            start_value = start_value - 57
            print("subtracting 57, value at ", start_value)
        else:
            start_value = start_value + 1
            print("adding 1, value at ", start_value)
        
    print("you have ended up with: ", start_value)

branch_tester(10)
    
    

    


    