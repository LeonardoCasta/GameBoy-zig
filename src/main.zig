const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});
const exec = @import("execute.zig");
const Btns = @import("btns.zig").Btns;
const cpuClock = 4194304;

pub fn main(init: std.process.Init) void {
    // see how to handle raylib, maybe in his own file or something
    // Hide all raylib log messages
    ray.SetTraceLogLevel(ray.LOG_NONE);
    ray.InitWindow(800, 450, "raylib [core] example");
    var timer: f128 = 0;

    var btns: Btns = Btns.init();
    const io = init.io;
    exec.init(io, &btns);

    //boot sequence
    //try boot.boot();
    while (!ray.WindowShouldClose()) {
        timer += ray.GetFrameTime();
        if (timer >= 1 / cpuClock) {
            //update buttons
            btns.update();
            //execute instruction
            const cpuCycles = exec.execute() * 4;

            timer -= timeElapsed;

            //advance all other components cpuCycles
            return;

            //raylib related things
            //ray.BeginDrawing();
            //ray.ClearBackground(ray.RAYWHITE);
            //ray.EndDrawing();

        }
    }

    ray.CloseWindow();
}
