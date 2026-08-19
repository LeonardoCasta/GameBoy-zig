pub const joyp: u16 = 0xFF00;

// Serial
pub const sb: u16 = 0xFF01;
pub const sc: u16 = 0xFF02;

// Timer
pub const div: u16 = 0xFF04;
pub const tima: u16 = 0xFF05;
pub const tma: u16 = 0xFF06;
pub const tac: u16 = 0xFF07;

// Interrupt Flag
pub const if_: u16 = 0xFF0F;

// Audio - Channel 1
pub const nr10: u16 = 0xFF10;
pub const nr11: u16 = 0xFF11;
pub const nr12: u16 = 0xFF12;
pub const nr13: u16 = 0xFF13;
pub const nr14: u16 = 0xFF14;

// Audio - Channel 2
pub const nr21: u16 = 0xFF16;
pub const nr22: u16 = 0xFF17;
pub const nr23: u16 = 0xFF18;
pub const nr24: u16 = 0xFF19;

// Audio - Channel 3
pub const nr30: u16 = 0xFF1A;
pub const nr31: u16 = 0xFF1B;
pub const nr32: u16 = 0xFF1C;
pub const nr33: u16 = 0xFF1D;
pub const nr34: u16 = 0xFF1E;

// Audio - Channel 4
pub const nr41: u16 = 0xFF20;
pub const nr42: u16 = 0xFF21;
pub const nr43: u16 = 0xFF22;
pub const nr44: u16 = 0xFF23;

// Audio - Control
pub const nr50: u16 = 0xFF24;
pub const nr51: u16 = 0xFF25;
pub const nr52: u16 = 0xFF26;

// Wave RAM
pub const wave_ram_start: u16 = 0xFF30;
pub const wave_ram_end: u16 = 0xFF3F;

// LCD / PPU
pub const lcdc: u16 = 0xFF40;
pub const stat: u16 = 0xFF41;
pub const scy: u16 = 0xFF42;
pub const scx: u16 = 0xFF43;
pub const ly: u16 = 0xFF44;
pub const lyc: u16 = 0xFF45;
pub const dma: u16 = 0xFF46;
pub const bgp: u16 = 0xFF47;
pub const obp0: u16 = 0xFF48;
pub const obp1: u16 = 0xFF49;
pub const wy: u16 = 0xFF4A;
pub const wx: u16 = 0xFF4B;

// CGB
pub const key0: u16 = 0xFF4C;
pub const key1: u16 = 0xFF4D;
pub const vbk: u16 = 0xFF4F;

// Boot ROM
pub const bank: u16 = 0xFF50;

// CGB VRAM DMA
pub const hdma1: u16 = 0xFF51;
pub const hdma2: u16 = 0xFF52;
pub const hdma3: u16 = 0xFF53;
pub const hdma4: u16 = 0xFF54;
pub const hdma5: u16 = 0xFF55;

// CGB infrared
pub const rp: u16 = 0xFF56;

// CGB palettes
pub const bcps: u16 = 0xFF68; // BGPI
pub const bcpd: u16 = 0xFF69; // BGPD
pub const ocps: u16 = 0xFF6A; // OBPI
pub const ocpd: u16 = 0xFF6B; // OBPD

// CGB object priority
pub const opri: u16 = 0xFF6C;

// CGB WRAM bank
pub const svbk: u16 = 0xFF70; // WBK

// Undocumented CGB
pub const ff72: u16 = 0xFF72;
pub const ff73: u16 = 0xFF73;
pub const ff74: u16 = 0xFF74;
pub const ff75: u16 = 0xFF75;

// CGB PCM
pub const pcm12: u16 = 0xFF76;
pub const pcm34: u16 = 0xFF77;

// Interrupt Enable
pub const ie: u16 = 0xFFFF;
