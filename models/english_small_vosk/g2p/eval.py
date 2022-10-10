#!/usr/bin/env python3

import sys
import re
from collections import defaultdict

def LoadRefs (refs_file) :
    refs = {}

    with open (refs_file, "r") as ifp :
        for line in ifp :
            parts = re.split (r"\t", line.strip ())
            word = parts.pop (0)
            refs [word] = parts

    return refs

def LoadNbestHyps (hyps_file) :
    hyps = defaultdict (list)

    with open (hyps_file, "r") as ifp :
        for line in ifp :
            parts = re.split (r"\t", line.strip ())
            if parts [-1] == "" :
                continue

            hyps [parts [0]].append (parts [-1])

    return hyps

def ComputeEval (refs, hyps) :
    refs = LoadRefs (refs)
    hyps = LoadNbestHyps (hyps)

    total = 0.
    corr = 0.
    for ref_word, ref_prons in refs.items () :
        hyp_prons = hyps [ref_word]
        ref_set = set (ref_prons)
        hyp_set = set (hyp_prons)
        intersection = ref_set.intersection (hyp_set)

        total += 1.0
        if len (intersection) > 0 :
            corr += 1.0

    print ("Corr: {0}, Err: {1}, WACC: {2:0.2f}%, WER: {3:0.2f}%".format (
        corr,
        total - corr,
        corr / total * 100,
        (1.0 - (corr / total)) * 100
    ))

if __name__ == '__main__':
    ComputeEval(sys.argv[1], sys.argv[2])
