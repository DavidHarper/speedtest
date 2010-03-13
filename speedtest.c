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

static int executeSpeedTest(double *a, double *b, double *c, int nsize,
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
  case VECTOR_ADD:
    opname = "additions";
    break;

  case VECTOR_MULTIPLY:
    opname = "multiplications";
    break;

  case VECTOR_DIVIDE:
    opname = "divisions";
    break;

  case VECTOR_COSINE:
    opname = "cosines";
    break;

  case VECTOR_SQRT:
    opname = "square roots";
    break;

  case VECTOR_ATAN2:
    opname = "arc-tangents";
    break;

  case VECTOR_YLOGX:
    opname = "y.log2(x) operations";
    break;

  case VECTOR_SINCOS:
    opname = "combined sine/cosines";
    break;

  case VECTOR_BEXP:
    opname = "binary exponentials";
    break;

  default:
    opname = "unknown operations";
    break;
  }

  getrusage(RUSAGE_SELF, &ru1);

  rc1 = vectorOps(a, b, c, nsize, niters, mode);

  getrusage(RUSAGE_SELF, &ru2);

  rc2 = vectorOps(a, b, c, nsize, niters, VECTOR_NOP);

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

  return rc1;
}

int main(int argc, char **argv) {
  int nsize = 0;
  int niters = 0;
  double *a, *b, *c;
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

  if (mode >0 && mode < 10) {
    executeSpeedTest(a, b, c, nsize, niters, mode, stdout);
  } else {
    printf("Running ALL speed tests.\n\n");

    for (mode = 1; mode < 10; mode++) {
      if (executeSpeedTest(a, b, c, nsize, niters, mode, stdout) != 0)
	printf("\n");
    }
  }

  return 0;
}
