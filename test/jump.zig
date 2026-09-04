const std = @import("std");
const expect = std.testing.expect;
const exe = @import("execute");

fn init(instruction: u8) void {
    exe.testInit();
    exe.ram.write(0, instruction);
}

fn initTestJr(instruction: u8) void {
    init(instruction);
    exe.ram.write(1, 10);
}

test "JR e8" {
    initTestJr(0x18);
    _ = exe.execute();
    try expect(exe.cpu.PC == 12);
}

test "JR NZ, e8" {
    initTestJr(0x20);
    exe.cpu.setZ(0);
    _ = exe.execute();
    try expect(exe.cpu.PC == 12);
}

test "JR NZ, e8 - not jumping" {
    initTestJr(0x20);
    exe.cpu.setZ(1);
    _ = exe.execute();
    try expect(exe.cpu.PC == 2);
}

test "JR N, e8" {
    initTestJr(0x28);
    exe.cpu.setZ(1);
    _ = exe.execute();
    try expect(exe.cpu.PC == 12);
}

test "JR N, e8 - not jumping" {
    initTestJr(0x28);
    exe.cpu.setZ(0);
    _ = exe.execute();
    try expect(exe.cpu.PC == 2);
}

test "JR NC, e8" {
    initTestJr(0x30);
    exe.cpu.setC(0);
    _ = exe.execute();
    try expect(exe.cpu.PC == 12);
}

test "JR NC, e8 - not jumping" {
    initTestJr(0x30);
    exe.cpu.setC(1);
    _ = exe.execute();
    try expect(exe.cpu.PC == 2);
}

test "JR C, e8" {
    initTestJr(0x38);
    exe.cpu.setC(1);
    _ = exe.execute();
    try expect(exe.cpu.PC == 12);
}

test "JR C, e8 - not jumping" {
    initTestJr(0x38);
    exe.cpu.setC(0);
    _ = exe.execute();
    try expect(exe.cpu.PC == 2);
}

//================ JP ==================
fn initTestJp(instruction: u8) void {
    init(instruction);
    exe.ram.write(1, 10);
}

test "JP NZ, a16" {
    initTestJp(0xC2);
    exe.cpu.setZ(0);
    _ = exe.execute();
    try expect(exe.cpu.PC == 10);
}

test "JP NZ, a16 - no jump" {
    initTestJp(0xC2);
    exe.cpu.setZ(1);
    _ = exe.execute();
    try expect(exe.cpu.PC == 3);
}

test "JP Z, a16" {
    initTestJp(0xCA);
    exe.cpu.setZ(1);
    _ = exe.execute();
    try expect(exe.cpu.PC == 10);
}

test "JP Z, a16 - no jump" {
    initTestJp(0xCA);
    exe.cpu.setZ(0);
    _ = exe.execute();
    try expect(exe.cpu.PC == 3);
}

test "JP NC, a16" {
    initTestJp(0xD2);
    exe.cpu.setC(0);
    _ = exe.execute();
    try expect(exe.cpu.PC == 10);
}

test "JP NC, a16 - no jump" {
    initTestJp(0xD2);
    exe.cpu.setC(1);
    _ = exe.execute();
    try expect(exe.cpu.PC == 3);
}

test "JP C, a16" {
    initTestJp(0xDA);
    exe.cpu.setC(1);
    _ = exe.execute();
    try expect(exe.cpu.PC == 10);
}

test "JP C, a16 - no jump" {
    initTestJp(0xDA);
    exe.cpu.setC(0);
    _ = exe.execute();
    try expect(exe.cpu.PC == 3);
}

//============== RST ====================
fn testRst(inst: u8, result: u16) !void {
    init(inst);
    _ = exe.execute();
    try expect(exe.cpu.PC == result);
}

test "RST 00" {
    try testRst(0xC7, 0);
}

test "RST 08" {
    try testRst(0xCF, 0x8);
}

test "RST 10" {
    try testRst(0xD7, 0x10);
}

test "RST 18" {
    try testRst(0xDF, 0x18);
}

test "RST 20" {
    try testRst(0xE7, 0x20);
}

test "RST 28" {
    try testRst(0xEF, 0x28);
}

