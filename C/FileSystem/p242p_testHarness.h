/* COMPUTER SCIENCE 360 - OPERATING SYSTEMS
 * University of Victoria, Fall 2011
 *
 * Written by:      Michael Dean
 * Student Number:  V00483333
 *
 * Assignment 3, Part 2
 */

#include "p242p_filesystem.h"

//Prototypes
int test_create_disk(void);
void test_create_freeList(int disk);
int *test_retrieve_freelist(int disk);
void test_create_ilist(int disk, int *freelist);
int *test_retrieve_ilist(int disk);
int test_create_directory(int disk);
int test_create_file(int disk);

//globals
char *pass_fail;

//create a disk
int test_create_disk(void) {
    int disk;
    
    disk = openDisk("disk", NUM_BLOCKS*BLOCK_SIZE);
    
    //did the create/open file operation succeed? If not, throw an error
	if(disk == -1) {
		pass_fail = "FAIL";
    } else {
        pass_fail = "PASS";
    }
    
    printf("CREATE DISK: %s\n",pass_fail);
    
    if (disk==-1) {
        exit(0);
    }
    
    return disk;
}

//create freelist & write freelist to disk
void test_create_freeList(int disk) {
    create_FreeList(disk);
    if (globalFail==1) {
        pass_fail="FAIL";
    } else {
        pass_fail="PASS";
    }
    
    printf("CREATE FREELIST: %s\n", pass_fail);
    
    if (globalFail==1) {
        exit(0);
    }
}

//retrieve freelist from disk
int *test_retrieve_freelist(int disk) {
    int *freelist = retrieve_freeList(disk);
    
    if (globalFail==1) {
        pass_fail="FAIL";
    } else {
        pass_fail="PASS";
    }
    
    printf("-----\nFreelist after writing to disk: \n");
    print_int_array(freelist,FREELIST_SIZE);
    printf("READ FREELIST: %s\n", pass_fail);
    
    if (globalFail==1) {
        exit(0);
    }
    
    return freelist;
}

//create ilist (creates inodes)
void test_create_ilist(int disk, int *freelist) {
    create_ilist(disk, freelist);
    
    if (globalFail==1) {
        pass_fail="FAIL";
    } else {
        pass_fail="PASS";
    }
    
    printf("CREATE ILIST: %s\n", pass_fail);
    
    if (globalFail==1) {
        exit(0);
    }
}

//retrieve ilist
int *test_retrieve_ilist(disk) {
    int *ilist = retrieve_ilist(disk);
    
    if (globalFail==1) {
        pass_fail="FAIL";
    } else {
        pass_fail="PASS";
    }
    
    printf("-----\nilist after writing to disk: \n");
    print_int_array(ilist,NUM_INODES);
    printf("READ ILIST: %s\n", pass_fail);
    
    if (globalFail==1) {
        exit(0);
    }
    
    return ilist;
}

//create a home directory (creates a file)
int test_create_directory(int disk) {
    int homeID = create_dir(disk, "home", NULL);
    
    if (globalFail==1) {
        pass_fail="FAIL";
    } else {
        pass_fail="PASS";
    }
    
    if (testing==1) {
        printf("Directories inode is: %i\n",homeID);
        //printf("Current list of children:");
    }
    
    printf("CREATE HOME DIRECTORY: %s\n", pass_fail);
    
    if (globalFail==1) {
        exit(0);
    }
    
    return homeID;
}
//write the directory
//read the directory

//create a file within the new home directory
int test_create_file(int disk) {
    int homeID = create_file(disk, "test_file", "home");
    
    if (globalFail==1) {
        pass_fail="FAIL";
    } else {
        pass_fail="PASS";
    }
    
    if (testing==1) {
        //printf("Directories inode is: %i\n",homeID);
        //printf("Current list of children:");
    }
    
    printf("CREATE FILE: %s\n", pass_fail);
    
    if (globalFail==1) {
        exit(0);
    }
    
    return homeID;
}
//modify, then write a file
//read a file

//shutdown system

//on re-boot, recognize disk
//print current state of file system

//create a new directory within the home directory
//create a new file within this new directory
//shutdown system

//print contents of filesystem

//exit