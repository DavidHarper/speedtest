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
  fprintf(fp, "-mode\t\tMode to test\n\n");
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
  fprintf(fp, "\t 10\tNO-OP\n");
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

static long timeInterval(struct rusage *ru1, struct rusage *ru2) {
  return (1000000L * (long)ru2->ru_utime.tv_sec + (long)ru2->ru_utime.tv_usec) -
    (1000000L * (long)ru1->ru_utime.tv_sec + (long)ru1->ru_utime.tv_usec);
}

static int executeFPSpeedTest(double *a, double *b, double *c, int nsize,
			     int niters, int mode, FILE *fp) {
  struct rusage ru1, ru2, ru3;
  char *opname;
  double mflops;
  long ticks;
  double dticks;
  double dops;
  int rc1, rc2;
  long dt12,dt23;

  switch (mode) {
  case VECTOR_FP_ADD:
    opname = "additions";
    break;

  case VECTOR_FP_MULTIPLY:
    opname = "multiplications";
    break;

  case VECTOR_FP_DIVIDE:
    opname = "divisions";
    break;

  case VECTOR_FP_COSINE:
    opname = "cosines";
    break;

  case VECTOR_FP_SQRT:
    opname = "square roots";
    break;

  case VECTOR_FP_ATAN2:
    opname = "arc-tangents";
    break;

  case VECTOR_FP_YLOGX:
    opname = "y.log2(x) operations";
    break;

  case VECTOR_FP_SINCOS:
    opname = "combined sine/cosines";
    break;

  case VECTOR_FP_BEXP:
    opname = "binary exponentials";
    break;

  default:
    opname = "unknown operations";
    break;
  }

  getrusage(RUSAGE_SELF, &ru1);

  rc1 = vectorOps(a, b, c, nsize, niters, mode);

  getrusage(RUSAGE_SELF, &ru2);

  rc2 = vectorOps(a, b, c, nsize, niters, VECTOR_FP_NOP);

  getrusage(RUSAGE_SELF, &ru3);

  if (rc1 == 0 || rc2 == 0)
    return 0L;

  dt12 = timeInterval(&ru1, &ru2);

  dt23 = timeInterval(&ru2, &ru3);

  ticks = dt12 - dt23;
  dticks = (double)ticks;

  dops = (double)nsize * (double)niters;

  mflops = dops/dticks;

  fprintf(fp, "It took %.3lf seconds to perform %.3lf million %s.\n", dticks/1.0e6, dops/1.0e6, opname);

  fprintf(fp, "That corresponds to %.3lf mflops.\n", mflops);

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
      if (executeFPSpeedTest(a, b, c, nsize, niters, mode, stdout) != 0)
	printf("\n");
    }
  } else {
    executeFPSpeedTest(a, b, c, nsize, niters, mode, stdout);
  }

  free(a);
  free(b);
  free(c);
}


static int executeIntegerSpeedTest(long int *a, long int *b, long int *c, int nsize,
			     int niters, int mode, FILE *fp) {
  struct rusage ru1, ru2, ru3;
  char *opname;
  double mflops;
  long ticks;
  double dticks;
  double dops;
  int rc1, rc2;
  long dt12,dt23;

  switch (mode) {
  case VECTOR_INT64_ADD:
    opname = "add-and-stores";
    break;

  case VECTOR_INT64_SUM:
    opname = "sums";
    break;

  case VECTOR_INT64_MULTIPLY:
    opname = "multiplications";
    break;

  case VECTOR_INT64_DIVIDE:
    opname = "divisions";
    break;

  case VECTOR_INT64_FETCH:
    opname = "sequential fetches";
    break;

  case VECTOR_INT64_RANDOM_FETCH:
    opname = "random fetches";
    break;

  case VECTOR_INT64_STORE:
    opname = "stores";
    break;

  case VECTOR_INT64_FETCH_AND_STORE:
    opname = "fetches and stores";
    break;

  default:
    opname = "unknown operations";
    break;
  }

  getrusage(RUSAGE_SELF, &ru1);

  rc1 = vectorOps(a, b, c, nsize, niters, mode);

  getrusage(RUSAGE_SELF, &ru2);

  rc2 = vectorOps(a, b, c, nsize, niters, VECTOR_INT64_NOP);

  getrusage(RUSAGE_SELF, &ru3);

  if (rc1 == 0 || rc2 == 0)
    return 0L;

  dt12 = timeInterval(&ru1, &ru2);

  dt23 = timeInterval(&ru2, &ru3);

  ticks = dt12 - dt23;
  dticks = (double)ticks;

  dops = (double)nsize * (double)niters;

  mflops = dops/dticks;

  fprintf(fp, "It took %.3lf seconds to perform %.3lf million %s.\n", dticks/1.0e6, dops/1.0e6, opname);

  fprintf(fp, "That corresponds to %.3lf mops.\n", mflops);

  fflush(fp);

  return rc1;
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
      if (executeIntegerSpeedTest(a, b, c, nsize, niters, mode, stdout) != 0)
	printf("\n");
    }
  } else {
    executeIntegerSpeedTest(a, b, c, nsize, niters, mode, stdout);
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

  printMessage();

  while (*(++argv)) {
    if (strcmp(*argv, "-nsize") == 0)
      nsize = atoi(*(++argv));

    if (strcmp(*argv, "-niters") == 0)
      niters = atoi(*(++argv));

    if (strcmp(*argv, "-mode") == 0)
      mode = atoi(*(++argv));
  }

  if (niters == 0 || nsize == 0) {
    printUsage(stderr, "One or more mandatory parameters are missing");
    exit(1);
  }

  if (mode >= VECTOR_FP_NOP && mode <= VECTOR_FP_LAST)
    executeFloatingPointTests(mode, nsize, niters);
  else if (mode >= VECTOR_INT64_NOP && mode <= VECTOR_INT64_LAST)
    executeIntegerTests(mode, nsize, niters);

  return 0;
}


