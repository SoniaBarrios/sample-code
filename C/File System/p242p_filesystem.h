/* COMPUTER SCIENCE 360 - OPERATING SYSTEMS
 * University of Victoria, Fall 2011
 *
 * Written by:      Michael Dean
 * Student Number:  V00483333
 *
 * Assignment 3, Part 2
 */

#include "p242p_disk.h"

/* Test Harness Contents:
 * Test each and every function, have a check that says it's working for each (nothing extensive, just confirm everything functions using simple data) - PASS/FAIL
 * Test start-up from no existing disk - demonstrate all creations
 * Create a file and place in home directory
 * Create a directory and place in home directory ('usr')
 * Create a file and place in the User directory - "UserSettings"?
 * Print contents of 'home' directory
 * Print contents of 'usr' directory
 * Shut down system
 * Re-Boot and acknowledge the existence of a disk
 * Demonstrate retrieval of all info from disk and print contents of 'home', 'usr'
 * Test complete!
 */

//total number of system blocks is stored in freeList[NUM_BLOCKS]
//index containing the next available block is stored in freeList[NUM_BLOCKS+1]

int inodeCount = 0;
int globalFail = 0;

//SUPERBLOCK IS LOCATED AT THE LAST BLOCK IN MEMORY
//ILIST IS LOCATED AT THE SECOND LAST BLOCK IN MEMORY

//Free List Functions------------------------------------------------------------------------------

//create free list - write it to disk when it's done
void create_FreeList(int disk) {
    int blockNr;
    int freeList[FREELIST_SIZE]; //one extra blocks at the end of the array for next free block pointer
    
    freeList[FREELIST_SIZE-1] = -1; //update the index for the next available block (none available)
    
    //no blocks are available - free all the system blocks so they are available
    for(blockNr=0;blockNr<NUM_BLOCKS;blockNr++) {
        freeBlock(freeList, blockNr);
    }
    
    if (testing==1) {
        printf("-----\nFreelist before writing to disk: \n");
        print_int_array(freeList,FREELIST_SIZE);
    }
    
    //write freeList array to disk
    write_freeList(disk,freeList);
}

//add the block number
void freeBlock(int freeList[], int blockNr) {
    freeList[NEXTFREE]++;                       //point to the index in the free list to store the new free block
    freeList[freeList[NEXTFREE]] = blockNr;     //add the newly free block to the free list
}

//return block number to be used
int useBlock(int freeList[]) {
    int blockToUse = freeList[freeList[NEXTFREE]];
    freeList[freeList[NEXTFREE]] = -1;               //indicate block is in use
    freeList[NEXTFREE]--;                            //update update indexer
    return blockToUse;
}

//write the freelist to the superblock
void write_freeList(int disk, int freeList[]) {
    int bytesWritten, blockToWriteTo;
    void *writeBuffer;
    
    //write array to super block, update freelist before write
    if ((blockToWriteTo = useBlock(freeList)) != SUPERBLOCK) {
        //freelist is getting written to wrong block!
        printf("Error: Free-List indexing error\n");
        globalFail=1;
    }
     
    writeBuffer = freeList;
    
    /*
    for(blockNr=0;blockNr<FREELIST_SIZE;blockNr++) {
        printf("freeList[blockNr] = %i\n",freeList[blockNr]);
        printf("writeBuffer[blockNr] = %i\n",(*(int*)(writeBuffer+blockNr*4)));
    }
    */
    
    if((bytesWritten = writeBlock(disk,blockToWriteTo,writeBuffer)) < 0){
        printf("Error: Free-List failed to write to disk\n");
        globalFail=1;
	}
}

int *retrieve_freeList(int disk) {
    int blockIdx;
    int *freeList = (int*)malloc(FREELIST_SIZE*sizeof(int));                        //MUST FREE THIS
    void *readBuffer = (void*)calloc(FREELIST_SIZE, sizeof(int));
    
    if (readBlock(disk, SUPERBLOCK, readBuffer)<0) {
        globalFail=1;
    }
    
    for(blockIdx=0;blockIdx<FREELIST_SIZE;blockIdx++) {
        freeList[blockIdx]=(*(int*)(readBuffer+blockIdx*4));
    }
    
    //free(readBuffer);
    return freeList;
}

