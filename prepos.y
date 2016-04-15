
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

%error-verbose

%token theader
%token tmain  
%token tret   
%token tvoid
%token tint  
%token tfloat  
%token tchar  
%token tfunction
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

p	: prog						{ 
							  printf("Master of C!\n");
							  showtab(); 
							}
	;

/* should account for all sets of program possibilities at high level */
prog	: header main '{' '}'				{ printf("empty program\n"); }
	| header main '{' DL SL '}'			{ printf("DL & SL good\n"); }
	| header main '{' DL '}'			{ printf("Just DL\n"); }
	| header main '{' SL '}'			{ printf("Just SL\n"); }
	;

/* includes header files to be transfered over during code generation */
header	: /* no headers */
	| theader header				{ printf("%s", $1.thestr); }
	;

/* should we also add constants and defines? */

/* 
** main's definition can include int or void as return type
** tmain includes entire string (e.g. main(int argc, char *argv[]) for code generation
*/
main	: tint tmain					{ printf("int %s\n{\n", $2.thestr); }
	| tvoid tmain					{ printf("void %s\n{\n", $2.thestr); }
	;

/* if declarations exist, they will always be above statements */
DL	: DL D						{}
	| D						{}
	;

D	: type tid tassign tnum ';'			{ 
							  addtab($2.thestr, $1.ttype, 1);
							  switch($1.ttype)
							  {
								case 10:
									printf("\tint %s = %d;\n", $2.thestr, $4.ival);
									break;
								case 20:
									printf("\tfloat %s = %f;\n", $2.thestr, $4.fval);
									break;
								case 30:
									printf("Cannot assign int into char\n");
									exit(1);
							  }
							}
	| type tid tassign tchrlit ';'			{ 
							  addtab($2.thestr, $1.ttype, 1); 
							  switch($1.ttype)
							  {
								case 10:
									printf("Cannot assign char into int\n");
									exit(1);
								case 20:
									printf("Cannot assign char into float\n");
									exit(1);
								case 30:
									printf("\tchar %s = %s;\n", $2.thestr, $4.thestr);
									break;
							  }
							}
        | type tid '[' tnum ']'tassign tnum';'	{ 
							  if ($4.ttype != 10)
							  {
							    printf("Array size must be an integer!\n");
							    exit(1);
							  }
							  if ($1.ttype == 10)  
							     addtab($2.thestr, 11, $4.ival); //int array
							  else if ($1.ttype == 20)
							     addtab($2.thestr, 22, $4.ival); //float array
							  else if ($1.ttype == 30)
							     addtab($2.thestr, 33, $4.ival); //char array
							  
							  switch($1.ttype)
							  {
								case 10:
									printf("\tint %s[%d] = %d;\n", $2.thestr, $4.ival, $7.ival);
									break;
								case 20:
									printf("\tfloat %s[%d] = %f;\n", $2.thestr, $4.ival, $7.fval);
									break;
								case 30:
									printf("Cannot assign number into char array\n");
									exit(1);
							  }
							}
        | type tid '[' tnum ']'tassign tchrlit';' 	{
							  if ($4.ttype != 10)
							  {
							    printf("Array size must be an integer!\n");
							    exit(1);
							  }
							  if ($1.ttype == 10)  
							     addtab($2.thestr, 11, $4.ival); //int array
							  else if ($1.ttype == 20)
							     addtab($2.thestr, 22, $4.ival); //float array
							  else if ($1.ttype == 30)
							     addtab($2.thestr, 33, $4.ival); //char array
							  
							  switch($1.ttype)
							  {
								case 10:
									printf("Cannot assign char into int array\n");
									exit(1);
								case 20:
									printf("Cannot assign char into float array\n");
									exit(1);
								case 30:
									printf("\tchar %s[%d] = %s;\n", $2.thestr, $4.ival, $7.thestr);
									break;
							  }
							 }
        | type tid '[' tnum']'tassign tstrlit';' 	{
							  if ($4.ttype != 10)
							  {
							    printf("Array size must be an integer!\n");
							    exit(1);
							  }
							  if ($1.ttype == 10)  
							     addtab($2.thestr, 11, $4.ival); //int array
							  else if ($1.ttype == 20)
							     addtab($2.thestr, 22, $4.ival); //float array
							  else if ($1.ttype == 30)
							     addtab($2.thestr, 33, $4.ival); //char array
							  
							  switch($1.ttype)
							  {
								case 10:
									printf("Cannot assign string into int array\n");
									exit(1);
								case 20:
									printf("Cannot assign string into float array\n");
									exit(1);
								case 30:
									printf("\tchar %s[%d] = %s;\n", $2.thestr, $4.ival, $7.thestr);
									if (strlen($7.thestr) > $4.ival)
									{
										printf("String literal larger than char array size\n");
										exit(1);
									}
									break;
							  }
							 }
	;

type	: tint {$$.ttype = 10;} | tfloat {$$.ttype = 20;} | tchar {$$.ttype = 30;} ;			

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

S	: tfunction		 			{}
	| select		 			{}
	| loop			 			{}
	| tid tassign expr ';'				{}
	/* below is needed for loops assignment */
	| tid tassign expr 				{}
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

/* condition needs to allow for no semicolon to work with looping */
cond	: expr relop expr				{}
	| expr relop expr ';'				{}
	;

relop 	: tlt {} | tgt {} | tle {} | tge {} | teq {} | tne {} ;

/* logop 	: tor {} | tand {} | tnot {} ; */

loop	: twhile block					{}
	/* the semicolons are handled by rules above */
	| tfor '(' S  cond  S ')' block 		{}
	;

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
    setuptab();
    yyparse();
    printf("---------------------------\n");
}

