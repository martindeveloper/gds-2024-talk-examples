const std = @import("std");

const GameEntity = struct {
    allocator: std.mem.Allocator,
    name: []u8,
    position: @Vector(3, f32), // SIMD enabled Vector

    pub fn init(allocator: std.mem.Allocator, i: u64) !*GameEntity {
        // `try` means `if (err != null) return err;`
        const entity = try allocator.create(GameEntity);
        // `errdefer` means if this function returns error in any point, call this function
        errdefer allocator.destroy(entity);

        const name = try std.fmt.allocPrint(allocator, "Entitty {d}", .{i}); // Returns slice []u8(pointer, length)
        errdefer allocator.free(name);

        entity.* = .{ .allocator = allocator, .name = name, .position = .{ 0.0, 0.0, 0.0 } };

        return entity;
    }

    pub fn destroy(self: *GameEntity) void {
        self.allocator.free(self.name);
        self.allocator.destroy(self);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            @panic("Memory leak detected!");
        }
    }

    const entities_len = 10;
    const entities = try allocator.alloc(*GameEntity, entities_len);
    defer allocator.free(entities); // Will be called after the main function

    for (0..entities_len) |i| {
        var entity = try GameEntity.init(allocator, i);
        errdefer entity.destroy();

        const i_float: f32 = @floatFromInt(i);
        entity.position = .{ i_float, i_float, i_float };

        entities[i] = entity;
    }

    // Manual cleanup after program run
    // Defer here is not needed, just for demonstration
    defer {
        for (entities) |entity| {
            std.debug.print("Destroying entity '{s}' (position: {e})\n", .{ entity.name, entity.position });
            entity.destroy(); // Same as `GameEntity.destroy(&entity)`
        }
    }
}
