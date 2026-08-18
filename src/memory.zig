const std = @import("std");
const builtint = @import("builtin");

const vbk: u16 = 0xFF4F;
pub const Game = struct {
    game: [1_000_000]u8,

    pub fn init() Game {
        return Game{ .game = std.mem.zeroes([1_000_000]u8) };
    }
};
pub const Vram = struct {
    vram: [2][0x2000]u8,

    pub fn init() Vram {
        return Vram{ .vram = std.mem.zeroes([2][0x2000]u8) };
    }
};

pub const Ram = struct {
    game: Game,
    vram: Vram,

    pub fn init() Ram {
        return Ram{ .game = Game.init(), .vram = Vram.init() };
    }

    pub fn read(self: *const Ram, address: u16) u8 {
        //here based on the value of index i need to change where to read
        if (builtint.is_test) {
            return self.game.game[@intCast(address)];
        } else {
            switch (address) {
                0x8000...0x9FFF => return self.vramRead(address),
                _ => std.debug.print("memory not addressable\n", .{}),
            }
        }
    }

    pub fn read16(self: *const Ram, address: u16) u16 {
        //here based on the value of index i need to change where to read
        const first: u8 = self.game.game[@intCast(address)];
        const second: u16 = self.game.game[@intCast(address + 1)];
        const result: u16 = (second << 8) | first;
        return result;
    }

    pub fn write(self: *Ram, address: u16, value: u8) void {
        //here based on the value of index i need to change where to read
        self.game.game[@intCast(address)] = value;
    }

    //TODO implemt the 2 differen ways of addressing vram
    fn vramRead(self: *const Ram, address: u16) u8 {
        const vbkValue = self.read(vbk) & 1;
        return self.vram[vbkValue][address];
    }
    fn vramWrite(self: *const Ram, address: u16, value: u8) void {
        const vbkValue = self.read(vbk) & 1;
        self.vram[vbkValue][address] = value;
    }
};
