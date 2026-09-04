const std = @import("std");
const expect = std.testing.expect;
const reg = exe.cpuModule.reg;
const exe = @import("execute");

fn init(instruction: u8) void {
    exe.testInit();
    exe.ram.write(0, instruction);
}

//================== sp add i8 ==================
test "LD SP + n8" {
    init(0xF8);
    exe.cpu.setSP(33);
    exe.ram.write(1, 17);
    exe.ram.write(2, 0xF8);
    exe.ram.write(3, 0xFF);
    _ = exe.execute();
    try expect(exe.cpu.getHL() == 50);
    exe.cpu.setSP(50);
    _ = exe.execute();
    try expect(exe.cpu.getHL() == 49);
}

//================== 16 bit arithmetic ==================
test "INC BC" {
    init(0x03);
    try expect(exe.cpu.getBC() == 0);
    _ = exe.execute();
    try expect(exe.cpu.getBC() == 1);
}

test "INC DE" {
    init(0x13);
    try expect(exe.cpu.getDE() == 0);
    _ = exe.execute();
    try expect(exe.cpu.getDE() == 1);
}

test "INC HL" {
    init(0x23);
    try expect(exe.cpu.getHL() == 0);
    _ = exe.execute();
    try expect(exe.cpu.getHL() == 1);
}

test "INC SP" {
    init(0x33);
    try expect(exe.cpu.getSP() == 0xFFFE);
    _ = exe.execute();
    try expect(exe.cpu.getSP() == 0xFFFF);
}

test "DEC BC" {
    init(0x0B);
    exe.cpu.setBC(2);
    try expect(exe.cpu.getBC() == 2);
    _ = exe.execute();
    try expect(exe.cpu.getBC() == 1);
}

test "DEC DE" {
    init(0x1B);
    exe.cpu.setDE(2);
    try expect(exe.cpu.getDE() == 2);
    _ = exe.execute();
    try expect(exe.cpu.getDE() == 1);
}

test "DEC HL" {
    init(0x2B);
    exe.cpu.setHL(2);
    try expect(exe.cpu.getHL() == 2);
    _ = exe.execute();
    try expect(exe.cpu.getHL() == 1);
}

test "DEC SP" {
    init(0x3B);
    exe.cpu.setSP(2);
    try expect(exe.cpu.getSP() == 2);
    _ = exe.execute();
    try expect(exe.cpu.getSP() == 1);
}

test "ADD HL BC" {
    init(0x09);
    exe.cpu.setBC(47);
    try expect(exe.cpu.getHL() == 0);
    _ = exe.execute();
    try expect(exe.cpu.getHL() == 47);
    try expect(exe.cpu.getH() == 0);
    try expect(exe.cpu.getC() == 0);
}

test "ADD HL DE" {
    init(0x19);
    exe.cpu.setDE(47);
    try expect(exe.cpu.getHL() == 0);
    _ = exe.execute();
    try expect(exe.cpu.getHL() == 47);
}

test "ADD HL HL" {
    init(0x29);
    try expect(exe.cpu.getHL() == 0);
    exe.cpu.setHL(47);
    try expect(exe.cpu.getHL() == 47);
    _ = exe.execute();
    try expect(exe.cpu.getHL() == 94);
}

test "ADD HL SP" {
    init(0x39);
    exe.cpu.setSP(47);
    try expect(exe.cpu.getHL() == 0);
    _ = exe.execute();
    try expect(exe.cpu.getHL() == 47);
}

test "ADD HL, r16 flags H should set to 1" {
    init(0x09);
    exe.cpu.setBC(0x1FFF);
    _ = exe.execute();
    //test 11 bit carry flag
    try expect(exe.cpu.getH() == 1);
}

test "ADD HL, r16 flags H and C should set to 1" {
    init(0x09);
    exe.cpu.setBC(0xFFFF);
    exe.cpu.setHL(0x1);
    _ = exe.execute();
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
    _ = exe.execute();
    try expect(exe.cpu.getRegister(reg.A) == 41);
}

test "SUB A, n8" {
    init(0xD6);
    exe.cpu.setRegister(reg.A, 11);
    exe.ram.write(1, 1);
    _ = exe.execute();
    try expect(exe.cpu.getRegister(reg.A) == 10);
}

test "AND A, n8" {
    init(0xE6);
    exe.cpu.setRegister(reg.A, 0xF0);
    exe.ram.write(1, 0x0F);
    _ = exe.execute();
    try expect(exe.cpu.getRegister(reg.A) == 0);
}

test "OR A, n8" {
    init(0xF6);
    exe.cpu.setRegister(reg.A, 0xF0);
    exe.ram.write(1, 0x0F);
    _ = exe.execute();
    try expect(exe.cpu.getRegister(reg.A) == 0xFF);
}

