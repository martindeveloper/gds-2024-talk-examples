const std = @import("std");
const mem = std.mem;

fn factorial(n: comptime_int) comptime_int {
    if (n == 0 or n == 1) {
        return 1;
    } else {
        return n * factorial(n - 1);
    }
}

pub fn List(comptime T: type) type {
    return struct {
        const Self = @This();

        _items: []T,
        _len: usize,
        _allocator: mem.Allocator,

        pub fn init(allocator: mem.Allocator) Self {
            return Self{
                ._items = &[_]T{},
                ._len = 0,
                ._allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            if (self._items.len > 0) {
                self._allocator.free(self._items);
            }
        }

        pub fn append(self: *Self, item: T) !void {
            const new_items = try self._allocator.realloc(self._items, self._len + 1);
            new_items[self._len] = item;
            self._items = new_items;
            self._len += 1;
        }

        pub fn get(self: *Self, index: usize) ?T {
            if (index >= self._len) return null;
            return self._items[index];
        }

        pub fn clear(self: *Self) void {
            if (self._len > 0) {
                const new_items = self._allocator.realloc(self._items, 0) catch return;
                self._items = new_items;
                self._len = 0;
            }
        }
    };
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const N = 5;

    // Compute factorial at compile time using 'comptime'
    const result = comptime factorial(N);
    try stdout.print("Factorial of {d} is {d}\n", .{ N, result });

    // Create a 'generic' list of integers at compile time
    var list = List(i32).init(std.heap.page_allocator);
    defer list.deinit();

    try list.append(1);
    try list.append(2);
    try list.append(3);

    try stdout.print("List of integers with length {d} contains: {d}\n", .{ list._len, list._items });
}
