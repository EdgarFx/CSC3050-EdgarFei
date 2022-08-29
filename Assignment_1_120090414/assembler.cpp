#include <iostream>
#include <string>
#include <cstring>
#include <map>
#include <cstdio>
#include <bitset>
#include "assembler.h"
using namespace std;

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
    int PC = 0x400000;
    char currentLine[257];
    int tempPC = PC;
    int length;
    bool in_text = 0;
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

            if(!strcmp(block,".text")){
                in_text = 1;
            }

            if(!in_text){
                break;
            }

            int ins_i = get_instruction(block, instructions);
            if (ins_i != -1){
                PC+=4;
            }else if (!strcmp(block,".text")){
                PC = tempPC;
            }

            if (strstr(block,":")){
                int len_block = strlen(block);
                block[len_block-1] = '\0';
                append_label(block, PC);
            } 
        }
    }
}

// get the R instruction code
inline int R_ins_code(int reg_num,char* start_ptr,char** end_str) {
    char *reg;
    int op,rs,rt,rd,shamt,funct;
    unsigned int code;
    op = R_ins[reg_num].opcode;
    funct = R_ins[reg_num].funct;
    if (reg_num <= 12) {  // ins rd,rs,rt
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rd = get_regNum(reg);
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rs = get_regNum(reg);
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rt = get_regNum(reg);
        *end_str = start_ptr;
        code = funct+(rd << 11)+(rt << 16)+(rs << 21)+(op << 26);
    }else if (reg_num == 13) {  // ins rd, rs
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rd = get_regNum(reg);
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rs = get_regNum(reg);
        *end_str = start_ptr;
        code = funct+(rd << 11)+(rs << 21)+(op << 26);
    }else if ((reg_num >= 14)&&(reg_num <=17)) { // ins rs,rt
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rs = get_regNum(reg);
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rt = get_regNum(reg);
        *end_str = start_ptr;
        code = funct+(rt << 16)+(rs << 21)+(op << 26);
    }else if ((reg_num == 18)||(reg_num == 19)) {  // ins rd
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rd = get_regNum(reg);
        *end_str = start_ptr;
        code = funct+(rd << 11)+(op << 26);
    }else if ((reg_num >= 20)&&(reg_num<=22)){   // ins rs
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rs = get_regNum(reg);
        *end_str = start_ptr;
        code = funct+(rs << 21)+(op << 26);
    }else if ((reg_num >= 23)&&(reg_num <=25)) {  // ins rd,rt,sa
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rd = get_regNum(reg);
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rt = get_regNum(reg);
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        sscanf(reg,"%d",&shamt);
        *end_str = start_ptr;
        code = funct+(shamt << 6)+(rd << 11)+(rt << 16)+(op << 26);
    }else{  // syscall
        code = funct+(op << 26);
    }
    return code;
}