//=========================== arithmetic ======================
//=========================== add ======================
fn addA(addend: u8) !void {
    exe.cpu.setRegister(reg.A, 150);
    _ = exe.execute();
    const result: u8 = 150 +% addend;
    try expect(exe.cpu.getRegister(reg.A) == result);
}

fn adcA(addend: u8) !void {
    exe.cpu.setRegister(reg.A, 150);
    exe.cpu.setC(1);
    _ = exe.execute();
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

//=========================== sub ======================
fn subA(sub: u8) !void {
    exe.cpu.setRegister(reg.A, 150);
    _ = exe.execute();
    const result: u8 = 150 -% sub;
    try expect(exe.cpu.getRegister(reg.A) == result);
}

fn subA_r8(inst: u8, register: reg, sub: u8) !void {
    init(inst);
    exe.cpu.setRegister(register, sub);
    try subA(sub);
}

test "SUB A, B" {
    try subA_r8(0x90, reg.B, 50);
}

test "SUB A, C" {
    try subA_r8(0x91, reg.C, 50);
}

test "SUB A, D" {
    try subA_r8(0x92, reg.D, 50);
}

test "SUB A, E" {
    try subA_r8(0x93, reg.E, 50);
}

test "SUB A, H" {
    try subA_r8(0x94, reg.H, 50);
}

test "SUB A, L" {
    try subA_r8(0x95, reg.L, 50);
}

test "SUB A, [HL]" {
    init(0x96);
    exe.cpu.setHL(0x55);
    exe.ram.write(0x55, 30);
    try subA(30);
}

test "SUB A, A" {
    init(0x97);
    try subA(150);
    try expect(exe.cpu.getZ() == 1);
    try expect(exe.cpu.getN() == 1);
    try expect(exe.cpu.getH() == 0);
    try expect(exe.cpu.getC() == 0);
}

fn sbcA_r8(inst: u8, register: reg, sub: u8) !void {
    init(inst);
    exe.cpu.setRegister(register, sub);
    try sbcA(sub);
}

fn sbcA(sub: u8) !void {
    exe.cpu.setRegister(reg.A, 150);
    exe.cpu.setC(1);
    _ = exe.execute();
    const result: u8 = 150 -% sub -% 1;
    //std.debug.print("reslt {} reg {}\n", .{ result, exe.cpu.getRegister(reg.A) });
    try expect(exe.cpu.getRegister(reg.A) == result);
}

test "SBC A, B" {
    try sbcA_r8(0x98, reg.B, 50);
}

test "SBC A, C" {
    try sbcA_r8(0x99, reg.C, 50);
}

test "SBC A, D" {
    try sbcA_r8(0x9A, reg.D, 50);
}

test "SBC A, E" {
    try sbcA_r8(0x9B, reg.E, 50);
}

test "SBC A, H" {
    try sbcA_r8(0x9C, reg.H, 50);
}

test "SBC A, L" {
    try sbcA_r8(0x9D, reg.L, 50);
}

test "SBC A, [HL]" {
    init(0x9E);
    exe.cpu.setHL(0x55);
    exe.ram.write(0x55, 30);
    try subA(30);
}

test "SBC A, A" {
    init(0x9F);
    try sbcA(150);
    try expect(exe.cpu.getZ() == 0);
    try expect(exe.cpu.getN() == 1);
    try expect(exe.cpu.getH() == 0);
    try expect(exe.cpu.getC() == 1);
}

test "SUB A, L - test registers" {
    try subA_r8(0x95, reg.L, 15);
    try expect(exe.cpu.getN() == 1);
    try expect(exe.cpu.getH() == 1);
}

//=========================== sub ======================
fn andA(op: u8) !void {
    exe.cpu.setRegister(reg.A, 0xF2);
    _ = exe.execute();
    const result: u8 = 0xF2 & op;
    try expect(exe.cpu.getRegister(reg.A) == result);
}

fn andA_r8(inst: u8, register: reg, op: u8) !void {
    init(inst);
    exe.cpu.setRegister(register, op);
    try andA(op);
}

test "AND A, B" {
    try andA_r8(0xA0, reg.B, 0xF0);
}

test "AND A, C" {
    try andA_r8(0xA1, reg.C, 0xF0);
}

test "AND A, D" {
    try andA_r8(0xA2, reg.D, 0xF0);
}

test "AND A, E" {
    try andA_r8(0xA3, reg.E, 0xF0);
}

test "AND A, H" {
    try andA_r8(0xA4, reg.H, 0xF0);
}

test "AND A, L" {
    try andA_r8(0xA5, reg.L, 0xF0);
}

test "AND A, [HL]" {
    init(0xA6);
    exe.cpu.setHL(0x55);
    exe.ram.write(0x55, 0xF0);
    try andA(0xF0);
}

test "AND A, A" {
    init(0xA7);
    try andA(0xF2);
    //try expect(exe.cpu.getZ() == 1);
    try expect(exe.cpu.getN() == 0);
    try expect(exe.cpu.getH() == 1);
    try expect(exe.cpu.getC() == 0);
}

//=========================== or ======================
fn orA(op: u8) !void {
    exe.cpu.setRegister(reg.A, 0xF2);
    _ = exe.execute();
    const result: u8 = 0xF2 | op;
    try expect(exe.cpu.getRegister(reg.A) == result);
}

fn orA_r8(inst: u8, register: reg, op: u8) !void {
    init(inst);
    exe.cpu.setRegister(register, op);
    try orA(op);
}

test "OR A, B" {
    try orA_r8(0xB0, reg.B, 0xF0);
}

test "OR A, C" {
    try orA_r8(0xB1, reg.C, 0xF0);
}

test "OR A, D" {
    try orA_r8(0xB2, reg.D, 0xF0);
}

test "OR A, E" {
    try orA_r8(0xB3, reg.E, 0xF0);
}

test "OR A, H" {
    try orA_r8(0xB4, reg.H, 0xF0);
}

test "OR A, L" {
    try orA_r8(0xB5, reg.L, 0xF0);
}

test "OR A, [HL]" {
    init(0xB6);
    exe.cpu.setHL(0x55);
    exe.ram.write(0x55, 0xF0);
    try orA(0xF0);
}

test "OR A, A" {
    init(0xB7);
    try orA(0xF2);
    //try expect(exe.cpu.getZ() == 1);
    try expect(exe.cpu.getN() == 0);
    try expect(exe.cpu.getH() == 0);
    try expect(exe.cpu.getC() == 0);
}

//=========================== xor ======================
fn xorA(op: u8) !void {
    exe.cpu.setRegister(reg.A, 0xF2);
    _ = exe.execute();
    const result: u8 = 0xF2 ^ op;
    try expect(exe.cpu.getRegister(reg.A) == result);
}

fn xorA_r8(inst: u8, register: reg, op: u8) !void {
    init(inst);
    exe.cpu.setRegister(register, op);
    try xorA(op);
}

test "XOR A, B" {
    try xorA_r8(0xA8, reg.B, 0xF0);
}

test "XOR A, C" {
    try xorA_r8(0xA9, reg.C, 0xF0);
}

test "XOR A, D" {
    try xorA_r8(0xAA, reg.D, 0xF0);
}

test "XOR A, E" {
    try xorA_r8(0xAB, reg.E, 0xF0);
}

test "XOR A, H" {
    try xorA_r8(0xAC, reg.H, 0xF0);
}

test "XOR A, L" {
    try xorA_r8(0xAD, reg.L, 0xF0);
}

test "XOR A, [HL]" {
    init(0xAE);
    exe.cpu.setHL(0x55);
    exe.ram.write(0x55, 0xF0);
    try xorA(0xF0);
}

test "XOR A, A" {
    init(0xAF);
    try xorA(0xF2);
    try expect(exe.cpu.getN() == 0);
    try expect(exe.cpu.getH() == 0);
    try expect(exe.cpu.getC() == 0);
}

//=========================== cp ======================
fn cpA() !void {
    exe.cpu.setRegister(reg.A, 0xF2);
    _ = exe.execute();
    try expect(exe.cpu.getRegister(reg.A) == 0xF2);
    try expect(exe.cpu.getZ() == 0);
    try expect(exe.cpu.getN() == 1);
    try expect(exe.cpu.getH() == 1);
    try expect(exe.cpu.getC() == 1);
}

fn cpA_r8(inst: u8, register: reg, op: u8) !void {
    init(inst);
    exe.cpu.setRegister(register, op);
    try cpA();
}

test "CP A, B" {
    try cpA_r8(0xB8, reg.B, 0xF3);
}

test "CP A, C" {
    try cpA_r8(0xB9, reg.C, 0xF3);
}

test "CP A, D" {
    try cpA_r8(0xBA, reg.D, 0xF4);
}

test "CP A, E" {
    try cpA_r8(0xBB, reg.E, 0xF3);
}

test "CP A, H" {
    try cpA_r8(0xBC, reg.H, 0xF3);
}

test "CP A, L" {
    try cpA_r8(0xBD, reg.L, 0xF3);
}

test "CP A, [HL]" {
    init(0xBE);
    exe.cpu.setHL(0x55);
    exe.ram.write(0x55, 0xF3);
    try cpA();
}

test "CP A, A" {
    init(0xBF);
    exe.cpu.setRegister(reg.A, 0xF0);
    _ = exe.execute();
    try expect(exe.cpu.getZ() == 1);
    try expect(exe.cpu.getN() == 1);
    try expect(exe.cpu.getH() == 0);
    try expect(exe.cpu.getC() == 0);
}
