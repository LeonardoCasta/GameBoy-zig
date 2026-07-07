const std = @import("std");
const expect = std.testing.expect;
const exe = @import("execute");
const reg = exe.cpuModule.reg;

fn init(instruction: u8) void {
    exe.testInit();
    //exe.ram.ram[0] = instruction;
    exe.game.game[0] = instruction;
}

//set the reg with a constant value
fn setReg(register: reg, value: u8) void {
    exe.cpu.reg[@intFromEnum(register)] = value;
}

//load the value in from into to
fn loadReg(from: reg, to: reg) void {
    exe.cpu.reg[@intFromEnum(to)] = exe.cpu.reg[@intFromEnum(from)];
}

fn checkReg(register: reg, value: u8) !void {
    try expect(exe.cpu.reg[@intFromEnum(register)] == value);
}

fn runTest(to: reg, from: reg) !void {
    const value: u8 = 15;
    setReg(from, value);
    loadReg(from, to);
    exe.execute();
    try checkReg(to, value);
}

//copy value pointed by HL insto r8
fn runTestR8Hl(register: reg) !void {
    setReg(reg.H, 0x05);
    setReg(reg.L, 0x02);
    exe.ram.ram[0x0502] = 0x23;
    exe.execute();
    try checkReg(register, 0x23);
}

test "0x40 ld b, b" {
    init(0x40);
    try runTest(reg.B, reg.A);
}

test "0x41 ld b, c" {
    init(0x41);
    try runTest(reg.B, reg.C);
}

test "0x42 ld b, d" {
    init(0x42);
    try runTest(reg.B, reg.D);
}

test "0x43 ld b, e" {
    init(0x43);
    try runTest(reg.B, reg.E);
}

test "0x44 ld b, h" {
    init(0x44);
    try runTest(reg.B, reg.H);
}

test "0x45 ld b, l" {
    init(0x45);
    try runTest(reg.B, reg.L);
}

test "0x46 ld b, HL" {
    init(0x46);
    try runTestR8Hl(reg.B);
}

test "0x47 ld b, a" {
    init(0x47);
    try runTest(reg.B, reg.A);
}

test "0x48 ld c, b" {
    init(0x48);
    try runTest(reg.C, reg.B);
}

test "0x49 ld c, c" {
    init(0x49);
    try runTest(reg.C, reg.C);
}

test "0x4A ld c, d" {
    init(0x4A);
    try runTest(reg.C, reg.D);
}

test "0x4B ld c, e" {
    init(0x4B);
    try runTest(reg.C, reg.E);
}

test "0x4C ld c, h" {
    init(0x4C);
    try runTest(reg.C, reg.H);
}

test "0x4D ld c, l" {
    init(0x4D);
    try runTest(reg.C, reg.L);
}

test "0x4E ld c, HL" {
    init(0x4E);
    try runTestR8Hl(reg.C);
}

test "0x4F ld c, a" {
    init(0x4F);
    try runTest(reg.C, reg.A);
}

test "0x50 ld d, b" {
    init(0x50);
    try runTest(reg.D, reg.B);
}

test "0x51 ld d, c" {
    init(0x51);
    try runTest(reg.D, reg.C);
}

test "0x52 ld d, d" {
    init(0x52);
    try runTest(reg.D, reg.D);
}

test "0x53 ld d, e" {
    init(0x53);
    try runTest(reg.D, reg.E);
}

test "0x54 ld d, h" {
    init(0x54);
    try runTest(reg.D, reg.H);
}

test "0x55 ld d, l" {
    init(0x55);
    try runTest(reg.D, reg.L);
}

test "0x56 ld d, HL" {
    init(0x56);
    try runTestR8Hl(reg.D);
}

test "0x57 ld d, a" {
    init(0x57);
    try runTest(reg.D, reg.A);
}

test "0x58 ld e, b" {
    init(0x58);
    try runTest(reg.E, reg.B);
}

test "0x59 ld e, c" {
    init(0x59);
    try runTest(reg.E, reg.C);
}

test "0x5A ld e, d" {
    init(0x5A);
    try runTest(reg.E, reg.D);
}

test "0x5B ld e, e" {
    init(0x5B);
    try runTest(reg.E, reg.E);
}

test "0x5C ld e, h" {
    init(0x5C);
    try runTest(reg.E, reg.H);
}

test "0x5D ld e, l" {
    init(0x5D);
    try runTest(reg.E, reg.L);
}

test "0x5E ld e, HL" {
    init(0x5E);
    try runTestR8Hl(reg.E);
}

test "0x5F ld e, a" {
    init(0x5F);
    try runTest(reg.E, reg.A);
}

test "0x60 ld h, b" {
    init(0x60);
    try runTest(reg.H, reg.B);
}

test "0x61 ld h, c" {
    init(0x61);
    try runTest(reg.H, reg.C);
}

test "0x62 ld h, d" {
    init(0x62);
    try runTest(reg.H, reg.D);
}

test "0x63 ld h, e" {
    init(0x63);
    try runTest(reg.H, reg.E);
}

test "0x64 ld h, h" {
    init(0x64);
    try runTest(reg.H, reg.H);
}

test "0x65 ld h, l" {
    init(0x65);
    try runTest(reg.H, reg.L);
}

test "0x66 ld h, HL" {
    init(0x66);
    try runTestR8Hl(reg.H);
}

test "0x67 ld h, a" {
    init(0x67);
    try runTest(reg.H, reg.A);
}

test "0x68 ld l, b" {
    init(0x68);
    try runTest(reg.L, reg.B);
}

test "0x69 ld l, c" {
    init(0x69);
    try runTest(reg.L, reg.C);
}

test "0x6A ld l, d" {
    init(0x6A);
    try runTest(reg.L, reg.D);
}

test "0x6B ld l, e" {
    init(0x6B);
    try runTest(reg.L, reg.E);
}

test "0x6C ld l, h" {
    init(0x6C);
    try runTest(reg.L, reg.H);
}

test "0x6D ld l, l" {
    init(0x6D);
    try runTest(reg.L, reg.L);
}

test "0x6E ld l, HL" {
    init(0x6E);
    try runTestR8Hl(reg.L);
}

test "0x6F ld l, a" {
    init(0x6F);
    try runTest(reg.L, reg.A);
}
