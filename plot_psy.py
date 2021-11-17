from bokeh.plotting import figure, show
import bokeh
from numpy import *

from sys import argv
import os

listfile = []
try:
    if argv[1] == "bulk":
        for file in os.listdir("results"):
            listfile.append("results/" + file)
    else:
        try:
            i = int(argv[1])
            if i < 10:
                with open(f"results/Wavefunction_ {i}.txt"):
                    listfile = [f"results/Wavefunction_ {i}.txt"]
            else:
                with open(f"results/Wavefunction_{i}.txt"):
                    listfile = [f"results/Wavefunction_{i}.txt"]
        except:
            pass
except:
    pass

if listfile == []:
    try:
        with open("results/Wavefunction.txt"):
            listfile = ["results/Wavefunction.txt"]
    except:
        print("No result file found")
        exit()

# , y_axis_type="log"
color=["red","orange","yellow","green","blue","purple","pink"]
for i, filename in enumerate(listfile):
    p = figure(title="Wavefunction", sizing_mode="stretch_both", y_axis_label='Psy (r)', x_axis_label='r')

    if filename == "results/Wavefunction.txt":
        node = "v=unknown"
    else:
        node = "v=" + filename.replace(" ","").replace("results/Wavefunction_","").replace(".txt","")
    line_color = color[i%7]
    x = None
    y = None
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
        
    #, sizing_mode="stretch_both", height=800
    p.line(x, y, legend_label=node, line_color="red", line_width=2)
    #color[i%7]
    bokeh.io.save(p)
    show(p)
