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
    
    return 0;
}



