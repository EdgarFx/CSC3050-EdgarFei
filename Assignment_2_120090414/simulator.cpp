#include <iostream>
#include <string>
#include <cstring>
#include <map>
#include <set>
#include <cstdio>
#include <unistd.h>
#include <fcntl.h>
#include <bitset>
#include <cstdlib>
#include "simulator.h"
using namespace std;


int main(int argc,char** argv){
    FILE *mips_file;
    FILE *in_file;
    FILE *out_file;
    FILE *code_file;
    FILE *checkpoints_file;
    if(argc!=6){
        printf("Incorrect number of arguments!\n");
        exit(1);
    }
    else{
        mips_file = fopen(argv[1],"r");
        code_file = fopen(argv[2],"r");
        checkpoints_file = fopen(argv[3],"r");
        in_file = fopen(argv[4],"r");
        out_file = fopen(argv[5],"w");
        MEMORY_START = virtual_memory()-0x400000;
        init_checkpoint(checkpoints_file);
        phase1(mips_file,instructions);
        rewind(mips_file);
        phase2(mips_file,code_file,instructions);
        simulator(in_file,out_file);
    }
    return 0;
}


// get the corrsponding number of the register
inline int get_regNum(char *reg_name) {
    if (!strcmp(reg_name,"$zero")) return 0;
    else if (!strcmp(reg_name,"$at")) return 1;
    else if (!strcmp(reg_name,"$v0")) return 2;
    else if (!strcmp(reg_name,"$v1")) return 3;
    else if (!strcmp(reg_name,"$a0")) return 4;
    else if (!strcmp(reg_name,"$a1")) return 5;
    else if (!strcmp(reg_name,"$a2")) return 6;
    else if (!strcmp(reg_name,"$a3")) return 7;
    else if (!strcmp(reg_name,"$t0")) return 8;
    else if (!strcmp(reg_name,"$t1")) return 9;
    else if (!strcmp(reg_name,"$t2")) return 10;
    else if (!strcmp(reg_name,"$t3")) return 11;
    else if (!strcmp(reg_name,"$t4")) return 12;
    else if (!strcmp(reg_name,"$t5")) return 13;
    else if (!strcmp(reg_name,"$t6")) return 14;
    else if (!strcmp(reg_name,"$t7")) return 15;
    else if (!strcmp(reg_name,"$s0")) return 16;
    else if (!strcmp(reg_name,"$s1")) return 17;
    else if (!strcmp(reg_name,"$s2")) return 18;
    else if (!strcmp(reg_name,"$s3")) return 19;
    else if (!strcmp(reg_name,"$s4")) return 20;
    else if (!strcmp(reg_name,"$s5")) return 21;
    else if (!strcmp(reg_name,"$s6")) return 22;
    else if (!strcmp(reg_name,"$s7")) return 23;
    else if (!strcmp(reg_name,"$t8")) return 24;
    else if (!strcmp(reg_name,"$t9")) return 25;
    else if (!strcmp(reg_name,"$k0")) return 26;
    else if (!strcmp(reg_name,"$k1")) return 27;
    else if (!strcmp(reg_name,"$gp")) return 28;
    else if (!strcmp(reg_name,"$sp")) return 29;
    else if (!strcmp(reg_name,"$fp")) return 30;
    else if (!strcmp(reg_name,"$ra")) return 31;
    else{
        return -1;
    }
}

// get the index of the specific label stored in the label array
inline int get_label(char *label_name){
    for (int i = 1; i <= label_num; i++){
        if (!strcmp(labelArray[i].name, label_name)){
            return i;}     
    }    
    return 0;
}

char* virtual_memory(){
    char* memory;
    memory = (char*)malloc(0x600010*sizeof(int));
    return memory;
}

// append the label we finded into the label array
inline void append_label(char *block,int PC) {
    if (!get_label(block)) {
        label_num++;    
        labelArray[label_num].address = PC;
        labelArray[label_num].name = block;
    }
}

// get the effective block of the MIPS code
inline char *get_block(char *start_ptr,char **end_ptr,char const *invalid) {
    int length;
    char *block,*p1,*p2;
    
    length = strspn(start_ptr,invalid); // find the first valid one after the invalid character
    p1 = start_ptr+length;
    p2 = strpbrk(p1,invalid); // get the first invalid character after the valid ones
    if (p2 == NULL){
        return(NULL);
    }
    length = p2-p1;
    *end_ptr = p2+1;
    block = (char*)malloc(length+1);
    if ((length==0)||(block==NULL)) {
        return NULL;
    }
    memcpy(block,p1,length);
    block[length] = '\0';
    return block;
}

