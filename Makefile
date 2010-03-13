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

c_speedtest: $(SHARED_OBJS) $(C_SPEEDTEST_OBJS)
	$(LD) $(DEBUG) -o $@ $(SHARED_OBJS) $(C_SPEEDTEST_OBJS) $(LDLIBS)

a_speedtest: $(SHARED_OBJS) $(A_SPEEDTEST_OBJS)
	$(LD) $(DEBUG) -o $@ $(SHARED_OBJS) $(A_SPEEDTEST_OBJS)

a_vectorops.s: a_vectorops-$(ARCH).m4
	$(M4) a_vectorops-$(ARCH).m4 > a_vectorops.s

clean:
	$(RM) *.o a_speedtest c_speedtest speedtest.tar.gz

tar: speedtest.tar.gz

speedtest.tar.gz: $(TAR_CONTENTS)
	tar zcvf $@ $(TAR_CONTENTS)