// get the I instruction code
inline int I_ins_code(int reg_num,char* start_ptr,char** end_ptr,int PC) {
    char *reg;
    unsigned int code;
    int op,rs=0,rt,immediate;
    op = I_ins[reg_num-27].opcode;
    rt = I_ins[reg_num-27].rt;
    if (reg_num <= 33) { // ins rt,rs,i
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rt = get_regNum(reg);
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rs = get_regNum(reg);
        reg = get_block(start_ptr,&start_ptr,",\n\t $");
        *end_ptr = start_ptr;
        sscanf(reg,"%d",&immediate);
        if(immediate < 0) {
            immediate += (1 << 16);
        }
        code = immediate+(rt << 16)+(rs << 21)+(op << 26);
    }else if (reg_num == 34){  // bgez rs,label
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rs = get_regNum(reg);
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        *end_ptr = start_ptr;
        int label_index = get_label(reg);
        int addr = labelArray[label_index].address;
        addr -= PC;
        addr /= 4; 
        if (addr < 0) {
            addr += (1 << 16);
        }    
        rt = 1;
        code = addr+(rt << 16)+(rs << 21)+(op << 26);
    }else if ((reg_num >= 35)&&(reg_num <= 37)) { // ins rs,label
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rs = get_regNum(reg);
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        *end_ptr = start_ptr;
        int label_index = get_label(reg);
        int addr = labelArray[label_index].address;
        addr -= PC;
        addr /= 4; 
        if (addr < 0) {
            addr += (1 << 16);
        }
        code = addr+(rs << 21)+(op << 26);
    }else if ((reg_num >= 38)&&(reg_num <= 39)) { // ins rs,rt,label
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rs = get_regNum(reg);
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rt = get_regNum(reg);
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        *end_ptr = start_ptr;
        int label_index = get_label(reg);
        int addr = labelArray[label_index].address;
        addr -= PC; 
        addr /= 4;
        if (addr < 0) {
            addr += (1 << 16);
        }
        code = addr+(rt << 16)+(rs << 21)+(op << 26);
    }else if ((reg_num >= 40)&&(reg_num <= 51)) { // ins rt,i(rs)
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rt = get_regNum(reg);
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        sscanf(reg,"%d%s",&immediate,reg);
        reg = get_block(reg,&reg,"()");
        rs = get_regNum(reg);
        *end_ptr = start_ptr;
        if (immediate < 0) {
            immediate += (1 << 16);
        }
        code = immediate+(rt << 16)+(rs << 21)+(op << 26);
    }else if (reg_num == 52) {  // ins rt,i 
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        rt = get_regNum(reg);
        reg = get_block(start_ptr,&start_ptr,",\n\t ");
        sscanf(reg,"%d",&immediate);
        if(immediate < 0) {
            immediate += (1 << 16);
        }
        *end_ptr = start_ptr;
        code = immediate+(rt << 16)+(op << 26);
    }
    return code;
}


// get the J instruction code
inline int J_ins_code(int reg_num, char* start_ptr, char** end_ptr) {
    char *reg;
    unsigned int code;
    int op,addr;
    op = J_ins[reg_num-53].opcode;
    if (reg_num <= 54) {  // ins label
        reg = get_block(start_ptr, &start_ptr, ",\n\t ");
        int ID = get_label(reg);
        addr = labelArray[ID].address;
        if (addr < 0) {
            addr += (1 << 16);
        }
        addr /= 4;
        *end_ptr = start_ptr;
        code = addr+(op << 26);
    }
    return code;
}

// convert our decimal code to binary form
inline string binary_convert(int code) {
    string str;
    bitset<32> bits;
    bits = code;
    str = bits.to_string();
    return str;
}


// this is the phase2 of the project, which translate the mips code to machine code
void phase2(FILE* in_file, FILE* out_file, char const **instructions) {
    int PC = 0x400000;
    char currentLine[257];
    int tempPC = PC;
    int length;
    bool in_text = 0;
    char *block, *spt, *thisLine;
    string str_code;

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

            if(!strcmp(block,".text")){
                in_text = 1;
            }

            if(!in_text){
                break;
            }

            int ins_i = get_instruction(block, instructions);
            if (ins_i != -1){
                PC += 4;
            }else if (!strcmp(block,".text")) {
                PC = tempPC;
            }

            if (in_text) {
                unsigned int code;
                if (ins_i != -1) {
                    if (ins_i <= 26){
                        code = R_ins_code(ins_i,spt,&spt);
                    }else if ((ins_i >= 27)&&(ins_i <= 52)){ 
                        code = I_ins_code(ins_i, spt, &spt, PC);
                    }else if ((ins_i >= 53)&&(ins_i <= 54)){
                        code = J_ins_code(ins_i, spt, &spt);
                    }
                    str_code = binary_convert(code);
                    fputs(str_code.c_str(),out_file);
                    fputs("\n",out_file);
                }
            }
        }
    }
    fclose(out_file); 
}
