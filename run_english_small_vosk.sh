 . ./path.sh

corpus=$1
rescoring_corpus=$2

model_name=english_small_vosk
model_dir=models/$model_name/am
ivector_dir=models/$model_name/extractor
conf_dir=models/$model_name/conf
g2p_dir=models/$model_name/g2p/g2p.fst
dict_dir_=models/$model_name/dict
#complex_dict=models/spanish/dict/complex_words.txt

global_dict=
#models/spanish/dict/

order=3
tmp_dir=out_english_small_vosk
dict_dir=$tmp_dir/dict/
#carpa=vosk-model-en-us-daanzu-20200905-train/db/en-150k-0.4-small.lm.gz

mkdir -p $tmp_dir

stage=1
rescore=true

rm -rf $tmp_dir
mkdir $tmp_dir
mkdir -p $dict_dir

if [ $stage -le 1 ]; then
	if [ -z "$global_dict" ]
	then
	
		cat $corpus | tr " " "\n" | sort | uniq > $tmp_dir/dict/vocab.txt || exit 0;
		if [ -z "$rescoring_corpus" ]
		then
			echo ""
		else
			cat $rescoring_corpus | tr " " "\n" | sort | uniq >> $tmp_dir/dict/vocab.txt || exit 0;
		fi
		
		cp -r ${dict_dir_}/* $dict_dir/

		cat $tmp_dir/dict/vocab.txt  | sort | uniq > $tmp_dir/dict/vocab.txt.uniq

		python check_base_lexicon.py $model_name $tmp_dir/dict/vocab.txt.uniq $tmp_dir/dict/lexicon_valid.txt $tmp_dir/dict/missing_base.txt || exit 0;
		
		phonetisaurus-apply --model ${g2p_dir} --word_list $tmp_dir/dict/missing_base.txt > $tmp_dir/dict/lexicon_missing.txt || exit 0;

		cat $tmp_dir/dict/lexicon_valid.txt $tmp_dir/dict/lexicon_missing.txt > $tmp_dir/dict/lexicon.txt

		echo "!SIL	SIL" >> $tmp_dir/dict/lexicon.txt || exit 0;
		echo "[unk]	NSN" >> $tmp_dir/dict/lexicon.txt || exit 0;
		rm $tmp_dir/dict/lexiconp.txt
		if [ -z "$global_dict" ]
		then
			echo "no complex dict"
		else
			cat $complex_dict >> $tmp_dir/dict/lexicon.txt || exit 0;
		fi
		python remove_empty_pronunciation.py $tmp_dir/dict/lexicon.txt || exit 0;
		mv $tmp_dir/dict/lexicon.txt.clean $tmp_dir/dict/lexicon.txt || exit 0;
	else
		dict_dir=${global_dict}
	fi
fi


mkdir -p $tmp_dir/out || exit 0;

if [ $stage -le 2 ]; then
	echo "######################################################################################"
	echo "building arpa"
        echo "######################################################################################"

	ngram-count -order $order -write-vocab $tmp_dir/out/wordlist -wbdiscount -text $corpus -lm $tmp_dir/out/lm.arpa || exit 0;
	gzip < $tmp_dir/out/lm.arpa > $tmp_dir/out/lm.arpa.gz || exit 0;

        if [ -z "$rescoring_corpus" ]
        then
		echo ""
	else
	        echo "######################################################################################"
		echo "building arpa for rescoring"
	        echo "######################################################################################"
        	ngram-count -order $order -write-vocab $tmp_dir/out/wordlist_rescore -wbdiscount -text $rescoring_corpus -lm $tmp_dir/out/lm_rescore.arpa || exit 0;
        	gzip < $tmp_dir/out/lm_rescore.arpa > $tmp_dir/out/lm_rescore.arpa.gz || exit 0;
	fi

fi

if [ $stage -le 3 ]; then
        echo "######################################################################################"
	echo "formating lm"
        echo "######################################################################################"

	utils/prepare_lang.sh $dict_dir "[unk]" $tmp_dir/out/lang_tmp $tmp_dir/out/lang || exit 0;
	utils/format_lm.sh $tmp_dir/out/lang $tmp_dir/out/lm.arpa.gz ${dict_dir}/lexicon.txt $tmp_dir/out/lang_test || exit 0;
fi

if [ $stage -le 4 ]; then
        echo "######################################################################################"
	echo "building lookahead"
        echo "######################################################################################"
        echo "utils/mkgraph_lookahead.sh --self-loop-scale 1.0 $tmp_dir/out/lang_test $model_dir $tmp_dir/out/lm.arpa.gz $tmp_dir/out/lgraph"
	utils/mkgraph_lookahead.sh --self-loop-scale 1.0 $tmp_dir/out/lang_test $model_dir $tmp_dir/out/lm.arpa.gz $tmp_dir/out/lgraph || exit 0;

fi

if [ $stage -le 5 ]; then
        echo "######################################################################################"
	echo "building normal graph"
        echo "######################################################################################"

	utils/mkgraph.sh --self-loop-scale 1.0 $tmp_dir/out/lang_test $model_dir $tmp_dir/out/graph || exit 0;
fi


if [ $stage -le 6 ]; then
        echo "######################################################################################"
	echo "building rescoring lm"
        echo "######################################################################################"

        if [ -z "$rescoring_corpus" ]
        then
		echo ""
	else
		utils/format_lm.sh $tmp_dir/out/lang $tmp_dir/out/lm_rescore.arpa.gz ${dict_dir}/lexicon.txt $tmp_dir/out/lang_carpa_test || exit 0;
		utils/build_const_arpa_lm.sh $tmp_dir/out/lm_rescore.arpa.gz $tmp_dir/out/lang_carpa_test $tmp_dir/out/lang_carpa_test_tglarge || exit 0;
	fi
fi



mkdir -p $tmp_dir/model
mkdir -p $tmp_dir/model/am  $tmp_dir/model/conf  $tmp_dir/model/graph  $tmp_dir/model/ivector

if [ -z "$rescoring_corpus" ]
then
	echo ""
else
	mkdir -p $tmp_dir/model/rescore
fi

mkdir -p $tmp_dir/model/graph/phones
mkdir -p $tmp_dir/model_lh

#cp $tmp_dir/out/lgraph/disambig_tid.int $tmp_dir/model/graph/ || exit 0;
#cp $tmp_dir/out/lgraph/HCLr.fst $tmp_dir/model/graph/ || exit 0;
cp $tmp_dir/out/graph/HCLG.fst $tmp_dir/model/graph/ || exit 0;
cp $tmp_dir/out/graph/words.txt $tmp_dir/model/graph/ || exit 0;
#cp $tmp_dir/out/lgraph/Gr.fst $tmp_dir/model/graph/ || exit 0;
cp -r $ivector_dir/* $tmp_dir/model/ivector || exit 0;
cp $conf_dir/* $tmp_dir/model/conf/ || exit 0;
cp $tmp_dir/out/lgraph/phones/word_boundary.int $tmp_dir/model/graph/phones/ || exit 0;
#cp $model_dir/tree $tmp_dir/model/am/ || exit 0;
cp $model_dir/final.mdl $tmp_dir/model/am/ || exit 0;


if [ -z "$rescoring_corpus" ]
then
	echo ""
else
	cp $tmp_dir/out/lang_carpa_test_tglarge/G.carpa $tmp_dir/model/rescore || exit 0;
	cp $tmp_dir/out/lang_carpa_test_tglarge/G.fst $tmp_dir/model/rescore || exit 0;
fi

cp -r $tmp_dir/model/* $tmp_dir/model_lh/ || exit 0;
cp $tmp_dir/out/lgraph/HCLr.fst $tmp_dir/model_lh/graph/ || exit 0;
cp $tmp_dir/out/lgraph/Gr.fst $tmp_dir/model_lh/graph/ || exit 0;
cp $tmp_dir/out/lgraph/disambig_tid.int $tmp_dir/model_lh/graph/ || exit 0;
rm $tmp_dir/model_lh/graph/HCLG.fst || exit 0;

#if [ "$rescore" = true ] ; then
#	rm -rf $tmp_dir/model_lh/rescore || exit 0;
#fi
