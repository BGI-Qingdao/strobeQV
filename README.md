# strobeQV

## Evaluate quality value (QV) of genome assemblies based on strobemers.

This script calculates the quality value (QV) of genome assemblies based on strobemers for error-tolerant searching and matching. The use of strobemers in text similarity searches allows for more flexibility in matching, even with mutations or small shifts in the text. This pipeline is designed to use the strobemers to increase the matching possibilities of error-prone third-generation long-read genome assembly sequences to the accurate NGS read sets, thus tolerating the sequencing errors of long reads and evaluating the true assembly errors.    

## Dependency
* gcc/g++ (version>4.8.5 to support c++11)
* make
* [Meryl v1.4.1](https://github.com/marbl/meryl/releases/tag/v1.4.1)
* [strobmers](https://github.com/ksahlin/strobemers)
  
## Installation

### Download and compile from source codes

```
git clone https://github.com/BGI-Qingdao/strobeQV.git  ./strobeQV
cd  ./strobeQV/sources
make
export PATH=$pwd:$PATH
```

## Run

* !! strobeQV requires accurate NGS reads in a single file, one haplotype-collapsed or two haplotype-resolved genome assemblies for the same sample !!

```
sh strobeQV.sh <ngs.read.fq.gz> <asm1.fasta> [asm2.fasta] <out> [strobe_n] [strobe_k] [strobe_w] [strobe_m]

Usage: sh strobeQV.sh <ngs.read.fq.gz> <asm1.fasta> [asm2.fasta] <out> [strobe_n] [strobe_k] [strobe_w] [strobe_m]
        
        <read.fq.gz>: accurate NGS read file of this sample
        <asm1.fasta>: assembly 1 of the same sample
        [asm2.fasta]: assembly 2, optional
         <out>.qv: QV of asm1, asm2 and both (asm1+asm2) 
        
        `Strobemer Options`
        [strobe_n]:  number of strobes [2], optional
        [strobe_k]:  strobe length, limited to 32 [7], optional
        [strobe_w]:  window size [14], optional
        [strobe_m]:  minstrobe mode [randstrobe], optional
```
`< >` : required  
`[ ]` : optional

## Example

```
# Run strobeQV
sh strobeQV.sh ngs.reads.fq.gz mat_asm.fasta pat_asm.fasta test
```

### 1. I have one haplotype-collapsed assembly
```shell
# I have one single NGS read file
mkdir strobeQV
cd strobeQV
ln -s DATA_PATH/YOUR_NGS_FILE ./ngs.reads.fq.gz
ln -s DATA_PATH/YOUR_ASM_FILE ./asm.fasta
sh strobeQV.sh ngs.reads.fq.gz asm.fasta mixed

# I have multiple NGS read files
cat DATA_PATH/YOUR_NGS_FILE1 DATA_PATH/YOUR_NGS_FILE2 > DATA_PATH/YOUR_NGS_FILE
mkdir strobeQV
cd strobeQV
ln -s DATA_PATH/YOUR_NGS_FILE  ./ngs.reads.fq.gz
ln -s DATA_PATH/YOUR_ASM_FILE ./asm.fasta
sh strobeQV.sh ngs.reads.fq.gz asm.fasta mixed
```

### 2. I have two haplotype-resolved assemblies
```shell
# I have one single NGS read file
mkdir strobeQV
cd strobeQV
ln -s DATA_PATH/YOUR_NGS_FILE ./ngs.reads.fq.gz
ln -s DATA_PATH/YOUR_ASM_FILE1 ./mat_asm.fasta
ln -s DATA_PATH/YOUR_ASM_FILE2 ./pat_asm.fasta
sh strobeQV.sh ngs.reads.fq.gz mat_asm.fasta pat_asm.fasta diploid

# I have multiple NGS read files
cat DATA_PATH/YOUR_NGS_FILE1 DATA_PATH/YOUR_NGS_FILE2 > DATA_PATH/YOUR_NGS_FILE
mkdir strobeQV
cd strobeQV
ln -s DATA_PATH/YOUR_NGS_FILE  ./ngs.reads.fq.gz
ln -s DATA_PATH/YOUR_ASM_FILE ./mat_asm.fasta
ln -s DATA_PATH/YOUR_ASM_FILE ./pat_asm.fasta
sh strobeQV.sh ngs.reads.fq.gz mat_asm.fasta pat_asm.fasta diploid
```

## Output

* !! The QV evaluation results are stored in the <out>.qv file !!

```
ASM_NAME        # STROBEMERS ONLY IN ASM        # TOTAL STROBEMERS IN ASM        # QV        # ERROR_RATE
```

For example:

```
mat_asm        18252        82877672        48.0321        1.57322e-05
pat_asm        14834        82985222        48.9383        1.27693e-05
both        33086        165862894        48.4619        1.42497e-05
```