// find whether a block is an instruction, if so, get the index of the instruction in the list of all instructions
inline int get_instruction(char *block,char const **instructions){
    for (int i = 0; i < 55; i++){
        if (!strcmp(block,*(instructions+i))){return i;}
    }       
    return -1;
}

// this is the phase1 of the project, the most important thing of this part is to store the label name and its address in a list
void phase1(FILE *in_file,char const **instructions){
    int PC = TEXT_START;
    char currentLine[257];
    int tempPC = PC;
    int length;
    bool in_text = 1;
    bool in_data = 0;
    char *block,*spt,*thisLine;
    
    while (true){
        for (int i = 0;i < 257;i++){
            currentLine[i] = '\0';
        } 
        thisLine = fgets(currentLine,256,in_file);
        if (thisLine == NULL){
            break;
        }
        length = strlen(currentLine);
        currentLine[length] = '\n';   
        spt = currentLine;
        while (true){
            block = get_block(spt,&spt,",\n\t ");
            if ((block==NULL)||(*block=='#')) {
                free(block);
                break;
            }
            int ins_i = get_instruction(block, instructions);
            if (ins_i != -1&&in_text==1){
                PC+=4;
            }else if (!strcmp(block,".text")){
                dynamic = (int*)(MEMORY_START+PC);
                in_text = 1;
                in_data = 0;
                PC = tempPC;
            }else if (!strcmp(block,".data")){
                in_data = 1;
                in_text = 0;
                tempPC = PC;
                PC = STATIC_START;
            }

            if (strstr(block,":")){  //find label
                int len_block = strlen(block);
                block[len_block-1] = '\0';
                if (in_text){
                    append_label(block, PC);
                }else if (in_data){
                    char* variable_name = block;
                    block = get_block(spt,&spt,",\n\t ");
                    char *variable = NULL;
                    char *variablePt = spt;
                    if(!strcmp(block,".ascii")){
                        while(is_in(" \t",*variablePt)){
                            variablePt++;
                        }
                        variable = get_block(variablePt,&variablePt,"\"");
                        size_t len = strlen(variable);
                        char *str = (char*)malloc(len);
                        int j=0;
                        for(int i=0;i<len&&*(variable+i)!='\0';i++){
                            if(*(variable+i)=='\\'&&(variable+i+1)!=NULL&&i+1<len){
                                if(*(variable+i+1)=='t'){
                                    *(str+j)='\t';
                                }else if(*(variable+i+1)=='n'){
                                    *(str+j)='\n';
                                }
                                i++;
                                j++;
                                continue;
                            }
                            *(str+j)=*(variable+i);
                            j++;
                        }
                        free(str);
                        append_label(variable_name,PC);
                        PC+=4*((j/4)+((j%4>0)?1:0));
                    }else if(!strcmp(block,".asciiz")){
                        while(is_in(" \t",*variablePt)){
                            variablePt++;
                        }
                        variable = get_block(variablePt,&variablePt,"\"");
                        size_t len = strlen(variable);
                        char *str = (char*)malloc(len);
                        int j=0;
                        for(int i=0;i<len&&*(variable+i)!='\0';i++){
                            if(*(variable+i)=='\\'&&(variable+i+1)!=NULL&&i+1<len){
                                if(*(variable+i+1)=='t'){
                                    *(str+j)='\t';
                                }else if(*(variable+i+1)=='n'){
                                    *(str+j)='\n';
                                }
                                i++;
                                j++;
                                continue;
                            }
                            *(str+j)=*(variable+i);
                            j++;
                        }
                        j++;
                        free(str);
                        append_label(variable_name,PC);
                        PC+=4*((j/4)+((j%4>0)?1:0));
                    }else if(!strcmp(block,".word")){
                        append_label(variable_name,PC);
                        while(true){
                            variable = get_block(variablePt,&variablePt,",\n\t ");
                            if(variable==NULL||*variable=='#'){
                                break;
                            }
                            PC+=4;
                        }
                    }else if(!strcmp(block,".byte")){
                        int num = 0;
                        while(true){
                            variable = get_block(variablePt,&variablePt,",\n\t ");
                            if(variable==NULL||*variable=='#'){
                                break;
                            }
                            num++;
                        }
                        append_label(variable_name,PC);
                        PC+=4*((num/4)+((num%4>0)?1:0));
                    }else if(!strcmp(block,".half")){
                        int num = 0;
                        while(true){
                            variable = get_block(variablePt,&variablePt,",\n\t ");
                            if(variable==NULL||*variable=='#'){
                                break;
                            }
                            num++;
                        }
                        append_label(variable_name,PC);
                        PC+=4*((num/2)+((num%2>0)?1:0));
                    }
                }
            } 
        }
    }
}


