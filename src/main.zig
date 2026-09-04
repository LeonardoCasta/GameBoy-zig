const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});
const exec = @import("execute.zig");
const Btns = @import("btns.zig").Btns;
const Timers = @import("timer.zig").Timers;
const cpuClock = 4194304;
const cpuDoubleClock = 8328608;
const cpuClockTimeElapsed = 1 / cpuClock;
const cpuDoubleClockTimeElapsed = 1 / cpuDoubleClock;

pub fn main(init: std.process.Init) void {
    // see how to handle raylib, maybe in his own file or something
    // Hide all raylib log messages
    ray.SetTraceLogLevel(ray.LOG_NONE);
    ray.InitWindow(800, 450, "raylib [core] example");
    var timer: f128 = 0;

    var btns: Btns = Btns.init();
    var timers: Timers = Timers.init();
    const io = init.io;
    exec.init(io, &btns, &timer);

    //boot sequence
    //try boot.boot();
    while (!ray.WindowShouldClose()) {
        timer += ray.GetFrameTime();
        if (timer >= cpuClockTimeElapsed) {
            //update buttons
            btns.update();
            //execute instruction
            const tCycles = exec.execute() * 4;

            //advance all other components cpuCycles
            timers.update(tCycles);

            timer -= tCycles * cpuClockTimeElapsed;
            return;

            //raylib related things
            //ray.BeginDrawing();
            //ray.ClearBackground(ray.RAYWHITE);
            //ray.EndDrawing();

        }
    }

    ray.CloseWindow();
}
