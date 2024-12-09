const std = @import("std");
const expect = std.testing.expect;

pub extern fn odin_lib_init() callconv(.C) void;
pub extern fn odin_lib_destroy() callconv(.C) void;
pub extern fn odin_fav_num() callconv(.C) u32;
pub extern fn odin_says_hello() callconv(.C) [*:0]u8;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello from Zig!\n", .{});

    // Unnecessary for this example, but often used style in library situations
    odin_lib_init();

    const odin = odin_fav_num();
    const odin_hello = odin_says_hello();

    // Following is not necessary, but we are gonna create sentinel slice of unknown amount from C string
    // As we used Odin's cstring we know it is null terminated, let's check it
    const odin_hello_slice = std.mem.span(odin_hello);
    try expect(odin_hello[odin_hello_slice.len] == 0);

    try stdout.print("Odin says: {s}\n", .{odin_hello_slice});

    odin_lib_destroy();

    try stdout.print("Odin fav num: {d}\n", .{odin});
}
