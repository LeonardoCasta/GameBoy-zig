const std = @import("std");

pub const reg = enum { A, F, B, C, D, E, H, L };

pub const Cpu = struct {
    reg: [8]u8,
    SP: u16,
    PC: u16,
    // z -> zero flag
    // n subtraction flag
    // h half carry flah
    // c carry flag

    pub fn init() Cpu {
        return Cpu{ .SP = 0, .PC = 0, .reg = .{0} ** 8 };
    }

    pub fn getHL(self: *Cpu) u16 {
        const iH: u8 = @intFromEnum(reg.H);
        const iL: u8 = @intFromEnum(reg.L);
        const result: u16 = (self.reg[iH] << 7) | self.reg[iL];
        return result;
    }

    pub fn getC(self: *Cpu) u1 {
        const index = @intFromEnum(reg.F);
        const result: u1 = @truncate(((self.reg[index] & 0b00010000) >> 4));
        return result;
    }

    fn setZ(self: *Cpu, value: u1) void {
        const index = @intFromEnum(reg.F);
        if (value == 1) {
            self.reg[index] = self.reg[index] | 0b10000000;
        } else {
            self.reg[index] = self.reg[index] & 0b01111111;
        }
    }

    fn setN(self: *Cpu, value: u1) void {
        const index = @intFromEnum(reg.F);
        if (value == 1) {
            self.reg[index] = self.reg[index] | 0b01000000;
        } else {
            self.reg[index] = self.reg[index] & 0b10111111;
        }
    }

    fn setH(self: *Cpu, value: u1) void {
        const index = @intFromEnum(reg.F);
        if (value == 1) {
            self.reg[index] = self.reg[index] | 0b00100000;
        } else {
            self.reg[index] = self.reg[index] & 0b11011111;
        }
    }

    fn setC(self: *Cpu, value: u1) void {
        const index = @intFromEnum(reg.F);
        if (value == 1) {
            self.reg[index] = self.reg[index] | 0b00010000;
        } else {
            self.reg[index] = self.reg[index] & 0b11101111;
        }
    }

    //ADDITION
    fn _add(self: *Cpu, register: reg, first: u8, second: u8, addCarry: bool) void {
        var result: u16 = first + second;
        if (addCarry == true) {
            result += self.getC();
        }
        //Z register set to zero if result is zero
        if (result == 0) {
            self.setZ(0);
        } else {
            self.setZ(1);
        }
        //N set to zero
        self.setN(0);
        //H set if overflow from bit 3
        if (result > 15) {
            self.setH(1);
        } else {
            self.setH(0);
        }
        //C set overflow from bit seven
        if (result > 255) {
            self.setC(1);
        } else {
            self.setC(0);
        }

        self.reg[@intFromEnum(register)] = @truncate(result);
    }

    pub fn add(self: *Cpu, dest: reg, addend: reg) void {
        self._add(dest, self.reg[@intFromEnum(dest)], self.reg[@intFromEnum(addend)], false);
    }

    pub fn addA(self: *Cpu, addend: reg) void {
        self.add(reg.A, addend);
    }

    pub fn addHL(self: *Cpu, dest: reg, addend: u16) void {
        const byteAddend: u8 = @truncate(addend);
        self._add(dest, self.reg[@intFromEnum(dest)], byteAddend, false);
    }

    pub fn addA_HL(self: *Cpu, addend: u16) void {
        self.addHL(reg.A, addend);
    }

    pub fn adc(self: *Cpu, dest: reg, addend: reg) void {
        self._add(dest, self.reg[@intFromEnum(dest)], self.reg[@intFromEnum(addend)], true);
    }

    pub fn adcA(self: *Cpu, addend: reg) void {
        self.adc(reg.A, addend);
    }

    pub fn adcL(self: *Cpu, dest: reg, addend: u16) void {
        self._add(dest, self.reg[@intFromEnum(dest)], addend, true);
    }

    pub fn adcA_HL(self: *Cpu, addend: u16) void {
        self.addHL(reg.A, addend);
    }

    //SUBTRACTION
    fn _sub(self: *Cpu, register: reg, first: u8, second: u8, addCarry: bool) void {
        var subtrahend: u8 = second;
        var isBorrow: bool = false;
        var result: u8 = 0;
        if (addCarry == true) {
            subtrahend += self.getC();
        }
        if (first < subtrahend) {
            isBorrow = true;
            result = 255 - (subtrahend - first - 1);
        } else {
            result = first - subtrahend;
        }
        //Z register set to zero if result is zero
        if (result == 0) {
            self.setZ(0);
        } else {
            self.setZ(1);
        }
        //N set to zero
        self.setN(1);
        //H set if borrow from bit 4
        if ((first & 0x0F) < (second & 0x0F)) {
            self.setH(1);
        } else {
            self.setH(0);
        }
        //C set if borrow from bit seven
        if (isBorrow) {
            self.setC(1);
        } else {
            self.setC(0);
        }

        self.reg[@intFromEnum(register)] = result;
    }

    pub fn sub(self: *Cpu, dest: reg, addend: reg) void {
        self._sub(dest, self.reg[@intFromEnum(dest)], self.reg[@intFromEnum(addend)], false);
    }

    pub fn subA(self: *Cpu, addend: reg) void {
        self.sub(reg.A, addend);
    }

    pub fn subHL(self: *Cpu, dest: reg, addend: u16) void {
        const byteAddend: u8 = @truncate(addend);
        self._sub(dest, self.reg[@intFromEnum(dest)], byteAddend, false);
    }

    pub fn subA_HL(self: *Cpu, addend: u16) void {
        self.subHL(reg.A, addend);
    }

    pub fn sbc(self: *Cpu, dest: reg, addend: reg) void {
        self._sub(dest, self.reg[@intFromEnum(dest)], self.reg[@intFromEnum(addend)], true);
    }

    pub fn sbcA(self: *Cpu, addend: reg) void {
        self.sbc(reg.A, addend);
    }

    pub fn sbcHL(self: *Cpu, dest: reg, addend: u16) void {
        self._sub(dest, self.reg[@intFromEnum(dest)], addend, true);
    }

    pub fn sbcA_HL(self: *Cpu, addend: u16) void {
        self.sbcHL(reg.A, addend);
    }
};
