%option noinput nounput noyywrap nodefault
%{
#include "./lexer.h"
#include "./parser.tab.h"


// YYSTYPE yylval;

char *temp;

int lineNumber;
char *fileName;

// Define userfule variables
char *numberNotesText[] = {
	"INT",
	"UNSIGNED,INT",
	"LONG",
	"LONGLONG",
	"UNSIGNED,LONG",
	"UNSIGNED,LONGLONG",
	"DOUBLE",
	"LONGDOUBLE",
	"FLOAT",

};

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

// char *enum_TokenName[] = {
//     "IDENT",
// 	"CHARLIT",
// 	"STRING",
// 	"NUMBER",
// 	"INDSEL",
// 	"PLUSPLUS",
// 	"MINUSMINUS",
// 	"SHL",
// 	"SHR",
// 	"LTEQ",
// 	"GTEQ",
// 	"EQEQ",
// 	"NOTEQ",
// 	"LOGAND",
// 	"LOGOR",
// 	"ELLIPSIS",
// 	"TIMESEQ",
// 	"DIVEQ",
// 	"MODEQ",
// 	"PLUSEQ",
// 	"MINUSEQ",
// 	"SHLEQ",
// 	"SHREQ",
// 	"ANDEQ",
// 	"OREQ",
// 	"XOREQ",
// 	"AUTO",
// 	"BREAK",
// 	"CASE",
// 	"CHAR",
// 	"CONST",
// 	"CONTINUE",
// 	"DEFAULT",
// 	"DO",
// 	"DOUBLE",
// 	"ELSE",
// 	"ENUM",
// 	"EXTERN",
// 	"FLOAT",
// 	"FOR",
// 	"GOTO",
// 	"IF",
// 	"INLINE",
// 	"INT",
// 	"LONG",
// 	"REGISTER",
// 	"RESTRICT",
// 	"RETURN",
// 	"SHORT",
// 	"SIGNED",
// 	"SIZEOF",
// 	"STATIC",
// 	"STRUCT",
// 	"SWITCH",
// 	"TYPEDEF",
// 	"UNION",
// 	"UNSIGNED",
// 	"VOID",
// 	"VOLATILE",
// 	"WHILE",
// 	"_BOOL",
// 	"_COMPLEX",
// 	"_IMAGINARY"
// };

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


					output[o] = strtoull(escapeSimpleHex[e], NULL, 16);

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
					tempHex[0] = '0';
					tempHex[4] = '\0';
					int tempChar = strtoull(tempHex, NULL, 16);
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
							tempHex[0] = '0';
							int tempDecimal = strtoull(tempHex, NULL, 16);
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
			if(input[i] == strtoull(escapeSimpleHex[e], NULL,16)){

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

%}

%%
    /*Get the file name here and ignore other preprossed information and reset lineNumber*/

"# 0 \"ltests/".*\n {
    fileName = strdup(yytext+strlen("# 1 \""));
    // Remove the last "
    fileName[strlen(fileName)-2]= '\0'; 

    lineNumber = 1;
    }

"#".*\n {}

    /*Specify Keywords Tokens*/
    
"->"	    {return INDSEL;}
"++"	    {return PLUSPLUS;}
"--"	    {return MINUSMINUS;}
"<<"	    {return SHL;}
">>"	    {return SHR;}
"<="	    {return LTEQ;}
">="	    {return GTEQ;}
"=="	    {return EQEQ;}
"!="	    {return NOTEQ;}
"&&"	    {return LOGAND;}
"||"	    {return LOGOR;}
"..."	    {return ELLIPSIS;}
"*="	    {return TIMESEQ;}
"/="	    {return DIVEQ;}
"%="	    {return MODEQ;}
"+="	    {return PLUSEQ;}
"-="	    {return MINUSEQ;}
"<<="	    {return SHLEQ;}
">>="	    {return SHREQ;}
"&="	    {return ANDEQ;}
"|="	    {return OREQ;}
"^="	    {return XOREQ;}
auto        {return AUTO;}
break       {return BREAK;}
case        {return CASE;}
char        {return CHAR;}
const       {return CONST;}
continue    {return CONTINUE;}
default     {return DEFAULT;}
do          {return DO;}
double      {return DOUBLE;}
else        {return ELSE;}
enum        {return ENUM;}
extern      {return EXTERN;}
float       {return FLOAT;}
for         {return FOR;}
goto        {return GOTO;}
if          {return IF;}
inline      {return INLINE;}
int         {return INT;}
long        {return LONG;}
register    {return REGISTER;}
restrict    {return RESTRICT;}
return      {return RETURN;}
short       {return SHORT;}
signed      {return SIGNED;}
sizeof      {return SIZEOF;}
static      {return STATIC;}
struct      {return STRUCT;}
switch      {return SWITCH;}
typedef     {return TYPEDEF;}
union       {return UNION;}
unsigned    {return UNSIGNED;}
void        {return VOID;}
volatile    {return VOLATILE;}
while       {return WHILE;}
_Bool       {return _BOOL;}
_Complex    {return _COMPLEX;}
_Imaginary  {return _IMAGINARY;}

    /*Single Char Operators*/

"+"     {return '+';}
"-"     {return '-';}
"*"     {return '*';}
"("     {return '(';}
")"     {return ')';}
"["     {return '[';}
"]"     {return ']';}
"{"     {return '{';}
"}"     {return '}';}
"|"     {return '|';}
"."     {return '.';}
"&"     {return '&';}
"~"     {return '~';}
"/"     {return '/';}
"!"     {return '!';}
"%"     {return '%';}
"<"     {return '<';}
">"     {return '>';}
"^"     {return '^';}
"?"     {return '?';}
":"     {return ':';}
";"     {return ';';}
","     {return ',';}
"="     {return '=';}

    /*Specify Identifiers*/
[a-zA-Z_][a-zA-Z0-9_]*    {
    yylval.ident = strdup(yytext);
    return IDENT;
    }
    
    
    /*Different Type of Number*/

    /*Different Type of Integer*/

    /*Decimal Integer*/
[1-9][0-9]*                 {
    yylval.number.value = atoi(yytext);
    yylval.number.type = INTEGER;
    yylval.number.note = SINT;
    return NUMBER;
}
[1-9][0-9]*[uU]             {
    yylval.number.value = atoi(yytext);
    yylval.number.type = INTEGER;
    yylval.number.note = UINT;
    return NUMBER;
}

[1-9][0-9]*[lL]             {
    yylval.number.value = atoi(yytext);
    yylval.number.type = INTEGER;
    yylval.number.note = L;
    return NUMBER;
}

[1-9][0-9]*[lL][lL]         {   
    yylval.number.value = atoi(yytext);
    yylval.number.type = INTEGER;
    yylval.number.note = LL;
    return NUMBER;
}
[1-9][0-9]*([uU][lL]|[lL][uU])             {
    yylval.number.value = atoi(yytext);
    yylval.number.type = INTEGER;
    yylval.number.note = UL;
    return NUMBER;
}
[1-9][0-9]*([uU][lL][lL]|[lL][lL][uU])             {
    yylval.number.value = atoi(yytext);
    yylval.number.type = INTEGER;
    yylval.number.note = ULL;
    return NUMBER;
}


    /*Hexidecimal*/     
0[xX][0-9a-fA-F]+                {
    yylval.number.value = strtoull(yytext, NULL,16);
    yylval.number.type = INTEGER;
    yylval.number.note = SINT;
    return NUMBER;
}
0[xX][0-9a-fA-F]+[uU]                {
    temp = strdup(yytext);
    temp[strlen(temp)-1] = '\0';
    yylval.number.value = strtoull(yytext, NULL,16);
    yylval.number.type = INTEGER;
    yylval.number.note = UINT;
    return NUMBER;
}

0[xX][0-9a-fA-F]+[lL][lL]        {
    temp = strdup(yytext);
    temp[strlen(temp)-2] = '\0';
    yylval.number.value = strtoull(yytext, NULL,16);
    yylval.number.type = INTEGER;
    yylval.number.note = LL;
    return NUMBER;
}

0[xX][0-9a-fA-F]+[lL]           {
    temp = strdup(yytext);
    temp[strlen(temp)-1] = '\0';
    yylval.number.value = strtoull(yytext, NULL,16);
    yylval.number.type = INTEGER;
    yylval.number.note = L;
    return NUMBER;
}

0[xX][0-9a-fA-F]+([uU][lL]|[lL][uU])    {
    temp = strdup(yytext);
    temp[strlen(temp)-2] = '\0';
    yylval.number.value = strtoull(yytext, NULL,16);
    yylval.number.type = INTEGER;
    yylval.number.note = UL;
    return NUMBER;
}
0[xX][0-9a-fA-F]+([uU][lL][lL]|[lL][lL][uU])    {
    temp = strdup(yytext);
    temp[strlen(temp)-3] = '\0';
    yylval.number.value = strtoull(yytext, NULL,16);
    yylval.number.type = INTEGER;
    yylval.number.note = ULL;
    return NUMBER;
}


    /*Octal Constant*/
0[0-7]*                {
    yylval.number.value = strtoull(yytext, NULL,8);
    yylval.number.type = INTEGER;
    yylval.number.note = SINT;
    return NUMBER;
}
0[0-7]*[uU]                {
    yylval.number.value = strtoull(yytext, NULL,8);
    yylval.number.type = INTEGER;
    yylval.number.note = UINT;
    return NUMBER;
}

0[0-7]*[lL][lL]        {
    yylval.number.value = strtoull(yytext, NULL,8);
    yylval.number.type = INTEGER;
    yylval.number.note = LL;
    return NUMBER;
}

0[0-7]*[lL]           {
    yylval.number.value = strtoull(yytext, NULL,8);
    yylval.number.type = INTEGER;
    yylval.number.note = L;
    return NUMBER;
}

0[0-7]*([uU][lL]|[lL][uU])    {
    yylval.number.value = strtoull(yytext, NULL,8);
    yylval.number.type = INTEGER;
    yylval.number.note = UL;
    return NUMBER;
}

0[0-7]*([uU][lL][lL]|[lL][lL][uU])    {
    yylval.number.value = strtoull(yytext, NULL,8);
    yylval.number.type = INTEGER;
    yylval.number.note = ULL;
    return NUMBER;
}

    /*Different Type of Float*/

[0-9]*[\.][0-9]*          {
    // printf("%s 1\n",yytext);
    yylval.number.fValue = strtold(yytext, NULL);
    yylval.number.type =REAL;
    yylval.number.note = D;
    return NUMBER;
}

[0-9]*[\.][0-9]*f        {
    // printf("%s 2/n",yytext);
    
    yylval.number.fValue = strtold(yytext, NULL);
    yylval.number.type =REAL;
    yylval.number.note = D;
    return NUMBER;
}

[0-9]*[\.][0-9]*(f)?[lL]        {
    // printf("%s 3/n",yytext);

    yylval.number.fValue = strtold(yytext, NULL);
    yylval.number.type =REAL;
    yylval.number.note = LD;
    return NUMBER;
}

[0-9]+[eE](\+)?[0-9]+           {
    // printf("%s 4/n",yytext);

    yylval.number.fValue = strtold(yytext, NULL);
    yylval.number.type =REAL;
    yylval.number.note = D;
    return NUMBER;
}

[0-9]+[eE](\+)?[0-9]+(f)        {
    // printf("%s 4/n",yytext);

    yylval.number.fValue = strtold(yytext, NULL);
    yylval.number.type =REAL;
    yylval.number.note = F;
    return NUMBER;
}

    /*Hex Float Number*/
[0][xX][0-9a-fA-F]+[pP][+-]?[0-9a-fA-F] {
    // printf("%s", yytext);
    
    yylval.number.fValue = strtold(yytext, NULL);
    yylval.number.type =REAL;
    yylval.number.note = D;
    return NUMBER;
}

    /*String Literals and Characters*/
["]([^"\\\n]|\\.|\\\n)*["]      {
    yytext[strlen(yytext) - 1] = '\0';
    char *temp = strdup(yytext+1);
    yylval.string_literal = (char *) malloc(MAXSTRING);
    to_Byte(temp, yylval.string_literal);
    return STRING;
}

