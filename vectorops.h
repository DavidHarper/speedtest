#ifndef _VECTOROPS_H
#define _VECTOROPS_H
int vectorOps(void *a, void *b, void *c, int nsize,
	      int niters, int nmode);

#define VECTOR_FP_NOP 0
#define VECTOR_FP_ADD 1
#define VECTOR_FP_MULTIPLY 2
#define VECTOR_FP_DIVIDE 3
#define VECTOR_FP_COSINE 4
#define VECTOR_FP_SQRT 5
#define VECTOR_FP_ATAN2 6
#define VECTOR_FP_YLOGX 7
#define VECTOR_FP_SINCOS 8
#define VECTOR_FP_BEXP 9

#define VECTOR_FP_FIRST 1
#define VECTOR_FP_LAST 9

#define VECTOR_INT64_NOP 10
#define VECTOR_INT64_FETCH 11
#define VECTOR_INT64_STORE 12
#define VECTOR_INT64_FETCH_AND_STORE 13
#define VECTOR_INT64_ADD 14
#define VECTOR_INT64_SUM 15
#define VECTOR_INT64_MULTIPLY 16
#define VECTOR_INT64_DIVIDE 17

#define VECTOR_INT64_FIRST 11
#define VECTOR_INT64_LAST 17

#endif
