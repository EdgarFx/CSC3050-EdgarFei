#include <cstdio>
#include <string>
#include "assembler.h"

int compare_files(FILE* fp1, FILE* fp2)
{
	char char1 = fgetc(fp1);
	char char2 = fgetc(fp2);

	while(char1 != EOF && char2 != EOF){
		if(char1 != char2){
			return -1;
		}
        char1 = fgetc(fp1);
        char2 = fgetc(fp2);
	}
	return 0;
}

int main (int argc, char * argv[]){
    if(argc<4){
        printf("Please enter an input file, an output file, and expected output file \n");
    }
    FILE *in_file, *out_file;
    in_file = fopen(argv[1], "r");
    out_file = fopen(argv[2],"w+");
    phase1(in_file,instructions);
    rewind(in_file);
    phase2(in_file,out_file,instructions);

    FILE *fp1,*fp2;
    fp1 = fopen(argv[3],"r");
    fp2 = fopen(argv[2],"r");
    if(fp1 == NULL || fp2 == NULL){
    	printf("Error: Files are not open correctly \n");
    }

    int res = compare_files(fp1, fp2);

    if(res == 0){
    	printf("ALL PASSED! CONGRATS :) \n");
    }else{
    	printf("YOU DID SOMETHING WRONG :( \n");
    }

    fclose(fp1);
    fclose(fp2);
    return 0;
}