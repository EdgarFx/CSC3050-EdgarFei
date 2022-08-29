tester:tester.o assembler.o
	g++ tester.o assembler.o -o tester
tester.o:tester.cpp assembler.h
	g++ -c tester.cpp -o tester.o
assembler.o:assembler.cpp assembler.h
	g++ -c assembler.cpp -o assembler.o