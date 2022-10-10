order=3
tmp_dir=tmp
corpus=$1
ngram-count -order $order -write-vocab $tmp_dir/wordlist -wbdiscount -text $corpus -lm $tmp_dir/lm.arpa
