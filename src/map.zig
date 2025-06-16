const std = @import("std");

pub fn map(
    comptime T: type,
    items: []const T,
    fn_map: fn (T) T,
    allocator: *std.mem.Allocator,
) ![]T {
    var result = try allocator.alloc(T, items.len);
    for (items, 0..) |item, i| {
        result[i] = fn_map(item);
    }
    return result;
}

test "map square numbers" {
    var allocator = std.testing.allocator;
    const numbers = [_]i32{ 1, 2, 3 };

    const TestStruct = struct {
        fn square(n: i32) i32 {
            return n * n;
        }
    };
    const mapped = try map(i32, numbers[0..], TestStruct.square, &allocator);
    defer allocator.free(mapped);

    try std.testing.expect(mapped.len == 3);
    try std.testing.expect(mapped[0] == 1);
    try std.testing.expect(mapped[1] == 4);
    try std.testing.expect(mapped[2] == 9);
}

// test "always fail" {
//     try std.testing.expect(false);
// }
