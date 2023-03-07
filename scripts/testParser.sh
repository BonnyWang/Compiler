flex lexer.l
bison -d parser.y
gcc -o a.out  lex.yy.c parser.tab.c ast.c
gcc -lm -E ../ptests/exprtests.c | ./a.out >../ptests/mytest.out 2>../ptests/mytest.err

rm *.yy.c *.out *tab.*