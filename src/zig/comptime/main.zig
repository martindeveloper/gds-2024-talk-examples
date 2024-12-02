const std = @import("std");

fn factorial(n: comptime_int) comptime_int {
    if (n == 0 or n == 1) {
        return 1;
    } else {
        return n * factorial(n - 1);
    }
}

fn List(comptime T: type) type {
    return struct {
        items: []T,
        len: usize,
    };
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const N = 5;

    // Compute factorial at compile time using 'comptime'
    const result = comptime factorial(N);
    try stdout.print("Factorial of {d} is {d}\n", .{ N, result });

    // Create a list of integers at compile time
    var buffer: [10]i32 = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const list = List(i32){
        .items = &buffer,
        .len = 10,
    };
    try stdout.print("List: {d}\n", .{list.items});
}
