const std = @import("std");
const Oam = @import("memory.zig").Oam;
const Vram = @import("memory.zig").Vram;
const State = enum { mode0, mode1, mode2, mode3 };

var lineSprite: [10]u8 = @splat(0xFF);
pub const Ppu = struct {
    state: State,
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
    execState: bool,

    pub fn init() Ppu {
        var ppu = std.mem.zeroInit(Ppu, .{});
        ppu.execState = true;
        return ppu;
    }

    //every frame is divided into rows then every row is draw
    //it starts with mode2 scanning the OEM and last 80 cycles
    //then mode3 draw the 160 visible pixels of the scan line
    //then mode0 (HBlank) will wait to reach 456 t-cycles
    //at the end of all rows, LY == to 144
    //we have mode1 (HBlank), draw non visible pixels, LY == LYC
    //mode2 80 cycles
    //mode3 172 cycles
    //mode0 204 cycles
    pub fn update(self: *Ppu, Tcycles: u8, oam: *Oam, vram: *Vram) void {
        self.cycles = (self.cycles + Tcycles) % 456;
        //need to calculate what state I'm in
        switch (self.state) {
            State.mode2 => {
                if (self.cycles >= 0 and self.cycles <= 80) {
                    oam.accessible = false;
                    vram.accessible = true;
                } else {
                    self.state = State.mode3;
                    self.executeMode2();
                }
            },
            State.mode3 => {
                if (self.cycles >= 81 and self.cycles <= 252) {
                    oam.accessible = false;
                    vram.accessible = false;
                } else {
                    self.state = State.mode3;
                    self.executeMode3();
                }
            },
            State.mode0 => {
                if (self.cycles < 456) {
                    oam.accessible = true;
                    vram.accessible = true;
                } else {
                    //is last line?
                    if (self.ly < 144) {
                        self.state = State.mode2;
                    } else {
                        self.state = State.mode1;
                    }
                    self.ly += 1;
                }
            },
            State.mode1 => {
                if (self.cycles < 153) {
                    oam.accessible = true;
                    vram.accessible = true;
                } else {
                    //TODO VBlank logic
                    self.ly == 0;
                }
            },
        }

        //compare LY to LCY, if equal update STAT
        if (self.ly == self.lyc) {
            //idk yet
        }

        switch (self.state) {
            State.mode0 => {
                if (!self.execState) {
                    return;
                }
                //line is done wait and reset all i need to reset
                @memset(&lineSprite, 0xFF);
            },
            State.mode1 => {
                if (!self.execState) {
                    return;
                }
            },
            State.mode2 => {
                if (!self.execState) {
                    return;
                }
                //scan oem for sprites and seve the first 10
                //if ly == oam.y - 16 then is visible in that line
                var spriteCount: u8 = 0;
                var i: usize = 0;
                while (i < 40) : (i += 4) {
                    const spriteLength: i16 = if (self.getLcdcBit(2) == 0) 8 else 16;
                    const spriteY: i16 = oam.oam[i] - 16;
                    //not in the row
                    if (!(self.ly >= spriteY and self.ly < spriteY + spriteLength))
                        continue;
                    if (spriteCount >= 10)
                        break;

                    //save sprite to list and increase count
                    lineSprite[spriteCount] = i;
                    spriteCount += 1;
                }
                self.execState = false;
            },
            State.mode3 => {
                if (!self.execState) {
                    //if mode finish incremente ly
                    return;
                }
            },
            State.start => return,
        }
    }

    //LCDC
    pub fn setLcdc(self: *Ppu, value: u8) void {
        self.lcdc = value;
    }
    pub fn getLcdc(self: *Ppu) u8 {
        return self.lcdc;
    }
    pub fn getLcdcBit(self: *Ppu, value: u8) u1 {
        return (self.lcdc >> value) & 0x01;
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
