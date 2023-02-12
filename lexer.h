#include <stdio.h>
#include "tokens-manual.h"
#include <math.h>
#include <ctype.h>
#define MAXSTRING 2000
#define ESCAPENUMBER 12

int lineNumber = 1;
char *fileName;

struct numberType{
    long long int value;
	long double fValue;
    char *type;
    char *note;
};

typedef union
{
    char *string_literal;
    int integer;
    struct numberType number;
} YYSTYPE;

typedef unsigned char BYTE;

extern YYSTYPE yylval;

char escapeSimpleSequence[] = {
	'a',
	'b',
	'e',
	'f',
	'n',
	'r',
	't',
	'v',
	'\\',
	'\'',
	'\"',
	'\?',
};

char escapeSimpleChar[] = {
	'\a',
	'\b',
	'\e',
	'\f',
	'\n',
	'\r',
	'\t',
	'\v',
	'\\',
	'\'',
	'\"',
	'\?',
};


char *escapeSimpleHex[] = {
	"0x07",
	"0x08",
	"0x1B",
	"0x0C",
	"0x0A",
	"0x0D",
	"0x09",
	"0x0B",
	"0x5C",
	"0x27",
	"0x22",
	"0x3F",
};

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

void to_Byte(char* input, BYTE* output)
{
	// control input and output index
    int i,j;
    int o;
    
	i = 0;
	o = 0;

	j = 0;
    
    while(input[i] != '\0'){
		if((input[i] == '\\') && (input[i+1]!= '\0')){
			int e;
			int validEscape = 0;
			for(e = 0; e < ESCAPENUMBER ; e++){
				if(input[i+1] == escapeSimpleSequence[e]){
					// To escape these characters
					if((input[i+1] == '\'')||(input[i+1] == '\\')||(input[i+1] == '\"')){
						output[o] = '\\';
						o++;
					}
					output[o] = HexTODecimal(escapeSimpleHex[e]);

					o++;
					i = i +2;
					validEscape = 1;
					break;
				}
			}

			if(validEscape == 0){
				// Convert Hexidecimal
				if(input[i+1] == 'x'){
					// First check if it is valid ascii from the nearest 2 digit
					char *tempHex = (char *) malloc(MAXSTRING);
					tempHex = strdup(input + i);
					tempHex[4] = '\0';
					int tempChar = HexTODecimal(tempHex);
					if((tempChar >=0) && (tempChar < 127)){
						output[o] = tempChar;
						i = i + 4;
						o++;
					}else{
						// if not ascii convert it to octal number
						tempHex = strdup(input + i);
						i++;
						j = 2;
						while(tempHex[j] != '\0'){
							if (((tempHex[j] >= '0') && (tempHex[j] <= '9'))
							|| ((tempHex[j] >= 'a') &&
							(tempHex[j] <= 'f'))
							|| ((tempHex[j] >= 'A') && (tempHex[j] <= 'F'))){
								j++;
							}else{
								tempHex[j] = '\0';
								break;
							}
						}

						output[o] = '\\';
						o++;

						if (j >4){
							output[o++] = '3';
							output[o++] = '7';
							output[o++] = '7';

							fprintf(stderr, "%s:%d:Warning:Hex escape sequence %s out of range\n", fileName, lineNumber, tempHex);
						}else{

							int tempDecimal = HexTODecimal(tempHex);
							char *tempOctal;
							tempOctal = (char *) malloc(MAXSTRING);

							int octalIndex = 0;
							int reverseIndex;
							
							for(octalIndex = 0; tempDecimal > 0; octalIndex++)
							{
								tempOctal[octalIndex] = tempDecimal % 8 + '0';
								tempDecimal = tempDecimal / 8;
							}

							// reverse the order of digits

							for(reverseIndex = octalIndex - 1; reverseIndex >= 0; reverseIndex--){
								// printf("%c",tempOctal[reverseIndex]);
								output[o] = tempOctal[reverseIndex];
								o++;
							}
							// printf("%d", tempChar);
							
						}
						i = i + j - 1;
					}

				}else if((input[i+1]>='0') && (input[i+1]<'8')){
					// check for octal
					if((input[i+2]>='0') && (input[i+2]<'8')){
						if((input[i+3]>='0') && (input[i+3]<'8')){
							output[o++] = input[i++];
							output[o++] = input[i++];
							output[o++] = input[i++];
							output[o++] = input[i++];
						}else{
							output[o++] = input[i++];
							output[o++] = '0';
							output[o++] = input[i++];
							output[o++] = input[i++];
						}

					}else{
						if((input[i+1]>='1') && (input[i+1]<'8')){
							output[o++] = input[i++];
							output[o++] = '0';
							output[o++] = '0';
							output[o++] = input[i++];
						}else{
							output[o++] = input[i++];
						}
					}
				}else{
					output[o] = input[i];
					// printf("%c\n", output[i]);
					i++;
					o++;
				}
			}

		}else{
			output[o] = input[i];
			// printf("%c\n", output[i]);
			i++;
			o++;

		}
    }

	output[o] = '\0';
}

void printBytes(BYTE* input){
	int i = 0;
	int e;
	int validEscape;

	while(input[i] != '\0'){
		validEscape = 0;
		for(e = 0; e <ESCAPENUMBER ; e++){
			if(input[i] == HexTODecimal(escapeSimpleHex[e])){
				if(isprint(input[i])){
					printf("%c", input[i]);
				}else{
					printf("\\");
					printf("%c",escapeSimpleSequence[e]);
				}
				validEscape = 1;
				break;
			}
		}

		if(validEscape == 0){
			printf("%c", input[i]);
		}

		i++;
	}

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



