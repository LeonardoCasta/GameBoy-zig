const std = @import("std");
const cpuModule = @import("cpu.zig");
const memoryModule = @import("memory.zig");
const instructionModule = @import("instructions.zig");

var cpu: cpuModule.Cpu = undefined;
var game: memoryModule.Game = undefined;

pub fn init(io: std.Io) void {
    cpu = cpuModule.Cpu.init();
    game = memoryModule.Game.init();

    _ = std.Io.Dir.readFile(std.Io.Dir.cwd(), io, "./Games/Pokemon", &game.game) catch {
        std.debug.print("Error while opening game file\n", .{});
        return;
    };

    instructionModule.init();
}

pub fn execute() void {
    //extract byte
    const opcode: u8 = game.game[cpu.PC];
    const info = instructionModule.instructionTable[opcode];

    switch (opcode) {
        0x00 => {
            cpu.A = 1;
        },
        0x80 => {
            cpu.A = 1;
        },
        else => {
            std.debug.print("{}{}\n", .{ info.length, info.states });
        },
    }

    std.debug.print("{}{}\n", .{ info.length, info.states });

    std.debug.print("{X}{X}\n", .{ game.game[0], game.game[1] });
}
