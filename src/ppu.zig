const std = @import("std");

pub const Ppu = struct {
    cycles: u16,
    lcdc: u8,
    scy: u8,
    scx: u8,
    stat: u8,
    ly: u8,
    lyc: u8,
    bgp: u8,
    obp0: u8,
    obp1: u8,
    mode0: bool,
    mode1: bool,
    mode2: bool,
    mode3: bool,

    pub fn init() Ppu {
        return Ppu{};
    }

    pub fn update(self: *Ppu, Tcycles: u8) void {
        self.cycles += Tcycles;
        if (self.cycles >= 0 and self.cycles <= 80) {
            //execute mode 2 if not executes before
            self.mode0 = false;
            self.mode1 = false;
            self.mode2 = true;
            self.mode3 = false;
        } else {
            //execute mode 3 return and do mode 0
            self.mode0 = false;
            self.mode1 = false;
            self.mode2 = false;
            self.mode3 = true;
        }
    }

    //LCDC
    pub fn setLcdc(self: *Ppu, value: u8) void {
        self.lcdc = value;
    }
    pub fn getLcdc(self: *Ppu) u8 {
        return self.lcdc;
    }
    //SCY
    pub fn setScy(self: *Ppu, value: u8) void {
        self.scy = value;
    }
    pub fn getScy(self: *Ppu) u8 {
        return self.scy;
    }
    //SCX
    pub fn setScx(self: *Ppu, value: u8) void {
        self.scx = value;
    }
    pub fn getScx(self: *Ppu) u8 {
        return self.scx;
    }
    //STAT
    pub fn setStat(self: *Ppu, value: u8) void {
        self.stat = value;
    }
    pub fn getStat(self: *Ppu) u8 {
        return self.stat;
    }
    //LY
    pub fn setLy(self: *Ppu, value: u8) void {
        self.ly = value;
    }
    pub fn getLy(self: *Ppu) u8 {
        return self.ly;
    }
    //LYC
    pub fn setLyc(self: *Ppu, value: u8) void {
        self.lyc = value;
    }
    pub fn getLyc(self: *Ppu) u8 {
        return self.lyc;
    }
    //BGP
    pub fn setBgp(self: *Ppu, value: u8) void {
        self.bgp = value;
    }
    pub fn getBgp(self: *Ppu) u8 {
        return self.bgp;
    }
    //OBP0
    pub fn setObp0(self: *Ppu, value: u8) void {
        self.obp0 = value;
    }
    pub fn getObp0(self: *Ppu) u8 {
        return self.obp0;
    }
    //OBP1
    pub fn setObp1(self: *Ppu, value: u8) void {
        self.obp1 = value;
    }
    pub fn getObp1(self: *Ppu) u8 {
        return self.obp1;
    }
};
