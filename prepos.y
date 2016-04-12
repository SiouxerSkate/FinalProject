
%{
#define VAR_SIZE 1024

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef struct 
{
 char thestr[VAR_SIZE];
 int ival;
 float fval;
 char cval;
 int ttype;
}tstruct ; 

#define YYSTYPE  tstruct 

#include "symtab.c"

%}

%error-verbose

%token theader
%token tmain  
%token tret   
%token tvoid
%token tint  
%token tfloat  
%token tchar  
%token tprintf  
%token tscanf
%token telse
%token tif  
%token tfor
%token twhile  
%token tlt  
%token tgt
%token tle
%token tge
%token teq  
%token tne
%token tfalse  
%token ttrue  
%token tassign  
%token tor
%token tand
%token tnot
%token taddressof
%token tstrlit  
%token tid  
%token tnum
%token tchrlit

%%

p	: prog						{ printf("Master of C!\n"); }
	;

/* should account for all sets of program possibilities at high level */
prog	: header main '{' '}'				{ printf("empty program\n"); }
	| header main '{' DL SL '}'			{ printf("DL & SL good\n"); }
	| header main '{' DL '}'			{ printf("Just DL\n"); }
	| header main '{' SL '}'			{ printf("Just SL\n"); }
	;

/* includes header files to be transfered over during code generation */
header	: /* no headers */
	| theader header				{ printf("Header files\n"); }
	;

/* should we also add constants and defines? */

/* 
** main's definition can include int or void as return type
** tmain includes entire string (e.g. main(int argc, char *argv[]) for code generation
*/
main	: tint tmain					{ printf("int main...\n"); }
	| tvoid tmain					{ printf("void main...\n"); }
	;

/* if declarations exist, they will always be above statements */
DL	: DL D						{}
	| D						{}
	;

/* 
** declarations include: primitives (int, float, char) and arrays for each
** declarations must be initialized at time of declaration
*/
D	: type tid tassign tnum ';'			{}
	| type tid tassign tchrlit ';'			{}
	/* array declarations here */
	;

type	: tint {} | tfloat {} | tchar {} ;			

/* 
** will allow syntactically correct abitrarily deep nesting of blocks
** will be good for situations where a single statement is expected or
** where another block 
** (e.g., for (...) do something; vs. for (...) { do a lot more }
*/
block	: '{' SL '}'					{}
	| S						{}
	;

SL 	: SL S		 				{}
	| S						{}
	;

S	: tprintf		 			{}
	| tscanf 		 			{}
	| select		 			{}
	/* while and for will become iteration */ 
	| twhile '(' cond ')' block			{}
	| tfor '(' ')' block				{}
	| tid tassign expr ';'				{}
	| tret tnum ';'					{}
	| error ';'					{}
	;

/*
** should cover if, if/else, if/else if/else, and
** if/else if
** should also allow for nesting of these
*/
select	: tif '(' cond ')' block			{}
	| tif '(' cond ')' block telse block		{}
	;

/* condition may need to expand to help cover &&, ||, ! */
cond	: expr relop expr				{}
	;

relop 	: tlt {} | tgt {} | tle {} | tge {} | teq {} | tne {} ;

/* logop 	: tor {} | tand {} | tnot {} ; */

expr 	: expr '+' term					{}
	| expr '-' term					{}
	| term						{}
	;
	
term	: term '*' factor				{}
	| term '/' factor				{}
	| term '%' factor				{}
	| factor					{}
	;

factor	: tnum						{}
	| tid						{}
	| '(' expr ')'					{}
	;

%%

main()
{
    yyparse();
    printf("---------------------------\n");
}

