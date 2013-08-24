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
#define VECTOR_INT64_RANDOM_FETCH 12
#define VECTOR_INT64_STORE 13
#define VECTOR_INT64_FETCH_AND_STORE 14
#define VECTOR_INT64_ADD 15
#define VECTOR_INT64_SUM 16
#define VECTOR_INT64_MULTIPLY 17
#define VECTOR_INT64_DIVIDE 18

#define VECTOR_INT64_FIRST 11
#define VECTOR_INT64_LAST 18

#endif
