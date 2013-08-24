# speedtest : a CPU speed test utility
#
# Copyright (C) 2013 David Harper at obliquity.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see [http://www.gnu.org/licenses/].

# Machine architecture
ARCH ?= x86_64

# Define debug level
#DEBUG = -g

# Define optimisation level
OPTLEVEL = -O3

# Define compiler to be used, and compile-time flags
CC = gcc
CFLAGS = -c $(OPTLEVEL)  $(DEBUG)

# Define linker and link-time flags
LD = gcc
LDLIBS = -lm

# Define file removal command
RM = /bin/rm -f

#define the macro command
M4 = m4

SHARED_OBJS = speedtest.o

A_SPEEDTEST_OBJS = a_vectorops.o

C_SPEEDTEST_OBJS = c_vectorops.o

TAR_CONTENTS = speedtest.c a_vectorops.m4 c_vectorops.c vectorops.h Makefile README

a_speedtest: $(SHARED_OBJS) $(A_SPEEDTEST_OBJS)
	$(LD) $(DEBUG) -o $@ $(SHARED_OBJS) $(A_SPEEDTEST_OBJS)

c_speedtest: $(SHARED_OBJS) $(C_SPEEDTEST_OBJS)
	$(LD) $(DEBUG) -o $@ $(SHARED_OBJS) $(C_SPEEDTEST_OBJS) $(LDLIBS)

a_vectorops.s: a_vectorops-$(ARCH).m4
	$(M4) a_vectorops-$(ARCH).m4 > a_vectorops.s

clean:
	$(RM) *.o a_vectorops.s a_speedtest c_speedtest speedtest.tar.gz

tar: speedtest.tar.gz

speedtest.tar.gz: $(TAR_CONTENTS)
	tar zcvf $@ $(TAR_CONTENTS)
