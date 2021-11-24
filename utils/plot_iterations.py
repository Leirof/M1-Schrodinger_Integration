from bokeh.plotting import figure, output_file,show
import numpy as np
from bokeh.models import Span

v0 = np.array([
    [-0.96,-0.9473,3],
    [-0.96,-0.9473,3],
    [-0.96,-0.9473,3],
    [-0.95,-0.9473,2],
    [-0.94,-0.9473,3],
    [-0.92,-0.9473,4],
    [-0.91,-0.9473,4],
    [-0.90,-0.9473,5]
])

v1 = np.array([
    [-0.89,-0.8469,9],
    [-0.88,-0.8469,5],
    [-0.87,-0.8469,4],
    [-0.86,-0.8469,3], 
    [-0.85,-0.8469,2], 
    [-0.84,-0.8469,3], 
    [-0.83,-0.8469,3], 
    [-0.82,-0.8469,4], 
    [-0.81,-0.8469,4], 
    [-0.80,-0.8469,4], 
    [-0.79,-0.8469,5], 
    [-0.78,-0.8469,7]
])

p0 = figure(title="Iterations", sizing_mode="stretch_both", y_axis_label='Number of iteration', x_axis_label='Starting Energy')
p0.line(v0[:,0],v0[:,2])
p0.circle(v0[:,0],v0[:,2],size=10)
vline = Span(location=v0[0,1], dimension='height', line_color='red', line_width=3)
p0.renderers.extend([vline])
output_file(filename="v0_iterations.html")
show(p0)


p1 = figure(title="Iterations", sizing_mode="stretch_both", y_axis_label='Number of iteration', x_axis_label='Starting Energy')
p1.line(v1[:,0],v1[:,2])
p1.circle(v1[:,0],v1[:,2],size=10)
vline = Span(location=v1[0,1], dimension='height', line_color='red', line_width=3)
p1.renderers.extend([vline])
output_file(filename="v1_iterations.html")
show(p1)