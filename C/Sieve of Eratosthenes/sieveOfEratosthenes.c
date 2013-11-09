/* File: sieveOfEratosthenes.c */
/* Assignment 4, Summer 2010 for CSc 230 at UVic */
/* Written by Michael Dean */
/* S/N: V00483333 */

/********************************************************/
/* sieveOfEratosthenes.c is a C implementation of the Sieve of	*/
/* Eratosthenes algorithm. The algorithm finds all prime*/
/* numbers up to a desired number. This program			*/
/* implements the algorithm by using an array of size of*/
/* the desired numbers to search, and assigns a 0 to the*/
/* index if it is not a prime, and 1 to the index if it */
/* is a prime. After discovering a prime, the algorithm */
/* then sets all multiples of that prime to indicate	*/
/* that they are therefore not prime numbers.			*/
/********************************************************/

#include <stdio.h>
#define MAXLIST 100 /*possible numbers to test as prime 0->MAXLIST-1 */
#define MAX 100	/*numbers to actually test and print*/

typedef struct {
	int index;
	int array[MAXLIST];
} List;

/*	Inputs: index variable for sieve array
	Results: None
	Side-Effects: Sets initial sieve values & initializes array indices
	Description: Initializes neccessary components for sieve array.
 */
void Initialize(List *sieve) {
}

/*	Inputs: index values for seive and primes arrays
	Results: Fills array "primes". numPrimes is assigned a value.
	Description: Function uses the Sieve of Eratosthenes algorithm to determine
					which indices of sieve array are prime numbers or not.
 */
int FindPrimes(List *sieve, List *primes) {
	return 0;
}

/*	 Inputs: numPrimes, pIdx
	 Results: none
	 Side-Effects:
	 Description:
 */
void PrintPrimes(int numPrimes, List *primes) {
}

/*	Inputs: none
 Results: none
 Side-Effects:
 Description:
 */
int main() {
	List sieve;
	List primes;
	int Howmany;
	sieve.index = 2;
	primes.index = 0;
	Initialize(&sieve);
	Howmany = FindPrimes(&sieve, &primes);
	PrintPrimes(Howmany, &primes);
	return 0;
}
