const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

pub const Btns = struct {
    start: bool,
    select: bool,
    b: bool,
    a: bool,
    down: bool,
    up: bool,
    left: bool,
    right: bool,

    pub fn init() Btns {
        return Btns{ .start = false, .select = false, .b = false, .a = false, .down = false, .up = false, .left = false, .right = false };
    }

    pub fn update() void {}

    pub fn readBtns() u8 {}

    pub fn writeBtns() void {}
};
