//main.c

/* COMPUTER SCIENCE 360 - OPERATING SYSTEMS
 * University of Victoria, Fall 2011
 *
 * Written by:      Michael Dean
 * Student Number:  V00483333
 *
 * Assignment 3, Part 2
 */

#include <stdio.h>
//#include "p242p_filesystem.h"
#include "p242p_testHarness.h"

//the main program is the boot program
//------------------------------------
//in this case, it simply runs a bunch of tests to make sure the system is working properly
//the test functions exist in the p242p_testHarness file
//the file system functions are all located in the p242p_filesystem.h header
//the disk functions are all located in the p242p_disk.h header
//all prototypes, structs, and definitions are located in the p242pio.h header
int main (int argc, const char * argv[])
{
    int disk, home_directory_inodeID, userFile_inodeID;
    int *freeList, *ilist;
    
    //set testing flag to be set
    testing = 1;
    
    //create a disk
    disk = test_create_disk();
    
    //create freelist & write freelist to disk
    test_create_freeList(disk);
    
    //retrieve freelist
    freeList = test_retrieve_freelist(disk);
    
    //create ilist (creates inodes)
    test_create_ilist(disk, freeList);
    
    //retrieve ilist
    ilist = test_retrieve_ilist(disk);
    
    //--------------------------------Phase 1 complete
    printf("-----\n\n");
    printf(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
    printf("SYSTEM INITIALIZATION COMPLETED - NOW TESTING FILE DEPENDENT FUNCTIONS \n");
    printf(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n");

    printf("-----\n\n");
    printf(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
    printf("SYSTEM INITIALIZATION COMPLETED - NOW TESTING FILE/DIRECTORIES \n");
    printf(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n");
    
    //create a home directory (creates a file)
    home_directory_inodeID = test_create_directory(disk);

    printf("\nShowing updated free list after inode allocations:\n");
    print_int_array(freeList, FREELIST_SIZE);
    printf("\nShowing updated ilist after directory creation \n(last element is ilist index containing ID of next available inode):\n");
    print_int_array(retrieve_ilist(disk), NUM_INODES+1);
    
    //write the directory
    //read the directory
    
    printf("\nCreating a file within the new home directory:\n");
    //create a file within the new home directory
    userFile_inodeID = test_create_file(disk);
    
    printf("\nShowing updated ilist after directory creation \n(last element is ilist index containing ID of next available inode):\n");
    print_int_array(retrieve_ilist(disk), NUM_INODES+1);
    
    //printf("\nCurrent children of home directory:\n");
    
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
    
    
    
    
    /*
    int disk, disk_size;
    int *freeList;
    //int blockNr;
    
    disk_size = NUM_BLOCKS*BLOCK_SIZE;
    disk = openDisk("disk",disk_size);              //make a new disk of 16 blocks
    
                                                    //Need to make a case for freeList already existing
    create_FreeList(disk);                          //writes free list to disk when completed
    freeList = retrieve_freeList(disk);     //pointer to first element of free list
    
    //load/create ilist - make a case if ilist already exists
    create_ilist(disk, freeList);
    
    
    create_file(disk, "testFile", "parentFile");
    //createDirectory("Home",-1);                     //-1 denotes top directory
    
     //confirm retrival of free list - WORKS
     for(blockNr=0;blockNr<FREELIST_SIZE;blockNr++) {
     //printf("freeList[blockNr] = %i\n",freeList[blockNr]);
         printf("freeList[%i] = %i\n",blockNr,freeList[blockNr]);
     }
    
    free(freeList);
     */
    
    
    
    return 0;
}



