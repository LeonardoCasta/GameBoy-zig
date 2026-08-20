const std = @import("std");
pub const cpuModule = @import("cpu.zig");
const reg = @import("cpu.zig").reg;
const reg16 = @import("cpu.zig").reg16;
const memoryModule = @import("memory.zig");
const instructionModule = @import("instructions.zig");

pub var cpu: cpuModule.Cpu = undefined;
pub var ram: memoryModule.Ram = undefined;
pub var ei: u8 = 0;
pub var isJp: bool = false;

pub fn testInit() void {
    cpu = cpuModule.Cpu.init();
    ram = memoryModule.Ram.init();
    instructionModule.init();
}

pub fn init(io: std.Io) void {
    cpu = cpuModule.Cpu.init();
    ram = memoryModule.Ram.init();

    //when testing i dont want to load the file
    _ = std.Io.Dir.readFile(std.Io.Dir.cwd(), io, "./Games/Pokemon", &ram.game.game) catch {
        std.debug.print("Error while opening game file\n", .{});
        return;
    };

    instructionModule.init();
}

pub fn execute() void {
    var opcode: u8 = ram.read(cpu.PC);
    var jump: i32 = 0;
    const info = instructionModule.base[opcode];

    if (opcode == 0xCB) {
        opcode = ram.read(cpu.PC + 1);
    }
    switch (opcode) {
        0x00 => {},
        0x01 => {
            const value: u16 = ram.read16(cpu.PC + 1);
            cpu.ld_r16_n16(reg16.BC, value);
        },
        0x02 => {
            const address = cpu.getBC();
            const value = cpu.getRegister(reg.A);
            ram.write(address, value);
        },
        0x03 => {
            const value = cpu.getBC() + 1;
            cpu.setBC(value);
        },
        0x04 => {
            cpu.inc(reg.B);
        },
        0x05 => {
            cpu.dec(reg.B);
        },
        0x06 => {
            const value = ram.read(cpu.PC + 1);
            cpu.setRegister(reg.B, value);
        },
        0x07 => {
            cpu.rlc(reg.A, true);
        },
        0x08 => {
            const sp = cpu.getSP();
            const address = ram.read16(cpu.PC + 1);
            const first: u8 = @truncate(sp & 0xFF);
            const second: u8 = @truncate(sp >> 8);
            ram.write(address, first);
            ram.write(address + 1, second);
        },
        0x09 => {
            cpu.add_HL_r16(cpu.getBC());
        },
        0x0A => {
            const address = cpu.getBC();
            const value = ram.read(address);
            cpu.setRegister(reg.A, value);
        },
        0x0B => {
            const value = cpu.getBC() - 1;
            cpu.setBC(value);
        },
        0x0C => {
            cpu.inc(reg.C);
        },
        0x0D => {
            cpu.dec(reg.C);
        },
        0x0E => {
            const value = ram.read(cpu.PC + 1);
            cpu.setRegister(reg.C, value);
        },
        0x0F => {
            cpu.rrc(reg.A, true);
        },
        0x10 => {},
        0x11 => {
            const value: u16 = ram.read16(cpu.PC + 1);
            cpu.ld_r16_n16(reg16.DE, value);
        },
        0x12 => {
            const address = cpu.getDE();
            const value = cpu.getRegister(reg.A);
            ram.write(address, value);
        },
        0x13 => {
            const value = cpu.getDE() + 1;
            cpu.setDE(value);
        },
        0x14 => {
            cpu.inc(reg.D);
        },
        0x15 => {
            cpu.dec(reg.D);
        },
        0x16 => {
            const value = ram.read(cpu.PC + 1);
            cpu.setRegister(reg.D, value);
        },
        0x17 => {
            cpu.rl(reg.A, true);
        },
        0x18 => {
            const uJump = ram.read(cpu.PC + 1);
            jump = @as(i32, @intCast(uJump));
        },
        0x19 => {
            cpu.add_HL_r16(cpu.getDE());
        },
        0x1A => {
            const address = cpu.getDE();
            const value = ram.read(address);
            cpu.setRegister(reg.A, value);
        },
        0x1B => {
            const value = cpu.getDE() - 1;
            cpu.setDE(value);
        },
        0x1C => {
            cpu.inc(reg.E);
        },
        0x1D => {
            cpu.dec(reg.E);
        },
        0x1E => {
            const value = ram.read(cpu.PC + 1);
            cpu.setRegister(reg.E, value);
        },
        0x1F => {
            cpu.rr(reg.A, true);
        },
        0x20 => {
            const z = cpu.getZ();
            if (z == 0) {
                const uJump = ram.read(cpu.PC + 1);
                jump = @as(i32, @intCast(uJump));
            }
        },
        0x21 => {
            const value: u16 = ram.read16(cpu.PC + 1);
            cpu.ld_r16_n16(reg16.HL, value);
        },
        0x22 => {
            const address = cpu.getHL();
            const value = cpu.getRegister(reg.A);
            ram.write(address, value);
            cpu.setHL(address + 1);
        },
        0x23 => {
            const value = cpu.getHL() + 1;
            cpu.setHL(value);
        },
        0x24 => {
            cpu.inc(reg.H);
        },
        0x25 => {
            cpu.dec(reg.H);
        },
        0x26 => {
            const value = ram.read(cpu.PC + 1);
            cpu.setRegister(reg.H, value);
        },
        0x27 => {
            cpu.daa();
        },
        0x28 => {
            const z = cpu.getZ();
            if (z == 1) {
                const uJump = ram.read(cpu.PC + 1);
                jump = @as(i32, @intCast(uJump));
            }
        },
        0x29 => {
            cpu.add_HL_r16(cpu.getHL());
        },
        0x2A => {
            const address = cpu.getHL();
            const value = ram.read(address);
            cpu.setRegister(reg.A, value);
            cpu.setHL(address + 1);
        },
        0x2B => {
            const value = cpu.getHL() - 1;
            cpu.setHL(value);
        },
        0x2C => {
            cpu.inc(reg.L);
        },
        0x2D => {
            cpu.dec(reg.L);
        },
        0x2E => {
            const value = ram.read(cpu.PC + 1);
            cpu.setRegister(reg.L, value);
        },
        0x2F => {
            cpu.cpl();
        },
        0x30 => {
            const c = cpu.getC();
            if (c == 0) {
                const uJump = ram.read(cpu.PC + 1);
                jump = @as(i32, @intCast(uJump));
            }
        },
        0x31 => {
            const value: u16 = ram.read16(cpu.PC + 1);
            cpu.ld_r16_n16(reg16.SP, value);
        },
        0x32 => {
            const address = cpu.getHL();
            const value = cpu.getRegister(reg.A);
            ram.write(address, value);
            cpu.setHL(address - 1);
        },
        0x33 => {
            const value = cpu.getSP() + 1;
            cpu.setSP(value);
        },
        0x34 => {
            const address = cpu.getHL();
            const value = ram.read(address);
            ram.write(address, cpu.incHL(value));
        },
        0x35 => {
            const address = cpu.getHL();
            const value = ram.read(address);
            ram.write(address, cpu.decHL(value));
        },
        0x36 => {
            const value = ram.read(cpu.PC + 1);
            const address = cpu.getHL();
            ram.write(address, value);
        },
        0x37 => {
            cpu.scf();
        },
        0x38 => {
            const c = cpu.getC();
            if (c == 1) {
                const uJump = ram.read(cpu.PC + 1);
                jump = @as(i32, @intCast(uJump));
            }
        },
        0x39 => {
            cpu.add_HL_r16(cpu.getSP());
        },
        0x3A => {
            const address = cpu.getHL();
            const value = ram.read(address);
            cpu.setRegister(reg.A, value);
            cpu.setHL(address - 1);
        },
        0x3B => {
            const value = cpu.getSP() - 1;
            cpu.setSP(value);
        },
        0x3C => {
            cpu.inc(reg.A);
        },
        0x3D => {
            cpu.dec(reg.A);
        },
        0x3E => {
            const value = ram.read(cpu.PC + 1);
            cpu.setRegister(reg.A, value);
        },
        0x3F => {
            cpu.ccf();
        },
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
            const value = ram.read(hlValue);
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
            const value = ram.read(hlValue);
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
            const value = ram.read(hlValue);
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
            const value = ram.read(hlValue);
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
            const value = ram.read(hlValue);
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
            const value = ram.read(hlValue);
            cpu.ld_HL(reg.L, value);
        },
        0x6F => {
            cpu.ld(reg.L, reg.A);
        },
        0x70 => {
            const hlValue = cpu.getHL();
            const register = cpu.getRegister(reg.B);
            ram.write(hlValue, register);
        },
        0x71 => {
            const hlValue = cpu.getHL();
            const register = cpu.getRegister(reg.C);
            ram.write(hlValue, register);
        },
        0x72 => {
            const hlValue = cpu.getHL();
            const register = cpu.getRegister(reg.D);
            ram.write(hlValue, register);
        },
        0x73 => {
            const hlValue = cpu.getHL();
            const register = cpu.getRegister(reg.E);
            ram.write(hlValue, register);
        },
        0x74 => {
            const hlValue = cpu.getHL();
            const register = cpu.getRegister(reg.H);
            ram.write(hlValue, register);
        },
        0x75 => {
            const hlValue = cpu.getHL();
            const register = cpu.getRegister(reg.L);
            ram.write(hlValue, register);
        },
        0x76 => {
            //HALT
        },
        0x77 => {
            const hlValue = cpu.getHL();
            const register = cpu.getRegister(reg.A);
            ram.write(hlValue, register);
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
            const value = ram.read(hlValue);
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
            cpu.addA_HL(ram.read(hlValue));
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
            cpu.adcA_HL(ram.read(hlValue));
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
            cpu.subA_HL(ram.read(hlValue));
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
            cpu.sbcA_HL(ram.read(hlValue));
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
            cpu.andA_HL(ram.read(hlValue));
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
            cpu.xorA_HL(ram.read(hlValue));
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
            cpu.orA_HL(ram.read(hlValue));
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
            cpu.cpA_HL(ram.read(hlValue));
        },
        0xBF => {
            cpu.cpA(reg.A);
        },
        0xC0 => {
            const z = cpu.getZ();
            if (z == 0) {
                const first: u16 = @as(u16, ram.read(cpu.SP));
                cpu.incSP();
                const second: u16 = @as(u16, ram.read(cpu.SP));
                cpu.incSP();
                const result: u16 = first << 8 | second;
                cpu.PC = result;
                isJp = true;
            }
        },
        0xC1 => {
            cpu.setRegister(reg.C, ram.read(cpu.SP));
            cpu.incSP();
            cpu.setRegister(reg.B, ram.read(cpu.SP));
            cpu.incSP();
        },
        0xC2 => {
            const z = cpu.getZ();
            if (z == 0) {
                const newAddress = ram.read16(cpu.PC + 1);
                cpu.PC = newAddress;
                isJp = true;
            }
        },
        0xC3 => {
            const newAddress = ram.read16(cpu.PC + 1);
            cpu.PC = newAddress;
            isJp = true;
        },
        0xC4 => {
            const z = cpu.getZ();
            if (z == 0) {
                const addressToBePushed: u16 = cpu.PC + 3;
                const first: u8 = @truncate(addressToBePushed & 0xFF00); //high bits
                const second: u8 = @truncate((addressToBePushed & 0x00FF) >> 8); //low bits
                cpu.decSP();
                ram.write(cpu.SP, first);
                cpu.decSP();
                ram.write(cpu.SP, second);

                const newAddress: u16 = ram.read16(cpu.PC + 1);
                cpu.PC = newAddress;
                isJp = true;
            }
        },
        0xC5 => {
            cpu.decSP();
            ram.write(cpu.SP, cpu.getRegister(reg.B));
            cpu.decSP();
            ram.write(cpu.SP, cpu.getRegister(reg.C));
        },
        0xC6 => {
            cpu.addA_r8(ram.read(cpu.PC + 1));
        },
        0xC7 => {
            rst(&cpu, 0x0);
            isJp = true;
        },
        0xC8 => {
            const z = cpu.getZ();
            if (z == 1) {
                const first: u16 = @as(u16, ram.read(cpu.SP));
                cpu.incSP();
                const second: u16 = @as(u16, ram.read(cpu.SP));
                cpu.incSP();
                const result: u16 = first << 8 & second;
                cpu.PC = result;
            }
        },
        0xC9 => {
            const first: u16 = @as(u16, ram.read(cpu.SP));
            cpu.incSP();
            const second: u16 = @as(u16, ram.read(cpu.SP));
            cpu.incSP();
            const result: u16 = first << 8 & second;
            cpu.PC = result;
        },
        0xCA => {
            const z = cpu.getZ();
            if (z == 1) {
                const newAddress = ram.read16(cpu.PC + 1);
                cpu.PC = newAddress;
                isJp = true;
            }
        },
        0xCB => {},
        0xCC => {
            const z = cpu.getZ();
            if (z == 1) {
                const addressToBePushed: u16 = cpu.PC + 3;
                const first: u8 = @truncate(addressToBePushed & 0xFF00); //high bits
                const second: u8 = @truncate((addressToBePushed & 0x00FF) >> 8); //low bits
                cpu.decSP();
                ram.write(cpu.SP, first);
                cpu.decSP();
                ram.write(cpu.SP, second);

                const newAddress: u16 = ram.read16(cpu.PC + 1);
                cpu.PC = newAddress;
                isJp = true;
            }
        },
        0xCD => {
            const addressToBePushed: u16 = cpu.PC + 3;
            const first: u8 = @truncate(addressToBePushed & 0xFF00); //high bits
            const second: u8 = @truncate((addressToBePushed & 0x00FF) >> 8); //low bits
            cpu.decSP();
            ram.write(cpu.SP, first);
            cpu.decSP();
            ram.write(cpu.SP, second);

            const newAddress: u16 = ram.read16(cpu.PC + 1);
            cpu.PC = newAddress;
            isJp = true;
        },
        0xCE => {
            cpu.addA_r8(ram.read(cpu.PC + 1));
        },
        0xCF => {
            rst(&cpu, 0x8);
            isJp = true;
        },
        0xD0 => {
            const c = cpu.getC();
            if (c == 0) {
                const first: u16 = @as(u16, ram.read(cpu.SP));
                cpu.incSP();
                const second: u16 = @as(u16, ram.read(cpu.SP));
                cpu.incSP();
                const result: u16 = first << 8 & second;
                cpu.PC = result;
                isJp = true;
            }
        },
        0xD1 => {
            cpu.setRegister(reg.E, ram.read(cpu.SP));
            cpu.incSP();
            cpu.setRegister(reg.D, ram.read(cpu.SP));
            cpu.incSP();
        },
        0xD2 => {
            const c = cpu.getC();
            if (c == 0) {
                const newAddress = ram.read16(cpu.PC + 1);
                cpu.PC = newAddress;
                isJp = true;
            }
        },
        0xD3 => {},
        0xD4 => {
            const c = cpu.getC();
            if (c == 0) {
                const addressToBePushed: u16 = cpu.PC + 3;
                const first: u8 = @truncate(addressToBePushed & 0xFF00); //high bits
                const second: u8 = @truncate((addressToBePushed & 0x00FF) >> 8); //low bits
                cpu.decSP();
                ram.write(cpu.SP, first);
                cpu.decSP();
                ram.write(cpu.SP, second);

                const newAddress: u16 = ram.read16(cpu.PC + 1);
                cpu.PC = newAddress;
                isJp = true;
            }
        },
        0xD5 => {
            cpu.decSP();
            ram.write(cpu.SP, cpu.getRegister(reg.D));
            cpu.decSP();
            ram.write(cpu.SP, cpu.getRegister(reg.E));
        },
        0xD6 => {
            cpu.subA_r8(ram.read(cpu.PC + 1));
        },
        0xD7 => {
            rst(&cpu, 0x10);
            isJp = true;
        },
        0xD8 => {
            const c = cpu.getC();
            if (c == 1) {
                const first: u16 = @as(u16, ram.read(cpu.SP));
                cpu.incSP();
                const second: u16 = @as(u16, ram.read(cpu.SP));
                cpu.incSP();
                const result: u16 = first << 8 & second;
                cpu.PC = result;
                isJp = true;
            }
        },
        0xD9 => {
            //exe EI then do a RET instruction
            ei = 2;
            const first: u16 = @as(u16, ram.read(cpu.SP));
            cpu.incSP();
            const second: u16 = @as(u16, ram.read(cpu.SP));
            cpu.incSP();
            const result: u16 = first << 8 & second;
            cpu.PC = result;
            isJp = true;
        },
        0xDA => {
            const c = cpu.getC();
            if (c == 1) {
                const newAddress = ram.read16(cpu.PC + 1);
                cpu.PC = newAddress;
                isJp = true;
            }
        },
        0xDB => {},
        0xDC => {
            const c = cpu.getC();
            if (c == 1) {
                const addressToBePushed: u16 = cpu.PC + 3;
                const first: u8 = @truncate(addressToBePushed & 0xFF00); //high bits
                const second: u8 = @truncate((addressToBePushed & 0x00FF) >> 8); //low bits
                cpu.decSP();
                ram.write(cpu.SP, first);
                cpu.decSP();
                ram.write(cpu.SP, second);

                const newAddress: u16 = ram.read16(cpu.PC + 1);
                cpu.PC = newAddress;
                isJp = true;
            }
        },
        0xDD => {},
        0xDE => {
            cpu.sbcA_r8(ram.read(cpu.PC + 1));
        },
        0xDF => {
            rst(&cpu, 0x18);
            isJp = true;
        },

        0xE0 => {
            const a8 = @as(u16, ram.read(cpu.PC + 1));
            const address: u16 = 0xFF00 | a8;
            const value = cpu.getRegister(reg.A);
            ram.write(address, value);
        },
        0xE1 => {
            cpu.setRegister(reg.L, ram.read(cpu.SP));
            cpu.incSP();
            cpu.setRegister(reg.H, ram.read(cpu.SP));
            cpu.incSP();
        },
        0xE2 => {
            const c = @as(u16, cpu.getRegister(reg.C));
            const address: u16 = 0xFF00 + c;
            ram.write(address, cpu.getRegister(reg.A));
        },
        0xE3 => {},
        0xE4 => {},
        0xE5 => {
            cpu.decSP();
            ram.write(cpu.SP, cpu.getRegister(reg.H));
            cpu.decSP();
            ram.write(cpu.SP, cpu.getRegister(reg.L));
        },
        0xE6 => {
            cpu.andA_r8(ram.read(cpu.PC + 1));
        },
        0xE7 => {
            rst(&cpu, 0x20);
            isJp = true;
        },
        0xE8 => {
            //const e8: i8 = @bitCast(ram.read(cpu.SP + 1));
            //cpu.add_SP_e8(e8);
        },
        0xE9 => {
            const address = cpu.getHL();
            cpu.PC = address;
            isJp = true;
        },
        0xEA => {
            const a = cpu.getRegister(reg.A);
            const address = ram.read16(cpu.PC + 1);
            ram.write(address, a);
        },
        0xEB => {},
        0xEC => {},
        0xED => {},
        0xEE => {
            cpu.xorA_r8(ram.read(cpu.PC + 1));
        },
        0xEF => {
            rst(&cpu, 0x28);
            isJp = true;
        },

        0xF0 => {
            const a8: u16 = @as(u16, ram.read(cpu.PC + 1));
            const address: u16 = 0xFF00 | a8;
            const value = ram.read(address);
            cpu.setRegister(reg.A, value);
        },
        0xF1 => {
            cpu.setRegister(reg.F, ram.read(cpu.SP));
            cpu.incSP();
            cpu.setRegister(reg.A, ram.read(cpu.SP));
            cpu.incSP();
            //TODO all registers
        },
        0xF2 => {
            const c: u16 = @as(u16, cpu.getRegister(reg.C));
            const address: u16 = 0xFF00 + c;
            const value: u8 = ram.read(address);
            cpu.setRegister(reg.A, value);
        },
        0xF3 => {
            cpu.ime = false;
        },
        0xF4 => {},
        0xF5 => {
            cpu.decSP();
            ram.write(cpu.SP, cpu.getRegister(reg.A));
            cpu.decSP();
            ram.write(cpu.SP, cpu.getRegister(reg.F));
        },
        0xF6 => {
            cpu.orA_r8(ram.read(cpu.PC + 1));
        },
        0xF7 => {
            rst(&cpu, 0x30);
            isJp = true;
        },
        0xF8 => {},
        0xF9 => {
            cpu.setSP(cpu.getHL());
        },
        0xFA => {
            const address = ram.read16(cpu.PC + 1);
            const value = ram.read(address);
            cpu.setRegister(reg.A, value);
        },
        0xFB => {
            ei = 2;
        },
        0xFC => {},
        0xFD => {},
        0xFE => {
            cpu.cpA_r8(ram.read(cpu.PC + 1));
        },
        0xFF => {
            rst(&cpu, 0x38);
            isJp = true;
        },
    }
    if (ei == 0) {} else if (ei == 1) {
        cpu.ime = true;
        ei -= 1;
    } else {
        ei -= 1;
    }

    if (isJp) {
        isJp = false;
    } else {
        const newAddress = @as(i32, @intCast(cpu.PC)) + jump + info.length;
        cpu.PC = @truncate(@as(u32, @bitCast(newAddress)));
    }
}

fn rst(cpuRef: *cpuModule.Cpu, value: u16) void {
    const addressToBePushed: u16 = cpu.PC + 1;
    const first: u8 = @truncate(addressToBePushed & 0xFF00); //high bits
    const second: u8 = @truncate((addressToBePushed & 0x00FF) >> 8); //low bits
    cpuRef.decSP();
    ram.write(cpu.SP, first);
    cpuRef.decSP();
    ram.write(cpu.SP, second);

    cpuRef.PC = value;
}
