const std = @import("std");
pub const cpuModule = @import("cpu.zig");
const reg = @import("cpu.zig").reg;
const memoryModule = @import("memory.zig");
const instructionModule = @import("instructions.zig");

pub var cpu: cpuModule.Cpu = undefined;
pub var game: memoryModule.Game = undefined;
pub var ram: memoryModule.Ram = undefined;

pub fn testInit() void {
    cpu = cpuModule.Cpu.init();
    game = memoryModule.Game.init();
    ram = memoryModule.Ram.init();
    instructionModule.init();
}

pub fn init(io: std.Io) void {
    cpu = cpuModule.Cpu.init();
    game = memoryModule.Game.init();
    ram = memoryModule.Ram.init();

    //when testing i dont want to load the file
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
        0x40 => {
            cpu.ld(reg.B, reg.B);
        },
        0x41 => {
            cpu.ld(reg.B, reg.C);
        },
        0x42 => {
            cpu.ld(reg.B, reg.D);
        },
        0x43 => {
            cpu.ld(reg.B, reg.E);
        },
        0x44 => {
            cpu.ld(reg.B, reg.H);
        },
        0x45 => {
            cpu.ld(reg.B, reg.L);
        },
        0x46 => {
            const hlValue = cpu.getHL();
            const value = ram.ram[hlValue];
            cpu.ld_HL(reg.B, value);
        },
        0x47 => {
            cpu.ld(reg.B, reg.A);
        },
        0x48 => {
            cpu.ld(reg.C, reg.B);
        },
        0x49 => {
            cpu.ld(reg.C, reg.C);
        },
        0x4A => {
            cpu.ld(reg.C, reg.D);
        },
        0x4B => {
            cpu.ld(reg.C, reg.E);
        },
        0x4C => {
            cpu.ld(reg.C, reg.H);
        },
        0x4D => {
            cpu.ld(reg.C, reg.L);
        },
        0x4E => {
            const hlValue = cpu.getHL();
            const value = ram.ram[hlValue];
            cpu.ld_HL(reg.C, value);
        },
        0x4F => {
            cpu.ld(reg.C, reg.A);
        },
        0x50 => {
            cpu.ld(reg.D, reg.B);
        },
        0x51 => {
            cpu.ld(reg.D, reg.C);
        },
        0x52 => {
            cpu.ld(reg.D, reg.D);
        },
        0x53 => {
            cpu.ld(reg.D, reg.E);
        },
        0x54 => {
            cpu.ld(reg.D, reg.H);
        },
        0x55 => {
            cpu.ld(reg.D, reg.L);
        },
        0x56 => {
            const hlValue = cpu.getHL();
            const value = ram.ram[hlValue];
            cpu.ld_HL(reg.D, value);
        },
        0x57 => {
            cpu.ld(reg.D, reg.A);
        },
        0x58 => {
            cpu.ld(reg.E, reg.B);
        },
        0x59 => {
            cpu.ld(reg.E, reg.C);
        },
        0x5A => {
            cpu.ld(reg.E, reg.D);
        },
        0x5B => {
            cpu.ld(reg.E, reg.E);
        },
        0x5C => {
            cpu.ld(reg.E, reg.H);
        },
        0x5D => {
            cpu.ld(reg.E, reg.L);
        },
        0x5E => {
            const hlValue = cpu.getHL();
            const value = ram.ram[hlValue];
            cpu.ld_HL(reg.E, value);
        },
        0x5F => {
            cpu.ld(reg.E, reg.A);
        },
        0x60 => {
            cpu.ld(reg.H, reg.B);
        },
        0x61 => {
            cpu.ld(reg.H, reg.C);
        },
        0x62 => {
            cpu.ld(reg.H, reg.D);
        },
        0x63 => {
            cpu.ld(reg.H, reg.E);
        },
        0x64 => {
            cpu.ld(reg.H, reg.H);
        },
        0x65 => {
            cpu.ld(reg.H, reg.L);
        },
        0x66 => {
            const hlValue = cpu.getHL();
            const value = ram.ram[hlValue];
            cpu.ld_HL(reg.H, value);
        },
        0x67 => {
            cpu.ld(reg.H, reg.A);
        },
        0x68 => {
            cpu.ld(reg.L, reg.B);
        },
        0x69 => {
            cpu.ld(reg.L, reg.C);
        },
        0x6A => {
            cpu.ld(reg.L, reg.D);
        },
        0x6B => {
            cpu.ld(reg.L, reg.E);
        },
        0x6C => {
            cpu.ld(reg.L, reg.H);
        },
        0x6D => {
            cpu.ld(reg.L, reg.L);
        },
        0x6E => {
            const hlValue = cpu.getHL();
            const value = ram.ram[hlValue];
            cpu.ld_HL(reg.L, value);
        },
        0x6F => {
            cpu.ld(reg.L, reg.A);
        },
        0x70 => {
            const hlValue = cpu.getHL();
            const register = cpu.getRegister(reg.B);
            ram.ram[hlValue] = register;
        },
        0x71 => {
            const hlValue = cpu.getHL();
            const register = cpu.getRegister(reg.C);
            ram.ram[hlValue] = register;
        },
        0x72 => {
            const hlValue = cpu.getHL();
            const register = cpu.getRegister(reg.D);
            ram.ram[hlValue] = register;
        },
        0x73 => {
            const hlValue = cpu.getHL();
            const register = cpu.getRegister(reg.E);
            ram.ram[hlValue] = register;
        },
        0x74 => {
            const hlValue = cpu.getHL();
            const register = cpu.getRegister(reg.H);
            ram.ram[hlValue] = register;
        },
        0x75 => {
            const hlValue = cpu.getHL();
            const register = cpu.getRegister(reg.L);
            ram.ram[hlValue] = register;
        },
        0x76 => {
            //HALT
        },
        0x77 => {
            const hlValue = cpu.getHL();
            const register = cpu.getRegister(reg.A);
            ram.ram[hlValue] = register;
        },
        0x78 => {
            cpu.ld(reg.A, reg.B);
        },
        0x79 => {
            cpu.ld(reg.A, reg.C);
        },
        0x7A => {
            cpu.ld(reg.A, reg.D);
        },
        0x7B => {
            cpu.ld(reg.A, reg.E);
        },
        0x7C => {
            cpu.ld(reg.A, reg.H);
        },
        0x7D => {
            cpu.ld(reg.A, reg.L);
        },
        0x7E => {
            const hlValue = cpu.getHL();
            const value = ram.ram[hlValue];
            cpu.ld_HL(reg.A, value);
        },
        0x7F => {
            cpu.ld(reg.A, reg.A);
        },
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
        0xA0 => {
            cpu.andA(reg.B);
        },
        0xA1 => {
            cpu.andA(reg.C);
        },
        0xA2 => {
            cpu.andA(reg.D);
        },
        0xA3 => {
            cpu.andA(reg.E);
        },
        0xA4 => {
            cpu.andA(reg.H);
        },
        0xA5 => {
            cpu.andA(reg.L);
        },
        0xA6 => {
            const hlValue = cpu.getHL();
            cpu.andA_HL(ram.ram[hlValue]);
        },
        0xA7 => {
            cpu.andA(reg.A);
        },
        0xA8 => {
            cpu.xorA(reg.B);
        },
        0xA9 => {
            cpu.xorA(reg.C);
        },
        0xAA => {
            cpu.xorA(reg.D);
        },
        0xAB => {
            cpu.xorA(reg.E);
        },
        0xAC => {
            cpu.xorA(reg.H);
        },
        0xAD => {
            cpu.xorA(reg.L);
        },
        0xAE => {
            const hlValue = cpu.getHL();
            cpu.xorA_HL(ram.ram[hlValue]);
        },
        0xAF => {
            cpu.xorA(reg.A);
        },
        0xB0 => {
            cpu.orA(reg.B);
        },
        0xB1 => {
            cpu.orA(reg.C);
        },
        0xB2 => {
            cpu.orA(reg.D);
        },
        0xB3 => {
            cpu.orA(reg.E);
        },
        0xB4 => {
            cpu.orA(reg.H);
        },
        0xB5 => {
            cpu.orA(reg.L);
        },
        0xB6 => {
            const hlValue = cpu.getHL();
            cpu.orA_HL(ram.ram[hlValue]);
        },
        0xB7 => {
            cpu.orA(reg.A);
        },
        0xB8 => {
            cpu.cpA(reg.B);
        },
        0xB9 => {
            cpu.cpA(reg.C);
        },
        0xBA => {
            cpu.cpA(reg.D);
        },
        0xBB => {
            cpu.cpA(reg.E);
        },
        0xBC => {
            cpu.cpA(reg.H);
        },
        0xBD => {
            cpu.cpA(reg.L);
        },
        0xBE => {
            const hlValue = cpu.getHL();
            cpu.cpA_HL(ram.ram[hlValue]);
        },
        0xBF => {
            cpu.cpA(reg.A);
        },
        else => {
            std.debug.print("Instruction not recognized {}\n", .{opcode});
        },
    }
}
