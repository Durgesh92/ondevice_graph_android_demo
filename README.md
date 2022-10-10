# How to set it up?

## Install dependencies

```bash
sudo apt install unzip tree python3-pip python3 automake autoconf sox gfortran libtool subversion python2.7 
```

Clone Kaldi https://github.com/kaldi-asr/kaldi and run following commands

```bash
	cd kaldi/tools/
	./extras/install_mkl.sh
	./extras/check_dependencies.sh  (Look for the output of this command, if all dependencies are installed it should output “all OK” else install the dependencies it has prompted)
	./extras/install_opengrm.sh
	./extras/install_srilm.sh
	cd ../src && ./configure
	make depend -j 8
	make -j 8
	make ext -j 8
```	


## How to do lm adaptation?

- goto https://github.com/CogHealthTech/Miro-Kaldi-for-android-new/tree/master/domain_adaptation/corpus and Add your language model corpus , refer to english.txt and spanish.txt over there (Make sure there are no symbols, no numbers, no punctuations)
- Set the correct path.sh (Example export KALDI_ROOT=/home/ubuntu/drive/kaldi)
- To build model run `./run_english english.txt` or `./run_spanish spanish.txt` for english and spanish model respectively
- The scripts will generate a model in `out_english/model_lh` and `out_spanish/model_lh` folders for english and spanish respectively
- To deploy the model on android just replace the model folder https://github.com/CogHealthTech/Miro-Kaldi-for-android-new/tree/master/android-demo/app/src/main/assets/model with newly generated model (make sure you change name form model_lh to model while changing android model)


