#!/usr/bin/env bash

if [[ "$#" -lt 3 ]]; then
	echo "Usage: sh strobeQV.sh <ngs.read.fq.gz> <asm1.fasta> [asm2.fasta] <out> [strobe_n] [strobe_k] [strobe_w] [strobe_m]"
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
	exit 0
fi

read_fq=$1
asm1_fa=$2
name=$4

strobe_n=2
strobe_k=7
strobe_w=14
strobe_m=randstrobe

if [[ "$#" -eq 7 ]]; then
        asm2_fa=""
	name=$3
	strobe_n=$4
	strobe_k=$5
	strobe_w=$6
	strobe_m=$7
elif [[ "$#" -eq 8 ]]; then
        asm2_fa=$3
        strobe_n=$5
	strobe_k=$6
	strobe_w=$7
	strobe_m=$8
else
	strobe_n=2
	strobe_k=7
	strobe_w=14
	strobe_m=randstrobe
fi

strobe_kmer=$[($strobe_n-1)*$strobe_w+$strobe_k]
strobemer_kmer=$[$strobe_n*$strobe_k]
echo "strobe_kmer: $strobe_kmer"
read_db=`echo $read_fq | sed 's/.fastq.gz//g' | sed 's/.fq.gz//g' | sed 's/.fastq//g' | sed 's/.fq//g'`

if [[ ! -e $read_db.strobemer.meryl ]]; then
	echo "# Generate strobemer db for $read_db"
	meryl count k=$strobe_kmer output $read_db.meryl $read_fq
	meryl print $read_db.meryl | awk '{ for(i=0; i<$2; i++) print $1;  }' >$read_db.kmer
	kmer2strobemer --nkmer $strobe_n --ksize $strobe_k --wsize $strobe_w <$read_db.kmer >$read_db.strobemer
	awk '{id=id+1;printf("%s_%s\n%s\n",">sys",id,$0); }' $read_db.strobemer > $read_db.strobemer.fa
	meryl count k=$strobemer_kmer output $read_db.strobemer.meryl $read_db.strobemer.fa
	echo
fi

echo "Remove intermediate files: $read_db.meryl $read_db.kmer $read_db.strobemer $read_db.strobemer.fa"
rm -r $read_db.meryl $read_db.kmer $read_db.strobemer $read_db.strobemer.fa

if [[ "$#" -eq 3 ]]; then
        asm2_fa=""
        name=$3
else
        asm2_fa=$3
        echo "Found asm2: $asm2_fa"
fi

for asm_fa in $asm1_fa $asm2_fa
do
	asm=`echo $asm_fa | sed 's/.fasta.gz//g' | sed 's/.fa.gz//g' | sed 's/.fasta//g' | sed 's/.fa//g'`

	if [[ ! -e $asm.strobemer.meryl ]]; then
		echo "# Generate strobemer db for $asm"
		meryl count k=$strobe_kmer output $asm.meryl $asm_fa
		meryl print $asm.meryl | awk '{ for(i=0; i<$2; i++) print $1;  }' >$asm.kmer
		kmer2strobemer --nkmer $strobe_n --ksize $strobe_k --wsize $strobe_w <$asm.kmer >$asm.strobemer
		awk '{id=id+1;printf("%s_%s\n%s\n",">sys",id,$0); }' $asm.strobemer > $asm.strobemer.fa
		meryl count k=$strobemer_kmer output $asm.strobemer.meryl $asm.strobemer.fa
		echo
	fi

	meryl difference output $asm.0.strobemer.meryl $asm.strobemer.meryl $read_db.strobemer.meryl

	echo "# QV statistics for $asm"
	ASM_ONLY=`meryl statistics $asm.0.strobemer.meryl  | head -n4 | tail -n1 | awk '{print $2}'`
	TOTAL=`meryl statistics $asm.strobemer.meryl  | head -n4 | tail -n1 | awk '{print $2}'`
	if [[ $TOTAL -eq 0 ]]; then
		echo "[[ ERROR ]] :: $asm has no kmers."
	else
	ERROR=`echo "$ASM_ONLY $TOTAL" | awk -v k=$strobe_w '{print (1-(1-$1/$2)^(1/k))}'`
	QV=`echo "$ASM_ONLY $TOTAL" | awk -v k=$strobe_w '{print (-10*log(1-(1-$1/$2)^(1/k))/log(10))}'`
	echo -e "$asm\t$ASM_ONLY\t$TOTAL\t$QV\t$ERROR" >> $name.qv
	fi
	echo

	echo "Remove intermediate files: $asm.meryl $asm.kmer $asm.strobemer $asm.strobemer.fa"
	rm -r $asm.meryl $asm.kmer $asm.strobemer $asm.strobemer.fa

done

if [[ "$asm2_fa" == "" ]]; then
	echo -e "No asm2 found.\nDone!"
#	echo "Remove intermediate files:
#	rm -r $asm1.0.meryl"
	cat $name.qv
	exit 0
fi

asm2=`echo $asm2_fa | sed 's/.fasta.gz//g' | sed 's/.fa.gz//g' | sed 's/.fasta//g' | sed 's/.fa//g'`
asm1=`echo $asm1_fa | sed 's/.fasta.gz//g' | sed 's/.fa.gz//g' | sed 's/.fasta//g' | sed 's/.fa//g'`
asm="both"

meryl union-sum output $asm.strobemer.meryl   $asm1.strobemer.meryl   $asm2.strobemer.meryl
meryl union-sum output $asm.0.strobemer.meryl $asm1.0.strobemer.meryl $asm2.0.strobemer.meryl

echo "# QV statistics for $asm"
ASM_ONLY=`meryl statistics $asm.0.strobemer.meryl  | head -n4 | tail -n1 | awk '{print $2}'`
TOTAL=`meryl statistics $asm.strobemer.meryl  | head -n4 | tail -n1 | awk '{print $2}'`
ERROR=`echo "$ASM_ONLY $TOTAL" | awk -v k=$strobe_w '{print (1-(1-$1/$2)^(1/k))}'`
QV=`echo "$ASM_ONLY $TOTAL" | awk -v k=$strobe_w '{print (-10*log(1-(1-$1/$2)^(1/k))/log(10))}'`
echo -e "$asm\t$ASM_ONLY\t$TOTAL\t$QV\t$ERROR" >> $name.qv
echo

echo "Done!"
echo "Remove intermediate files: $asm.strobemer.meryl $asm1.strobemer.meryl $asm2.strobemer.meryl $asm.0.strobemer.meryl $asm1.0.strobemer.meryl $asm2.0.strobemer.meryl"
rm -r $asm.strobemer.meryl $asm1.strobemer.meryl $asm2.strobemer.meryl $asm.0.strobemer.meryl $asm1.0.strobemer.meryl $asm2.0.strobemer.meryl

cat $name.qv


