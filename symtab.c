/* constants */
#define TRUE        1
#define FALSE       0
#define SIZE        1024

/* type constants */
#define INT     	10
#define INT_ARRARY	11
#define FLOAT   	20
#define FLOAT_ARRAY	22
#define CHAR		30
#define CHAR_ARRAY	33


/* error constants */
#define ERROR_NOT_INIT          100
#define ERROR_UNKNOWN_TYPE      101
#define ERROR_WHO_KNOWS         102

/* declarations/definitions */
struct stelem
{
 char sname[1024];
 int  stype;    /* see type constants for types */	 
 int  binit;    /* boolean for initialization */
 int  ssize;    /* if not an array set to 1 */
};
typedef struct stelem entry;

/* global variables */
entry symtab[SIZE];
int nsym = 0;

/* functions */
void setuptab(void)
{
    int i;
    for (i = 1; i < SIZE; i++)
    {  
	symtab[i].sname[0] = '\0';
	symtab[i].stype = 0;
	symtab[i].binit = FALSE;    /* When initialized, we set to TRUE */
	symtab[i].ssize = 1;	    /* when array is added, change size */
    }
}

void addtab( char *s, int type, int size)
{
    nsym++;
    strcpy( symtab[nsym].sname, s);
    symtab[nsym].stype = type;   
    symtab[nsym].binit = TRUE;  /* since initialization is required upon declaration, set type and binit with name. */
    symtab[nsym].ssize = size;	/* need to set size for arrays */ 
}

void showtab()
{
 int i;
 for (i = 1; i <= nsym; ++i)
 {
   printf("%d: %s %d", i, symtab[i].sname, symtab[i].stype);
   if( symtab[i].binit)
    printf(" initialized ");
   else
    printf(" uninitialized ");
   if (symtab[i].stype == 11 || symtab[i].stype == 22 || symtab[i].stype == 33)
    printf("bound: ");
   puts(""); 
 }  
}

int intab( char *s)
{
 int i;
 for ( i = 1; i <= nsym; ++i)
 {
   if ( strcmp(symtab[i].sname, s) == 0)
    return TRUE;
 }
 return FALSE;
}

 int varsInitialized(void)
 {
    int i;
     for ( i = 1; i <= nsym; ++i)
     {
        if (symtab[i].binit == FALSE)
        {
            printf("What are you thinking!? Initialize your variables!!!!\n");
            exit(ERROR_NOT_INIT);
        }
     }
     return TRUE;
 }
 
int gettype( char *s)
{
 int t = -1;
 int i, loc = -1;
 for ( i = 1; i <= nsym; ++i)
 {
   if ( strcmp(symtab[i].sname, s) == 0)
    loc = i;
 }
 if (loc > 0)
  {
   t = symtab[loc].stype;
   printf("Get type for %s to %d\n", s, t);
  }
 if (loc <= 0)
   printf("gettype var %s not found\n", s);
 else if (t < 0)
   printf("gettype var %s has bad type %d\n", s, t);
 else 
   printf("gettype var %s has type %d\n", s, t);
 return t;
}



