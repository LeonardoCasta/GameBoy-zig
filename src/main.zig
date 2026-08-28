const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});
const exec = @import("execute.zig");
const Btns = @import("btns.zig").Btns;

pub fn main(init: std.process.Init) void {
    // see how to handle raylib, maybe in his own file or something
    // Hide all raylib log messages
    ray.SetTraceLogLevel(ray.LOG_NONE);
    ray.InitWindow(800, 450, "raylib [core] example");

    var btns: Btns = Btns.init();
    const io = init.io;
    exec.init(io, &btns);

    //boot sequence
    //try boot.boot();
    while (!ray.WindowShouldClose()) {
        //update buttons
        btns.update();
        //execute instruction
        exec.execute();
        return;

        //raylib related things
        //ray.BeginDrawing();
        //ray.ClearBackground(ray.RAYWHITE);
        //ray.EndDrawing();
    }

    ray.CloseWindow();
}
