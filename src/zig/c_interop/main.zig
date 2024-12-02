const std = @import("std");
const c = @cImport({
    @cInclude("external.h");
});

pub fn main() !void {
    const a: i64 = 1;
    const b: i64 = 2;

    const result = c.external_lib_add_int(a, b);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Result: {d}\n", .{result});
}