//iList Functions------------------------------------------------------------------------------
void create_ilist(int disk, int freeList[]) {
    iNode *node;
    int inodeID, bytesWritten;
    void *writeBuffer;
    int *ilist = (int*)malloc((ILIST_SIZE)*sizeof(int));
    char **ilistNames = (char**)malloc(NUM_INODES*sizeof(char*));
    
    //create all inodes and fill the ilist
    for(inodeID=0;inodeID<NUM_INODES;inodeID++) {
        node = create_iNode(disk);                  //create an inode
        ilist[inodeID] = useBlock(freeList);        //store the block the inode is stored in in the index corresponding to the inode id
        ilistNames[inodeID] = "\0";                 //initialize all names to show they are not used
                                                    //update freelist
        writeBuffer = node;                         //store the inode in a block - write inode to disk
        
        //write the inode to disk at the block allocated for it
        write_iNode(disk, node, ilist[inodeID]);
    }
    
    ilist[ILIST_SIZE-1] = 0;                        //indicate the next available inode
    
    if (testing==1) {
        printf("-----\nilist before writing to disk (blocks that contain empty inodes): \n");
        print_int_array(ilist,ILIST_SIZE);
        printf("Directory and File names list has been initialized.\n");
        printf("-----\n");
        //print_char_array(ilistNames,NUM_INODES);
    }
    
    //write ilist to memory
    writeBuffer = ilist;
    if((bytesWritten = writeBlock(disk,ILIST,(void*)writeBuffer)) < 0){
        printf("Error: inode failed to write to disk\n");
        globalFail = 1;
    }
    
    //write ilist names to memory
    writeBuffer = ilistNames;
    if((bytesWritten = writeBlock(disk,ILIST_NAMES,(void*)writeBuffer)) < 0){
        printf("Error: inode names list failed to write to disk\n");
        globalFail = 1;
    }
    
    //free(ilist);
    //free(ilistNames);
}

int *retrieve_ilist(int disk) {
    int *ilist = (int*)malloc(NUM_INODES*sizeof(int));
    void *readBuffer = (void*)calloc(NUM_INODES, sizeof(int));
    
    //get ilist from its block in memory
    readBlock(disk, ILIST, readBuffer);
    
    ilist = readBuffer;
    
    //free(readBuffer);
    return ilist;
}

//call to retrive_ilistNames must be followed by a free(ilistNames) call
char **retrieve_iListNames(int disk) {
    int inodeID_idx;
    char *testVal;
    char **ilistNames = (char**)malloc(NUM_INODES*sizeof(char*));
    void *readBuffer = (void*)calloc(NUM_INODES, sizeof(char));
    
    readBlock(disk, ILIST_NAMES, readBuffer);
    ilistNames = readBuffer;
    
    for(inodeID_idx=0;inodeID_idx<NUM_INODES;inodeID_idx++) {
        testVal = ilistNames[inodeID_idx];
    }
    
    //free(readBuffer);
    return ilistNames;
}

//write the ilist_Names list to disk
void write_ilistNames(int disk, char **ilist_Names) {
    void *writeBuffer;
    int bytesWritten;
    
    writeBuffer = ilist_Names;
    if((bytesWritten = writeBlock(disk,ILIST_NAMES,(void*)writeBuffer)) < 0){
        printf("Error: inode failed to write to disk\n");
        globalFail=1;
    }
}

//iNode Functions------------------------------------------------------------------------------
iNode *create_iNode(int disk) {
    int blockNr;
    
    //allocate space for the struct
    iNode *newNode = (iNode*)malloc(sizeof(iNode));
    
    //file diskmap with -1 values to indicate no blocks being used
    for (blockNr=0; blockNr<DISKMAP_SIZE; blockNr++) {
        (*newNode).diskmap[blockNr] = -1;
    }
    
    //set the inode id by adding it to the ilist
    return newNode;
}

