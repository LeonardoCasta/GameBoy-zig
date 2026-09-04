const std = @import("std");

pub const Timers = struct {
    timer: u16,
    tima: u8,
    tma: u8,
    clockSelect: u2,
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
        self.timer = 0;
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
        self.enable = enableValue;
    }

    pub fn setClockSelect(self: *Timers, byte: u8) void {
        const csValue: u2 = @truncate(byte & 0b00000011);
        switch (csValue) {
            0b00 => {
                self.clockSelect = 0;
            },
            0b01 => {
                self.clockSelect = 0;
            },
            0b10 => {
                self.clockSelect = 0;
            },
            0b11 => {
                self.clockSelect = 0;
            },
        }
    }

    pub fn update(self: *Timers, tCycles: u8) void {
        self.timer +%= tCycles;
        if (self.enable == 1) {
            //increase tima
        }
    }
};
