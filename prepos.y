
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
 int arrayBound;
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
%token tchrlit
%token tintlit
%%

p	: prog						{ 
							  printf("Master of C!\n");
							  showtab(); 
							}
	;

prog	: header main '{' '}'				{ printf("empty program\n"); }
	| header main '{' DL SL '}'			{ printf("DL & SL good\n"); }
	| header main '{' DL '}'			{ printf("Just DL\n"); }
	| header main '{' SL '}'			{ printf("Just SL\n"); }
	;

header	: /* no headers */
	| theader header				{ printf("Header files\n"); }
	;

main	: tint tmain					{ printf("int main...\n"); }
	| tvoid tmain					{ printf("void main...\n"); }
	;

DL	: DL D						{}
	| D						{}
	;

D	: type tid tassign tnum ';'			{ printf("Single declaration per line and must be initialized.\n");
							  addtab($2.thestr, $1.ttype);
							}
	| type tid tassign tchrlit ';'			{ addtab($2.thestr, $1.ttype); }
        | type tid '[' tnum']'tassign tnum';'	{ 
							  if ($4.ttype != 10)
							  {
							    printf("Array size must be an integer!\n");
							    exit(1);
							  }
							  if ($1.ttype == 10)  
							     addtab($2.thestr, 11); //int array
							  else if ($1.ttype == 20)
							     addtab($2.thestr, 22); //float array
							  else if ($1.ttype == 30)
							     addtab($2.thestr, 33); //char array
							}
        | type tid '[' tnum ']'tassign tchrlit';' 	{
							  if ($4.ttype != 10)
							  {
							    printf("Array size must be an integer!\n");
							    exit(1);
							  }
							  if ($1.ttype == 10)  
							     addtab($2.thestr, 11); //int array
							  else if ($1.ttype == 20)
							     addtab($2.thestr, 22); //float array
							  else if ($1.ttype == 30)
							     addtab($2.thestr, 33); //char array
							 }
        | type tid '[' tnum']'tassign tstrlit';' 	{
							  if ($4.ttype != 10)
							  {
							    printf("Array size must be an integer!\n");
							    exit(1);
							  }
							  if ($1.ttype == 10)  
							     addtab($2.thestr, 11); //int array
							  else if ($1.ttype == 20)
							     addtab($2.thestr, 22); //float array
							  else if ($1.ttype == 30)
							     addtab($2.thestr, 33); //char array
							 }
	;

type	: tint {$$.ttype = 10;} | tfloat {$$.ttype = 20;} | tchar {$$.ttype = 30;} ;			

SL 	: SL S		 				{}
	| S						{}
	;

S	: tprintf		 			{}
	| tscanf 		 			{}
	| tif tid relop tid '{' S '}'			{}
	| twhile '(' tid relop tid ')' '{' S '}'	{}
	| tfor '(' ')' '{' S '}'			{}
	| tid tassign expr ';'				{}
	| tret tnum ';'					{}
	| error ';'					{}
	;

relop 	: tlt | tgt | tle | tge | teq | tne ;

logop 	: tor | tand | tnot ;

expr 	: /* empty for now */ 
	;
%%

main()
{
    setuptab();
    yyparse();
    printf("---------------------------\n");
}