void write_iNode(int disk, iNode *inodeToWrite, int block) {
    //only need to write the diskmap to a block since inode is referenced by name and ID elsewhere (ilist, ilistnames)
    void *writeBuffer;
    //int nodeArray[DISKMAP_SIZE+1];
    //nodeArray[0] = (*inodeToWrite).inode_id;
    
    writeBuffer=(*inodeToWrite).diskmap;                                           
    writeBlock(disk, block, writeBuffer);     //write to disk
}

iNode *retrieve_iNode(int disk, int inodeID) {
    iNode *inode = (iNode*)malloc(sizeof(iNode));
    void *readBuffer = (void*)calloc(NUM_INODES, sizeof(char));
    int *temp;
    int index;
    
    int *ilist = retrieve_ilist(disk);                  //get ilist from disk
    readBlock(disk,ilist[inodeID],readBuffer);          //find out which block inode is stored in, and retrieve that block
    temp = readBuffer;
    for (index=0; index<DISKMAP_SIZE; index++) {
        (*inode).diskmap[index] = (*temp);
    }
    (*inode).inode_id = inodeID;
    
    //return inode
    return inode;
}

//File operations------------------------------------------------------------------------------
//NOT COMPLETED
//takes disk identifier, filename and parent directory filename as arguments
//creates a file by associating an inode with it and storing the meta-data
//returns inode id for the file created
//returns -1 if file not created
int create_file(int disk, char *fileName, char *parentName) {
    //initialize neccessary variables
    int *ilist;                                         //used to identify the parent inode and pick an unused inode for the file
    char **ilist_names;
    void *writeBuffer;
    int nextFreeIdx, found;
    int inodeNum;                                       //index for the loop
    
    file *newFile = (file*)malloc(sizeof(file));

    ilist = retrieve_ilist(disk);                       //get list of unused inodes
    nextFreeIdx = ilist[ILIST_SIZE-1];                  //get the index for the next available inode
    (*newFile).inodeID = ilist[nextFreeIdx];            //assign an unused inode to this file
    ilist[ILIST_SIZE-1] = nextFreeIdx+1;                //update ilist to reflect this node is in use
    
    //CHECK TO SEE IF ILIST IS FULL!!!!!
    
    ilist_names = retrieve_iListNames(disk);            //get the list of inode names from file
    ilist_names[nextFreeIdx] = fileName;                //store the name associated with the file in the inode names list
    (*newFile).name = fileName;                         //assign this name to the file
    
    found=0;
    //find the inode associated with the parent
    for(inodeNum=0;inodeNum<NUM_INODES;inodeNum++) {
        if (strcmp(parentName, "home")==0 && strcmp(fileName, "home")==0) {                         //is this the home directory?
            (*newFile).parentID = -1;
            found = 1;
            break;
        } else if (strcmp(ilist_names[inodeNum],parentName)==0) {
            (*newFile).parentID = ilist[inodeNum];
            found=1;
            break;
        }
    }
    
    if (found!=1) {
        printf("Parent directory could not be found.\n");
        globalFail = 1;
    }
    
    //write all data to disk - ilist, ilist_names, newFile
    writeBuffer = ilist;
    if(writeBlock(disk,ILIST,(void*)writeBuffer) < 0){
        printf("Error: inode failed to write to disk\n");
        globalFail = 1;
    }
    write_ilistNames(disk, ilist_names);
    write_file(disk, newFile);
    
    return (*newFile).inodeID;                          //return inode ID of file
}