inline unsigned long int binary_convert(char const *code_str) {
    string str = code_str;
    bitset<32> bits(str);
    unsigned code = bits.to_ulong();
    return code;
}

inline void binary_form_print(int code){
    for (int i = 31; i >= 0; i--)
        printf("%c",((code>>i)&1)+'0');
    printf("\n");
}

// this is the phase2 of the project, which translate the mips code to machine code
void phase2(FILE* in_file,FILE* code_file,char const **instructions) {
    int PC = TEXT_START;
    char currentLine[257];
    char currentCode[257];
    int tempPC = PC;
    int length;
    bool in_text = 1;
    bool in_data = 0;
    char *block, *spt, *thisLine, *code_str;
    int *memory = (int*)MEMORY_START;

    while (true) {
        for (int i = 0; i < 257; i++) currentLine[i] = '\0';
        thisLine = fgets(currentLine, 256, in_file);
        if (thisLine == NULL){
            break;
        }
        length = strlen(currentLine);
        currentLine[length] = '\n';    
        spt = currentLine;
        while (true) {
            block = get_block(spt,&spt,",\n\t ");
            if ((block == NULL)||(*block == '#')) {
                free(block);
                break;
            }
            int ins_i = get_instruction(block, instructions);
            if (ins_i != -1){
                PC += 4;
            }else if(!strcmp(block,".text")){
                in_text = 1;
                in_data = 0;
                PC = tempPC;
            }else if(!strcmp(block,".data")){
                in_text = 0;
                in_data = 1;
                tempPC = PC;
                PC= STATIC_START;
            }
            if(in_text){
                unsigned int code;
                if (ins_i != -1&&in_text==1) {
                    code_str = fgets(currentCode, 256, code_file);
                    code = binary_convert(code_str);
                    *(memory+(PC-4)/4) = code;
                }
            }
            if(in_data){
                if (strstr(block,":")){  //find label
                    int len_block = strlen(block);
                    block[len_block-1] = '\0';
                    int index = get_label(block);
                    PC = labelArray[index].address;
                    char* variable_name = block;
                    block = get_block(spt,&spt,",\n\t ");
                    char *variable = NULL;
                    char *variablePt = spt;
                    if(!strcmp(block,".ascii")){
                        while(is_in(" \t",*variablePt)){
                            variablePt++;
                        }
                        variable = get_block(variablePt,&variablePt,"\"");
                        for(int i=0;i<strlen(variable)&&*(variable+i)!='\0';i++){
                            if(*(variable+i)=='\\'&&(variable+i+1)!=NULL&&i+1<strlen(variable)){
                                if(*(variable+i+1)=='t'){
                                    *(MEMORY_START+PC)='\t';
                                }else if(*(variable+i+1)=='n'){
                                    *(MEMORY_START+PC)='\n';
                                }
                                i++;
                                PC++;
                                continue;
                            }
                            *(MEMORY_START+PC)=(int)*(variable+i);
                            PC++;
                        }
                    }else if(!strcmp(block,".asciiz")){
                        while(is_in(" \t",*variablePt)){
                            variablePt++;
                        }
                        variable = get_block(variablePt,&variablePt,"\"");
                        for(int i=0;i<strlen(variable)&&*(variable+i)!='\0';i++){
                            if(*(variable+i)=='\\'&&(variable+i+1)!=NULL&&i+1<strlen(variable)){
                                if(*(variable+i+1)=='t'){
                                    *(MEMORY_START+PC)='\t';
                                }else if(*(variable+i+1)=='n'){
                                    *(MEMORY_START+PC)='\n';
                                }
                                i++;
                                PC++;
                                continue;
                            }
                            *(MEMORY_START+PC)=(int)*(variable+i);
                            PC++;
                        }
                        *(MEMORY_START+PC) = '\0';
                    }else if(!strcmp(block,".word")){
                        int num;
                        while(true){
                            variable = get_block(variablePt,&variablePt,",\n\t ");
                            if(variable==NULL||*variable=='#'){
                                break;
                            }
                            sscanf(variable,"%d",&num);
                            *(memory+PC/4) = num;
                            PC+=4;
                        }
                    }else if(!strcmp(block,".byte")){
                        while(true){
                            variable = get_block(variablePt,&variablePt,",\n\t ");
                            if(variable==NULL||*variable=='#'){
                                break;
                            }
                            int temp;
                            sscanf(variable,"%d",&temp);
                            *(MEMORY_START+PC) = temp;
                            PC++;
                        }
                    }else if(!strcmp(block,".half")){
                        while(true){
                            variable = get_block(variablePt,&variablePt,",\n\t ");
                            if(variable==NULL||*variable=='#'){
                                break;
                            }
                            int16_t temp;
                            sscanf(variable,"%d",&temp);
                            *(MEMORY_START+PC) = temp;
                            PC+=2;
                        }
                    }
                }
            }
        }
    }
}

