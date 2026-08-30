const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

pub const Btns = struct {
    // TODO make all keys configurable
    start: bool, // g
    select: bool, // b
    b: bool, // v
    a: bool, // c
    down: bool, // d
    up: bool, // e
    left: bool, // s
    right: bool, // f
    selectBtns: bool,
    selectDpad: bool,

    pub fn init() Btns {
        return Btns{ .start = false, .select = false, .b = false, .a = false, .down = false, .up = false, .left = false, .right = false, .selectBtns = false, .selectDpad = false };
    }

    pub fn update(self: *Btns) void {
        self.start = ray.IsKeyDown(ray.KEY_G);
        self.select = ray.IsKeyDown(ray.KEY_B);
        self.b = ray.IsKeyDown(ray.KEY_V);
        self.a = ray.IsKeyDown(ray.KEY_C);
        self.down = ray.IsKeyDown(ray.KEY_D);
        self.up = ray.IsKeyDown(ray.KEY_E);
        self.left = ray.IsKeyDown(ray.KEY_S);
        self.right = ray.IsKeyDown(ray.KEY_F);
    }

    pub fn readBtns(self: *Btns) u8 {
        var result: u8 = 0;
        if (self.selectDpad == false) {
            result = result | 0x10;
        }
        if (self.selectBtns == false) {
            result = result | 0x20;
        }
        if (self.selectDpad == self.selectBtns) {
            return result;
        }

        if (self.selectDpad == true) {
            if (self.down == false) {
                result = result | 0x8;
            }
            if (self.up == false) {
                result = result | 0x4;
            }
            if (self.left == false) {
                result = result | 0x2;
            }
            if (self.right == false) {
                result = result | 0x1;
            }
            return result;
        }

        if (self.selectBtns == true) {
            if (self.start == false) {
                result = result | 0x8;
            }
            if (self.up == false) {
                result = result | 0x4;
            }
            if (self.b == false) {
                result = result | 0x2;
            }
            if (self.a == false) {
                result = result | 0x1;
            }
            return result;
        }
        return result;
    }

    pub fn writeBtns(self: *Btns, byte: u8) void {
        //when writing i just care about setting these 2
        const sBtn = (byte >> 5) & 0x1;
        const sDpad = (byte >> 4) & 0x1;
        self.selectBtns = if (sBtn == 0) true else false;
        self.selectDpad = if (sDpad == 0) true else false;
    }
};
