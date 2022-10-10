import sys

mdl = sys.argv[1]
vocab = sys.argv[2]
out_lex = sys.argv[3]
missing_words = sys.argv[4]

base_ = {}
with open("models/"+mdl+"/dict/base_dictionary.txt","r") as f1:
	for line in f1:
		ls = line.strip().split(" ")
		if ls[0] not in base_:
			tmp = []
			tmp.append(" ".join(ls[1:]))
			base_[ls[0]] = tmp
		else:
			tmp = base_[ls[0]]
			tmp.append(" ".join(ls[1:]))
			base_[ls[0]] = tmp

op1 = open(out_lex,"w")
op2 = open(missing_words,"w")

with open(vocab,"r") as f1:
	for line in f1:
		ls = line.strip()
		if ls in base_:
			tmp = base_[ls]
			for y in tmp:
				op1.write(ls+"\t"+y+"\n")
		else:
			op2.write(ls+"\n")
			#print(ls)


