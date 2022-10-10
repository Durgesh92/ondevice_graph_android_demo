import sys

lex = {}

with open(sys.argv[1],"r") as f1: # dict
	for line in f1:
		ls = line.strip().split(" ")
		lex[ls[0]] = " ".join(ls[1:])

with open(sys.argv[2],"r") as f2: # corpus
	for line in f2:
		ls = line.strip().split(" ")
		for x in ls:
			print(x,lex[x])
