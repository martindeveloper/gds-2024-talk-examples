package main

import "base:runtime"
import "core:strings"

@(export)
odin_lib_init :: proc "c" () {
	context = runtime.default_context()
	runtime._startup_runtime()
}

@(export)
odin_lib_destroy :: proc "c" () {
	context = runtime.default_context()
	runtime._cleanup_runtime()
}

@(export)
odin_says_hello :: proc "c" () -> cstring {
	// Because we are in procedure which is C calling convention
	// we need to use runtime.default_context() to create a context for odin procedures
	context = runtime.default_context()

	hello_text := hello()

	// Odin string to C null-terminated string
	return strings.clone_to_cstring(hello_text)
}

@(export)
odin_fav_num :: proc "c" () -> u32 {
	return 50
}
