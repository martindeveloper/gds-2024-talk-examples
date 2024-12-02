const std = @import("std");

pub extern fn odin_lib_init() callconv(.C) void;
pub extern fn odin_lib_destroy() callconv(.C) void;
pub extern fn odin_fav_num() callconv(.C) u32;
pub extern fn odin_says_hello() callconv(.C) [*c]u8;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Hello from Zig!\n", .{});

    // Unnecessary for this example, but often used style in library situations
    odin_lib_init();

    const odin = odin_fav_num();
    const odin_hello = odin_says_hello();
    try stdout.print("Odin says: {s}\n", .{odin_hello});

    odin_lib_destroy();

    try stdout.print("Odin fav num: {d}\n", .{odin});
}
