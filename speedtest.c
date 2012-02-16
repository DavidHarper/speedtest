#include <stdlib.h>
#include <unistd.h>
#include <sys/times.h>
#include <stdio.h>
#include <string.h>
#include <sys/resource.h>

#include "vectorops.h"

static void printUsage(FILE *fp, char *message) {
  if (message)
    fprintf(fp, "An error occurred: %s\n\n", message);

  fprintf(fp, "MANDATORY PARAMETERS:\n");
  fprintf(fp, "-nsize\t\tSize of data vectors\n");
  fprintf(fp, "-niters\t\tNumber of iterations over the data vectors\n");
  fprintf(fp, "\n");
  fprintf(fp, "OPTIONAL PARAMETERS:\n");
  fprintf(fp, "-mode\t\tMode to test\n");
  fprintf(fp, "-quiet\t\tKeep output to a minimum\n\n");
  fprintf(fp, "\tFLOATING POINT\n");
  fprintf(fp, "\tMode\tOperation\n");
  fprintf(fp, "\t  1\tADD\n");
  fprintf(fp, "\t  2\tMULTIPLY\n");
  fprintf(fp, "\t  3\tDIVIDE\n");
  fprintf(fp, "\t  4\tCOSINE\n");
  fprintf(fp, "\t  5\tSQRT\n");
  fprintf(fp, "\t  6\tATAN2\n");
  fprintf(fp, "\t  7\tY LOG2(X)\n");
  fprintf(fp, "\t  8\tSINCOS\n");
  fprintf(fp, "\t  9\t2^X - 1\n");
  fprintf(fp, "\n");
  fprintf(fp, "\tINTEGER\n");
  fprintf(fp, "\tMode\tOperation\n");
  fprintf(fp, "\t 11\tFETCH\n");
  fprintf(fp, "\t 12\tRANDOM FETCH\n");
  fprintf(fp, "\t 13\tSTORE\n");
  fprintf(fp, "\t 14\tFETCH AND STORE\n");
  fprintf(fp, "\t 15\tADD\n");
  fprintf(fp, "\t 16\tSUM\n");
  fprintf(fp, "\t 17\tMULTIPLY\n");
  fprintf(fp, "\t 18\tDIVIDE\n");

}

static void printMessage() {
  printf("This is a CPU speed test program which is designed to report\n");
  printf("your processor's floating-point performance in megaflops.\n\n");
  printf("It gives the most reliable results for the Intel and AMD families\n");
  printf("of processors, because the timing loop for these devices is written\n");
  printf("in assembler code, but there is an architecture-independent\n");
  printf("version which will run on any CPU.  However, the results reported by\n");
  printf("the generic version are heavily dependent on the optimisation performed\n");
  printf("by the compiler!\n");
  printf("\nThis software was written by David Harper at obliquity.com\n");
  printf("If you find it useful, please give due credit to the author.\n\n");
}

static long getElapsedUserTime(struct rusage *ru) {
  return (1000000L * (long)ru->ru_utime.tv_sec + (long)ru->ru_utime.tv_usec);
}

static long getElapsedSystemTime(struct rusage *ru) {
  return (1000000L * (long)ru->ru_stime.tv_sec + (long)ru->ru_stime.tv_usec);
}

static char *getNameFromMode(int mode) {
  switch (mode) {
  case VECTOR_FP_ADD:
    return "additions";

  case VECTOR_FP_MULTIPLY:
    return "multiplications";

  case VECTOR_FP_DIVIDE:
    return "divisions";

  case VECTOR_FP_COSINE:
    return "cosines";

  case VECTOR_FP_SQRT:
    return "square roots";
 
  case VECTOR_FP_ATAN2:
    return "arc-tangents";

  case VECTOR_FP_YLOGX:
    return "y.log2(x) operations";
 
  case VECTOR_FP_SINCOS:
    return "combined sine/cosines";
 
  case VECTOR_FP_BEXP:
    return "binary exponentials";
 
  case VECTOR_INT64_ADD:
    return "add-and-stores";

  case VECTOR_INT64_SUM:
    return "sums";

  case VECTOR_INT64_MULTIPLY:
    return "multiplications";

  case VECTOR_INT64_DIVIDE:
    return "divisions";

  case VECTOR_INT64_FETCH:
    return "sequential fetches";

  case VECTOR_INT64_RANDOM_FETCH:
    return "random fetches";

  case VECTOR_INT64_STORE:
    return "stores";

  case VECTOR_INT64_FETCH_AND_STORE:
    return "fetches and stores";

  default:
    return "unknown operations";
  }
}

