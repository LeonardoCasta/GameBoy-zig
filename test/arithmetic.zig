const std = @import("std");
const expect = std.testing.expect;
const exe = @import("execute");

fn init(instruction: u8) void {
    exe.testInit();
    exe.ram.ram[0] = instruction;
}

test "0x40 ld b, b" {
    init(0x40);
    exe.cpu.reg[2] = 2;
    exe.execute();
    try expect(exe.cpu.reg[2] == 2);
}

test "0x41 ld b, c" {
    init(0x40);
    exe.cpu.reg[2] = 2;
    exe.execute();
    try expect(exe.cpu.reg[2] == 2);
}
