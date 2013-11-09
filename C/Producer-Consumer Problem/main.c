//  main.c
//  producer/consumer problem
//
//  Author: Michael Dean
//  S/N :   V00483333
//  CSc 360
//  University of Victoria
//
//  References: http://cs.gmu.edu/~white/CS571/Examples/pthread_examples.html
//              

/*
 *If the buffer is ever full, the producing thread does not add to it.
 *If the buffer is ever empty, the consuming thread does not consume anything.
 *It might help to think of your buffer as a circular array.
 *Make sure your buffer is coherent.  ie. use a mutex!
 *When waiting, use the pthread_cond_wait() function
 *Make sure you signal when the buffer is not full or not empty with pthread_cond_signal()
 *Make sure you compile with the -pthread flag
*/


//HEADER FILES---------------------------------------------------------------
#include <pthread.h>    //pthread API
#include <stdio.h>      //needed for printf
#include <stdlib.h>     //needed for random()
#include <unistd.h>   //needed for sleep()

//DEFINITIONS----------------------------------------------------------------
#define buffSize 32
#define numNumbers 100

//PROTOTYPES-----------------------------------------------------------------
void *producer(void *threadID);
void *consumer(void *threadID);

//GLOBAL DATA----------------------------------------------------------------
int currNumElements = 0;    //current number of elements in buffer
int buffer[buffSize];       //initialize buffer to store data.  The buffer needs to store 32 ints.

int front,rear = 0;

//initialize any mutex/condition variables
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t freeSpace = PTHREAD_COND_INITIALIZER;    //signal when there is space available in buffer
pthread_cond_t openData = PTHREAD_COND_INITIALIZER;     //signal when the buffer has data available to consume

//METHODS--------------------------------------------------------------------
int main() {
    
    //create/start threads
    pthread_t producerThread;
    pthread_t consumerThread;
    
    //int pthread_create(pthread_t *thread, const pthread_attr_t *attr,
    //                   void *(*start_routine)(void*), void *arg);
    pthread_create(&consumerThread,NULL,consumer,NULL);
    pthread_create(&producerThread,NULL,producer,NULL);
    
    //join threads
    pthread_join(consumerThread,NULL);
    
    pthread_exit(NULL);
    
    //return
    return 0;
}

void *producer(void *threadID) {
    int i, x;
    //loop 100 times
    for(i=0;i<numNumbers;i++) {
        pthread_mutex_lock(&mutex);
        if (currNumElements == buffSize) { //buffer is full
            printf("buffer full, waiting...\n");
            pthread_cond_wait(&freeSpace,&mutex); //wait for buffer to not be full
        }//endif
        
        //generate random int between 0 and 99 and add it to the buffer
        x = (int) rand()/(RAND_MAX / numNumbers + 1);
        buffer[rear] = x;
        rear++;
        currNumElements++;
        printf("produced %i\n",x);
        
        pthread_cond_signal(&openData); //signal that the buffer is not empty
        pthread_mutex_unlock(&mutex);   //unlock the mutex, allow other code to access shared data
        
        //sleep either 1 second or 4 seconds.  50% chance for each
        if (x%2 == 0) { //if random number is even
            sleep(1);
        } else {        //if random number is odd
            sleep(4);
        }
        
    } //endloop
    
    pthread_exit(NULL);
}

void *consumer(void *threadID) {
    int i,x;
    
    //loop 100 times
    for(i=0;i<numNumbers;i++) {
        pthread_mutex_lock(&mutex);
        if (currNumElements==0) {//buffer is empty	
            printf("buffer empty, waiting...\n");
            pthread_cond_wait(&openData,&mutex); //wait for buffer not to be empty
        }//endif

        //consume an integer from the buffer
        x = buffer[front];
        front++;
        currNumElements--;
        printf("consumed %d\n",x);
    
        pthread_cond_signal(&freeSpace);    //signal that the buffer has space available
        pthread_mutex_unlock(&mutex);       //unlock the mutex - allow code to access shared data
        
        //sleep either 1 second or 5 seconds.  50% chance for each
        if (x%2 == 0) { //if buffer number is even
            sleep(1);
        } else {        //if buffer number is odd
            sleep(5);
        }   
        
    }//endloop
    
    pthread_exit(NULL);
}