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
    exe.execute();
    try expect(exe.cpu.PC == 12);
}

test "JR NZ, e8" {
    initTestJr(0x20);
    exe.cpu.setZ(0);
    exe.execute();
    try expect(exe.cpu.PC == 12);
}

test "JR NZ, e8 - not jumping" {
    initTestJr(0x20);
    exe.cpu.setZ(1);
    exe.execute();
    try expect(exe.cpu.PC == 2);
}

test "JR N, e8" {
    initTestJr(0x28);
    exe.cpu.setZ(1);
    exe.execute();
    try expect(exe.cpu.PC == 12);
}

test "JR N, e8 - not jumping" {
    initTestJr(0x28);
    exe.cpu.setZ(0);
    exe.execute();
    try expect(exe.cpu.PC == 2);
}

test "JR NC, e8" {
    initTestJr(0x30);
    exe.cpu.setC(0);
    exe.execute();
    try expect(exe.cpu.PC == 12);
}

test "JR NC, e8 - not jumping" {
    initTestJr(0x30);
    exe.cpu.setC(1);
    exe.execute();
    try expect(exe.cpu.PC == 2);
}

test "JR C, e8" {
    initTestJr(0x38);
    exe.cpu.setC(1);
    exe.execute();
    try expect(exe.cpu.PC == 12);
}

test "JR C, e8 - not jumping" {
    initTestJr(0x38);
    exe.cpu.setC(0);
    exe.execute();
    try expect(exe.cpu.PC == 2);
}
