#include "share/atspre_staload.hats"

#define NULL the_null_ptr

typedef rusage = $extype "struct rusage"

extern fun report: (int, &rusage) -> void = "mac#"
extern fun getrusage: (int, &rusage? >> rusage) -> int = "mac#"
extern fun posix_spawn: (&int? >> int, string, ptr, ptr, ptr, ptr) -> int = "mac#"
extern fun waitpid: (int, ptr, int) -> int = "mac#"
extern fun rest: (ptr) -> ptr = "mac#"

fun benchmark(n: int, command: string, args: ptr, environ: ptr): void =
	if n > 0 then {
		var pid: int
		val- 0 = posix_spawn(pid, command, NULL, NULL, args, environ)
		val- pid = waitpid(pid, NULL, 0)
		val () = benchmark(n-1, command, args, environ) 
	}

implement main(argc, argv, envp) =
	if argc > 2 then 0 where {
		val count = g0string2int(argv[1])
		var usage: rusage
		val () = benchmark(count, argv[2], rest($UNSAFE.castvwtp1{ptr}(argv)), envp)
		val- 0 = getrusage($extval(int, "RUSAGE_CHILDREN"), usage)
		val () = report(count, usage)
	} else (
		prerrln!(argv[0], " <n> <command> [<args> ...]");
		1
	)

%{^
#include <sys/time.h>
#include <sys/resource.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <spawn.h>
%}
%{
#define rest(x) &((char**)x)[2]

void report(int count, struct rusage *usage) {
	fprintf(stderr,
		"User time      : %ld s, %ld us\n" \
		"System time    : %ld s, %ld us\n" \
		"Time           : %lld ms (%.3f ms/per)\n" \
		"Max RSS        : %ld kB\n" \
		"Page reclaims  : %ld\n" \
		"Page faults    : %ld\n" \
		"Block inputs   : %ld\n" \
		"Block outputs  : %ld\n" \
		"vol ctx switches   : %ld\n" \
		"invol ctx switches : %ld\n",
		(long int)usage->ru_utime.tv_sec,
		(long int)usage->ru_utime.tv_usec,
		(long int)usage->ru_stime.tv_sec,
		(long int)usage->ru_stime.tv_usec,
		(((usage->ru_utime.tv_usec + usage->ru_stime.tv_usec)/1000) + ((usage->ru_utime.tv_sec + usage->ru_stime.tv_sec)*1000)),
		(((usage->ru_utime.tv_usec + usage->ru_stime.tv_usec)/1000.0) + ((usage->ru_utime.tv_sec + usage->ru_stime.tv_sec)*1000.0))/count,
		usage->ru_maxrss,
		usage->ru_minflt,
		usage->ru_majflt,
		usage->ru_inblock,
		usage->ru_oublock,
		usage->ru_nvcsw,
		usage->ru_nivcsw);
}
%}
