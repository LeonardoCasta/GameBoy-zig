const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});
const exec = @import("execute.zig");

pub fn main(init: std.process.Init) void {
    // see how to handle raylib, maybe in his own file or something
    // Hide all raylib log messages
    ray.SetTraceLogLevel(ray.LOG_NONE);
    ray.InitWindow(800, 450, "raylib [core] example");

    const io = init.io;
    exec.init(io);

    //boot sequence
    //try boot.boot();

    while (!ray.WindowShouldClose()) {
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
