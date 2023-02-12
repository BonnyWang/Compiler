#!/bin/sh

flex lexer.l
gcc lex.yy.c -lm -o lexer
gcc -E ltests/*.c | ./lexer >ltest.out 2>ltest.err