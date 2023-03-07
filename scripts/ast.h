#include "lexer.h"
#include "parser.tab.h"
#include <stdbool.h>

enum nodeType{
    IDENTNODE,
    NUMNODE,
    STRNODE,
    CHARNODE,

    FUNCNODE,

    UNARY,
    BINARY,
    TERNARY,
};

// For speccial operators
enum opType{
    DEREFERENCE = 999,
    SELECT,
};

typedef struct astnode *astnode_t;

struct unary{
    int op;
    astnode_t exp; 
};

struct binary {
    int op;
    // For assignment compound
    bool is_compound;
    astnode_t left;
    astnode_t right;
};

struct ternary {
    astnode_t left;
    astnode_t mid;
    astnode_t right;
};

struct function_call {
    astnode_t postfix;
    struct list_item *head;
};

// For the arguments inside the function call parathesis
struct list_item {
    astnode_t exp; 
    struct list_item *next;
    int n_args; 
};


struct astnode {
    int type;
    union {
      char *ident;
      char *string_literal;
      struct numberType number;
      struct unary unary;
      struct binary binary;
      struct ternary ternary;
      struct function_call funct;
    };
};


astnode_t createNode(int type);
astnode_t createOneNode();
astnode_t createUnary( int op, astnode_t exp);
astnode_t createBinary( int op, astnode_t left, astnode_t right, bool is_compound);
astnode_t createTernary( astnode_t left, astnode_t mid, astnode_t right);
astnode_t createFuncNode(astnode_t postfix, struct list_item *head);

struct list_item* createList(astnode_t exp);
struct list_item* addItem(struct list_item *head, astnode_t exp);

void printAst(astnode_t head, int depth);



