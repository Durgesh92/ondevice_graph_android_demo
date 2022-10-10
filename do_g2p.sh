 . ./path.sh

corpus=$1

model_dir=vosk-model-en-us-daanzu-20200905-train/exp/chain/nnet
ivector_dir=vosk-model-en-us-daanzu-20200905-train/extractor/ivector_extractor
conf_dir=vosk-model-en-us-daanzu-20200905-train/conf
global_dict=vosk-model-en-us-daanzu-20200905-train/dict
order=3
tmp_dir=tmp_dict
dict_dir=$tmp_dir/dict/

mkdir -p $tmp_dir $dict_dir

carpa=vosk-model-en-us-daanzu-20200905-train/db/en-150k-0.4-small.lm.gz

mkdir -p $tmp_dir


	grep -o -E '\w+' $corpus | sort -u -f > $tmp_dir/dict/vocab.txt || exit 0;
	g2p.py --model kaldi-generic-en-tdnn_f-r20190609/g2p/sequitur-dict-en.ipa-r20190113 --apply $tmp_dir/dict/vocab.txt > $tmp_dir/dict/lexicon.txt || exit 0;
	echo "!SIL SIL" >> $tmp_dir/dict/lexicon.txt || exit 0;
	echo "[unk] SPN" >> $tmp_dir/dict/lexicon.txt || exit 0;
	rm $tmp_dir/dict/lexiconp.txt
	python local/fix_lexicon.py $tmp_dir/dict/lexicon.txt || exit 0;
	mv $tmp_dir/dict/lexicon.txt.new $tmp_dir/dict/lexicon.txt || exit 0;
