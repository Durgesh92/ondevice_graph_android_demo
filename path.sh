export KALDI_ROOT=/home/ubuntu/kaldi


export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh

export PATH=$PATH:/usr/local/cuda/bin

export PATH=$KALDI_ROOT/tools/python:${PATH}
export LIBLBFGS=$KALDI_ROOT/tools/liblbfgs-1.10
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:${LIBLBFGS}/lib/.libs:$KALDI_ROOT/tools/openfst/lib/fst
export SRILM=$KALDI_ROOT/tools/srilm
export PATH=${PATH}:${SRILM}/bin:${SRILM}/bin/i686-m64
export LC_ALL=C
