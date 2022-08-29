#include <iostream>
#include <string>
#include <cstring>
#include <map>
#include <cstdio>
#include <bitset>
using namespace std;


// store a list of strings with an array of pointers to char
static char const *instructions[] = {
    "add","addu","and","nor","or","sllv","slt","sltu","srav","srlv","sub","subu","xor",
    "jalr","div","divu","mult","multu","mfhi","mflo","mthi","mtlo","jr","sll","sra","srl","syscall",
    "addi","addiu","andi","slti","sltiu","xori","ori","bgez","bgtz","blez","bltz","bne","beq",
    "lb","lbu","lh","lhu","lw","sb","sh","sw","lwl","lwr","swl","swr","lui",
    "j","jal"};

struct R_type_ins
{
    int opcode,funct;
};

static R_type_ins R_ins[27] = {
    {0,0x20}, // add rd,rs,rt
    {0,0x21}, // addu rd,rs,rt
    {0,0x24}, // and rd,rs,rt
    {0,0x27}, // nor rd,rs,rt
    {0,0x25}, // or rd,rs,rt
    {0,0x04}, // sllv rd,rt,rs
    {0,0x2a}, // slt rd,rs,rt
    {0,0x2b}, // sltu rd,rs,rt
    {0,0x07}, // srav rd,rt,rs
    {0,0x06}, // srlv rd,rt,rs
    {0,0x22}, // sub rd,rs,rt
    {0,0x23}, // subu rd,rs,rt
    {0,0x26}, // xor rd,rs,rt

    {0,0x09}, // jalr rd,rs

    {0,0x1a}, // div rs,rt
    {0,0x1b}, // divu rs,rt
    {0,0x18}, // mult rs,rt
    {0,0x19}, // multu rs,rt
    
    {0,0x10}, // mfhi rd
    {0,0x12}, // mflo rd

    {0,0x11}, // mthi rs
    {0,0x13}, // mtlo rs
    {0,0x08}, // jr rs
    
    {0,0x00}, // sll rd,rt,sa
    {0,0x03}, // sra rd,rt,sa
    {0,0x02}, // srl rd,rt,sa

    {0,0x0c}, // syscall
};

struct I_type_ins{
    int opcode,rt;
};

static I_type_ins I_ins[26] = {
    {0x08,0}, // addi rt,rs,i
    {0x09,0}, // addiu rt,rs,i
    {0x0c,0}, // andi rt,rs,i
    {0x0a,0}, // slti rt,rs,i
    {0x0b,0}, // sltiu rt,rs,i
    {0x0e,0}, // xori rt,rs,i
    {0x0d,0}, // ori rt,rs,i

    
    {0x01,1}, // bgez rs,label
    {0x07,0}, // bgtz rs,label
    {0x06,0}, // blez rs,label
    {0x01,0}, // bltz rs,label

    {0x05,0}, // bne rs,rt,label
    {0x04,0}, // beq rs,rt,label

    {0x20,0}, // lb rt,i(rs)
    {0x24,0}, // lbu rt,i(rs)
    {0x21,0}, // lh rt,i(rs)
    {0x25,0}, // lhu rt,i(rs)
    {0x23,0}, // lw rt,i(rs)
    {0x28,0}, // sb rt,i(rs)
    {0x29,0}, // sh rt,i(rs)
    {0x2b,0}, // sw rt,i(rs)
    {0x22,0}, // lwl rt,i(rs)
    {0x26,0}, // lwr rt,i(rs)
    {0x2a,0}, // swl rt,i(rs)
    {0x2e,0}, // swr rt,i(rs)

    {0x0f,0}, // lui rt,i
};

struct J_type_ins{
    int opcode;
};

static J_type_ins J_ins[2] = {
    {0x02}, //j label
    {0x03}, //jal label
};

static int label_num;
struct LabelOj {char* name; int address;};
static LabelOj labelArray[1000];

inline int get_regNum(char *reg_name);
inline int get_label(char *label_name);
inline void append_label(char *block,int PC);
inline char *get_block(char *start_ptr,char **end_ptr,char const *invalid);
inline int get_instruction(char *block,char const **instructions);
void phase1(FILE *in_file,char const **instructions);
inline int R_ins_code(int reg_num, char* start_ptr, char** end_str);
inline int I_ins_code(int reg_num,char* start_ptr,char** end_ptr,int PC);
inline int J_ins_code(int reg_num, char* start_ptr, char** end_ptr);
inline string binary_convert(int x);
void phase2(FILE* in_file, FILE* out_file, char const **instructions);