static int executeSpeedTest(void *a, void *b, void *c, int nsize,
			     int niters, int mode, FILE *fp) {
  struct rusage ru1, ru2, ru3;
  char *opname = getNameFromMode(mode);
  double mflops;
  long ticks;
  double dticks;
  double dops;
  int rc1, rc2;
  long dt12,dt23;
  long ut1, ut2, ut3, st1, st2, st3;

  getrusage(RUSAGE_SELF, &ru1);

  rc1 = vectorOps(a, b, c, nsize, niters, mode);

  getrusage(RUSAGE_SELF, &ru2);

  rc2 = vectorOps(a, b, c, nsize, niters, VECTOR_FP_NOP);

  getrusage(RUSAGE_SELF, &ru3);

  if (rc1 == 0 || rc2 == 0)
    return 0L;

  ut1 = getElapsedUserTime(&ru1);
  st1 = getElapsedSystemTime(&ru1);

  fprintf(fp, "Before loop: user %12ld, system %12ld\n", ut1, st1);

  ut2 = getElapsedUserTime(&ru2);
  st2 = getElapsedSystemTime(&ru2);

  fprintf(fp, "After loop:  user %12ld, system %12ld\n", ut2, st2);

  ut3 = getElapsedUserTime(&ru3);
  st3 = getElapsedSystemTime(&ru3);

  fprintf(fp, "After nops:  user %12ld, system %12ld\n", ut3, st3);

  dt12 = ut2 - ut1;

  dt23 = ut3 - ut2;

  ticks = dt12 - dt23;
  dticks = (double)ticks;

  dops = (double)nsize * (double)niters;

  mflops = dops/dticks;

  fprintf(fp, "\n");

  fprintf(fp, "It took %.3lf seconds to perform %.3lf million %s.\n", dticks/1.0e6, dops/1.0e6, opname);

  fprintf(fp, "That corresponds to %.3lf million ops/second.\n", mflops);

  fflush(fp);

  return rc1;
}

static void executeFloatingPointTests(int mode, int nsize, int niters) {
  double *a, *b, *c;
  int j;

  printf("EXECUTING FLOATING POINT SPEED TESTS\n");

  printf("Allocating data arrays ...");
  fflush(stdout);

  a = (double *)calloc((size_t)nsize, sizeof(double));
  b = (double *)calloc((size_t)nsize, sizeof(double));
  c = (double *)calloc((size_t)nsize, sizeof(double));

  printf(" done.\nSetting input arrays to random number ...");
  fflush(stdout);

  for (j = 0; j < nsize; j++) {
    a[j] = drand48();
    b[j] = drand48();
  }

  printf(" done.\n\n");
  fflush(stdout);

  if (mode == VECTOR_FP_NOP) {
    printf("Running ALL speed tests.\n\n");

    for (mode = VECTOR_FP_FIRST; mode <= VECTOR_FP_LAST; mode++) {
      if (executeSpeedTest(a, b, c, nsize, niters, mode, stdout) != 0)
	printf("\n");
    }
  } else {
    executeSpeedTest(a, b, c, nsize, niters, mode, stdout);
  }

  free(a);
  free(b);
  free(c);
}

static void executeIntegerTests(int mode, int nsize, int niters) {
  long int *a, *b, *c;
  int j;
  long l;

  printf("EXECUTING INTEGER SPEED TESTS\n");

  printf("Allocating data arrays ...");
  fflush(stdout);

  a = (long int *)calloc((size_t)nsize, sizeof(long int));
  b = (long int *)calloc((size_t)nsize, sizeof(long int));
  c = (long int *)calloc((size_t)nsize, sizeof(long int));

  printf(" done.\nSetting input arrays to random number ...");
  fflush(stdout);

  for (j = 0; j < nsize; j++) {
    a[j] = lrand48() % nsize;

    l = lrand48();

    b[j] = l == 0 ? 1 : l;
  }

  printf(" done.\n\n");
  fflush(stdout);

  if (mode == VECTOR_INT64_NOP) {
    printf("Running ALL speed tests.\n\n");

    for (mode = VECTOR_INT64_FIRST; mode <= VECTOR_INT64_LAST; mode++) {
      if (executeSpeedTest(a, b, c, nsize, niters, mode, stdout) != 0)
	printf("\n");
    }
  } else {
    executeSpeedTest(a, b, c, nsize, niters, mode, stdout);
  }

  free(a);
  free(b);
  free(c);
}

int main(int argc, char **argv) {
  int nsize = 0;
  int niters = 0;
  int j;
  int mode = 0;
  int quiet = 0;

  while (*(++argv)) {
    if (strcmp(*argv, "-nsize") == 0)
      nsize = atoi(*(++argv));

    if (strcmp(*argv, "-niters") == 0)
      niters = atoi(*(++argv));

    if (strcmp(*argv, "-mode") == 0)
      mode = atoi(*(++argv));

    if (strcmp(*argv, "-quiet") == 0)
      quiet = 1;
  }

  if (niters == 0 || nsize == 0) {
    printUsage(stderr, "One or more mandatory parameters are missing");
    exit(1);
  }

  if (!quiet)
    printMessage();

  if (mode >= VECTOR_FP_NOP && mode <= VECTOR_FP_LAST)
    executeFloatingPointTests(mode, nsize, niters);
  else if (mode >= VECTOR_INT64_NOP && mode <= VECTOR_INT64_LAST)
    executeIntegerTests(mode, nsize, niters);

  return 0;
}


