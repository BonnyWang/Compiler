%option noyywrap
%{
#include "lexer.h"

YYSTYPE yylval;
int lineNumber = 1;
char *fileName;
char *temp;

%}

%%
    /*Get the file name here and ignore other preprossed information and reset lineNumber*/

"# 0 \"ltests/".*\n {
    fileName = strdup(yytext+strlen("# 0 \""));
    // Remove the last "
    fileName[strlen(fileName)-2]= '\0'; 
    printf("%s\n", fileName);

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
    yylval.string_literal = strdup(yytext);
    return IDENT;
    }
    
    
    /*Different Type of Number*/

    /*Different Type of Integer*/

    /*Decimal Integer*/
[1-9][0-9]*                 {
    yylval.number.value = atoi(yytext);
    yylval.number.type = "INTEGER";
    yylval.number.note = "INT";
    return NUMBER;
}
[1-9][0-9]*[uU]             {
    yylval.number.value = atoi(yytext);
    yylval.number.type = "INTEGER";
    yylval.number.note = "UNSIGNED,INT";
    return NUMBER;
}

[1-9][0-9]*[lL]             {
    yylval.number.value = atoi(yytext);
    yylval.number.type = "INTEGER";
    yylval.number.note = "LONG";
    return NUMBER;
}

[1-9][0-9]*[lL][lL]             {
    yylval.number.value = atoi(yytext);
    yylval.number.type = "INTEGER";
    yylval.number.note = "LONGLONG";
    return NUMBER;
}
[1-9][0-9]*([uU][lL]|[lL][uU])             {
    yylval.number.value = atoi(yytext);
    yylval.number.type = "INTEGER";
    yylval.number.note = "UNSIGNED,LONG";
    return NUMBER;
}
[1-9][0-9]*([uU][lL][lL]|[lL][lL][uU])             {
    yylval.number.value = atoi(yytext);
    yylval.number.type = "INTEGER";
    yylval.number.note = "UNSIGNED,LONGLONG";
    return NUMBER;
}


    /*Hexidecimal*/     
0[xX][0-9a-fA-F]+                {
    yylval.number.value = HexTODecimal(yytext);
    yylval.number.type = "INTEGER";
    yylval.number.note = "INT";
    return NUMBER;
}
0[xX][0-9a-fA-F]+[uU]                {
    temp = strdup(yytext);
    temp[strlen(temp)-1] = '\0';
    yylval.number.value = HexTODecimal(temp);
    yylval.number.type = "INTEGER";
    yylval.number.note = "UNSIGNED,INT";
    return NUMBER;
}

0[xX][0-9a-fA-F]+[lL][lL]        {
    temp = strdup(yytext);
    temp[strlen(temp)-2] = '\0';
    yylval.number.value = HexTODecimal(temp);
    yylval.number.type = "INTEGER";
    yylval.number.note = "LONGLONG";
    return NUMBER;
}

0[xX][0-9a-fA-F]+[lL]           {
    temp = strdup(yytext);
    temp[strlen(temp)-1] = '\0';
    yylval.number.value = HexTODecimal(temp);
    yylval.number.type = "INTEGER";
    yylval.number.note = "LONG";
    return NUMBER;
}

0[xX][0-9a-fA-F]+([uU][lL]|[lL][uU])    {
    temp = strdup(yytext);
    temp[strlen(temp)-2] = '\0';
    yylval.number.value = HexTODecimal(temp);
    yylval.number.type = "INTEGER";
    yylval.number.note = "UNSIGNED,LONG";
    return NUMBER;
}
0[xX][0-9a-fA-F]+([uU][lL][lL]|[lL][lL][uU])    {
    temp = strdup(yytext);
    temp[strlen(temp)-3] = '\0';
    yylval.number.value = HexTODecimal(temp);
    yylval.number.type = "INTEGER";
    yylval.number.note = "UNSIGNED,LONGLONG";
    return NUMBER;
}


    /*Octal Constant*/
0[0-7]*                {
    yylval.number.value = OctalToDecimal(atoi(yytext));
    yylval.number.type = "INTEGER";
    yylval.number.note = "INT";
    return NUMBER;
}
0[0-7]*[uU]                {
    yylval.number.value = OctalToDecimal(atoi(yytext));
    yylval.number.type = "INTEGER";
    yylval.number.note = "UNSIGNED,INT";
    return NUMBER;
}

0[0-7]*[lL][lL]        {
    yylval.number.value = OctalToDecimal(atoi(yytext));
    yylval.number.type = "INTEGER";
    yylval.number.note = "LONGLONG";
    return NUMBER;
}

0[0-7]*[lL]           {
    yylval.number.value = OctalToDecimal(atoi(yytext));
    yylval.number.type = "INTEGER";
    yylval.number.note = "LONG";
    return NUMBER;
}

0[0-7]*([uU][lL]|[lL][uU])    {
    yylval.number.value = OctalToDecimal(atoi(yytext));
    yylval.number.type = "INTEGER";
    yylval.number.note = "UNSIGNED,LONG";
    return NUMBER;
}

0[0-7]*([uU][lL][lL]|[lL][lL][uU])    {
    yylval.number.value = OctalToDecimal(atoi(yytext));
    yylval.number.type = "INTEGER";
    yylval.number.note = "UNSIGNED,LONGLONG";
    return NUMBER;
}

    /*Different Type of Float*/

[0-9...]+[\.][0-9...]+          {
    yylval.number.fValue = atof(yytext);
    yylval.number.type = "REAL";
    yylval.number.note = "DOUBLE";
    return NUMBER;
}



[ \t]+  {/* Ignore White space*/ }
[\n]    {// To keep track of the lineNumbers
        lineNumber++;}
.       {fprintf(stderr,"Error: unrecognized character %s\n",yytext);}

%%

int main(){

    int t;
    
    // char a;
    // t = 0;

    // while(t < 10000){
    //     a = getchar();
    //     fputc(a, stdout);
    //     t++;
    // }

    while(t = yylex()){

        switch(t){
            case NUMBER:
                if(yylval.number.type == "INTEGER"){
                    printf("%s\t%d\tNUMBER\t%s\t%d\t%s\n", fileName, lineNumber, yylval.number.type, yylval.number.value,yylval.number.note); 
                }else if(yylval.number.type == "REAL"){
                    printf("%s\t%d\tNUMBER\t%s\t%g\t%s\n", fileName, lineNumber, yylval.number.type, yylval.number.fValue,yylval.number.note); 
                }
                break;
            case INDSEL ... _IMAGINARY:
                printf("%s\t%d\t%s\n", fileName, lineNumber, enum_TokenName[t - IDENT]); 
                break;
            case 0 ... 255: 
                printf("%s\t%d\t%c\n", fileName, lineNumber, t); 
                break;
            case IDENT:
                printf("%s\t%d\tIDENT\t%s\n", fileName, lineNumber, yylval.string_literal);
                break;
            default:
                break;
        }
    }
    return 0;
    
}