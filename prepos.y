
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

%%

p	: prog					{ printf("Ok\n"); }
	;

prog	: header main '{' '}'				{}
	| header main '{' DL SL '}'			{}
	;

header	: /* no headers */
	| theader header				{}
	;

main	: tint tmain					{}
	| tvoid tmain					{}
	;

DL	: DL D						{}
	| D						{}
	;

D	: type IDL ';'					{}
	;

IDL	: IDL ',' tid					{}
	| tid						{}
	;

type	: tint {} | tfloat {} | tchar {} ;			

SL 	: SL S						{}
	| S						{}
	;

S	: tprintf '(' tstrlit ')' ';'			{}
	| tscanf  '(' tstrlit ')' ';'			{}
	/* separate if into another category */
	| tif tid relop tid '{' S '}'			{}
	/* separate while into iteration category */
	| twhile '(' tid relop tid ')' '{' S '}'	{}
	/* separate for into iteration category */
	| tfor '(' ')' '{' S '}'			{}
	| tid tassign expr ';'				{}
	| error ';'					{}
	;

relop 	: tlt | tgt | tle | tge | teq | tne ;

logop 	: tor | tand | tnot ;

expr	: expr '+' term					{}
	| expr '-' term					{}
	| term						{}
	;

term	: term '*' factor				{}
	| term '/' factor				{}
	| term '%' factor				{}
	| factor					{}
	;

factor	: tid						{}
	| tnum						{}
	;

%%

main()
{
    yyparse();
    printf("---------------------------\n");
}

yyerror(char *s)
{
    printf("\terror: %s\n", s);
    printf("ERROR: %s at line %d\n", s, 123);
}
