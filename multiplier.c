#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>

#define DEBUG

void end_case(FILE* fptr) {
    printf("deadbeef cap\n");
    fprintf(fptr, "%032x", 0xdeadbeef);
}

// Log the case
void log_multiply(FILE* fptr, int32_t a, int32_t b) {
    int64_t ab = (int64_t)a * (int64_t)b;
    #ifdef DEBUG
    printf("%x times %x is %lx\n", a, b, ab);
    #endif
    // format is a, b, ab_upper, ab_lower
    fprintf(fptr, "%08x%08x%016lx\n", a, b, ab);
}

void specific_multiply(FILE* fptr) {
    // 0 times 0
    log_multiply(fptr, 0, 0);
    log_multiply(fptr, 0, 1);
    log_multiply(fptr, 1, 1);
    log_multiply(fptr, INT32_MAX, 0);
    log_multiply(fptr, INT32_MIN, 0);
    log_multiply(fptr, INT32_MAX, 1);
    log_multiply(fptr, INT32_MIN, 1);
    log_multiply(fptr, INT32_MAX, INT32_MAX);
    log_multiply(fptr, INT32_MIN, INT32_MIN);
    log_multiply(fptr, INT32_MAX, INT32_MIN);
}

void rand_multiply(FILE* fptr) {
    // So we get both.
    int32_t a = RAND_MAX - 2 * rand();
    int32_t b = RAND_MAX - 2 * rand();
    log_multiply(fptr, a, b);
}

// General approach:
// Have some specific cases
// Have some randomized cases
// Put them all into the file
int main() {
    const int SEED = 2;
    const int cases = 0;

    srand(SEED);
    FILE *fptr = fopen("test_cases.vmh", "w");

    specific_multiply(fptr);

    for (int i = 0; i < cases; i++) {
        rand_multiply(fptr);
    }

    end_case(fptr);
}