//function writes the file's metadata, and it's associated inode to disk
void write_file(int disk, file *fileToWrite) {
    char **ilistNames;
    iNode *file_iNode = (iNode*)malloc(sizeof(iNode));
    
    //Step 1 - write the file name to the ilist_names
    ilistNames = retrieve_iListNames(disk);                             //retrieve ilist from disk
    ilistNames[(*fileToWrite).inodeID] = (*fileToWrite).name;           //write the file name to the ilist_names
    write_ilistNames(disk,ilistNames);                                  //write the ilist_names back to disk
    
    //Step 2 - write the parent ID to disk - don't need to write inodeID since ilist_names lists that already
    //get parent directory from disk - parentID is located in diskmap[0] of the file's diskmap
    //need to get the inode associate with the file to get the diskmap
    file_iNode = retrieve_iNode(disk, (*fileToWrite).inodeID);          //get the inode from disk
    (*file_iNode).diskmap[0] = (*fileToWrite).parentID;                 //store parentID in inode's diskmap
    write_iNode(disk,file_iNode, retrieve_ilist(disk)[(*file_iNode).inode_id]);                                       //write the iNode to disk now that parentID is stored
    
    //Step 3 - update parent directory to list this file as a child
    file_iNode = retrieve_iNode(disk, (*fileToWrite).inodeID);          //reusing this variable to retrieve the parent's iNode...
    
    //NEED TO FIGURE OUT INDIRECT BLOCKS HERE
    //block 0 is home directory, block 1-9 are inode ids, block 10 contains indirect 1 for inodes(10-23)
    //inodes 24-34 stored in 0-9 of 2nd indirect diskmap
    //      - 35-48 stored in the inode that is pointed to in block 10 of this inode
    //      - 49-62 in the inode that is in block 11
    //      - 63-76 in the inode that is in block 12
    //third-level indirect...                                                      
    (*file_iNode).diskmap[(*fileToWrite).inodeID] = 1;                  //indicate that this inodeID is a child of the directory
    write_iNode(disk, file_iNode,retrieve_ilist(disk)[(*file_iNode).inode_id]);                         //write the parent directory to disk
}

file *retrieve_file(int disk, char* file_name) {
    int inodeNum;
    file *fileRet = (file*)malloc(sizeof(file));
    iNode *file_iNode = (iNode*)malloc(sizeof(iNode));
    
    char **ilist_names = retrieve_iListNames(disk);
    int *ilist = retrieve_ilist(disk);
    
    //find inode id from ilist_names
    for (inodeNum=0;inodeNum<NUM_INODES;inodeNum++) {
        if (strcmp(ilist_names[inodeNum],file_name)==0) {               //get block that inode is stored in from ilist
            (*fileRet).inodeID=ilist[inodeNum];                         //assign this id to the file structure
            file_iNode = retrieve_iNode(disk, (*fileRet).inodeID);      
            (*fileRet).parentID = (*file_iNode).diskmap[0];             //assign the file's parent inode id to the structure
            (*fileRet).name = file_name;                                //assign the file name to the file structure
            break;
        }
    }
    
    //return newly constructed file that was represented on disk before
    return fileRet;
}

//Directory operations-------------------------------------------------------------------------
//THESE FUNCTIONS ARE NOT FINISHED
//NEED TO INITIALIZE CHILDREN ARRAY
//      IF NOT A CHILD, USE -1, otherwise store 1 to indicate that the inodeID associate with the array index IS a child
int create_dir(int disk, char *dirName, char *parentName) {
    int child;
    
    directory *newDir = (directory*)malloc(sizeof(directory)+sizeof(file));          //initialize a new directory structure
    
    (*newDir).dir.inodeID = create_file(disk, dirName, parentName);     //assign an inode and parentID to this directory
    
    //initialize list of children
    for (child=0; child<NUM_INODES-1; child++) {
        (*newDir).children[child] = -1;
    }
    
    //write the directory to disk
    write_dir(disk, newDir);
    
    return (*newDir).dir.inodeID;
}

void write_dir(int disk, directory *dirToWrite) {
    //
}

directory *retrieve_dir(int disk, char *dir_name);


//Testing Functions
void print_int_array(int *array,int indexMax) {
    int index;
    for (index=0; index<indexMax; index++) {
        if (index==indexMax-1) {
            printf("%i\n-----\n",array[index]);
        } else {
            printf("%i, ",array[index]);
        }
    }
}

void print_char_array(char **array,int indexMax) {
    int index;
    for (index=0; index<indexMax; index++) {
        if (index==indexMax-1) {
            printf("%s\n-----\n",array[index]);
        } else {
            printf("%s, ",array[index]);
        }
    }
}


