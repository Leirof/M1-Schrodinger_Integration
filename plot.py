from bokeh.plotting import figure, show, output_file
import bokeh
import bokeh.models as pltm
from numpy import *

from sys import argv
import os

listfile = []
try:
    toPlot = argv[1]
    if toPlot == "bulk":
        for file in os.listdir("results"):
            listfile.append("results/" + file)
    if toPlot == "variation":
        listfile.append("results/de_variation.dat")
    else:
        raise
except:
    try:
        with open("results/Wavefunction.txt"):
            listfile = ["results/Wavefunction.txt"]
    except:
        print("No result file found")
        exit()

# , y_axis_type="log"
color=["red","orange","yellow","green","blue","purple","pink"]
for i, filename in enumerate(listfile):
    if toPlot == "variation":
        p = figure(title="Variation of de", sizing_mode="stretch_both", y_axis_label='de', x_axis_label='e')
    else:
        p = figure(title="Wavefunction", sizing_mode="stretch_both", y_axis_label='Psy (r)', x_axis_label='r')
    
    line_color = color[i%7]
    x = []
    y = []
    N = 0
    with open(filename) as file:
        for line in file:
            if line[-1] == "\n": line = line[:-1]
            line = line.replace("E","").replace("-","E-").replace("+","E+")
            newValues = []
            values = line.split(" ")
            for i in values:
                try:
                    if i[0] == "E": i = i[1:]
                    newValues.append(float(i))
                except:
                    pass
            x.append(float(newValues[0]))
            y.append(float(newValues[1]))
            N += 1
        
    
    if toPlot == "variation":
        t = zip(x,y)
        t = sorted(t)
        t = zip(*t)
        x,y = [a for a in t]
        p.circle(x, y, line_color="blue", line_width=2)
        p.line(x, y, line_color="black", line_width=1)
        p.add_tools(pltm.HoverTool())
        output_file(filename="results/variation.html")
    else:
        p.line(x, y, line_color="red", line_width=2)
        output_file(filename="results/wavefunction_plotted.html")
    bokeh.io.save(p)
    show(p)
