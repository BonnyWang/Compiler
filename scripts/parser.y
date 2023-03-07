%{
   #include "ast.h"
   #include <ctype.h>

   void yyerror(char *s);
   int yylex();

%}

%union {
      BYTE *string_literal;
      int integer;
      char* ident;
      struct numberType number;
      struct astnode* astnode;
      int op;
      struct list_item* li;
};

%start exps 

%token<ident> IDENT 
%token<string_literal> CHARLIT 
%token<string_literal> STRING 
%token<number> NUMBER 
%type	<astnode> primary_exp postfix_exp function_call unary_exp 
%type <op>  unary_op
%type <astnode> cast_exp multiplicative_exp additive_exp shift_exp
%type <astnode> relational_exp equality_exp bitwise_and_exp bitwise_xor_exp
%type <astnode> bitwise_or_exp logical_and_exp logical_or_exp conditional_exp
%type <astnode> assignment_exp
%type <op> assignment_op 
%type <li> arguments
%type <astnode>   exp exps;
%type<op> '=' '<' '>' '!' '~' '(' ')' '[' ']' '.'

/* From the token Manual */
%token<op> INDSEL PLUSPLUS MINUSMINUS SHL SHR LTEQ GTEQ EQEQ NOTEQ
%token<op> LOGAND LOGOR TIMESEQ DIVEQ MODEQ PLUSEQ MINUSEQ SHLEQ SHREQ
%token<op> ANDEQ OREQ XOREQ SIZEOF
%token<op> ELLIPSIS AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE 
%token<op> ELSE ENUM EXTERN FLOAT FOR GOTO IF INLINE INT LONG REGISTER 
%token<op> RESTRICT RETURN SHORT SIGNED STATIC STRUCT SWITCH TYPEDEF UNION 
%token<op> UNSIGNED VOID VOLATILE WHILE _BOOL _COMPLEX _IMAGINARY

/* Operator precedence from c website */
%left <op> ','
%right '=' PLUSEQ MINUSEQ TIMESEQ DIVEQ MODEQ SHLEQ SHREQ ANDEQ XOREQ OREQ
%right <op> '?' ":"
%left LOGOR
%left LOGAND
%left <op> '|'
%left <op> '^'
%left <op> '&'
%left EQEQ NOTEQ
%left '<' '>' LTEQ GTEQ
%left SHL SHR
%left <op> '+' '-'
%left <op> '*' '/' '%'
%right SIZEOF '!' '~' /* +a, -a, &a, a* */
%left PLUSPLUS MINUSMINUS /* postfix */ INDSEL '(' ')' '[' ']' /* .a, ->a */
%left IF
%left ELSE

%%

primary_exp:      IDENT             {     
                                          astnode_t node = createNode(IDENTNODE); 
                                          node->ident = yylval.ident;
                                          $$ = node; 
                  }
                  | NUMBER          {
                                          astnode_t node = createNode(NUMNODE); 
                                          node->number = yylval.number;
                                          $$ = node; 

                  }
                  | STRING          {
                                          astnode_t node = createNode(STRNODE); 
                                          node->string_literal = yylval.string_literal;
                                          $$ = node; 
                  }
                  | CHARLIT         {
                                          astnode_t node = createNode(CHARNODE); 
                                          node->string_literal = yylval.string_literal;
                                          $$ = node; 
                  }
                  
                  | '(' exp ')'     {
                                          $$ = $2;
                  }
                  ;

postfix_exp:      primary_exp       { $$ = $1;}
                  | postfix_exp '[' exp ']'     {
                                                      astnode_t subNode = createBinary('+', $1, $3, false);
                                                      astnode_t node = createUnary(DEREFERENCE, subNode);
                                                      $$ = node;
                  }
                  | postfix_exp '.' IDENT       {
                                                      astnode_t node = createNode(IDENTNODE); 
                                                      node->ident = $3;

                                                      $$ = createBinary(SELECT, $1, node, false);
                                                            
                  }
                  | postfix_exp INDSEL IDENT    {
                                                      // INDSEL ->
                                                      astnode_t ident = createNode(IDENTNODE);
                                                      ident->ident = $3;

                                                      astnode_t add = createBinary('+', $1, ident, false);
                                                      
                                                      $$ = createUnary(DEREFERENCE, add);
                  }
                  | postfix_exp PLUSPLUS            {$$ = createUnary(PLUSPLUS, $1);}
                  | postfix_exp MINUSMINUS          {$$ = createUnary(MINUSMINUS, $1);}
                  ;

function_call:    postfix_exp '(' arguments ')'      { $$ = createFuncNode($1, $3);}
                  | postfix_exp '(' ')'         { $$ = createFuncNode($1, NULL);}
                  ;

arguments:        assignment_exp                     {$$ = createList($1);}
                  | arguments ',' assignment_exp     {$$ = addItem($1, $3);}
                  ;

