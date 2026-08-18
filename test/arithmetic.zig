const std = @import("std");
const expect = std.testing.expect;
const reg = exe.cpuModule.reg;
const exe = @import("execute");

fn init(instruction: u8) void {
    exe.testInit();
    exe.ram.write(0, instruction);
}

//================== 16 bit arithmetic ==================
test "INC BC" {
    init(0x03);
    try expect(exe.cpu.getBC() == 0);
    exe.execute();
    try expect(exe.cpu.getBC() == 1);
}

test "INC DE" {
    init(0x13);
    try expect(exe.cpu.getDE() == 0);
    exe.execute();
    try expect(exe.cpu.getDE() == 1);
}

test "INC HL" {
    init(0x23);
    try expect(exe.cpu.getHL() == 0);
    exe.execute();
    try expect(exe.cpu.getHL() == 1);
}

test "INC SP" {
    init(0x33);
    try expect(exe.cpu.getSP() == 0xFFFE);
    exe.execute();
    try expect(exe.cpu.getSP() == 0xFFFF);
}

test "DEC BC" {
    init(0x0B);
    exe.cpu.setBC(2);
    try expect(exe.cpu.getBC() == 2);
    exe.execute();
    try expect(exe.cpu.getBC() == 1);
}

test "DEC DE" {
    init(0x1B);
    exe.cpu.setDE(2);
    try expect(exe.cpu.getDE() == 2);
    exe.execute();
    try expect(exe.cpu.getDE() == 1);
}

test "DEC HL" {
    init(0x2B);
    exe.cpu.setHL(2);
    try expect(exe.cpu.getHL() == 2);
    exe.execute();
    try expect(exe.cpu.getHL() == 1);
}

test "DEC SP" {
    init(0x3B);
    exe.cpu.setSP(2);
    try expect(exe.cpu.getSP() == 2);
    exe.execute();
    try expect(exe.cpu.getSP() == 1);
}

test "ADD HL BC" {
    init(0x09);
    exe.cpu.setBC(47);
    try expect(exe.cpu.getHL() == 0);
    exe.execute();
    try expect(exe.cpu.getHL() == 47);
    try expect(exe.cpu.getH() == 0);
    try expect(exe.cpu.getC() == 0);
}

test "ADD HL DE" {
    init(0x19);
    exe.cpu.setDE(47);
    try expect(exe.cpu.getHL() == 0);
    exe.execute();
    try expect(exe.cpu.getHL() == 47);
}

test "ADD HL HL" {
    init(0x29);
    try expect(exe.cpu.getHL() == 0);
    exe.cpu.setHL(47);
    try expect(exe.cpu.getHL() == 47);
    exe.execute();
    try expect(exe.cpu.getHL() == 94);
}

test "ADD HL SP" {
    init(0x39);
    exe.cpu.setSP(47);
    try expect(exe.cpu.getHL() == 0);
    exe.execute();
    try expect(exe.cpu.getHL() == 47);
}

test "ADD HL, r16 flags H should set to 1" {
    init(0x09);
    exe.cpu.setBC(0x1FFF);
    exe.execute();
    //test 11 bit carry flag
    try expect(exe.cpu.getH() == 1);
}

test "ADD HL, r16 flags H and C should set to 1" {
    init(0x09);
    exe.cpu.setBC(0xFFFF);
    exe.cpu.setHL(0x1);
    exe.execute();
    //test 11 bit carry flag
    try expect(exe.cpu.getH() == 1);
    try expect(exe.cpu.getC() == 1);
}

test "ADD SP, e8" {}

//=========================== A N8  ======================
test "ADD A, n8" {
    init(0xC6);
    exe.cpu.setRegister(reg.A, 11);
    exe.ram.write(1, 30);
    exe.execute();
    try expect(exe.cpu.getRegister(reg.A) == 41);
}

