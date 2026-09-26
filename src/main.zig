const std = @import("std");
const exec = @import("execute.zig");
const Btns = @import("btns.zig").Btns;
const Timers = @import("timer.zig").Timers;
const Graphic = @import("graphic.zig").Graphic;
const cpuClock = 4194304;
const cpuDoubleClock = 8328608;
const cpuClockTimeElapsed: f128 = 1 / cpuClock;
const cpuDoubleClockTimeElapsed: f128 = 1 / cpuDoubleClock;

pub fn main(init: std.process.Init) void {
    // raylib graphic init
    var x = Graphic.init();

    var timer: f128 = 0;

    var btns: Btns = Btns.init();
    var timers: Timers = Timers.init();
    const io = init.io;
    exec.init(io, &btns, &timers);

    //boot sequence
    //try boot.boot();
    var selectedClock: f128 = cpuClockTimeElapsed;
    while (!x.WindowShouldClose()) {
        timer += x.GetFrameTime();
        if (timer >= selectedClock) {
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
            return;

            //raylib related things
            //ray.BeginDrawing();
            //ray.ClearBackground(ray.RAYWHITE);
            //ray.EndDrawing();
        }
    }
    x.CloseWindow();
}
