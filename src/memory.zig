const std = @import("std");
const constants = @import("registersConstants.zig");
const builtint = @import("builtin");

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
    highRam: [0x7E]u8,

    pub fn init() Ram {
        return Ram{ .game = Game.init(), .vram = Vram.init(), .highRam = std.mem.zeroes([0x7E]u8) };
    }

    pub fn read(self: *const Ram, address: u16) u8 {
        //here based on the value of index i need to change where to read
        if (builtint.is_test) {
            return self.game.game[@intCast(address)];
        } else {
            var result: u8 = undefined;
            switch (address) {
                0x8000...0x9FFF => {
                    result = self.vramRead(address);
                },
                0xE000...0xFDFF => {
                    result = 0;
                    std.debug.print("memory not addressable\n", .{});
                },
                0xFF80...0xFFFE => {
                    result = self.highRam[address - 0xFF80];
                },
                else => std.debug.print("memory not addressable\n", .{}),
            }
            return result;
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
    //implement how to read tiles
    fn vramRead(self: *const Ram, address: u16) u8 {
        const vbkValue = self.read(constants.vbk) & 0x01;
        return self.vram.vram[vbkValue][address];
    }
    fn vramWrite(self: *const Ram, address: u16, value: u8) void {
        const vbkValue = self.read(constants.vbk) & 0x01;
        self.vram.vram[vbkValue][address] = value;
    }
};
