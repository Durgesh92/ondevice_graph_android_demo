import sys

op = open(sys.argv[1]+".clean","w")
sk = 0
sk_ = []
with open(sys.argv[1],"r") as f1:
	for line in f1:
		ls = line.strip().split("\t")
		if len(ls) == 2:
			op.write(line)

		else:
			sk = sk + 1
			sk_.append(ls)
print("skipped :: ",sk)
print(sk_)	
