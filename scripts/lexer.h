#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#define MAXSTRING 2000
#define ESCAPENUMBER 12


struct numberType{
    long long int value;
	long double fValue;
    int type;
    int note;
};

// typedef union
// {
//     char *string_literal;
//     int integer;
//     struct numberType number;
// } YYSTYPE;

typedef unsigned char BYTE;

// extern YYSTYPE yylval;

enum numberTypes{
	INTEGER,
	REAL
};

enum numberNotes{
	// In face INT but to differ
	SINT,
	UINT,
	L,
	LL,
	UL,
	ULL,
	D,
	LD,
	F,

};





