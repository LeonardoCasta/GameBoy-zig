const std = @import("std");
const exec = @import("execute.zig");
const Btns = @import("btns.zig").Btns;
const Timers = @import("timer.zig").Timers;
const Graphic = @import("graphic.zig").Graphic;
const Ppu = @import("ppu.zig").Ppu;
const cpuClock = 4194304;
const cpuDoubleClock = 8328608;
const cpuClockTimeElapsed: f128 = 1 / cpuClock;
const cpuDoubleClockTimeElapsed: f128 = 1 / cpuDoubleClock;

pub fn main(init: std.process.Init) void {
    // raylib graphic init
    Graphic.init();
    var timer: f128 = 0;

    var btns: Btns = Btns.init();
    var timers: Timers = Timers.init();
    var ppu: Ppu = Ppu.init();
    const io = init.io;
    exec.init(io, &btns, &timers, &ppu);

    //boot sequence
    //try boot.boot();
    var selectedClock: f128 = cpuClockTimeElapsed;
    while (!Graphic.WindowShouldClose()) {
        timer += Graphic.GetFrameTime();
        if (timer >= selectedClock) {
            btns.update();
            if (false) {
                //update buttons
                btns.update();
                //execute instruction
                const tCycles = exec.execute() * 4;

                //advance all other components cpuCycles
                const result: u8 = timers.update(tCycles);
                exec.ram.setIfRegister(result);

                timer -= tCycles * cpuClockTimeElapsed;

                if (exec.ram.isDoubleSpeed) {
                    selectedClock = cpuDoubleClockTimeElapsed;
                } else {
                    selectedClock = cpuClockTimeElapsed;
                }
            }
            //raylib related things
            Graphic.draw(&btns);
            timer = 0;
        }
    }
    Graphic.CloseWindow();
}
