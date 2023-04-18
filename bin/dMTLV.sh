#!/bin/bash
#set -euxo pipefail

read inbam sample outdir hash <<< "$@"

if [ $# -lt 3 ]; then
    echo "Usage: $0 in.sort.bam sample outdir"
    exit 1
fi

`mkdir -p $outdir/$sample`

bin=`dirname $0`
bamRdf_opt=""
bamDCS_opt=" -c -q 0 -b -s 2 -t 2 -d "

home=`dirname $bin`
ref="$home/lib/chrM.fa"
pre="$outdir/$sample/$sample"

echo `date` dMTLV-start


if [ ! -f $pre.pileup.sign ]
then
    samtools mpileup -B -A -d 5000000 -f $ref $inbam > $pre.pileup

    touch $pre.pileup.sign
    echo `date` pileup-done
fi

# call mutation
if [ ! -f $pre.mut.adj.sign ]
then
    $bin/lhmut -s 1 -i $pre.pileup -o $pre.mut
    cat $pre.mut | perl -lane '$"="\t";@v=();  map { chomp; if (/^[DI]/){ /:(\d+)/;  push @v, $_ if $1 > 5 } elsif(/^[ACGT]/) {/:(\S+)/;  push @v, $_ if $1 <=1e-5;  } } @F[12..$#F]; print "@F[0..11]\t@v" if @v > 1 ' > $pre.mut.filted.txt

    touch $pre.mut.adj.sign
    echo `date` lhmut-done
fi

perl $bin/get_mut_for_anno.pl $pre && echo `date` format-done

rm -f $pre.*.sign

echo `date` job-done
