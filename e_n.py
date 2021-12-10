from numpy import *
a = 1.3924; b = 1.484e-3
for n in range(9): print(f"E_{n} = {round(-(1 - a*sqrt(b)*(n+1/2))**2,4)}")