const std = @import("std");
const constants = @import("registersConstants.zig");
const builtint = @import("builtin");
const Btns = @import("btns.zig").Btns;

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
    bank: u8,

    pub fn init() Wram {
        return Wram{ .wram = std.mem.zeroes([8][4096]u8), .bank = 0 };
    }

    pub fn read(self: *Wram, address: u16) u8 {
        return self.wram[self.bank][address];
    }

    pub fn write(self: *Wram, address: u16, value: u8) void {
        self.wram[self.bank][address] = value;
    }
};

pub const Ram = struct {
    game: Game,
    wram: Wram,
    vram: Vram,
    highRam: [0x7E]u8,
    btns: *Btns,
    interruptReg: u8,

    pub fn init(btnsRef: *Btns) Ram {
        return Ram{ .game = Game.init(), .wram = Wram.init(), .vram = Vram.init(), .highRam = std.mem.zeroes([0x7E]u8), .btns = btnsRef, .interruptReg = 0 };
    }

    fn unmappedRead() u8 {
        //for now i don't know how to handle unused bytes
        return 0;
    }

    pub fn read(self: *Ram, address: u16) u8 {
        //here based on the value of index i need to change where to read
        var result: u8 = undefined;
        switch (address) {
            0x0...0x3FFF => {
                //fixed from cartridge
                result = self.game.game[@intCast(address)];
            },
            0x4000...0x7FFF => {
                //from cartridge switchable bank
                //this gonna be a pain to understand and implement all types
            },
            0x8000...0x9FFF => {
                result = self.vramRead(address - 0x8000);
            },
            0xA000...0xBFFF => {
                //from cartridge switchable
            },
            0xC000...0xCFFF => {
                _ = self.wram.read(address - 0xC000);
            },
            0xD000...0xDFFF => {
                var bank = self.read(constants.vbk);
                if (bank == 0) {
                    bank = 1;
                }
                _ = self.wram.read(address - 0xD000);
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
                result = self.readWriteIO(address, 0, false);
            },
            0xFF80...0xFFFE => {
                result = self.highRam[address - 0xFF80];
            },
            0xFFFF => {
                //interrupt registers
                result = self.interruptReg;
            },
        }
        return result;
    }

    pub fn read16(self: *Ram, address: u16) u16 {
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
        switch (address) {
            0x0...0x3FFF => {
                //fixed from cartridge
                self.game.game[@intCast(address)] = value;
            },
            0x4000...0x7FFF => {
                //from cartridge switchable bank
                //this gonna be a pain to understand and implement all types
            },
            0x8000...0x9FFF => {
                self.vramWrite(address - 0x8000, value);
            },
            0xA000...0xBFFF => {
                //from cartridge switchable
            },
            0xC000...0xCFFF => {
                _ = self.wram.write(address - 0xC000, value);
            },
            0xD000...0xDFFF => {
                _ = self.wram.write(address - 0xD000, value);
            },
            0xE000...0xFDFF => {
                std.debug.print("memory not addressable\n", .{});
            },
            0xFE00...0xFE9F => {
                //object attribute memory
            },
            0xFEA0...0xFEFF => {
                std.debug.print("memory not addressable\n", .{});
            },
            0xFF00...0xFF7F => {
                //io registers
                _ = self.readWriteIO(address, value, true);
            },
            0xFF80...0xFFFE => {
                self.highRam[address - 0xFF80] = value;
            },
            0xFFFF => {
                //interrupt registers
                self.interruptReg = value;
            },
        }
    }

    //TODO implemt the 2 differen ways of addressing vram
    //implement how to read tiles
    fn vramRead(self: *Ram, address: u16) u8 {
        const vbkValue = self.read(constants.vbk) & 0x01;
        return self.vram.vram[vbkValue][address];
    }
    fn vramWrite(self: *Ram, address: u16, value: u8) void {
        const vbkValue = self.read(constants.vbk) & 0x01;
        self.vram.vram[vbkValue][address] = value;
    }

    //not the best using one for reading and writing but it would be
    //too much having 2 different functions
    fn readWriteIO(self: *Ram, address: u16, value: u8, isWrite: bool) u8 {
        switch (address) {
            0xFF00 => {
                if (isWrite) {
                    self.btns.writeBtns(value);
                    return 0;
                } else {
                    return self.btns.readBtns();
                }
            },
            0xFF70 => {
                if (isWrite) {
                    self.wram.bank = value;
                    return 0;
                } else {
                    return self.wram.bank;
                }
            },
            0xFF04 => {
                //div divider register
            },
            0xFF05 => {
                //tima timer counter
            },
            0xFF06 => {
                //tma timer modulo
            },
            0xFF07 => {
                //tac time control
            },
            else => {
                //FF01 serial transfer not implemented for now
                //FF56 ir post non implemented
                //last bytes and bits must be make read and write
                if (isWrite) {
                    return 0;
                } else {
                    return 0;
                }
            },
        }
    }
};
