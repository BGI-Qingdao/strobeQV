# strobeQV

## Evaluate quality value (QV) of genome assemblies based on strobemers.

This script calculates the quality value (QV) of genome assemblies based on strobemers for error-tolerant searching and matching.

## Dependency
* gcc/g++ (version>4.8.5 to support c++11)
* make
* [Meryl v1.4.1](https://github.com/marbl/meryl/releases/tag/v1.4.1)

## Installation


Usage: ./qv.sh <ngs.read.fq.gz> <asm1.fasta> [asm2.fasta] <out> [strobe_n] [strobe_k] [strobe_w] [strobe_m]"
        echo
        echo -e "\t<read.fq.gz>:\t accurate NGS read set of the same sample"
        echo -e "\t<asm1.fasta>:\t assembly 1"
        echo -e "\t[asm2.fasta]:\t assembly 2, optional"
        echo -e "\t<out>.qv:\tQV of asm1, asm2 and both (asm1+asm2)"    
        echo
        echo -e "Strobemer Options"
        echo -e "\t[strobe_n]:\t  number of strobes [2], optional"
        echo -e "\t[strobe_k]:\t  strobe length, limited to 32 [10], optional"
        echo -e "\t[strobe_w]:\t  window size [30], optional"
        echo -e "\t[strobe_m]:\t  minstrobe mode [randstrobe], optional"
        echo
        echo "** This script calculates the quality value (QV) based on strobemers. **"
        
