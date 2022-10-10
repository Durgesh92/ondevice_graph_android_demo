#!/usr/bin/python

import sys

if len(sys.argv) != 3:
    print "Split the list on train and test sets"
    print
    print "Usage: traintest.py file split_count"
    exit()

infile = open(sys.argv[1], "r")
outtrain = open(sys.argv[1] + ".train", "w")
outtest = open(sys.argv[1] + ".test", "w")
outlist = open(sys.argv[1] + ".test.list", "w")

cnt = 0
split_count = int(sys.argv[2])

for line in infile:
    items = line.split()
    if items[0][-1] == ')':
	items[0] = items[0][:-3]
    if items[0].find("_") > 0:
	continue
    line = items[0] + '\t' + " ".join(items[1:]) + '\n'
    if cnt % split_count == 7:
        outtest.write(line)
        outlist.write(items[0] + '\n')
    else:
        outtrain.write(line)
    cnt = cnt + 1
