const std = @import("std");
const Io = std.Io;
const ray = @cImport({
    @cInclude("raylib.h");
});
const GameBoy = @import("GameBoy");
const memory = @import("memory.zig");

pub fn main(init: std.process.Init) void {
    //see how to handle raylib, maybe in his own file or something
    // Hide all raylib log messages
    ray.SetTraceLogLevel(ray.LOG_NONE);
    ray.InitWindow(800, 450, "raylib [core] example");

    //what I need to do is load the game file and print first instruction
    const io = init.io;
    var game: memory.memory = .{};
    _ = std.Io.Dir.readFile(std.Io.Dir.cwd(), io, "./Games/Pokemon", &game.game) catch {
        std.debug.print("Error while opening game file\n", .{});
        return;
    };
    std.debug.print("{X}{X}\n", .{ game.game[0], game.game[1] });

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        ray.ClearBackground(ray.RAYWHITE);
        ray.EndDrawing();
    }

    ray.CloseWindow();
}