unary_exp:        postfix_exp                   {$$ = $1;}
                  | function_call               {$$ = $1;}
                  | PLUSPLUS unary_exp          {     
                                                      // This is same as + 1
                                                      astnode_t one = createOneNode();
                                                      $$ = createBinary('+', $2, one, true);

                  }
                  | MINUSMINUS unary_exp          {     
                                                      // This is same as + 1
                                                      astnode_t one = createOneNode();
                                                      $$ = createBinary('-', $2, one, true);

                  }
                  | unary_op cast_exp           { $$ = createUnary($1, $2);}
                  | SIZEOF '(' unary_exp ')'    { $$ = createUnary(SIZEOF, $3);}

cast_exp:         unary_exp                     {$$ = $1;}
                  ;
unary_op:   '&'   {$$ = '&';}
            | '*'   {$$ = '*';}
            | '+'   {$$ = '+';}
            | '-'   {$$ = '-';}
            | '~'   {$$ = '~';}
            | '!'   {$$ = '!';}
            ;

/* Maybe Combine all these later */
multiplicative_exp:     cast_exp                            {$$ = $1;}
                        | multiplicative_exp '*' cast_exp   {$$ = createBinary('*',$1,$3,false);}
                        | multiplicative_exp '/' cast_exp   {$$ = createBinary('/',$1,$3,false);}
                        | multiplicative_exp '%' cast_exp   {$$ = createBinary('%',$1,$3,false);}
                        ;

additive_exp:           multiplicative_exp                       {$$ = $1;}
                        | additive_exp '+' multiplicative_exp    {$$ = createBinary('+',$1,$3,false);}
                        | additive_exp '-' multiplicative_exp    {$$ = createBinary('-',$1,$3,false);}
                        ;

shift_exp:              additive_exp                    {$$ = $1;}
                        | shift_exp SHL additive_exp    {$$ = createBinary(SHL,$1,$3,false);}
                        | shift_exp SHR additive_exp    {$$ = createBinary(SHR,$1,$3,false);}

relational_exp:         shift_exp                         {$$ = $1;}
                        | relational_exp '<' shift_exp     {$$ = createBinary('<',$1,$3,false);}
                        | relational_exp '>' shift_exp     {$$ = createBinary('>',$1,$3,false);}
                        | relational_exp LTEQ shift_exp    {$$ = createBinary(LTEQ,$1,$3,false);}
                        | relational_exp GTEQ shift_exp    {$$ = createBinary(GTEQ,$1,$3,false);}
                        ;

equality_exp:           relational_exp                            {$$ = $1;}
                        | equality_exp EQEQ relational_exp        {$$ = createBinary(EQEQ,$1,$3,false);}
                        | equality_exp NOTEQ relational_exp       {$$ = createBinary(NOTEQ,$1,$3,false);}
                        ;

bitwise_and_exp:       equality_exp                              {$$ = $1;}
                        | bitwise_and_exp '&' equality_exp       {$$ = createBinary('&',$1,$3,false);}
                        ;

bitwise_xor_exp:       bitwise_and_exp                            {$$ = $1;}
                        | bitwise_xor_exp '^' bitwise_and_exp     {$$ = createBinary('^',$1,$3,false);}
                        ;

bitwise_or_exp: bitwise_xor_exp                           {$$ = $1;}
               | bitwise_or_exp '|' bitwise_xor_exp       {$$ = createBinary('|',$1,$3,false);}
               ;

logical_and_exp: bitwise_or_exp                             {$$ = $1;}
                | logical_and_exp LOGAND bitwise_or_exp     {$$ = createBinary(LOGAND,$1,$3,false);}
                ;

logical_or_exp: logical_and_exp                            {$$ = $1;}
               | logical_or_exp LOGOR logical_and_exp      {$$ = createBinary(LOGOR,$1,$3,false);}
               ;

conditional_exp: logical_or_exp                                  {$$ = $1;}
                | logical_or_exp '?' exp ':' conditional_exp     {$$ = createTernary($1,$3,$5);}
                ;

assignment_exp: conditional_exp                           {$$ = $1;}
               | unary_exp '=' assignment_exp             {$$ = createBinary('=',$1,$3, true);}
               | unary_exp assignment_op assignment_exp   {
                                                            astnode_t right = createBinary($2, $1, $3, false);
                                                            $$ = createBinary('=', $1, right, true);
               }
               ;

assignment_op:          TIMESEQ        {$$ = '*';}
                        | DIVEQ        {$$ = '/';}
                        | MODEQ        {$$ = '%';}
                        | PLUSEQ       {$$ = '+';}
                        | MINUSEQ      {$$ = '-';}
                        | SHLEQ        {$$ = SHL;}
                        | SHREQ        {$$ = SHR;}
                        | ANDEQ        {$$ = '&';}
                        | XOREQ        {$$ = '^';}
                        | OREQ         {$$ = '|';}
                        ;          



exp:		assignment_exp                {$$ = $1;}
            | exp ',' assignment_exp      {$$ = createBinary(',', $1, $3,false);}
            ;

exps:       exp ';'            { printAst($1, 0);}
            | exps exp ';'     { printAst($2, 0);}

%%

int main(){
   yyparse();

   return 1;
}

void yyerror(char *s)
{
      fprintf(stderr, "This is an error\n");

}

