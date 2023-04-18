# dMTLV (v1.1)
dMTLV is a framework for detecting mtDNA variants (SNVs and Indels) from short-read whole genome sequencing data

## Getting Started
dMTLV is written in C++, Perl and Shell

### Prerequisites

* htslib (https://github.com/samtools/htslib)

- SeqLib(https://github.com/walaj/SeqLib)

* alglib(http://www.alglib.net/translator/re/alglib-3.15.0.cpp.gpl.tgz)

***
### Installing

  git clone https://github.com/sunnyzxh/dMTLV.git
  cd dMTLV
  cd example
  sh test.sh # check if it works

If "job-done", there should be four files under the folder example

***

### Usage
#### Please prepare the following inputs

* The bam file with reads mapped to chrM (the Revised Cambridge Reference Sequence (rCRS, NC_012920))

- Sample name

* The output direction

#### Running

sh dMTLV.sh input.bam sample.name output.dir

#### Outputs

* *.pipelup the pipelup file

- *.mut the raw variants

* *.mut.filted.txt the filterred variants

- *.mut.filted.anno the formatted file of the filterred variants for annotation (the final output)

***

### Support
Should you have any question, please feel free to contanct sunnyzxh@connect.hku.hk
  