test "RST 30" {
    try testRst(0xF7, 0x30);
}

test "RST 38" {
    try testRst(0xFF, 0x38);
}

//============== RET ===============
fn initRet(inst: u8) void {
    init(inst);
    exe.ram.write(0xFFFD, 0x04);
    exe.ram.write(0xFFFC, 0x05);
    exe.cpu.setSP(0xFFFC);
}

test "RET NZ" {
    initRet(0xC0);
    exe.cpu.setZ(0);
    _ = exe.execute();
    try expect(exe.cpu.PC == 0x504);
}

test "RET NZ - no ret" {
    initRet(0xC0);
    exe.cpu.setZ(1);
    _ = exe.execute();
    try expect(exe.cpu.PC == 1);
}

test "RET Z" {
    initRet(0xC8);
    exe.cpu.setZ(1);
    _ = exe.execute();
    try expect(exe.cpu.PC == 0x504);
}

test "RET Z - no ret" {
    initRet(0xC8);
    exe.cpu.setZ(0);
    _ = exe.execute();
    try expect(exe.cpu.PC == 1);
}

//============== CALL ===============
//save instruction after in stack
//put PC equals to n16
fn initCall(inst: u8) void {
    init(inst);
    exe.ram.write(1, 0x06);
    exe.ram.write(2, 0x07);
}

test "CALL a16" {
    initCall(0xCD);
    _ = exe.execute();
    try expect(exe.cpu.PC == 0x0706);
    try expect(exe.ram.read(0xFFFD) == 0);
    try expect(exe.ram.read(0xFFFC) == 3);
}

test "CALL NZ, a16" {
    initCall(0xC4);
    exe.cpu.setZ(0);
    _ = exe.execute();
    try expect(exe.cpu.PC == 0x706);
    try expect(exe.ram.read(0xFFFD) == 0);
    try expect(exe.ram.read(0xFFFC) == 3);
}

test "CALL NZ, a16 - not exec" {
    initCall(0xC4);
    exe.cpu.setZ(1);
    _ = exe.execute();
    try expect(exe.cpu.PC == 0x3);
    try expect(exe.ram.read(0xFFFD) == 0);
    try expect(exe.ram.read(0xFFFC) == 0);
}

test "CALL Z, a16" {
    initCall(0xCC);
    exe.cpu.setZ(1);
    _ = exe.execute();
    try expect(exe.cpu.PC == 0x0706);
    try expect(exe.ram.read(0xFFFD) == 0);
    try expect(exe.ram.read(0xFFFC) == 3);
}

test "CALL Z, a16 - not exec" {
    initCall(0xCC);
    exe.cpu.setZ(0);
    _ = exe.execute();
    try expect(exe.cpu.PC == 0x3);
    try expect(exe.ram.read(0xFFFD) == 0);
    try expect(exe.ram.read(0xFFFC) == 0);
}

test "CALL NC, a16" {
    initCall(0xD4);
    exe.cpu.setC(0);
    _ = exe.execute();
    try expect(exe.cpu.PC == 0x0706);
    try expect(exe.ram.read(0xFFFD) == 0);
    try expect(exe.ram.read(0xFFFC) == 3);
}

test "CALL NC, a16 - not exec" {
    initCall(0xD4);
    exe.cpu.setC(1);
    _ = exe.execute();
    try expect(exe.cpu.PC == 0x3);
    try expect(exe.ram.read(0xFFFD) == 0);
    try expect(exe.ram.read(0xFFFC) == 0);
}

test "CALL C, a16" {
    initCall(0xDC);
    exe.cpu.setC(1);
    _ = exe.execute();
    try expect(exe.cpu.PC == 0x0706);
    try expect(exe.ram.read(0xFFFD) == 0);
    try expect(exe.ram.read(0xFFFC) == 3);
}

test "CALL C, a16 - not exec" {
    initCall(0xDC);
    exe.cpu.setC(0);
    _ = exe.execute();
    try expect(exe.cpu.PC == 0x3);
    try expect(exe.ram.read(0xFFFD) == 0);
    try expect(exe.ram.read(0xFFFC) == 0);
}
