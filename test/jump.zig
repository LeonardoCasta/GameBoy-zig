const std = @import("std");
const expect = std.testing.expect;
const exe = @import("execute");

fn init(instruction: u8) void {
    exe.testInit();
    exe.ram.write(0, instruction);
}