inline int extend_sign(int num){
    return num&(1<<15) ? num|(0xffff0000) : num;
}

inline void add(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = *rs + *rt;
}

inline void addu(int* rs, int*rt, int*rd, int shamt, int funct){
    *rd = *rs + *rt;
}

inline void And(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = (*rs)&(*rt);
}

inline void nor(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = ~((*rs)|(*rt));
}

inline void Or(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = (*rs)|(*rt);
}

inline void sllv(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = (unsigned)(*rt)<<((*rs)&(0xf));     //rd <- rt << rs[4:0](logic)
}

inline void slt(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = (*rs)<(*rt) ? 1 : 0;
}

inline void sltu(int* rs, int* rt, int* rd, int shamt, int funct){
    unsigned x1 = *rs;
    unsigned x2 = *rt;
    *rd = (x1<x2) ? 1 : 0;
}

inline void srav(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = (*rt)>>((*rs)&(0xf));
}

inline void srlv(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = (unsigned)(*rt)>>((*rs)&(0xf)); 
}

inline void sub(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = *rs - *rt;
}

inline void subu(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = *rs - *rt;
}

inline void Xor(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = (*rs)^(*rt);
}

inline void jalr(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = (int)(PROGRAMCOUNTER-MEMORY_START)+4;
    PROGRAMCOUNTER = MEMORY_START + *rs - 4;
}

inline void div(int* rs, int* rt, int* rd, int shamt, int funct){
    *LO = (*rs)/(*rt);
    *HI = (*rs)%(*rt);
}

inline void divu(int* rs, int* rt, int* rd, int shamt, int funct){
    unsigned x1 = *rs;
    unsigned x2 = *rt;
    *LO = x1/x2;
    *HI = x1%x2;
}

inline void mult(int* rs, int* rt, int* rd, int shamt, int funct){
    long long x1 = (long long) *rs;
    long long x2 = (long long) *rt;
    long long x3 = x1*x2;
    *LO = (int)x3;
    x3>>=32;
    *HI = (int)x3;
}

inline void multu(int* rs, int* rt, int* rd, int shamt, int funct){
    unsigned long long x1 = (long long) *rs;
    unsigned long long x2 = (long long) *rt;
    long long x3 = x1*x2;
    *LO = (int)x3;
    x3>>=32;
    *HI = (int)x3;
}

inline void mfhi(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = *HI;
}

inline void mflo(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = *LO;
}

inline void mthi(int* rs, int* rt, int* rd, int shamt, int funct){
    *HI = *rs;
}

inline void mtlo(int* rs, int* rt, int* rd, int shamt, int funct){
    *LO = *rs;
}

inline void jr(int* rs, int* rt, int* rd, int shamt, int funct){
    PROGRAMCOUNTER = MEMORY_START + *rs - 4;
}

inline void sll(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = (*rt)<<shamt;
}

inline void sra(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = (*rt)>>shamt;
}

inline void srl(int* rs, int* rt, int* rd, int shamt, int funct){
    *rd = (unsigned)(*rt)>>shamt;
}

inline void addi(int* rs, int* rt, int i){
    *rt = *rs + i;
}

inline void addiu(int* rs, int* rt, int i){
    *rt = *rs + i; 
}

inline void andi(int* rs, int* rt, int i){
    *rt = (unsigned)(*rs)&i;
}

