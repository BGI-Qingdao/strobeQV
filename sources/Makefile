.PHONY: all clean

kmer2strobemer: kmer2strobemer.cpp strobemer.cpp strobemer.h
	g++ -c -std=c++11 -g strobemer.cpp -I./strobemer -o strobemer.o
	g++ -g -std=c++11 kmer2strobemer.cpp strobemer.o -o kmer2strobemer