[uUL]?\'([\\]?.)*\'  {
    if(yytext[1] =='\\'){
        if(strlen(yytext) > 4){
            fprintf(stderr, "%s:%d:Warning:Unsupported multibyte character literal truncated to first byte\n", fileName, lineNumber);
        }
        yytext[3] = '\0';
    }else{
        if(strlen(yytext) > 3){
            fprintf(stderr, "%s:%d:Warning:Unsupported multibyte character literal truncated to first byte\n", fileName, lineNumber);
        }
        yytext[2] = '\0';
    }
    
    char *temp = strdup(yytext+1);

    yylval.string_literal = (char *) malloc(MAXSTRING);
    to_Byte(temp, yylval.string_literal);

    return CHARLIT;
}


[ \t]+  {/* Ignore White space*/ }
[\n]    {// To keep track of the lineNumbers
        lineNumber++;}
.       {fprintf(stderr,"Error: unrecognized character %s\n",yytext);}

%%

// int main(){

//     int t;
    
//     while(t = yylex()){

//         switch(t){
//             case NUMBER:
//                 if(yylval.number.type == INTEGER){
//                     printf("%s\t%d\tNUMBER\tINTEGER\t%lld\t%s\n", fileName, lineNumber, yylval.number.value,numberNotesText[yylval.number.note]); 
//                 }else if(yylval.number.type ==REAL){
//                     printf("%s\t%d\tNUMBER\tREAL\t%Lg\t%s\n", fileName, lineNumber, yylval.number.fValue, numberNotesText[yylval.number.note]); 
//                 }
//                 break;
//             case INDSEL ... _IMAGINARY:
//                 printf("%s\t%d\t%s\n", fileName, lineNumber, enum_TokenName[t - IDENT]); 
//                 break;
//             case 0 ... 255: 
//                 printf("%s\t%d\t%c\n", fileName, lineNumber, t); 
//                 break;
//             case IDENT:
//                 printf("%s\t%d\tIDENT\t%s\n", fileName, lineNumber, yylval.string_literal);
//                 break;
//             case STRING:
//                 printf("%s\t%d\tSTRING\t", fileName, lineNumber);
//                 printBytes(yylval.string_literal);
//                 printf("\n");
//                 break;
//             case CHARLIT:
//                 printf("%s\t%d\tCHARLIT\t", fileName, lineNumber);
//                 printBytes(yylval.string_literal);
//                 printf("\n");
//                 break;
//             default:
//                 break;
//         }
//     }
//     return 0;
    
// }