inline void slti(int* rs, int* rt, int i){
    *rt = (*rs<i) ? 1 : 0;
}

inline void sltiu(int* rs, int* rt, int i){
    *rt = ((unsigned)(*rs)<i) ? 1 : 0;
}

inline void xori(int* rs, int* rt, int i){
    *rt = (unsigned)(*rs)^i;
}

inline void ori(int* rs, int* rt, int i){
    *rt = (unsigned int)(*rs)|i;
}

inline void bgez(int* rs, int* rt, int i){
    if (*rs<0){
        return;
    }else{
        i<<=2;
        PROGRAMCOUNTER+=extend_sign(i);
    }
}

inline void bgtz(int* rs, int* rt, int i){
    if (*rs>0){
        i<<=2;
        PROGRAMCOUNTER+=extend_sign(i);
    }
}

inline void blez(int* rs, int* rt, int i){
    if (*rs<=0){
        i<<=2;
        PROGRAMCOUNTER+=extend_sign(i);
    }
}

inline void bltz(int* rs, int* rt, int i){
    if (*rs<0){
        i<<=2;
        PROGRAMCOUNTER+=extend_sign(i);
    }
}

inline void bne(int* rs, int* rt, int i){
    if (*rs!=*rt){
        i<<=2;
        PROGRAMCOUNTER+=extend_sign(i);
    }
}

inline void beq(int* rs, int* rt, int i){
    if (*rs==*rt){
        i<<=2;
        PROGRAMCOUNTER+=extend_sign(i);
    }
}

inline void lb(int* rs, int* rt, int i){
    i = extend_sign(i);
    *rt = *((int8_t*)(MEMORY_START+*rs+i));
}

inline void lbu(int* rs, int* rt, int i){
    i = extend_sign(i);
    *rt = *((uint8_t*)(MEMORY_START+*rs+i));
}

inline void lh(int* rs, int* rt, int i){
    i = extend_sign(i);
    *rt = *((int16_t*)(MEMORY_START+*rs+i));
}

inline void lhu(int* rs, int* rt, int i){
    i = extend_sign(i);
    *rt = *((uint16_t*)(MEMORY_START+*rs+i));
}

inline void lw(int* rs, int* rt, int i){
    i = extend_sign(i);
    *rt = *((int*)(MEMORY_START+*rs+i));
}

inline void sb(int* rs, int* rt, int i){
    i = extend_sign(i);
    *((int*)(MEMORY_START+*rs+i)) = uint8_t(*rt);
}

inline void sh(int* rs, int* rt, int i){
    i = extend_sign(i);
    *((int*)(MEMORY_START+*rs+i)) = uint16_t(*rt);
}

inline void sw(int* rs, int* rt, int i){
    i = extend_sign(i);
    *((int*)(MEMORY_START+*rs+i)) = *rt;
}


inline void lwl(int* rs, int* rt, int i){
    i = extend_sign(i);
    int address = *rs + i;
    int n = address%4;
    uint8_t *p1 = (uint8_t*)MEMORY_START;
    uint8_t *p2 = (uint8_t*)(address+p1);
    uint8_t *pt = (uint8_t*)rt;
    for(int j=0;j<4-n;j++){
        *(pt+j)=*(p2+j);
    }    
}

inline void lwr(int* rs, int* rt, int i){
    i = extend_sign(i);
    int address = *rs + i;
    int n = address%4;
    uint8_t *p1 = (uint8_t*)MEMORY_START;
    uint8_t *p2 = (uint8_t*)(address+p1);
    uint8_t *pt = (uint8_t*)rt+3;
    for(int j=0;j<n+1;j++){
        *(pt-j)=*(p2-j);
    }
}

inline void swl(int* rs, int* rt, int i){
    i = extend_sign(i);
    int address = *rs + i;
    int n = address%4;
    uint8_t *p1 = (uint8_t*)(address+MEMORY_START);
    uint8_t *pt = (uint8_t*)rt;
    for(int j=0;j<4-n;j++){
        *(p1+j)=*(pt+j);
    }
}

inline void swr(int* rs, int* rt, int i){
    i = extend_sign(i);
    int address = *rs + i;
    int n = address%4;
    uint8_t *p1 = (uint8_t*)(address+MEMORY_START);
    uint8_t *pt = (uint8_t*)rt+3;
    for(int j=0;j<n+1;j++){
        *(p1-j)=*(pt-j);
    }
}

