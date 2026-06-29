const instruction = struct {
    length: u8,
    cycles: u8,
};

var instructionTable: [256]instruction = undefined;

pub fn init() void {
    instructionTable[0x00] = .{ .length = 1, .cycles = 1 };
}
