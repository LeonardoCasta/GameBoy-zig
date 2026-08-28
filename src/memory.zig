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
pub const Wram = struct {
    wram: [8][4096]u8,

    pub fn init() Wram {
        return Wram{ .wram = std.mem.zeroes([8][4096]u8) };
    }

    pub fn read(self: *Wram, address: u16, bank: u8) u8 {
        return self.wram[bank][address];
    }
};

pub const Ram = struct {
    game: Game,
    wram: Wram,
    vram: Vram,
    highRam: [0x7E]u8,
    interruptReg: u1,

    pub fn init() Ram {
        return Ram{ .game = Game.init(), .wram = Wram.init(), .vram = Vram.init(), .highRam = std.mem.zeroes([0x7E]u8), .interruptReg = 0 };
    }

    pub fn read(self: *const Ram, address: u16) u8 {
        //here based on the value of index i need to change where to read
        if (builtint.is_test) {
            return self.game.game[@intCast(address)];
        } else {
            var result: u8 = undefined;
            switch (address) {
                0x0...0x3FFF => {
                    //fixed from cartridge
                },
                0x4000...0x7FFF => {
                    //from cartridge switchable bank
                    //this gonna be a pain to understand and implement all types
                },
                0x8000...0x9FFF => {
                    result = self.vramRead(address);
                },
                0xA000...0xBFFF => {
                    //from cartridge switchable
                },
                0xC000...0xCFFF => {
                    self.wram.read(address, 0);
                },
                0xD000...0xDFFF => {
                    var bank = self.read(constants.vbk);
                    if (bank == 0) {
                        bank = 1;
                    }
                    self.wram.read(address - 0xD000, bank);
                },
                0xE000...0xFDFF => {
                    result = 0;
                    std.debug.print("memory not addressable\n", .{});
                },
                0xFE00...0xFE9F => {
                    //object attribute memory
                },
                0xFEA0...0xFEFF => {
                    result = 0;
                    std.debug.print("memory not addressable\n", .{});
                },
                0xFF00...0xFF7F => {
                    //io registers
                },
                0xFF80...0xFFFE => {
                    result = self.highRam[address - 0xFF80];
                },
                0xFFFF => {
                    //interrupt registers
                    result = self.interruptReg;
                },
                else => std.debug.print("memory not addressable\n", .{}),
            }
            return result;
        }
    }

    pub fn read16(self: *const Ram, address: u16) u16 {
        //here based on the value of index i need to change where to read
        if (builtint.is_test) {
            const first: u8 = self.game.game[@intCast(address)];
            const second: u16 = self.game.game[@intCast(address + 1)];
            const result: u16 = (second << 8) | first;
            return result;
        } else {
            const first: u8 = self.read(@intCast(address));
            const second: u16 = self.read(@intCast(address + 1));
            const result: u16 = (second << 8) | first;
            return result;
        }
    }

    pub fn write(self: *Ram, address: u16, value: u8) void {
        //here based on the value of index i need to change where to read
        if (builtint.is_test) {
            self.game.game[@intCast(address)] = value;
        } else {}
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
