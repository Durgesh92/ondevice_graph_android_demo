import sys
import re


symb = {
	"%":"percentage",
	"$":"dollar",
	"+":"plus",
	"1":"one",
	"2":"two",
	"3":"three",
	"4":"four",
	"5":"five",
	"6":"six",
	"7":"seven",
	"8":"eight",
	"9":"nine",
	"0":"zero",
	".dom" : "dot com",
	"½" : "half",
	"°": "degree",
	"µl" : "microliter",
	}

	#"мой" : "",
	#"мужчина" : "",
	#"рута" : "",
	#"сильный" : "",
	#"червона" : "",
	#"オマエモナー" : "",
	#"中文" : "",
	#"國語" : "",
	#"漢字" : "",
	#"華人" : ""
	#}

def removeUTF(inputString):
	return inputString.encode("ascii", "ignore").decode()

def hasNumbers(inputString):
	return any(char.isdigit() for char in inputString)

def replaceSymb(inputString):
	no_punct = inputString
	for key in symb:
		if key in  no_punct:
			no_punct = no_punct.replace(key," "+symb[key]+" ")
	return removeMultiSpace(no_punct.strip())

def removePunc(inputString):
	punctuations = '''!()-[]{};:"\,<>./?^&*_~`#회|°–='''
	no_punct = ""
	for char in inputString:
		if char not in punctuations:
			no_punct = no_punct + char
	return removeMultiSpace(no_punct.strip())


def removeMultiSpace(inputString):
	return re.sub("\s\s+" , " ", inputString)


def clean_corpus(input_corpus):
	op1 = open(input_corpus+"_clean","w")
	with open(input_corpus,"r") as f1:
		for line in f1:
			ls = line.strip()
			ls = replaceSymb(removeUTF(ls))
			if not hasNumbers(ls):
				p1 = removePunc(ls)
				op1.write(p1+"\n")

def clean_utt(utt):
	ls = utt.strip()
	ls = replaceSymb(removeUTF(ls))
	if not hasNumbers(ls):
		p1 = removePunc(ls)
		return(p1)
	return ""
