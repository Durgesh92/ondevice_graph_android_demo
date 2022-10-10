import sys

dict1 = {
	"' e:":"'e:",
	"' OI":"'OI",
	"' aI":"'aI",
	"' 3":"'3",
	"' aU":"'aU",
	"' A":"'A",
	"' @":"'@",
	"' E":"'E",
	"' I":"'I",
	"' O":"'O",
	"' U":"'U",
	"' V":"'V",
	"' e":"'e",
	"' i":"'i",
	"' o":"'o",
	"' u":"'u",
	"' {":"'{"
	}


skip_err = True

op = open(sys.argv[1]+".new","w")
with open(sys.argv[1],"r") as f1:
	for line in f1:
		ls = line.strip().split()
		word = ls[0]
		pronun = " ".join(ls[1:])
		error = False
		for x in dict1:
			if x in pronun:
				pronun = pronun.replace(x,dict1[x])
		if len(ls) == 1:
			pronun = "SIL"
			error = True
			print("missing pronuncitation SIL ==>",ls)
		if "' " in pronun:
			pronun = "SIL"
			error = True
			print("1 SIL ==>",ls)

		if pronun[len(pronun)-1] == "'":
			pronun = "SIL"
			error = True
			print("nl SIL ==>",ls)

		if " ' " in pronun:
			pronun = "SIL"
			error = True
			print("sil ==>",ls)
		if not error:
			op.write(word+" "+pronun+"\n")
