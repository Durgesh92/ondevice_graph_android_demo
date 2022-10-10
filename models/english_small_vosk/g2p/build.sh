#!/bin/sh

export PATH=/home/shmyrev/.local/lib/python3.7/site-packages/phonetisaurus/bin/x86_64:$PATH
export LD_LIBRARY_PATH=/home/shmyrev/.local/lib/python3.7/site-packages/phonetisaurus/lib/x86_64

./convert.py cmudict.dic 20
phonetisaurus-align --input=cmudict.dic.train --ofile=cmudict.dic.corpus
ngram-count -order 8 –kn-modify-counts-at-end -ukndiscount -text cmudict.dic.corpus -lm cmudict.dic.arpa
phonetisaurus-arpa2wfst --lm=cmudict.dic.arpa -ofile=cmudict.fst
phonetisaurus-apply --model=cmudict.fst --word_list cmudict.dic.test.list > cmudict.dic.hyp
./eval.py cmudict.dic.test cmudict.dic.hyp
