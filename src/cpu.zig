const std = @import("std");

pub const reg = enum { A, F, B, C, D, E, H, L };
pub const reg16 = enum { BC, DE, HL, SP };

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

    pub fn IFE(register: reg) u8 {
        return @intFromEnum(register);
    }

    pub fn getRegister(self: *Cpu, register: reg) u8 {
        const iReg = IFE(register);
        return self.reg[iReg];
    }

    pub fn setRegister(self: *Cpu, register: reg, value: u8) void {
        self.reg[IFE(register)] = value;
    }

    pub fn getSP(self: *Cpu) u16 {
        return self.SP;
    }

    pub fn setSP(self: *Cpu, value: u16) void {
        self.SP = value;
    }

    pub fn getBC(self: *Cpu) u16 {
        const c: u16 = self.reg[IFE(reg.B)];
        const iB: u16 = c << 8;
        const iC: u8 = self.reg[IFE(reg.C)];
        const result: u16 = iB | iC;
        return result;
    }

    pub fn setBC(self: *Cpu, value: u16) void {
        const b: u8 = @truncate((value & 0xFF00) >> 8);
        const c: u8 = @truncate((value & 0x00FF));
        self.reg[IFE(reg.B)] = b;
        self.reg[IFE(reg.C)] = c;
    }

    pub fn getDE(self: *Cpu) u16 {
        const d: u16 = self.reg[IFE(reg.D)];
        const iD: u16 = d << 8;
        const iE: u8 = self.reg[IFE(reg.E)];
        const result: u16 = iD | iE;
        return result;
    }

    pub fn setDE(self: *Cpu, value: u16) void {
        const d: u8 = @truncate((value & 0xFF00) >> 8);
        const e: u8 = @truncate((value & 0x00FF));
        self.reg[IFE(reg.D)] = d;
        self.reg[IFE(reg.E)] = e;
    }

    pub fn getHL(self: *Cpu) u16 {
        const h: u16 = self.reg[IFE(reg.H)];
        const iH: u16 = h << 8;
        const iL: u8 = self.reg[IFE(reg.L)];
        const result: u16 = iH | iL;
        return result;
    }

    pub fn setHL(self: *Cpu, value: u16) void {
        const h: u8 = @truncate((value & 0xFF00) >> 8);
        const l: u8 = @truncate((value & 0x00FF));
        self.reg[IFE(reg.H)] = h;
        self.reg[IFE(reg.L)] = l;
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

    pub fn getH(self: *Cpu) u1 {
        const index = IFE(reg.F);
        const result: u1 = @truncate(((self.reg[index] & 0b00100000) >> 5));
        return result;
    }

    fn setC(self: *Cpu, value: u1) void {
        const index = @intFromEnum(reg.F);
        if (value == 1) {
            self.reg[index] = self.reg[index] | 0b00010000;
        } else {
            self.reg[index] = self.reg[index] & 0b11101111;
        }
    }

    pub fn getC(self: *Cpu) u1 {
        const index = IFE(reg.F);
        const result: u1 = @truncate(((self.reg[index] & 0b00010000) >> 4));
        return result;
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

    pub fn adcHL(self: *Cpu, dest: reg, addend: u16) void {
        const byteAddend: u8 = @truncate(addend);
        self._add(dest, self.reg[@intFromEnum(dest)], byteAddend, true);
    }

    pub fn adcA_HL(self: *Cpu, addend: u16) void {
        self.addHL(reg.A, addend);
    }

    pub fn add_HL_r16(self: *Cpu, second: u16) void {
        const castedHL: u17 = @intCast(self.getHL());
        const result: u17 = castedHL + second;
        //N set to zero
        self.setN(0);
        //H set if overflow from bit 11
        if (result > 0xFFF) {
            self.setH(1);
        } else {
            self.setH(0);
        }
        //C set if overflow from bit 15
        if (result > 0xFFFF) {
            self.setC(1);
        } else {
            self.setC(0);
        }

        self.setHL(@truncate(result));
    }

    pub fn add_SP_e8(self: *Cpu, value: i8) void {
        const iSP: i32 = @bitCast(self.getSP());
        const iResult = iSP + @as(i32, value);
        const uResult: u32 = @bitCast(iResult);
        self.setSP(@intCast(uResult));
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

    pub fn subHL(self: *Cpu, dest: reg, subtrahend: u16) void {
        const byteSubtrahend: u8 = @truncate(subtrahend);
        self._sub(dest, self.reg[@intFromEnum(dest)], byteSubtrahend, false);
    }

    pub fn subA_HL(self: *Cpu, subtrahend: u16) void {
        self.subHL(reg.A, subtrahend);
    }

    pub fn sbc(self: *Cpu, dest: reg, subtrahend: reg) void {
        self._sub(dest, self.reg[@intFromEnum(dest)], self.reg[@intFromEnum(subtrahend)], true);
    }

    pub fn sbcA(self: *Cpu, subtrahend: reg) void {
        self.sbc(reg.A, subtrahend);
    }

    pub fn sbcHL(self: *Cpu, dest: reg, subtrahend: u16) void {
        const byteSubtrahend: u8 = @truncate(subtrahend);
        self._sub(dest, self.reg[@intFromEnum(dest)], byteSubtrahend, true);
    }

    pub fn sbcA_HL(self: *Cpu, subtrahend: u16) void {
        self.sbcHL(reg.A, subtrahend);
    }

    //AND
    fn _and(self: *Cpu, register: reg, first: u8, second: u8) void {
        const result: u8 = first & second;

        //Z register set to zero if result is zero
        if (result == 0) {
            self.setZ(0);
        } else {
            self.setZ(1);
        }
        //N set to zero
        self.setN(0);
        //H set if borrow from bit 4
        self.setH(1);
        //C set if borrow from bit seven
        self.setC(0);

        self.reg[@intFromEnum(register)] = result;
    }

    pub fn andA(self: *Cpu, second: reg) void {
        self._and(reg.A, self.reg[@intFromEnum(reg.A)], self.reg[@intFromEnum(second)]);
    }

    pub fn andHL(self: *Cpu, dest: reg, second: u16) void {
        const byte: u8 = @truncate(second);
        self._and(dest, self.reg[@intFromEnum(dest)], byte);
    }

    pub fn andA_HL(self: *Cpu, second: u16) void {
        self.andHL(reg.A, second);
    }

    //OR
    fn _or(self: *Cpu, register: reg, first: u8, second: u8) void {
        const result: u8 = first | second;

        //Z register set to zero if result is zero
        if (result == 0) {
            self.setZ(0);
        } else {
            self.setZ(1);
        }
        //N set to zero
        self.setN(0);
        //H set if borrow from bit 4
        self.setH(0);
        //C set if borrow from bit seven
        self.setC(0);

        self.reg[@intFromEnum(register)] = result;
    }

    pub fn orA(self: *Cpu, second: reg) void {
        self._and(reg.A, self.reg[@intFromEnum(reg.A)], self.reg[@intFromEnum(second)]);
    }

    pub fn orHL(self: *Cpu, dest: reg, second: u16) void {
        const byte: u8 = @truncate(second);
        self._and(dest, self.reg[@intFromEnum(dest)], byte);
    }

    pub fn orA_HL(self: *Cpu, second: u16) void {
        self.andHL(reg.A, second);
    }

    //XOR
    fn _xor(self: *Cpu, register: reg, first: u8, second: u8) void {
        const result: u8 = first ^ second;

        //Z register set to zero if result is zero
        if (result == 0) {
            self.setZ(0);
        } else {
            self.setZ(1);
        }
        //N set to zero
        self.setN(0);
        //H set if borrow from bit 4
        self.setH(0);
        //C set if borrow from bit seven
        self.setC(0);

        self.reg[@intFromEnum(register)] = result;
    }

    pub fn xorA(self: *Cpu, second: reg) void {
        self._xor(reg.A, self.reg[@intFromEnum(reg.A)], self.reg[@intFromEnum(second)]);
    }

    pub fn xorHL(self: *Cpu, dest: reg, second: u16) void {
        const byte: u8 = @truncate(second);
        self._and(dest, self.reg[@intFromEnum(dest)], byte);
    }

    pub fn xorA_HL(self: *Cpu, second: u16) void {
        self.xorHL(reg.A, second);
    }

    //CP
    fn _cp(self: *Cpu, first: u8, second: u8) void {
        const result: i16 = first - second;

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
        if (result < 0) {
            self.setC(1);
        } else {
            self.setC(0);
        }
    }

    pub fn cp(self: *Cpu, dest: reg, addend: reg) void {
        self._cp(self.reg[IFE(dest)], self.reg[IFE(addend)]);
    }

    pub fn cpA(self: *Cpu, addend: reg) void {
        self.cp(reg.A, addend);
    }

    pub fn cpHL(self: *Cpu, dest: reg, subtrahend: u16) void {
        const byteSubtrahend: u8 = @truncate(subtrahend);
        self._cp(self.reg[IFE(dest)], byteSubtrahend);
    }

    pub fn cpA_HL(self: *Cpu, subtrahend: u16) void {
        self.cpHL(reg.A, subtrahend);
    }

    //LOAD
    pub fn ld(self: *Cpu, dest: reg, source: reg) void {
        const index = @intFromEnum(dest);
        const value = self.reg[IFE(source)];
        self.reg[index] = value;
    }

    pub fn ld_r16_n16(self: *Cpu, dest: reg16, value: u16) void {
        switch (dest) {
            reg16.BC => {
                self.setBC(value);
            },
            reg16.DE => {
                self.setDE(value);
            },
            reg16.HL => {
                self.setHL(value);
            },
            reg16.SP => {
                self.setSP(value);
            },
        }
    }

    pub fn ld_HL(self: *Cpu, register: reg, value: u8) void {
        const index = IFE(register);
        self.reg[index] = value;
    }
};
