const std = @import("std");

pub const Game = struct {
    game: [1_000_000]u8,

    pub fn init() Game {
        return Game{ .game = std.mem.zeroes([1_000_000]u8) };
    }
};

pub const Ram = struct {
    game: Game,

    pub fn init() Ram {
        return Ram{ .game = Game.init() };
    }

    pub fn read(self: *const Ram, address: u16) u8 {
        //here based on the value of index i need to change where to read
        return self.game.game[@intCast(address)];
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

    //pub fn write16(self: *Ram, address: u16, value: u16) void {
    //    //here based on the value of index i need to change where to read
    //    self.game.game[@intCast(address)] = value;
    //}
};
