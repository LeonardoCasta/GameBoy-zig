pub const instruction = struct {
    length: u8,
    states: u8,
};

pub var instructionTable: [256]instruction = undefined;

//takes the byte and returns the instruction so I know how many bytes to read and cycles
pub fn init() void {
    instructionTable[0x00] = .{ .length = 1, .states = 4 };
    instructionTable[0x80] = .{ .length = 1, .states = 4 };
}