inline void lui(int* rs, int* rt, int i){
    int num = i&(0xffff);
    *rt = (unsigned)num<<16;
}

inline void j(int label){
    PROGRAMCOUNTER = MEMORY_START+label-4;
}

inline void jal(int label){
    *REGS[31] = PROGRAMCOUNTER-MEMORY_START+4;
    PROGRAMCOUNTER = MEMORY_START+label-4;
}

inline bool is_in(char const *invalid,char ch){
    for(int i=0;i<strlen(invalid);i++){
        if(ch==invalid[i]){
            return true;
        }
    }
    return false;
}

inline void syscall(char *start_ptr,char **end_ptr,FILE *out_file){
    if(*REGS[2]==1){ //print_int
        string s = to_string(*REGS[4]);
        fputs(s.c_str(),out_file);
        return;
    }else if(*REGS[2]==4){ //print_string
        char *pt = *REGS[4] + MEMORY_START;
        fputs(pt,out_file);
        return;
    }else if(*REGS[2]==5){ //read_int
        char *block;
        int num;
        block = get_block(start_ptr,&start_ptr,",\n\t $");
        sscanf(block,"%d",&num);
        *REGS[2] = num;
        free(block);
        return;
    }else if(*REGS[2]==8){ //read_string
        char *pt;
        pt = *REGS[4] + MEMORY_START;
        for(int i=0;i<*REGS[5],(*start_ptr!='\0')&&(*start_ptr!='\n');i++){
            *(pt+i) = *start_ptr;
            start_ptr++;    
        }
        *end_ptr = start_ptr;
        return;
    }else if(*REGS[2]==9){ //sbrk
        int address = (char*)dynamic-MEMORY_START;
        *REGS[2] = address;
        dynamic+=*REGS[4];
        return;
    }else if(*REGS[2]==10){ //exit
        exit(0);
        return;
    }else if(*REGS[2]==11){ //print_char
        fputc(*REGS[4],out_file);
        return;
    }else if(*REGS[2]==12){ //read_char
        while(is_in("\n\t ",*start_ptr)){
            start_ptr++;
        }
        *REGS[2] = (char)*start_ptr;
        start_ptr++;
        *end_ptr = start_ptr;
        return;
    }else if(*REGS[2]==13){ //open
        char *str = *REGS[4]+MEMORY_START;
        int flag = *REGS[5];
        int mode = *REGS[6];
        int file_discriptor = open(str,flag,mode);
        if(file_discriptor==-1){
            return;
        }
        *REGS[4] = file_discriptor;
        return;
    }else if(*REGS[2]==14){ //read 
        int file_discriptor = *REGS[4];
        if (file_discriptor==-1){
            return;
        }
        char *buffer = *REGS[5] + MEMORY_START;
        int length = *REGS[6];
        read(file_discriptor,buffer,length);
        return;
    }else if(*REGS[2]==15){ //write
        int file_discriptor = *REGS[4];
        if (file_discriptor==-1){
            return;
        }
        char *buffer = *REGS[5]+MEMORY_START;
        int length = *REGS[6];
        write(file_discriptor,buffer,length);
        *REGS[4] = length;
        return;
    }else if(*REGS[2]==16){ //close
        int file_discriptor = *REGS[4];
        close(file_discriptor);
        return;
    }else if(*REGS[2]==17){ //exit2
        exit(*REGS[4]);
        return;
    }
}

