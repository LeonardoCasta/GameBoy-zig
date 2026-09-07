const std = @import("std");

pub const Timers = struct {
    timer: u16,
    tima: u8,
    tma: u8,
    clockSelect: u4,
    enable: u1,
    isDoubleSpeed: u1,

    pub fn init() Timers {
        return Timers{ .timer = 0, .tima = 0, .tma = 0, .clockSelect = 0, .enable = 0, .isDoubleSpeed = 0 };
    }

    pub fn getDiv(self: *Timers) u8 {
        const result: u8 = @truncate(self.timer >> 8);
        return result;
    }
    pub fn resetDiv(self: *Timers) void {
        const bitBefore = getTimaBit(self);
        self.timer = 0;
        if (self.enable == 1 and bitBefore == 1) {
            const res, const overflow = @addWithOverflow(self.tima, 1);
            self.tima = res;
            if (overflow == 1) {
                self.tima = self.tma;
                return 0b00000100;
            }
        }
    }

    pub fn resetTima(self: *Timers) void {
        self.tima = 0;
    }

    pub fn getTima(self: *Timers) u8 {
        return self.tima;
    }

    pub fn setTma(self: *Timers, value: u8) void {
        self.tma = value;
    }

    pub fn setTac(self: *Timers, value: u8) void {
        self.setEnable(value);
        self.setClockSelect(value);
    }

    pub fn setEnable(self: *Timers, byte: u8) void {
        const enableValue: u1 = @truncate(byte & 0b00000100);
        const oldEnable = self.enable;
        self.enable = enableValue;
        const bitBefore = getTimaBit(self);
        if (bitBefore == 1 and oldEnable == 1 and self.enable == 1) {
            const res, const overflow = @addWithOverflow(self.tima, 1);
            self.tima = res;
            if (overflow == 1) {
                self.tima = self.tma;
                return 0b00000100;
            }
        }
    }

    pub fn setClockSelect(self: *Timers, byte: u8) void {
        const csValue: u2 = @truncate(byte & 0b00000011);
        switch (csValue) {
            0b00 => {
                self.clockSelect = 7;
            },
            0b01 => {
                self.clockSelect = 1;
            },
            0b10 => {
                self.clockSelect = 3;
            },
            0b11 => {
                self.clockSelect = 5;
            },
        }
    }

    pub fn update(self: *Timers, tCycles: u8) u8 {
        // need to implement double speed mode in exec
        while (tCycles > 0) {
            const bitBefore = getTimaBit(self);
            self.timer +%= tCycles;
            if (self.enable == 1) {
                const bitAfter = getTimaBit(self);
                if (bitBefore == 1 and bitAfter == 0) {
                    const res, const overflow = @addWithOverflow(self.tima, 1);
                    self.tima = res;
                    if (overflow == 1) {
                        self.tima = self.tma;
                        return 0b00000100;
                    }
                }
            }
            tCycles -= 1;
        }
        return 0;
    }

    fn getTimaBit(self: *Timers) u1 {
        const bit: u1 = @truncate(self.timer >> self.clockSelect);
        return bit;
    }
};
