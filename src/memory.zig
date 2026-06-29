const std = @import("std");
const inst = @import("instructions.zig");

pub const memory = struct {
    game: [1_000_000]u8 = std.mem.zeroes([1000000]u8),
};