inline void executeRins(unsigned int code){
    int rs_num = (code&0x3e00000)>>21;
    int rt_num = (code&0x1f0000)>>16;
    int rd_num = (code&0xf800)>>11;
    unsigned int sa = (code&0x7c0)>>6;
    unsigned int funct = (code&0x3f);
    int *rs = *(REGS+rs_num);
    int *rt = *(REGS+rt_num);
    int *rd = *(REGS+rd_num);
    switch (funct)
    {
    case 0:
        sll(rs,rt,rd,sa,funct);
        break;
    case 2:
        srl(rs,rt,rd,sa,funct);
        break;
    case 3:
        sra(rs,rt,rd,sa,funct);
        break;
    case 4:
        sllv(rs,rt,rd,sa,funct);
        break;
    case 6:
        srlv(rs,rt,rd,sa,funct);
        break;
    case 7:
        srav(rs,rt,rd,sa,funct);
        break;
    case 8:
        jr(rs,rt,rd,sa,funct);
        break;
    case 9:
        jalr(rs,rt,rd,sa,funct);
        break;
    case 0x10:
        mfhi(rs,rt,rd,sa,funct);
        break;
    case 0x11:
        mthi(rs,rt,rd,sa,funct);
        break;
    case 0x12:
        mflo(rs,rt,rd,sa,funct);
        break;
    case 0x13:
        mtlo(rs,rt,rd,sa,funct);
        break;
    case 0x18:
        mult(rs,rt,rd,sa,funct);
        break;
    case 0x19:
        multu(rs,rt,rd,sa,funct);
        break;
    case 0x1a:
        div(rs,rt,rd,sa,funct);
        break;
    case 0x1b:
        divu(rs,rt,rd,sa,funct);
        break;
    case 0x20:
        add(rs,rt,rd,sa,funct);
        break;
    case 0x21:
        addu(rs,rt,rd,sa,funct);
        break;
    case 0x22:
        sub(rs,rt,rd,sa,funct);
        break;
    case 0x23:
        subu(rs,rt,rd,sa,funct);
        break;
    case 0x24:
        And(rs,rt,rd,sa,funct);
        break;
    case 0x25:
        Or(rs,rt,rd,sa,funct);
        break;
    case 0x26:
        Xor(rs,rt,rd,sa,funct);
        break;
    case 0x27:
        nor(rs,rt,rd,sa,funct);
        break;
    case 0x2a:
        slt(rs,rt,rd,sa,funct);
        break;
    case 0x2b:
        sltu(rs,rt,rd,sa,funct);
        break;
    default:
        break;
    }
}

inline void executeIins(int opcode, int code, int t){
    int rs_num = (code&0x3e00000)>>21;
    int rt_num = (code&0x1f0000)>>16;
    int i = (code&0xffff);
    int *rs = *(REGS+rs_num);
    int *rt = *(REGS+rt_num);
    if(i&0x8000){
        i = (-1)*((i^0xffff)+1);
    }
    if(t==0){
        switch (opcode)
        {
        case 4:
            beq(rs,rt,i);
            break;
        case 5:
            bne(rs,rt,i);
            break;
        case 6:
            blez(rs,rt,i);
            break;
        case 7:
            bgtz(rs,rt,i);
            break;
        case 8:
            addi(rs,rt,i);
            break;
        case 9:
            addiu(rs,rt,i);
            break;
        case 0xa:
            slti(rs,rt,i);
            break;
        case 0xb:
            sltiu(rs,rt,i);
            break;
        case 0xc:
            andi(rs,rt,i);
            break;
        case 0xd:
            ori(rs,rt,i);
            break;
        case 0xe:
            xori(rs,rt,i);
            break;
        case 0xf:
            lui(rs,rt,i);
            break;
        case 0x20:
            lb(rs,rt,i);
            break;
        case 0x21:
            lh(rs,rt,i);
            break;
        case 0x22:
            lwl(rs,rt,i);
            break;
        case 0x23:
            lw(rs,rt,i);
            break;
        case 0x24:
            lbu(rs,rt,i);
            break;
        case 0x25:
            lhu(rs,rt,i);
            break;
        case 0x26:
            lwr(rs,rt,i);
            break;
        case 0x28:
            sb(rs,rt,i);
            break;
        case 0x29:
            sh(rs,rt,i);
            break;
        case 0x2a:
            swl(rs,rt,i);
            break;
        case 0x2b:
            sw(rs,rt,i);
            break;
        case 0x2e:
            swr(rs,rt,i);
            break;
        default:
            break;
        }
    }else if(t==1){
        switch (opcode)
        {
        case 0:
            bltz(rs,rt,i);
            break;
        case 1:
            bgez(rs,rt,i);
            break;
        default:
            break;
        }
    }
}

inline void executeJins(int opcode, int code){
    int label = (code&0x3ffffff)<<2;
    int currentAddr = PROGRAMCOUNTER-MEMORY_START;
    currentAddr &= 0xfc000000;
    label = currentAddr|label;
    if(opcode==2){
        j(label);
    }else if(opcode==3){
        jal(label);
    }
}