test "SUB A, n8" {
    init(0xD6);
    exe.cpu.setRegister(reg.A, 11);
    exe.ram.write(1, 1);
    exe.execute();
    try expect(exe.cpu.getRegister(reg.A) == 10);
}

test "AND A, n8" {
    init(0xE6);
    exe.cpu.setRegister(reg.A, 0xF0);
    exe.ram.write(1, 0x0F);
    exe.execute();
    try expect(exe.cpu.getRegister(reg.A) == 0);
}

test "OR A, n8" {
    init(0xF6);
    exe.cpu.setRegister(reg.A, 0xF0);
    exe.ram.write(1, 0x0F);
    exe.execute();
    try expect(exe.cpu.getRegister(reg.A) == 0xFF);
}

//=========================== arithmetic ======================
fn addA(addend: u8) !void {
    exe.cpu.setRegister(reg.A, 150);
    exe.execute();
    const result: u8 = 150 +% addend;
    try expect(exe.cpu.getRegister(reg.A) == result);
}

fn adcA(addend: u8) !void {
    exe.cpu.setRegister(reg.A, 150);
    exe.cpu.setC(1);
    exe.execute();
    const result: u8 = 150 +% addend +% 1;
    //std.debug.print("reslt {} reg {}\n", .{ result, exe.cpu.getRegister(reg.A) });
    try expect(exe.cpu.getRegister(reg.A) == result);
}

fn addA_r8(inst: u8, register: reg, addend: u8) !void {
    init(inst);
    exe.cpu.setRegister(register, addend);
    try addA(addend);
}

fn adcA_r8(inst: u8, register: reg, addend: u8) !void {
    init(inst);
    exe.cpu.setRegister(register, addend);
    try adcA(addend);
}

test "ADC A, B" {
    try adcA_r8(0x88, reg.B, 50);
}

test "ADC A, C" {
    try adcA_r8(0x89, reg.C, 50);
}

test "ADC A, D" {
    try adcA_r8(0x8A, reg.D, 50);
}

test "ADC A, E" {
    try adcA_r8(0x8B, reg.E, 50);
}

test "ADC A, H" {
    try adcA_r8(0x8C, reg.H, 50);
}

test "ADC A, L" {
    try adcA_r8(0x8D, reg.L, 50);
}

test "ADC A, [HL]" {
    init(0x8E);
    exe.cpu.setHL(0x55);
    exe.ram.write(0x55, 30);
    try adcA(30);
}

test "ADC A, A" {
    init(0x8F);
    try adcA(150);
}

test "ADD A, B" {
    try addA_r8(0x80, reg.B, 50);
}

test "ADD A, C" {
    try addA_r8(0x81, reg.C, 50);
}

test "ADD A, D" {
    try addA_r8(0x82, reg.D, 50);
}

test "ADD A, E" {
    try addA_r8(0x83, reg.E, 50);
}

test "ADD A, H" {
    try addA_r8(0x84, reg.H, 50);
}

test "ADD A, L" {
    try addA_r8(0x85, reg.L, 50);
}

test "ADD A, [HL]" {
    init(0x86);
    exe.cpu.setHL(0x55);
    exe.ram.write(0x55, 30);
    try addA(30);
}

test "ADD A, A" {
    init(0x87);
    try addA(150);
    try expect(exe.cpu.getZ() == 0);
    try expect(exe.cpu.getN() == 0);
    try expect(exe.cpu.getH() == 0);
    try expect(exe.cpu.getC() == 1);
}

test "ADD A, L - test reg c" {
    try addA_r8(0x85, reg.L, 0xFF);
    try expect(exe.cpu.getH() == 1);
}

test "ADD A, L - test reg z" {
    try addA_r8(0x85, reg.L, 106);
    try expect(exe.cpu.getZ() == 1);
}

fn subA(inst: u8, sub: u8) !void {
    init(inst);
    exe.cpu.setRegister(reg.A, 150);
    exe.execute();
    try expect(exe.cpu.getRegister(reg.A) == (150 - sub));
}
