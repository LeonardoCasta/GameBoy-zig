const std = @import("std");
const Io = std.Io;
const ray = @cImport({
    @cInclude("raylib.h");
});
const GameBoy = @import("GameBoy");
//init: std.process.Init
pub fn main() void {
    // Hide all raylib log messages
        ray.SetTraceLogLevel(ray.LOG_NONE);

        ray.InitWindow(800, 450, "raylib [core] example");

        while (!ray.WindowShouldClose()) {
            ray.BeginDrawing();
            ray.ClearBackground(ray.RAYWHITE);
            ray.EndDrawing();
        }

        ray.CloseWindow();
}
