from scipy.integrate import simpson
from bokeh.plotting import figure, show
import numpy as np
import matplotlib.pyplot as plt
B=60.8

p = figure(title="Wavefunction verification",sizing_mode="stretch_both",x_axis_label="r",y_axis_label="f")

W0 = np.loadtxt('results/Wavefunction_0.txt')
x0 = W0[:,0]
y0 = W0[:,1]
r0 = 1 / x0**2
p.line(x0, y0, line_color="blue", legend_label=f"Wave 0", line_width=2)


W1 = np.loadtxt('results/Wavefunction_1.txt')
x1 = W1[:,0]
y1 = W1[:,1]
r1 = 1/x1**2
p.line(x1, y1, line_color="red", legend_label=f"Wave 1", line_width=2)

show(p)

tmp = y0**2 * r0 / simpson(y0**2, x0)
I0 = simpson(tmp, x0)

tmp = y1**2 * r1 / simpson(y1**2, x1)
I1 = simpson(tmp, x1)

print(f"B0 = {B * I0}")
print(f"B1 = {B * I1}")