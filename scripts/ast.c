#include "ast.h"

astnode_t createNode(int type){
  astnode_t node = (astnode_t )malloc(sizeof(struct astnode));
  node->type = type; 
  return node;
}

// create a number node with a value of 1
astnode_t createOneNode(){
  astnode_t node = createNode(NUMNODE);
  node->number.value = 1;
  node->number.type = INTEGER;
  node->number.note = SINT;
  return node;
}


astnode_t createUnary(int op, astnode_t exp){
      astnode_t node = createNode(UNARY);
      node->unary.op = op;
      node->unary.exp = exp;
      return node;
}

astnode_t createBinary( int op, astnode_t left, astnode_t right, bool is_compound){

      astnode_t node = createNode(BINARY);
      
      node->binary.op = op;
      node->binary.left = left;
      node->binary.right = right;
      node->binary.is_compound = is_compound;
      return node; 
}


// this if for if then else a ? b:c
astnode_t createTernary(astnode_t left, astnode_t mid, astnode_t right){
    
    astnode_t node = createNode(TERNARY);

    node->ternary.left = left;
    node->ternary.mid = mid;
    node->ternary.right = right;

    return node;
}

astnode_t createFuncNode(astnode_t postfix, struct list_item *head){

    astnode_t node = createNode(FUNCNODE);

    node->funct.postfix = postfix;
    node->funct.head = head;

    return node;
}

struct list_item * createList(astnode_t exp){
    struct list_item *head = (struct list_item *)malloc(sizeof(struct list_item));
    head->exp = exp; 
    head->next = NULL;
    head->n_args = 1;  
    return head; 
}

struct list_item* addItem(struct list_item *head, astnode_t exp){
    head->n_args++; 

    struct list_item *tail;
    tail = head;

    while (tail->next != NULL){
        tail = tail->next; 
    }

    tail->next = createList(exp);

    return head;
}


// Useful variable and functions for printing the ast tree
char* op_text[] ={
                    "->",
                    "POSTINC",
                    "--",
                    "<<",
                    ">>",
                    "<=",
                    ">=",
                    "==",
                    "!=",
                    "&&",
                    "||",
                    "...",
                    "*=",
                    "/=",
                    "%%=",
                    "+=",
                    "-=",
                    "<<=",
                    ">>=",
                    "&=",
                    "|=",
                    "^=",
};

void printDepth(int depth){
  int i;
  for( i = 0; i < depth; i++){
    printf("  ");
  }
}

// Not sure if I should make the operater type another enum and pass around
void printOp(char* op_type, int op_index, bool is_compound){
  
  switch(op_index){
    case (EQEQ):
      printf("COMPARISON OP ==");
      break;
    case (NOTEQ):
      printf("COMPARISON OP !=");
      break;
    case (DEREFERENCE):
      printf("DEREF");
      break;
    case (LOGAND):
      printf("LOGICAL OP &&");
      break;
    case (LOGOR):
      printf("LOGICAL OP ||");
      break;
    case (GTEQ):
      printf("COMPARISON OP >=");
      break;
    case (LTEQ):
      printf("COMPARISON OP <=");
      break;
    case (SIZEOF):
      printf("SIZEOF");
      break;
    case ('*'):
      printf("DEREF");
      break;
    default:  
    
      printf("%s", op_type);
      if((op_index >= INDSEL) &&( op_index <= XOREQ)){
        op_index = op_index - INDSEL;
        printf("%s", op_text[op_index]);
      }else{
        
        printf("%c", op_index);
      }

      if (is_compound){
        printf(")");
      }
      break;
  }

  printf("\n");

}

void printFunc(struct list_item *head, int depth){
    int i = 1;
    while (head->next != NULL){
        printDepth(depth);
        printf("arg #%d=\n", i);
        printAst(head->exp, depth + 1);
        head = head->next; 
        i++;
    }
    printDepth(depth);
    printf("arg #%d=\n", i);
    printAst(head->exp, depth + 1);
}

void printAst(astnode_t head, int depth){
  
  printDepth(depth);

  switch (head->type){
    case (IDENTNODE):
      
      printf("IDENT %s\n", head->ident);
      break;

    case (NUMNODE):

      if (head->number.type == INTEGER){
        printf("CONSTANT: (type=int)%lld\n", head->number.value);
      }else{
        // number.type == REAl
        printf("CONSTANT: (type=double)%Lg\n", head->number.fValue);
      }
      break;

    case (STRNODE):

      printf("STRING %s\n", head->string_literal);
      break;
    
    case (CHARNODE):
    
      printf("CONSTANT: (type=int)%d\n", head->string_literal[0]);
      break;
    
    case (FUNCNODE):
      printf("FNCALL, %d arguments\n", head->funct.head->n_args);
      printAst(head->funct.postfix, depth + 1);
      printFunc(head->funct.head, depth);
      break;
  
    case UNARY:{

        // This is ugly...
        if (head->unary.op == '&'){
          printf("ADDRESSOF\n");
          if(head->unary.exp->binary.op == DEREFERENCE){
            // printf("%s",head->unary.exp->unary.exp->binary.right->ident);
            if (head->unary.exp->unary.exp->binary.right != NULL){
              printDepth(depth + 1);
              printf("INDIRECT SELECT, member %s\n", head->unary.exp->unary.exp->binary.right->ident );
              
              printAst(head->unary.exp->unary.exp->binary.left, depth +2 );
            }
          }
          break;
        }
        printOp("UNARY OP ", head->unary.op, false);

        printAst(head->unary.exp, depth + 1);
        
        break;
    }
    case BINARY:{
        if (head->binary.op == SELECT){
          printf("SELECT, member ");
          printf("%s\n", head->binary.right->ident);
          printAst(head->binary.left, depth + 1);
          break;
        }
        if(head->binary.is_compound){
          if ( head->binary.right->binary.right !=NULL){
            printOp("ASSIGNMENT COMPOUND (", head->binary.right->binary.op, true);

            printAst(head->binary.left, depth + 1);
            printAst( head->binary.right->binary.right, depth + 1);
          }else{
            if(head->binary.op == '='){
              printf("ASSIGNMENT\n");
            }else{
              printOp("ASSIGNMENT COMPOUND (", head->binary.op, true);
            }

            printAst(head->binary.left, depth + 1);
            printAst(head->binary.right, depth + 1);
          }
        }else{
          printOp("BINARY OP ",head->binary.op, false);

          printAst(head->binary.left, depth + 1);
          printAst(head->binary.right, depth + 1);
        }

        break;
    }
    case TERNARY:{
        printf("TERNARY OP, IF:\n");
        printAst(head->ternary.left, depth + 1);
        printf("THEN:\n");
        printAst(head->ternary.mid, depth + 1);
        printf("ELSE:\n");
        printAst(head->ternary.right, depth + 1);
        break;
    }
    default:
      break;
  }
}