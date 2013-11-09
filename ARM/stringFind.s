@ CSc 230  - StringFind program for Assignment 2 Summer 2010

	.equ	SWI_Exit,   0x11	@terminate program
	.equ	SWI_Open,   0x66	@open a file
	.equ	SWI_Close,	0x68	@close a file
	.equ	SWI_PrStr,  0x69	@print a string
	.equ	SWI_RdStr,	0x6a	@read a string from file
	.equ	SWI_PrInt,	0x6b	@print integer to file
	.equ	SWI_RdInt,	0x6c	@read an integer from file
	.equ	Stdout,		1		@output mode for Stdout
	.equ	FileInputMode,  0
	.equ	FileOutputMode, 1
	.equ	MAXLENGTH,	80		@max length for strings	

	.global _start
	.text	
_start:
@ == Initial messages and identification =====================
	mov	r0,#Stdout			@print to stdout
	ldr	r1,=IDmessage		@ CUSTOMIZE
	swi	SWI_PrStr
	mov	r0,#Stdout
	ldr	r1,=Welcome1
	swi	SWI_PrStr	
@ == Open a file for reading =================================
	ldr	R0, =InFileName
	mov	R1, #0
	swi	SWI_Open
	bcs	InFileError 		@ If Carry-Bit =1 => ERROR 
	ldr	R1, =InFileHandle  	@ else get address to store handle
	str	R0, [R1]            @ save the file handle
	mov	r0,#Stdout			@ print open file message
	ldr	r1,=fileopenmsg
	swi	SWI_PrStr
@ == MainLoop: 
@		Read a pair of strings until end of file
@		Test if substring appears in mainstring and where
MainLoop:
	@ == Read mainstring ===========
	ldr	R0, =InFileHandle  	@ get address of file handle
	ldr	R0, [R0]           	@ get value at address	
	ldr	R1, =mainstring		@ Where to store string read in?	
	mov	R2, #MAXLENGTH		@ Max bytes to read
	swi	SWI_RdStr
	bcs	EndOfFile 			@ IfCarry-Bit =1 => end of file 	
	mov	r0,#Stdout			@ print mainstring + message
	ldr	r1,=mainstrmsg
	swi	SWI_PrStr
	mov	r0,#Stdout				
	ldr	r1,=mainstring
	swi	SWI_PrStr
	mov	r0,#Stdout			
	ldr	r1,=NL
	swi	SWI_PrStr
	@ == Read substring ===========
	ldr	R0, =InFileHandle  	@ get address of file handle
	ldr	R0, [R0]           	@ get value at address	
	ldr	R1, =substring		@ Where to store string read in?	
	mov	R2, #MAXLENGTH		@ Max bytes to read
	swi	SWI_RdStr
	mov	r0,#Stdout			@ print substring + message
	ldr	r1,=substrmsg
	swi	SWI_PrStr
	mov	r0,#Stdout			
	ldr	r1,=substring
	swi	SWI_PrStr
	mov	r0,#Stdout				
	ldr	r1,=NL
	swi	SWI_PrStr
@ == Find of substring is in mainstring and where ==========
@@@@ THIS IS WHERE NEW CODE MUST BE PLACED
@@@@ AT THE END R0 MUST CONTAIN AN INTEGER >=0 STATING
@@@@	THE POSITION OF SUBSTRING IN MAINSTRING
@@@@	OR -1 STATING THAT IT WAS NOT FOUND

@@@@ TEST BY USING ONE OF THE LINES BELOW
	mov	r0,#2			@test with positive number
@	mov	r0,#-1			@test with not found

	cmp	r0,#0			@ was substring found?
	bge	FoundMain		@ if yes, go print position
	mov	r0,#Stdout		@ else not found message
	ldr	r1,=notfoundmsg	
	swi	SWI_PrStr
	bal	MainLoop		@ and go to MainLoop
FoundMain:
	mov	r2,r0			@ save position
	mov	r0,#Stdout		@ found message
	ldr	r1,=foundmsg	
	swi	SWI_PrStr
	mov	r0,#Stdout		@ print position
	mov	r1,r2			@ get position
	swi	SWI_PrInt
	mov	r0,#Stdout				
	ldr	r1,=NL
	swi	SWI_PrStr
	bal	MainLoop		@ and go to MainLoop

InFileError:
	mov	r0,#1			@ print to stdout
	ldr	r1,=FileOpenErrMsg
	swi	SWI_PrStr
	bal	MainExit		@ give up, go to end
EndOfFile:
	mov	r0,#1			@ print eof message
	ldr	r1,=eofmessage
	swi	SWI_PrStr
Exit1:	@ == Close a file =================
	ldr	R0, =InFileHandle  @ get address of file handle
	ldr	R0, [R0]           @ get value at address
	swi	SWI_Close		
MainExit:	
	mov	r0,#1			@print to stdout
	ldr	r1,=Bye1
	swi	SWI_PrStr
	swi	SWI_Exit  @ stop executing instructions: end of program
		
	.data
	.align	@ IMPORTANT: Begin next data at word-aligned address
InFileHandle:		.skip	4

@	declare all char variables below to avoid alignment problems
InFileName:  		.asciz	"TestA2.txt"
mainstring:   		.skip	MAXLENGTH
substring:   		.skip	MAXLENGTH
FileOpenErrMsg: 	.asciz	"Failed to open input file\n"
ColonSpace:     	.asciz	": "
NL:					.asciz	"\n"	@ new line 
Welcome1:			.asciz	"StringFind program starts\n"
IDmessage:			.asciz	"I am Captain Picard\n"
Bye1:				.asciz	"StringFind program ends\n"
fileopenmsg:		.asciz	"Input file opened\n\n"
eofmessage:			.asciz	"End of file reached\n"
mainstrmsg:			.asciz	"   WITH mainstring = "
substrmsg:			.asciz	"      THEN substring = "
notfoundmsg:		.asciz	"         was not found\n"
foundmsg:			.asciz	"         was found at position "

	.end