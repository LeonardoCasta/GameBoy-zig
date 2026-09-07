const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});
const exec = @import("execute.zig");
const Btns = @import("btns.zig").Btns;
const Timers = @import("timer.zig").Timers;
const cpuClock = 4194304;
const cpuDoubleClock = 8328608;
const cpuClockTimeElapsed: f128 = 1 / cpuClock;
const cpuDoubleClockTimeElapsed: f128 = 1 / cpuDoubleClock;

pub fn main(init: std.process.Init) void {
    // see how to handle raylib, maybe in his own file or something
    // Hide all raylib log messages
    ray.SetTraceLogLevel(ray.LOG_NONE);
    ray.InitWindow(800, 450, "Game Boy Color Emulator");
    var timer: f128 = 0;

    var btns: Btns = Btns.init();
    var timers: Timers = Timers.init();
    const io = init.io;
    exec.init(io, &btns, &timers);

    //boot sequence
    //try boot.boot();
    var selectedClock: f128 = cpuClockTimeElapsed;
    while (!ray.WindowShouldClose()) {
        timer += ray.GetFrameTime();
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

    ray.CloseWindow();
}
