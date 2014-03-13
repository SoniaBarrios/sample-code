/* COMPUTER SCIENCE 360 - OPERATING SYSTEMS
 * University of Victoria, Fall 2011
 *
 * Written by:      Michael Dean
 * Student Number:  V00483333
 *
 * Assignment 3, Part 2
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <pthread.h>

#define BLOCK_SIZE      1024            //size of each block
#define NUM_BLOCKS      16              //total number of blocks on disk
#define DISKMAP_SIZE    13              //number of elements in the diskmap for each inode
#define FREELIST_SIZE   NUM_BLOCKS+1    //space for all blocks, plus a spot at the end to store the index of next free block
#define SUPERBLOCK      NUM_BLOCKS-1    //index of superblock on disk
#define ILIST           NUM_BLOCKS-2    //index of ilist on disk
#define ILIST_NAMES     NUM_BLOCKS-3    //index of ilist names on disk
#define DIR_LIST        NUM_BLOCKS-4    //index of dir_list on disk
#define NEXTFREE        FREELIST_SIZE-1 //next free block
#define NUM_INODES      NUM_BLOCKS/2    //total number of inodes able to be created
#define ILIST_SIZE      NUM_INODES+1    //number of elements in ilist (1 extra for indexing)

int testing = 1; //enable testing output

//Disk---------------------------------------------
int openDisk(char *filename, int nbytes);
int readBlock(int disk, int blocknr, void *block);
int writeBlock(int disk, int blocknr, void *block);
void syncDisk(void);

//File system--------------------------------------
//*************structs
//structure for inode
struct iNodeStruct {
    int inode_id;                   //assign a unique id to this inode
    int diskmap[DISKMAP_SIZE];      //first ten blocks are used for direct reference to blocks, last three are used for indirect references
                                    //this is where the file's data is contained
                                    //the diskmap is just a list of the block numbers which contain the file's data
                                    //to read the file, readBlock
};
typedef struct iNodeStruct iNode;

//structure for a file
struct fileStruct {
    int inodeID;
    int parentID;
    char *name;
};
typedef struct fileStruct file;

//structure for a directory
struct dir{
    file dir;
    int children[NUM_INODES-1];     //maximum possible children is all inodes except the directory's
};
typedef struct dir directory;

//*************functions
//Free List
void create_FreeList(int disk);
void freeBlock(int freeList[], int blockNr);
int useBlock(int freeList[]);
void write_freeList(int disk, int freeList[]);
int *retrieve_freeList(int disk);

//iNodes
iNode *create_iNode(int disk);
void write_iNode(int disk, iNode *inodeToWrite, int block);
iNode *retrieve_iNode(int disk, int inodeID);

//ilist
void create_ilist(int disk, int freeList[]);
int *retrieve_ilist(int disk);
char **retrieve_iListNames(int disk);
void write_ilistNames(int disk, char **ilistNames);

//File operations
int create_file(int disk, char *fileName, char *parentName);
void write_file(int disk, file *fileToWrite);
file *retrieve_file(int disk, char *file_name);

//Directory Operations
int create_dir(int disk, char *dirName, char *parentName);
void write_dir(int disk, directory *dirToWrite);
directory *retrieve_dir(int disk, char *dir_name);

//Testing functions
void print_int_array(int *array,int index);
void print_char_array(char **array,int indexMax);