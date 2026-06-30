const std = @import("std");

pub const Cpu = struct {
    SP: u16,
    PC: u16,
    A: u8,
    F: u8,
    // z -> zero flag
    // n subtraction flag
    // h half carry flah
    // c carry flag
    B: u8,
    C: u8,
    D: u8,
    E: u8,
    H: u8,
    L: u8,

    pub fn init() Cpu {
        return Cpu{
            .SP = 0,
            .PC = 0,
            .A = 0,
            .F = 0,
            .B = 0,
            .C = 0,
            .D = 0,
            .E = 0,
            .H = 0,
            .L = 0,
        };
    }
};
