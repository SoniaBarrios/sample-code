//HEADER FILES------------------------------------
#include <stdio.h> //needed for lseek, read, write
#include <fcntl.h> //needed for file control options like O_CREAT
#include <unistd.h>
#include <errno.h>
#include <sys/stat.h>
#include "p242pio.h" //includes prototypes (the interface)

/* openDisk opens a file (filename) for reading and 
 * writing and returns a descriptor used to access
 * the disk. The file size is fixed at nbytes. If 
 * filename does not already exist, openDisk creates 
 * it. */

int existingDiskFlag = 0;

//retrieves the existing disk
//if no disk exists, a new disk is created
//takes the proposed disk's filename and size as input
//returns the descriptor of the disk if successful
//if unsuccessful, returns -1
int openDisk(char *filename, int nbytes) {
    int descriptor; //create descriptor for virtual disk
	long location;
    
    //Checks if the file already exists
    descriptor = open(filename,O_RDWR);
    existingDiskFlag = descriptor;
    
    if (testing==1) {
        if (existingDiskFlag==-1) {
            printf("Disk does not exist.\n");
        } else {
            printf("Disk already exists.\n");
        }
    }
    
    //attempt to open file
    if(descriptor == -1) { 
        //file could not be opened->create file
        descriptor = open(filename, O_RDWR | O_CREAT, 0766);
        //Add the EOF character to the end of file
        location = lseek(descriptor,nbytes,SEEK_SET);
		write(descriptor,"\0",1);
    }
    
    //return the file descriptor
    return descriptor;
}

/* readBlock reads disk block blocknr from the disk 
 * pointed to by disk into a buffer pointed to by block.
 */
int readBlock(int disk, int blocknr, void *block) {
    int offset;
    long location;
    
    //each block is size BLOCK_SIZE
    //calculate byte address (offset)
	offset = blocknr * BLOCK_SIZE;
    
    //set location for read operation
	location = lseek(disk, offset, SEEK_SET);

    //if location can't be found, throw an error
	if (location == -1)
		printf( "Error: %s\n", strerror( errno ) );

    //return number of bytes successfully read
	return (int) read(disk, block, BLOCK_SIZE);
}

/* writeBlock writes the data in block to disk block 
 * blocknr pointed to by disk.
 */
int writeBlock(int disk, int blocknr, void *block) {
    int offset;
    long location;
    
    //each block is size BLOCK_SIZE
    //calculate byte address (offset)
    offset = blocknr * BLOCK_SIZE;
    location = lseek(disk, offset, SEEK_SET);

    //if location can't be found, throw an error
	if (location == -1)
		printf( "Error: %s\n", strerror( errno ) );

    //write data to disk, return number of bytes written to disk
	return (int) write(disk, block, BLOCK_SIZE);
}

/* syncDisk forces all outstanding writes to disk. */
void syncDisk(void) {
    sync();
}

