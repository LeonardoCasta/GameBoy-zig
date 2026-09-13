const std = @import("std");
const expect = std.testing.expect;
const exe = @import("execute");

test "set buttons to true" {
    var button = exe.Btns.init();
    var tmrs = exe.Timers.init();
    var ram = exe.memoryModule.Ram.init(&button, &tmrs);
    ram.write(0xFF00, 0x00);
    try expect(button.selectBtns == true);
    try expect(button.selectDpad == true);
}

test "set buttons to false" {
    var button = exe.Btns.init();
    var tmrs = exe.Timers.init();
    var ram = exe.memoryModule.Ram.init(&button, &tmrs);
    ram.write(0xFF00, 0xF0);
    try expect(button.selectBtns == false);
    try expect(button.selectDpad == false);
}

test "set pad to true and btn to false" {
    var button = exe.Btns.init();
    var tmrs = exe.Timers.init();
    var ram = exe.memoryModule.Ram.init(&button, &tmrs);
    ram.write(0xFF00, 0x20);
    try expect(button.selectBtns == false);
    try expect(button.selectDpad == true);
}

test "set pad to false and btn to true" {
    var button = exe.Btns.init();
    var tmrs = exe.Timers.init();
    var ram = exe.memoryModule.Ram.init(&button, &tmrs);
    ram.write(0xFF00, 0x10);
    try expect(button.selectBtns == true);
    try expect(button.selectDpad == false);
}

test "read buttons" {
    var button = exe.Btns.init();
    var tmrs = exe.Timers.init();
    var ram = exe.memoryModule.Ram.init(&button, &tmrs);
    ram.write(0xFF00, 0x10);
    button.a = true;
    button.start = true;
    try expect(button.readBtns() == 0b00010110);
}

test "read pad" {
    var button = exe.Btns.init();
    var tmrs = exe.Timers.init();
    var ram = exe.memoryModule.Ram.init(&button, &tmrs);
    ram.write(0xFF00, 0x20);
    button.up = true;
    button.right = true;
    try expect(button.readBtns() == 0b00101010);
}

test "read but both true or false returns all 0" {
    var button = exe.Btns.init();
    var tmrs = exe.Timers.init();
    var ram = exe.memoryModule.Ram.init(&button, &tmrs);
    button.a = true;
    button.start = true;
    button.up = true;
    button.right = true;
    ram.write(0xFF00, 0xF0);
    try expect(button.readBtns() == 0b00110000);
    ram.write(0xFF00, 0x00);
    try expect(button.readBtns() == 0b00000000);
}

fn initRam(tmrs: *exe.Timers) exe.memoryModule.Ram {
    var button = exe.Btns.init();
    return exe.memoryModule.Ram.init(&button, tmrs);
}

test "Timers simple increment" {
    var tmrs = exe.Timers.init();
    var ram = initRam(&tmrs);
    const timer = ram.timers.getTimer();
    try expect(timer == 0);
    const ret1 = ram.timers.update(1);
    const ret2 = ram.timers.update(1);
    try expect(ram.timers.timer == 2);
    try expect(ret1 == 0);
    try expect(ret2 == 0);
}

test "div timer test" {
    var tmrs = exe.Timers.init();
    var ram = initRam(&tmrs);
    _ = ram.timers.update(255);
    _ = ram.timers.update(1);
    try expect(tmrs.getDiv() == 1);
    ram.write(0xFF04, 11);
    try expect(tmrs.getDiv() == 0);
}

test "tima timer test" {
    var tmrs = exe.Timers.init();
    var ram = initRam(&tmrs);
    try expect(tmrs.enable == 0);
    try expect(tmrs.clockSelect == 0b00);
    ram.write(0xFF07, 0b00000101);
    try expect(tmrs.enable == 1);
    try expect(tmrs.clockSelect == 0b01);
    _ = ram.timers.update(3);
    try expect(tmrs.tima == 0);
    _ = ram.timers.update(1);
    try expect(tmrs.tima == 1);
    _ = ram.timers.update(2);
    ram.write(0xFF07, 0b00000001);
    try expect(tmrs.tima == 2);
}

test "tma timer test" {
    var tmrs = exe.Timers.init();
    var ram = initRam(&tmrs);
    ram.write(0xFF07, 0b00000101);
    ram.write(0xFF06, 0x33);
    tmrs.tima = 255;
    _ = ram.timers.update(4);
    try expect(tmrs.tima == 0x33);
}
