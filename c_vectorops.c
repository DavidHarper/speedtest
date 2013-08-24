/***********************************************************************
speedtest : a CPU speed test utility

Copyright (C) 2013 David Harper at obliquity.com

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see [http://www.gnu.org/licenses/].

***********************************************************************/

#include "vectorops.h"
#include <math.h>

static void vectorFPNop(double *a, double *b, double *c, int nsize) {
  int j;
  for (j = nsize; j >0; j--) {
    a++; b++; c++;
  }
}

static void vectorFPSum(double *a, double *b, double *c, int nsize) {
  int j;
  for (j = nsize; j >0; j--)
    *(c++) = *(a++) + *(b++);
}

static void vectorFPMultiply(double *a, double *b, double *c, int nsize) {
  int j;
  for (j = nsize; j >0; j--)
    *(c++) = *(a++) * *(b++);
}

static void vectorFPDivide(double *a, double *b, double *c, int nsize) {
  int j;
  for (j = nsize; j >0; j--)
    *(c++) = *(a++) / *(b++);
}

static void vectorFPSqrt(double *a, double *b, double *c, int nsize) {
  int j;
  for (j = nsize; j >0; j--)
    *(c++) = sqrt(*(a++));
}

static void vectorFPCosine(double *a, double *b, double *c, int nsize) {
  int j;
  for (j = nsize; j >0; j--)
    *(c++) = cos(*(a++));
}

static void vectorFPAtan2(double *a, double *b, double *c, int nsize) {
  int j;
  for (j = nsize; j >0; j--)
    *(c++) = atan2(*(a++), *(b++));
}

static void vectorFPYlogx(double *a, double *b, double *c, int nsize) {
  int j;
  for (j = nsize; j >0; j--)
    *(c++) = *(a++) * log(*(b++));
}

static void vectorFPSincos(double *a, double *b, double *c, int nsize) {
  int j;
  double d;

  for (j = nsize; j >0; j--) {
    d = sin(*a);
    *(c++) = cos(*(a++));
  }
}

static void vectorFPBexp(double *a, double *b, double *c, int nsize) {
  int j;
  for (j = nsize; j >0; j--)
    *(c++) = exp2(*(a++));
}

int vectorOps(void *a, void *b, void *c, int nsize,
	       int niters, int nmode) {
  int j;

  switch (nmode) {
  case VECTOR_FP_NOP:
    for (j = niters; j > 0; j--)
      vectorFPNop((double *)a, (double *)b, (double *)c, nsize);
    break;

  case VECTOR_FP_ADD:
    for (j = niters; j > 0; j--)
      vectorFPSum((double *)a, (double *)b, (double *)c, nsize);
    break;

  case VECTOR_FP_MULTIPLY:
    for (j = niters; j > 0; j--)
      vectorFPMultiply((double *)a, (double *)b, (double *)c, nsize);
    break;

  case VECTOR_FP_DIVIDE:
    for (j = niters; j > 0; j--)
      vectorFPDivide((double *)a, (double *)b, (double *)c, nsize);
    break;

  case VECTOR_FP_SQRT:
    for (j = niters; j > 0; j--)
      vectorFPSqrt((double *)a, (double *)b, (double *)c, nsize);
    break;

  case VECTOR_FP_COSINE:
    for (j = niters; j > 0; j--)
      vectorFPCosine((double *)a, (double *)b, (double *)c, nsize);
    break;

  case VECTOR_FP_ATAN2:
    for (j = niters; j > 0; j--)
      vectorFPAtan2((double *)a, (double *)b, (double *)c, nsize);
    break;

  case VECTOR_FP_YLOGX:
    for (j = niters; j > 0; j--)
      vectorFPYlogx((double *)a, (double *)b, (double *)c, nsize);
    break;

  case VECTOR_FP_SINCOS:
    for (j = niters; j > 0; j--)
      vectorFPSincos((double *)a, (double *)b, (double *)c, nsize);
    break;

  case VECTOR_FP_BEXP:
    for (j = niters; j > 0; j--)
      vectorFPBexp((double *)a, (double *)b, (double *)c, nsize);
    break;

  default:
    return 0;
  }

  return niters;
}
