#!/bin/sh

flex lexer.l
gcc lex.yy.c -lm
gcc -E ltests/*.c | ./a.out >ltest.out 2>ltest.err