const std = @import("std");
const cpuModule = @import("cpu.zig");
const reg = @import("cpu.zig").reg;
const memoryModule = @import("memory.zig");
const instructionModule = @import("instructions.zig");

var cpu: cpuModule.Cpu = undefined;
var game: memoryModule.Game = undefined;
var ram: memoryModule.Ram = undefined;

pub fn init(io: std.Io) void {
    cpu = cpuModule.Cpu.init();
    game = memoryModule.Game.init();
    ram = memoryModule.Ram.init();

    _ = std.Io.Dir.readFile(std.Io.Dir.cwd(), io, "./Games/Pokemon", &game.game) catch {
        std.debug.print("Error while opening game file\n", .{});
        return;
    };

    instructionModule.init();
}

pub fn execute() void {
    //extract byte
    const opcode: u8 = game.game[cpu.PC];
    _ = instructionModule.instructionTable[opcode];

    switch (opcode) {
        0x00 => {},
        0x80 => {
            cpu.addA(reg.B);
        },
        0x81 => {
            cpu.addA(reg.C);
        },
        0x82 => {
            cpu.addA(reg.D);
        },
        0x83 => {
            cpu.addA(reg.E);
        },
        0x84 => {
            cpu.addA(reg.H);
        },
        0x85 => {
            cpu.addA(reg.L);
        },
        0x86 => {
            const hlValue = cpu.getHL();
            cpu.addA_HL(ram.ram[hlValue]);
        },
        0x87 => {
            cpu.addA(reg.A);
        },
        0x88 => {
            cpu.adcA(reg.B);
        },
        0x89 => {
            cpu.adcA(reg.C);
        },
        0x8A => {
            cpu.adcA(reg.D);
        },
        0x8B => {
            cpu.adcA(reg.E);
        },
        0x8C => {
            cpu.adcA(reg.H);
        },
        0x8D => {
            cpu.adcA(reg.L);
        },
        0x8E => {
            const hlValue = cpu.getHL();
            cpu.adcA_HL(ram.ram[hlValue]);
        },
        0x8F => {
            cpu.adcA(reg.A);
        },
        0x90 => {
            cpu.subA(reg.B);
        },
        0x91 => {
            cpu.subA(reg.C);
        },
        0x92 => {
            cpu.subA(reg.D);
        },
        0x93 => {
            cpu.subA(reg.E);
        },
        0x94 => {
            cpu.subA(reg.H);
        },
        0x95 => {
            cpu.subA(reg.L);
        },
        0x96 => {
            const hlValue = cpu.getHL();
            cpu.subA_HL(ram.ram[hlValue]);
        },
        0x97 => {
            cpu.sbcA(reg.A);
        },
        0x98 => {
            cpu.sbcA(reg.B);
        },
        0x99 => {
            cpu.sbcA(reg.C);
        },
        0x9A => {
            cpu.sbcA(reg.D);
        },
        0x9B => {
            cpu.sbcA(reg.E);
        },
        0x9C => {
            cpu.sbcA(reg.H);
        },
        0x9D => {
            cpu.sbcA(reg.L);
        },
        0x9E => {
            const hlValue = cpu.getHL();
            cpu.sbcA_HL(ram.ram[hlValue]);
        },
        0x9F => {
            cpu.sbcA(reg.A);
        },
        else => {
            std.debug.print("Instruction not recognized {}\n", .{opcode});
        },
    }
}
