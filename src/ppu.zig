const std = @import("std");

pub const Ppu = struct {
    lcdc: u8,

    pub fn init() Ppu {
        return Ppu{ .lcdc = 0 };
    }

    pub fn setLcdc() void {}
};
