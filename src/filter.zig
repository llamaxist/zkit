const std = @import("std");

pub fn filter(
    comptime T: type,
    items: []const T,
    predicate: fn (T) bool,
    allocator: *std.mem.Allocator,
) ![]T {
    var result = std.ArrayList(T).init(allocator.*);
    for (items) |item| {
        if (predicate(item)) {
            try result.append(item);
        }
    }
    return result.toOwnedSlice();
}

test "filter even numbers" {
    var allocator = std.testing.allocator;
    const numbers = [_]i32{ 1, 2, 3, 4, 5 };
    const TestStruct = struct {
        fn isEven(n: i32) bool {
            return @rem(n, 2) == 0;
        }
    };

    const filtered = try filter(i32, numbers[0..], TestStruct.isEven, &allocator);
    defer allocator.free(filtered);

    try std.testing.expect(filtered.len == 2);
    try std.testing.expect(filtered[0] == 2);
    try std.testing.expect(filtered[1] == 4);
}
