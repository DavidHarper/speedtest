#include "vectorops.h"
#include <math.h>

static void vectorNop(double *a, double *b, double *c, int nsize) {
  int j;
  for (j = nsize; j >0; j--) {
    a++; b++; c++;
  }
}

static void vectorSum(double *a, double *b, double *c, int nsize) {
  int j;
  for (j = nsize; j >0; j--)
    *(c++) = *(a++) + *(b++);
}

static void vectorMultiply(double *a, double *b, double *c, int nsize) {
  int j;
  for (j = nsize; j >0; j--)
    *(c++) = *(a++) * *(b++);
}

static void vectorDivide(double *a, double *b, double *c, int nsize) {
  int j;
  for (j = nsize; j >0; j--)
    *(c++) = *(a++) / *(b++);
}

int vectorOps(double *a, double *b, double *c, int nsize,
	       int niters, int nmode) {
  int j;

  switch (nmode) {
  case VECTOR_NOP:
    for (j = niters; j > 0; j--)
      vectorNop(a, b, c, nsize);
    break;

  case VECTOR_ADD:
    for (j = niters; j > 0; j--)
      vectorSum(a, b, c, nsize);
    break;

  case VECTOR_MULTIPLY:
    for (j = niters; j > 0; j--)
      vectorMultiply(a, b, c, nsize);
    break;

  case VECTOR_DIVIDE:
    for (j = niters; j > 0; j--)
      vectorDivide(a, b, c, nsize);
    break;

  default:
    return 0;
  }

  return niters;
}
