#include <stdio.h>
#include "tokens-manual.h"
#include <math.h>

struct numberType{
    int value;
	double fValue;
    char *type;
    char *note;
};

typedef union
{
    char *string_literal;
    int integer;
    struct numberType number;
} YYSTYPE;

extern YYSTYPE yylval;

int OctalToDecimal(int num)
{
    int x = 0;
    int ans = 0;

    while (num > 0)
    {
        int y = num % 10;
        num /= 10;
        ans += y * pow(8, x);
        ++x;
    }

    return ans;
}

int HexTODecimal(char *hex){
	int val, i, len, decimal;
	
	i=2;
 	len = strlen(hex)-3;
	val = 0;
	decimal = 0;

	while(hex[i]!='\0')  {  
        if(hex[i]>='0' && hex[i]<='9')  
        {  
            val = hex[i] - 48;  
        }  
        else if(hex[i]>='a' && hex[i]<='f')  
        {  
            val = hex[i] - 97 + 10;  
        }  
        else if(hex[i]>='A' && hex[i]<='F')  
        {  
            val = hex[i] - 65 + 10;  
        }else{
			len--;
			i++;
			continue;
		}

  
        decimal += val * pow(16, len);
		len--;  
		i++;
	}

	return decimal;
}

char *enum_TokenName[] = {
    "IDENT",
	"CHARLIT",
	"STRING",
	"NUMBER",
	"INDSEL",
	"PLUSPLUS",
	"MINUSMINUS",
	"SHL",
	"SHR",
	"LTEQ",
	"GTEQ",
	"EQEQ",
	"NOTEQ",
	"LOGAND",
	"LOGOR",
	"ELLIPSIS",
	"TIMESEQ",
	"DIVEQ",
	"MODEQ",
	"PLUSEQ",
	"MINUSEQ",
	"SHLEQ",
	"SHREQ",
	"ANDEQ",
	"OREQ",
	"XOREQ",
	"AUTO",
	"BREAK",
	"CASE",
	"CHAR",
	"CONST",
	"CONTINUE",
	"DEFAULT",
	"DO",
	"DOUBLE",
	"ELSE",
	"ENUM",
	"EXTERN",
	"FLOAT",
	"FOR",
	"GOTO",
	"IF",
	"INLINE",
	"INT",
	"LONG",
	"REGISTER",
	"RESTRICT",
	"RETURN",
	"SHORT",
	"SIGNED",
	"SIZEOF",
	"STATIC",
	"STRUCT",
	"SWITCH",
	"TYPEDEF",
	"UNION",
	"UNSIGNED",
	"VOID",
	"VOLATILE",
	"WHILE",
	"_BOOL",
	"_COMPLEX",
	"_IMAGINARY"
    };

