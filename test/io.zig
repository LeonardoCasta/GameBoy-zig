const std = @import("std");
const expect = std.testing.expect;
const exe = @import("execute");

test "set buttons to true" {
    var button = exe.Btns.init();
    var ram = exe.memoryModule.Ram.init(&button);
    ram.write(0xFF00, 0x00);
    try expect(button.selectBtns == true);
    try expect(button.selectDpad == true);
}

test "set buttons to false" {
    var button = exe.Btns.init();
    var ram = exe.memoryModule.Ram.init(&button);
    ram.write(0xFF00, 0xF0);
    try expect(button.selectBtns == false);
    try expect(button.selectDpad == false);
}

test "set pad to true and btn to false" {
    var button = exe.Btns.init();
    var ram = exe.memoryModule.Ram.init(&button);
    ram.write(0xFF00, 0x20);
    try expect(button.selectBtns == false);
    try expect(button.selectDpad == true);
}

test "set pad to false and btn to true" {
    var button = exe.Btns.init();
    var ram = exe.memoryModule.Ram.init(&button);
    ram.write(0xFF00, 0x10);
    try expect(button.selectBtns == true);
    try expect(button.selectDpad == false);
}

test "read buttons" {
    var button = exe.Btns.init();
    var ram = exe.memoryModule.Ram.init(&button);
    ram.write(0xFF00, 0x10);
    button.a = true;
    button.start = true;
    try expect(button.readBtns() == 0b00010110);
}

test "read pad" {
    var button = exe.Btns.init();
    var ram = exe.memoryModule.Ram.init(&button);
    ram.write(0xFF00, 0x20);
    button.up = true;
    button.right = true;
    try expect(button.readBtns() == 0b00101010);
}

test "read but both true or false returns all 0" {
    var button = exe.Btns.init();
    var ram = exe.memoryModule.Ram.init(&button);
    button.a = true;
    button.start = true;
    button.up = true;
    button.right = true;
    ram.write(0xFF00, 0xF0);
    try expect(button.readBtns() == 0b00110000);
    ram.write(0xFF00, 0x00);
    try expect(button.readBtns() == 0b00000000);
}
