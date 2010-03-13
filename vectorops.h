#ifndef _VECTOROPS_H
#define _VECTOROPS_H
int vectorOps(double *a, double *b, double *c, int nsize,
	      int niters, int nmode);

#define VECTOR_NOP 0
#define VECTOR_ADD 1
#define VECTOR_MULTIPLY 2
#define VECTOR_DIVIDE 3
#define VECTOR_COSINE 4
#define VECTOR_SQRT 5
#define VECTOR_ATAN2 6
#define VECTOR_YLOGX 7
#define VECTOR_SINCOS 8
#define VECTOR_BEXP 9
#endif
