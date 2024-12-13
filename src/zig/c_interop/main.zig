const std = @import("std");
const c = @cImport({
    @cInclude("external.h");
});

pub fn main() !void {
    // This is unnecessary, for demonstration of comptime condition to check i64 size compared to int64_t (8 bytes)
    // Generally these checks could be useful to make sure that (your custom) Zig types match the C types
    comptime if (@sizeOf(i64) != 8) @panic("i64 size is not 8 bytes!");

    const a: i64 = 1;
    const b: i64 = 2;

    const result = c.external_lib_add_int(a, b);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Result: {d}\n", .{result});
}
