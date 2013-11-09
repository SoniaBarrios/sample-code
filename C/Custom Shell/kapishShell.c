//  main.c
//  kapish shell
//
//  Author: Michael Dean
//  S/N :   V00483333
//  CSc 360
//  University of Victoria
//  Assignment 1 - Part 2

#define _XOPEN_SOURCE 500

#include <stdio.h> //used for printf, fgets, stdin
#include <stdlib.h> //used for malloc, free, wait, exit
#include <unistd.h> //used for getcwd, chdir, fork, execvp
#include <string.h> //used for strtok, strcmp, strrchr and other various string functions
#include <errno.h> //used for error return code from exec
#include <signal.h> //to use the ctrl-c - kill process command - SIGINT

#define maxUsrIn 512
#define maxArg 20

//GLOBALS--------------------------------------------------------------------------------
char *argv[maxArg]; //an array of char* pointers to hold tokens
int argc;

//PROTOTYPES-----------------------------------------------------------------------------
void tokenize(char *input, char *seperator);
void processCMD(void);
char *calcPath(char *cwd, int path);
char *stripNewLine(char* stripStr);
void exitMsg(void);

//MAIN-----------------------------------------------------------------------------------
int main()
{
    char usrInput[maxUsrIn]; //allocate space for a line of user input (static)
    
    //loop - read user input and tokenize
    //end loop and exit shell if user presses control-d
    //control-d = ^d = EOF
    printf("? ");
    while(fgets(usrInput, maxUsrIn, stdin) != NULL) {
        //tokenize user input
        tokenize(usrInput, " "); //pointer to an array of pointers
        processCMD();
        printf("? ");
    }
    exitMsg();
	return 0;
}

//METHODS--------------------------------------------------------------------------------
//process user input and store pointers to each item in the argv
//input is line from user
//function causes input of the argv to change
void tokenize (char *input, char *seperator) {
    int index=0; 
    char *item = strtok(input, seperator); //returns pointer last string seperated by space    
    if(strcmp(item, "exit\n") == 0) {
        exitMsg(); //quit program
    }
    
    while(item != NULL && index<maxArg) {
        argv[index] = item; //store token in argv
        item = strtok(NULL, seperator); //allows subsequent calls on input to seperate tokens
        index++;
    }
    argv[index] = NULL;
    argc = index; //set total number of arguments
}

void processCMD(void) {  
    char *cwd = (char *) malloc(512); //allocate space for current dir string
    char *dir;
    int childPID; //child process ID
    getcwd(cwd, 512); //store current dir in cwd variable
    
    //dir = strcat(cwd, argv[1]);
    
        //PWD---------------------------------------------------------------------------
    if (strcmp("pwd\n", argv[0]) == 0) { //user tped the pwd command
        printf("%s\n",cwd);
        
        //CD COMMANDS-------------------------------------------------------------------
    } else if(strcmp("cd\n", argv[0]) == 0) { //user typed the cd command
        //cd to home directory
        dir = calcPath(cwd, 0); //calculate root directory path

        chdir(dir);
    } else if(strcmp("cd", argv[0]) == 0) { //user typed the cd command with an argument
            //CD to parent directory
        if (strcmp(stripNewLine(argv[1]),"..") == 0) {
            dir = calcPath(cwd, 1); //calculate parent directory path
            chdir(dir);
            //CD function to a new directory
        } else if(chdir(stripNewLine(argv[1])) != 0) { //chdir returns a value of 0 if successful
            printf("Invalid directory\n"); 
        }
        
        //EXECUTE PROGRAM----------------------------------------------------------------
    } else { //user wants to execute a program
        childPID = fork(); //get child process ID
        argv[argc-1] = stripNewLine(argv[argc-1]);
        if (childPID == 0) {
            //execute process
            //if exec returns, an error has occured -> errno is set to -1
            execvp(argv[0], argv); //path, ./ check compared
        } else if (childPID < 0) {
            printf("process error");
            //exit(1);
            
        }
        
        //signal(SIGINT, SIG_IGN);
        //PUT KILL PROCESS FUNCTION IN
        //wait() waits for any child process to complete
        //calling wait with an argument of 0 means that the caller does not want th return code
        while(wait(NULL)!=childPID);
         
    }
    
    free(cwd);
}

char *calcPath(char *cwd, int path) {
    char *slash = stripNewLine("/");
    char *dir = (char *)malloc(512);
    char *currdir;
    char *usrsFol;
    char *usr;
    
    if (path == 0) {
        //calculate root path 
        usrsFol = strtok(cwd, slash); //get user folder name
        usr = strtok(NULL, slash); //get user ID
        strcat(strcat(strcat(strcpy(dir, slash),usrsFol),slash), usr); //build root path including slashes
    } else if (path == 1) {
        //calculate parent path
        currdir = strrchr(cwd, '/'); //get pointer to current directory
        strncpy(dir, cwd, strlen(cwd)-strlen(currdir)); //copy entire path except the num chars in currdir
    }
    return dir;
}

char *stripNewLine(char* stripStr) {
    char* newLine;
    newLine = strrchr(stripStr, '\n'); //returns pointer to existance of \n character
    if (newLine) {
        *newLine = '\0';
    }
    
    return stripStr;

}

void exitMsg(void) {
    printf("exit\n"); //user forced exit with ^D command, typed exit, or error occured
    exit(0);
}
