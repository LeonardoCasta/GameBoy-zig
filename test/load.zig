const std = @import("std");
const expect = std.testing.expect;
const exe = @import("execute");
const reg = exe.cpuModule.reg;

fn init(instruction: u8) void {
    exe.testInit();
    exe.ram.write(0, instruction);
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

fn checkHL(expectedValue: u8) !void {
    const index = exe.cpu.getHL();
    const value = exe.ram.read(index);
    try expect(value == expectedValue);
}

fn runTest(to: reg, from: reg) !void {
    const value: u8 = 15;
    setReg(from, value);
    _ = exe.execute();
    try checkReg(to, value);
}

//copy value pointed by HL insto r8
fn runTestR8Hl(register: reg) !void {
    setReg(reg.H, 0x05);
    setReg(reg.L, 0x02);
    exe.ram.write(0x0502, 0x23);
    _ = exe.execute();
    try checkReg(register, 0x23);
}

//copy the value in r8 into HL
fn runTestHLR8(register: reg) !void {
    setReg(reg.H, 0x03);
    setReg(reg.L, 0x04);
    setReg(register, 0x11);
    _ = exe.execute();
    try checkHL(0x11);
}

fn test_r16_n16(instruction: u8) void {
    init(instruction);
    exe.ram.write(1, 0x11);
    exe.ram.write(2, 0x22);
    _ = exe.execute();
}

// =================== STRANGE LD INSTRUCTIONS =========================
test "LD [a16], SP" {
    init(0x08);
    exe.ram.write(1, 0x10);
    exe.ram.write(2, 0x10);
    exe.cpu.setSP(0x405);
    _ = exe.execute();
    try expect(exe.ram.read(0x1010) == 0x5);
    try expect(exe.ram.read(0x1011) == 0x4);
}

test "LD SP, HL" {
    init(0xF9);
    exe.cpu.setHL(0x78);
    _ = exe.execute();
    try expect(exe.cpu.getSP() == 0x78);
}

test "LDH [a8], A" {
    init(0xE0);
    exe.cpu.setRegister(reg.A, 0x11);
    exe.ram.write(1, 0x88);
    try expect(exe.ram.read(0xFF88) == 0);
    _ = exe.execute();
    try expect(exe.ram.read(0xFF88) == 0x11);
}

test "LDH A, [a8]" {
    init(0xF0);
    exe.ram.write(1, 0x88); //set low byte of address
    exe.ram.write(0xFF88, 0x67); //set full address
    try expect(exe.cpu.getRegister(reg.A) == 0);
    _ = exe.execute();
    try expect(exe.cpu.getRegister(reg.A) == 0x67);
}

test "LDH [C], A" {
    init(0xE2);
    exe.cpu.setRegister(reg.A, 0x89);
    exe.cpu.setRegister(reg.C, 0x88);
    try expect(exe.ram.read(0xFF88) == 0);
    _ = exe.execute();
    try expect(exe.ram.read(0xFF88) == 0x89);
}

test "LDH A, [C]" {
    init(0xF2);
    exe.cpu.setRegister(reg.C, 0x88);
    exe.ram.write(0xFF88, 0x78);
    try expect(exe.cpu.getRegister(reg.A) == 0);
    _ = exe.execute();
    try expect(exe.cpu.getRegister(reg.A) == 0x78);
}

test "LD [r16], A" {
    init(0xEA);
    exe.cpu.setRegister(reg.A, 0x99);
    exe.ram.write(1, 0x33);
    exe.ram.write(2, 0x33);
    try expect(exe.ram.read(0x3333) == 0);
    _ = exe.execute();
    try expect(exe.ram.read(0x3333) == 0x99);
}

test "LD A, [r16]" {
    init(0xFA);
    exe.ram.write(1, 0x33);
    exe.ram.write(2, 0x33);
    exe.ram.write(0x3333, 0x77);
    try expect(exe.cpu.getRegister(reg.A) == 0);
    _ = exe.execute();
    try expect(exe.cpu.getRegister(reg.A) == 0x77);
}

// =================== POP PUSH r16 =========================
fn initPop(instruction: u8) void {
    init(instruction);
    exe.ram.write(0xFFFD, 5);
    exe.ram.write(0xFFFC, 4);
    exe.cpu.decSP();
    exe.cpu.decSP();
}
fn initPush(instruction: u8) void {
    init(instruction);
    exe.ram.write(0xFFFD, 5);
    exe.ram.write(0xFFFC, 4);
    exe.cpu.decSP();
    exe.cpu.decSP();
}

test "POP BC" {
    initPop(0xC1);
    try expect(exe.cpu.getRegister(reg.B) == 0 and exe.cpu.getRegister(reg.C) == 0);
    _ = exe.execute();
    try expect(exe.cpu.getRegister(reg.C) == 4 and exe.cpu.getRegister(reg.B) == 5);
}

test "POP DE" {
    initPop(0xD1);
    try expect(exe.cpu.getRegister(reg.E) == 0 and exe.cpu.getRegister(reg.D) == 0);
    _ = exe.execute();
    try expect(exe.cpu.getRegister(reg.E) == 4 and exe.cpu.getRegister(reg.D) == 5);
}

test "POP HL" {
    initPop(0xE1);
    try expect(exe.cpu.getRegister(reg.L) == 0 and exe.cpu.getRegister(reg.H) == 0);
    _ = exe.execute();
    try expect(exe.cpu.getRegister(reg.L) == 4 and exe.cpu.getRegister(reg.H) == 5);
}

test "POP AF" {
    initPop(0xF1);
    try expect(exe.cpu.getRegister(reg.F) == 0 and exe.cpu.getRegister(reg.A) == 0);
    _ = exe.execute();
    try expect(exe.cpu.getRegister(reg.F) == 4 and exe.cpu.getRegister(reg.A) == 5);
}

fn testPush() !void {
    try expect(exe.cpu.SP == 0xFFFE);
    _ = exe.execute();
    try expect(exe.ram.read(0xFFFD) == 0x44);
    try expect(exe.ram.read(0xFFFC) == 0x55);
    try expect(exe.cpu.SP == 0xFFFC);
}

test "PUSH BC" {
    init(0xC5);
    exe.cpu.setBC(0x4455);
    try expect(exe.cpu.getRegister(reg.B) == 0x44 and exe.cpu.getRegister(reg.C) == 0x55);
    try testPush();
}
test "PUSH DE" {
    init(0xD5);
    exe.cpu.setDE(0x4455);
    try expect(exe.cpu.getRegister(reg.D) == 0x44 and exe.cpu.getRegister(reg.E) == 0x55);
    try testPush();
}
test "PUSH HL" {
    init(0xE5);
    exe.cpu.setHL(0x4455);
    try expect(exe.cpu.getRegister(reg.H) == 0x44 and exe.cpu.getRegister(reg.L) == 0x55);
    try testPush();
}

test "PUSH AF" {
    init(0xF5);
    exe.cpu.setAF(0x4455);
    try expect(exe.cpu.getRegister(reg.A) == 0x44 and exe.cpu.getRegister(reg.F) == 0x55);
    try testPush();
}

// =================== LD r16 n16 ==========================
test "0x01 LD BC, n16" {
    test_r16_n16(0x01);
    const result = exe.cpu.getBC();
    try expect(result == 0x2211);
}

test "0x11 LD DE, n16" {
    test_r16_n16(0x11);
    const result = exe.cpu.getDE();
    try expect(result == 0x2211);
}

test "0x21 LD HL, n16" {
    test_r16_n16(0x21);
    const result = exe.cpu.getHL();
    try expect(result == 0x2211);
}

test "0x31 LD SP, n16" {
    test_r16_n16(0x31);
    const result = exe.cpu.getSP();
    try expect(result == 0x2211);
}

// =================== LD r16 A ==========================
test "0x02 LD [BC] A" {
    init(0x02);
    exe.cpu.setRegister(reg.A, 0x67);
    exe.cpu.setBC(0x44);
    var result = exe.ram.read(0x44);
    try expect(result == 0);
    _ = exe.execute();
    result = exe.ram.read(0x44);
    try expect(result == 0x67);
}
test "0x12 LD [DE] A" {
    init(0x12);
    exe.cpu.setRegister(reg.A, 0x67);
    exe.cpu.setDE(0x44);
    var result = exe.ram.read(0x44);
    try expect(result == 0);
    _ = exe.execute();
    result = exe.ram.read(0x44);
    try expect(result == 0x67);
}

test "0x22 LD [HL+] A" {
    init(0x22);
    exe.cpu.setRegister(reg.A, 0x67);
    exe.cpu.setHL(0x44);
    var result = exe.ram.read(0x44);
    try expect(result == 0);
    _ = exe.execute();
    result = exe.ram.read(0x44);
    try expect(result == 0x67);
    try expect(exe.cpu.getHL() == 0x45);
}

test "0x32 LD [HL-] A" {
    init(0x32);
    exe.cpu.setRegister(reg.A, 0x67);
    exe.cpu.setHL(0x44);
    var result = exe.ram.read(0x44);
    try expect(result == 0);
    _ = exe.execute();
    result = exe.ram.read(0x44);
    try expect(result == 0x67);
    try expect(exe.cpu.getHL() == 0x43);
}

// =================== LD r8 n8 ==========================
fn test_r8_n8(instruction: u8, register: reg) !void {
    init(instruction);
    exe.ram.write(1, 0x88);
    try expect(exe.cpu.getRegister(register) == 0);
    _ = exe.execute();
    try expect(exe.cpu.getRegister(register) == 0x88);
}

test "LD B, n8" {
    try test_r8_n8(0x06, reg.B);
}

test "LD D, n8" {
    try test_r8_n8(0x16, reg.D);
}

test "LD H, n8" {
    try test_r8_n8(0x26, reg.H);
}

test "LD C, n8" {
    try test_r8_n8(0x0E, reg.C);
}

test "LD E, n8" {
    try test_r8_n8(0x1E, reg.E);
}

test "LD L, n8" {
    try test_r8_n8(0x2E, reg.L);
}

test "LD A, n8" {
    try test_r8_n8(0x3E, reg.A);
}

// ===================== LD HL n8 ==========================
test "LD HL, n8" {
    init(0x36);
    exe.ram.write(1, 0x34);
    exe.cpu.setHL(0x56);
    try expect(exe.ram.read(exe.cpu.getHL()) == 0);
    _ = exe.execute();
    try expect(exe.ram.read(exe.cpu.getHL()) == 0x34);
}

// ===================== LD A [r16] ==========================
fn test_A_r16() !void {
    exe.ram.write(0x11, 0x99);
    try expect(exe.cpu.getRegister(reg.A) == 0);
    _ = exe.execute();
    try expect(exe.cpu.getRegister(reg.A) == 0x99);
}
test "LD A, [BC]" {
    init(0x0A);
    exe.cpu.setBC(0x11);
    try test_A_r16();
}

test "LD A, [DE]" {
    init(0x1A);
    exe.cpu.setDE(0x11);
    try test_A_r16();
}

// ===================== LD A [HL+-] ==========================
test "LD A, [HL+]" {
    init(0x2A);
    exe.cpu.setHL(0x11);
    try test_A_r16();
    try expect(exe.cpu.getHL() == 0x12);
}

test "LD A, [HL-]" {
    init(0x3A);
    exe.cpu.setHL(0x11);
    try test_A_r16();
    try expect(exe.cpu.getHL() == 0x10);
}

// ===================== LD ==========================
test "0x40 ld b, b" {
    init(0x40);
    try runTest(reg.B, reg.B);
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

test "0x70 ld hl, b" {
    init(0x70);
    try runTestHLR8(reg.B);
}

test "0x71 ld hl, c" {
    init(0x71);
    try runTestHLR8(reg.C);
}

test "0x72 ld hl, d" {
    init(0x72);
    try runTestHLR8(reg.D);
}

test "0x73 ld hl, e" {
    init(0x73);
    try runTestHLR8(reg.E);
}

test "0x74 ld hl, h" {
    init(0x74);
    try runTestHLR8(reg.H);
}

test "0x75 ld hl, l" {
    init(0x75);
    try runTestHLR8(reg.L);
}

//0x76 is halt so not a load instruction

test "0x77 ld hl, a" {
    init(0x77);
    try runTestHLR8(reg.A);
}

test "0x78 ld a, b" {
    init(0x78);
    try runTest(reg.A, reg.B);
}

test "0x79 ld a, c" {
    init(0x79);
    try runTest(reg.A, reg.C);
}

test "0x7A ld a, d" {
    init(0x7A);
    try runTest(reg.A, reg.D);
}

test "0x7B ld a, e" {
    init(0x7B);
    try runTest(reg.A, reg.E);
}

test "0x7C ld a, h" {
    init(0x7C);
    try runTest(reg.A, reg.H);
}

test "0x7D ld a, l" {
    init(0x7D);
    try runTest(reg.A, reg.L);
}

test "0x7E ld a, HL" {
    init(0x7E);
    try runTestR8Hl(reg.A);
}

test "0x7F ld a, a" {
    init(0x7F);
    try runTest(reg.A, reg.A);
}
