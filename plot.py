from os.path import exists
import sys
import numpy as np

fileName = sys.argv[1]+".txt"
if exists(fileName):
  import matplotlib.pyplot as plt
  print(f"plotting file: {fileName}")
  values,labels,ticks = [],[],[]
  ticker = 0
  first = True
  for line in open(fileName):
    l = line.strip().split()
    if first:
      plt.title(line)
      first = False
    else:
      if l[0].endswith("Jan") and (int(l[0][:4])%3 == 0):
        labels.append(l[0])
        ticks.append(ticker)
      values.append(float(l[1]))
      ticker += 1
  means = []
  if exists("runmean.txt"):
    first = True
    for line in open("runmean.txt"):
      l = line.strip().split()
      if first: first = False
      else: 
        # print(l[1])
        means.append(float(l[1]))
        print(means[len(means)-1])
    for i in range(len(values)-len(means)):
      means.insert(i,np.nan)
  plt.plot(values)   
  if len(means) > 0:
    plt.plot(means,color = 'red')
  plt.xticks(ticks,labels)
  plt.xticks(rotation = 45)
  plt.xticks(fontsize = 5)
  plt.grid()
  # plt.autoscale(axis = 'y')
  plt.show()