void simulator(FILE *in_file,FILE *out_file){
    int ins_num = 0;
    REGS = (int**)malloc(32*sizeof(int*));
    HI = (int*)malloc(sizeof(int));
    LO = (int*)malloc(sizeof(int));
    for(int i=0;i<32;i++){
        REGS[i] = (int*)malloc(sizeof(int*));
    }
    *REGS[28] = 0x508000;
    *REGS[29] = STACK_START;
    *REGS[30] = STACK_START;
    PROGRAMCOUNTER = MEMORY_START + TEXT_START;
    int opcode;
    char *spt;
    char *thisLine;
    char currentLine[257];
    fgets(currentLine,256,in_file);
    int len = strlen(currentLine);
    currentLine[len] = '\n';
    spt = currentLine;
    while(((int*)PROGRAMCOUNTER)!=NULL){
        while((*spt==' '||*spt=='\t')&&spt!=NULL){
            spt++;
        }
        if(spt==NULL||*spt=='\n'){
            fgets(currentLine,256,in_file);
            int len = strlen(currentLine);
            currentLine[len] = '\n';
            spt = currentLine;
        }
        unsigned int code = *((int*)PROGRAMCOUNTER);
        opcode = (0xfc000000)&code;
        opcode>>=26;
        opcode&=0x0000003f;
        if(checkpoints.count(ins_num)){
            checkpoint_memory(ins_num);
            checkpoint_register(ins_num);
        }
        if(code==0xc){
            syscall(spt,&spt,out_file);
        }else if(!opcode){
            executeRins(code);
        }else if(opcode==1){
            executeIins(code&0x001f0000,code,1);
        }else if(opcode==2||opcode==3){
            executeJins(opcode,code);
        }else{
            executeIins(opcode,code,0);
        }
        PROGRAMCOUNTER+=4;
        ins_num++;
    }
    free(REGS);
    free(HI);
    free(LO);
}

void init_checkpoint(FILE *fp){
    int tmp, i=0;
    while(fscanf(fp,"%d",&tmp)!=EOF){
        checkpoints.insert(tmp);
    }
}

void checkpoint_memory(int ins_count){
    if(!checkpoints.count(ins_count)){
        return;
    }
    string name = "memory_"+to_string(ins_count)+".bin";
    FILE *fp = fopen(name.c_str(),"wb");
    char *memory_pointer = MEMORY_START + 0x400000;
    fwrite(memory_pointer,1,0x600000,fp);
    fclose(fp);
}

void checkpoint_register(int ins_count){
    if(!checkpoints.count(ins_count)){
        return;
    }
    string name = "register_"+to_string(ins_count)+".bin";
    FILE *fp = fopen(name.c_str(),"wb");
    fwrite(REGS[0],4,1,fp);
    fwrite(REGS[1],4,1,fp);
    fwrite(REGS[2],4,1,fp);
    fwrite(REGS[3],4,1,fp);
    fwrite(REGS[4],4,1,fp);
    fwrite(REGS[5],4,1,fp);
    fwrite(REGS[6],4,1,fp);
    fwrite(REGS[7],4,1,fp);
    fwrite(REGS[8],4,1,fp);
    fwrite(REGS[9],4,1,fp);
    fwrite(REGS[10],4,1,fp);
    fwrite(REGS[11],4,1,fp);
    fwrite(REGS[12],4,1,fp);
    fwrite(REGS[13],4,1,fp);
    fwrite(REGS[14],4,1,fp);
    fwrite(REGS[15],4,1,fp);
    fwrite(REGS[16],4,1,fp);
    fwrite(REGS[17],4,1,fp);
    fwrite(REGS[18],4,1,fp);
    fwrite(REGS[19],4,1,fp);
    fwrite(REGS[20],4,1,fp);
    fwrite(REGS[21],4,1,fp);
    fwrite(REGS[22],4,1,fp);
    fwrite(REGS[23],4,1,fp);
    fwrite(REGS[24],4,1,fp);
    fwrite(REGS[25],4,1,fp);
    fwrite(REGS[26],4,1,fp);
    fwrite(REGS[27],4,1,fp);
    fwrite(REGS[28],4,1,fp);
    fwrite(REGS[29],4,1,fp);
    fwrite(REGS[30],4,1,fp);
    fwrite(REGS[31],4,1,fp);

    int *PC;
    int currentAddr = PROGRAMCOUNTER-MEMORY_START;
    PC = &currentAddr;
    fwrite(PC,4,1,fp);
    fwrite(HI,4,1,fp);
    fwrite(LO,4,1,fp);
    fclose(fp);
}