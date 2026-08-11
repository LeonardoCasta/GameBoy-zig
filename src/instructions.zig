pub const Instruction = struct {
    length: u8,
    cycles: u8,
    cycles_taken: u8 = 0, // 0 = unconditional
};

pub var base: [256]Instruction = undefined;
pub var cb: [256]Instruction = undefined;

fn set(op: u8, len: u8, cyc: u8) void {
    base[op] = .{ .length = len, .cycles = cyc };
}

fn setCond(op: u8, len: u8, not_taken: u8, taken: u8) void {
    base[op] = .{
        .length = len,
        .cycles = not_taken,
        .cycles_taken = taken,
    };
}

fn setCb(op: u8, cyc: u8) void {
    cb[op] = .{ .length = 2, .cycles = cyc };
}

pub fn init() void {
    // -----------------------------------------------------------------
    // Default everything to an invalid 1-byte 1-cycle instruction.
    // -----------------------------------------------------------------
    for (0..256) |i| {
        base[i] = .{ .length = 1, .cycles = 1 };
        cb[i] = .{ .length = 2, .cycles = 2 };
    }

    // =========================
    // 0x00 - 0x0F
    // =========================
    set(0x00, 1, 1); // NOP
    set(0x01, 3, 3); // LD BC,d16
    set(0x02, 1, 2);
    set(0x03, 1, 2);
    set(0x04, 1, 1);
    set(0x05, 1, 1);
    set(0x06, 2, 2);
    set(0x07, 1, 1);
    set(0x08, 3, 5);
    set(0x09, 1, 2);
    set(0x0A, 1, 2);
    set(0x0B, 1, 2);
    set(0x0C, 1, 1);
    set(0x0D, 1, 1);
    set(0x0E, 2, 2);
    set(0x0F, 1, 1);

    // =========================
    // 0x10 - 0x1F
    // =========================
    set(0x10, 2, 1); // STOP (Pan Docs convention)
    set(0x11, 3, 3);
    set(0x12, 1, 2);
    set(0x13, 1, 2);
    set(0x14, 1, 1);
    set(0x15, 1, 1);
    set(0x16, 2, 2);
    set(0x17, 1, 1);
    setCond(0x18, 2, 3, 3); // JR e8
    set(0x19, 1, 2);
    set(0x1A, 1, 2);
    set(0x1B, 1, 2);
    set(0x1C, 1, 1);
    set(0x1D, 1, 1);
    set(0x1E, 2, 2);
    set(0x1F, 1, 1);

    // =========================
    // 0x20 - 0x3F
    // =========================
    setCond(0x20, 2, 2, 3); // JR NZ,e8
    set(0x21, 3, 3);
    set(0x22, 1, 2);
    set(0x23, 1, 2);
    set(0x24, 1, 1);
    set(0x25, 1, 1);
    set(0x26, 2, 2);
    set(0x27, 1, 1);

    setCond(0x28, 2, 2, 3); // JR Z,e8
    set(0x29, 1, 2);
    set(0x2A, 1, 2);
    set(0x2B, 1, 2);
    set(0x2C, 1, 1);
    set(0x2D, 1, 1);
    set(0x2E, 2, 2);
    set(0x2F, 1, 1);

    setCond(0x30, 2, 2, 3); // JR NC,e8
    set(0x31, 3, 3);
    set(0x32, 1, 2);
    set(0x33, 1, 2);
    set(0x34, 1, 3);
    set(0x35, 1, 3);
    set(0x36, 2, 3);
    set(0x37, 1, 1);

    setCond(0x38, 2, 2, 3); // JR C,e8
    set(0x39, 1, 2);
    set(0x3A, 1, 2);
    set(0x3B, 1, 2);
    set(0x3C, 1, 1);
    set(0x3D, 1, 1);
    set(0x3E, 2, 2);
    set(0x3F, 1, 1);

    // -----------------------------------------------------------------
    // LD r,r' block
    // -----------------------------------------------------------------
    inline for (0x40..0x80) |op| {
        if (op == 0x76)
            set(@intCast(op), 1, 1) // HALT
        else if ((op & 0x07) == 0x06 or ((op >> 3) & 0x07) == 0x06)
            set(@intCast(op), 1, 2) // accesses (HL)
        else
            set(@intCast(op), 1, 1);
    }

    // -----------------------------------------------------------------
    // ALU A,r block
    // -----------------------------------------------------------------
    inline for (0x80..0xC0) |op| {
        if ((op & 0x07) == 0x06)
            set(@intCast(op), 1, 2)
        else
            set(@intCast(op), 1, 1);
    }

    // =========================
    // 0xC0 - 0xCF
    // =========================
    setCond(0xC0, 1, 2, 5);
    set(0xC1, 1, 3);
    setCond(0xC2, 3, 3, 4);
    set(0xC3, 3, 4);
    setCond(0xC4, 3, 3, 6);
    set(0xC5, 1, 4);
    set(0xC6, 2, 2);
    set(0xC7, 1, 4);

    setCond(0xC8, 1, 2, 5);
    set(0xC9, 1, 4);
    setCond(0xCA, 3, 3, 4);
    set(0xCB, 2, 1); // PREFIX CB
    // 0xCC exists
    setCond(0xCC, 3, 3, 6);
    set(0xCD, 3, 6);
    set(0xCE, 2, 2);
    set(0xCF, 1, 4);

    // =========================
    // 0xD0 - 0xDF
    // =========================
    setCond(0xD0, 1, 2, 5);
    set(0xD1, 1, 3);
    setCond(0xD2, 3, 3, 4);
    // 0xD3 invalid
    setCond(0xD4, 3, 3, 6);
    set(0xD5, 1, 4);
    set(0xD6, 2, 2);
    set(0xD7, 1, 4);

    setCond(0xD8, 1, 2, 5);
    set(0xD9, 1, 4);
    setCond(0xDA, 3, 3, 4);
    // 0xDB invalid
    setCond(0xDC, 3, 3, 6);
    // 0xDD invalid
    set(0xDE, 2, 2);
    set(0xDF, 1, 4);

    // =========================
    // 0xE0 - 0xEF
    // =========================
    set(0xE0, 2, 3);
    set(0xE1, 1, 3);
    set(0xE2, 1, 2);
    // 0xE3,0xE4 invalid
    set(0xE5, 1, 4);
    set(0xE6, 2, 2);
    set(0xE7, 1, 4);

    set(0xE8, 2, 4);
    set(0xE9, 1, 1);
    set(0xEA, 3, 4);
    // 0xEB..0xED invalid
    set(0xEE, 2, 2);
    set(0xEF, 1, 4);

    // =========================
    // 0xF0 - 0xFF
    // =========================
    set(0xF0, 2, 3);
    set(0xF1, 1, 3);
    set(0xF2, 1, 2);
    set(0xF3, 1, 1);
    // 0xF4 invalid
    set(0xF5, 1, 4);
    set(0xF6, 2, 2);
    set(0xF7, 1, 4);

    set(0xF8, 2, 3);
    set(0xF9, 1, 2);
    set(0xFA, 3, 4);
    set(0xFB, 1, 1);
    // 0xFC,0xFD invalid
    set(0xFE, 2, 2);
    set(0xFF, 1, 4);

    // -----------------------------------------------------------------
    // CB-prefixed table
    // -----------------------------------------------------------------

    // Rotates / shifts / swap
    inline for (0x00..0x40) |op| {
        if ((op & 0x07) == 0x06)
            setCb(@intCast(op), 4)
        else
            setCb(@intCast(op), 2);
    }

    // BIT b,r
    inline for (0x40..0x80) |op| {
        if ((op & 0x07) == 0x06)
            setCb(@intCast(op), 3)
        else
            setCb(@intCast(op), 2);
    }

    // RES b,r
    inline for (0x80..0x100) |op| {
        if ((op & 0x07) == 0x06)
            setCb(@intCast(op), 4)
        else
            setCb(@intCast(op), 2);
    }
}
