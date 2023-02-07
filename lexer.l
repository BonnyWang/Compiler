%option noyywrap
%{
#include "lexer.h"

YYSTYPE yylval;
int lineNumber = 1;
char *fileName;

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
            // These are the recognized char keyworlds
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