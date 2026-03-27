%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>   // CALCULATOR

void yyerror(const char *msg);
int yylex(void);

// helped me in recalling how to structure tree node:
// https://stackoverflow.com/questions/3223416/how-to-structure-this-tree-of-nodes

// PARSE TREE IMPLEMENTATION:
// Tree Node Structure: each node can have up to 3 children (left, mid, right)
typedef struct Node {
    char* label;
    struct Node* left;
    struct Node* mid; // for operators or parentheses
    struct Node* right;
    int is_leaf;
    int value; // CALCULATOR: stores numeric value (evaluating expressions)
} Node;

// PARSE TREE: creates internal node/nonleaf (w/ optional children)
Node* create_node(char* label, Node* l, Node* m, Node* r) {
    Node* n = (Node*)malloc(sizeof(Node));
    n->label = strdup(label);
    n->left = l; n->mid = m; n->right = r;
    n->is_leaf = 0;
    return n;
}

// PARSE TREE: creates leaf node
Node* create_leaf(char* label, int val) {
    Node* n = (Node*)malloc(sizeof(Node));
    n->label = strdup(label);
    n->value = val;
    n->is_leaf = 1;
    n->left = n->mid = n->right = NULL;
    return n;
}

// PARSE TREE: Print function (recursive) + w/ indentation
void print_tree(Node* n, int depth) {
    if (!n) return;
    
    // print current node
    for(int i = 0; i < depth; i++) printf("  ");
    printf("%s\n", n->label);
    
    // if leaf -> print value (next depth)
    if (n->is_leaf) {
        for(int i = 0; i < depth + 1; i++) printf("  ");
        printf("%d\n", n->value);
    }

    // print children
    print_tree(n->left, depth + 1);
    print_tree(n->mid, depth + 1);
    print_tree(n->right, depth + 1);
}

%}

%union {
    int ival;           // CALCULATOR: for integer values
    double fval;        // CALCULATOR: for floating-point values
    struct Node* nptr;  // PARSE TREE: pointer to tree node
}

%token <ival> NUM
%token <fval> FNUM      // CALCULATOR: allows lexer to pass floating-point numbers

%token PLUS MINUS TIMES DIVIDE LPAREN RPAREN POWER  // CALCULATOR: added POWER to support exponent operator "^"

%left PLUS MINUS
%left TIMES DIVIDE

%right POWER            // CALCULATOR: added POWER and placed it above UMINUS so exponent has higher precedence than UMINUS
%right UMINUS

// CALCULATOR: changed ival to fval for expr, term, factor to support floats
// COMMENT THIS IF YOU WANT TO DO PARSE TREE
// %type <fval> expr term factor

// PARSE TREE: all non-terminals return Node pointers instead of numeric values
// COMMENT THIS IF YOU WANT TO DO CALCULATOR
%type <nptr> expr term factor

%%


// PARSE TREE IMPLEMENTATION:
// COMMENT FROM HERE YOU WANT TO DO CALCULATOR
program:
    expr {
        // PARSE TREE: prints the parse tree
        print_tree($1, 0); 
        printf("\nParse Complete.\n"); 
    }
;

expr:
    expr PLUS term { 
        // PARSE TREE: addition node
        // structure: expr -> expr + term
        $$ = create_node("expr", $1, create_node("+", NULL, NULL, NULL), $3); 
    }
    | term { 
        // PARSE TREE: wraps term into "expr" node
        $$ = create_node("expr", $1, NULL, NULL); 
    }
;

term:
    term TIMES factor { 
        // PARSE TREE: multiplication node
        // structure: term -> term * factor
        $$ = create_node("term", $1, create_node("*", NULL, NULL, NULL), $3); 
    }
    | factor { 
        // PARSE TREE: wraps factor into "term" node
        $$ = create_node("term", $1, NULL, NULL); 
    }
;

factor:
    NUM { 
        // PARSE TREE: creates leaf node for integer
        $$ = create_leaf("factor", $1); 
    }
    | LPAREN expr RPAREN {
        // PARSE TREE: explicitly shows parentheses in the tree
        // structure: factor -> ( expr )
        $$ = create_node("factor", create_node("(", NULL, NULL, NULL), $2, create_node(")", NULL, NULL, NULL));
    }
;

// END OF PARSE TREE IMPLEMENTATION

/*

// CALCULATOR IMPLEMENTATION:
// COMMENT FROM HERE YOU WANT TO DO PARSE TREE
program:
    expr { printf("Result: %f\n", $1); }
;

expr:
    expr PLUS term          { $$ = $1 + $3; }
    | expr MINUS term       { $$ = $1 - $3; }
    | term                  { $$ = $1; }
;

term:
    term TIMES factor       { $$ = $1 * $3; }
    | term DIVIDE factor    { $$ = $1 / $3; }
    | factor                { $$ = $1; }
;

factor:
    NUM                     { $$ = $1; }
    // CALCULATOR: added FNUM to allow floating-point nums
    | FNUM                  { $$ = $1; }
    | LPAREN expr RPAREN    { $$ = $2; }
    | MINUS factor %prec UMINUS { $$ = -$2; }

    // CALCULATOR: added to handle exponents (pow()), right-associative (%right POWER)
    | factor POWER factor { $$ = (double)((int)pow((double)$1, (double)$3)); }
;

// END OF CALCULATOR IMPLEMENTATION
*/

%%

void yyerror(const char *msg) {
    fprintf(stderr, "Parse error: %s\n", msg);
}

int main(void) {
    // CALCULATOR & PARSE TREE: added loop to allow continuous input for easy testing
    while (1) {
        printf("> ");
        yyparse();
    }
    return 0;
}