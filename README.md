# getrusage() wrapper
- known to work on Linux
- created as my simple "time for x in {1..100}; ..." benchmarks were a lot less pleasant on OpenBSD.

## ATS notes
- this is an ATS translation of the C version at https://github.com/jrfondren/getr
- this version uses pattern-matching for runtime errors if `posix_spawn` et al. fail
- this version 'cheats' the most with its FFI, not even modeling `struct rusage` in-language

## build
```
make
```

## usage and examples
```
$ getr 1000 ./fizzbuzz >/dev/null
User time      : 0 s, 285575 us
System time    : 0 s, 124823 us
Time           : 410 ms (0.410 ms/per)
Max RSS        : 1684 kB
Page reclaims  : 65264
Page faults    : 0
Block inputs   : 0
Block outputs  : 0
vol ctx switches   : 998
invol ctx switches : 32

$ getr 100 $(which python3) -c ''
User time      : 1 s, 455055 us
System time    : 0 s, 282360 us
Time           : 1737 ms (17.374 ms/per)
Max RSS        : 8704 kB
Page reclaims  : 98433
Page faults    : 0
Block inputs   : 0
Block outputs  : 0
vol ctx switches   : 102
invol ctx switches : 19

$ getr 100 $(which perl) -le ''
User time      : 0 s, 95907 us
System time    : 0 s, 51440 us
Time           : 147 ms (1.473 ms/per)
Max RSS        : 5056 kB
Page reclaims  : 22161
Page faults    : 0
Block inputs   : 0
Block outputs  : 0
vol ctx switches   : 103
invol ctx switches : 5
```

## defects and room for improvement
- no $PATH resolution occurs
- output is in an ad-hoc text format that machine consumers would need to parse manually
- only `posix_spawn` is used, but fork&exec might be preferred for timings more like a fork&exec-using application
- this command lacks a manpage
- 'getr' is probably a poor name
- kB and ms are always used even when number ranges might be easier to understand in MB or s, or GB or min:s
