const std = @import("std");
const ray = @cImport({
    @cInclude("raylib.h");
});

const width: u32 = 693;
const height: u32 = 1111;
const maskPath = "../images/final/mask.png";
const maskTexture: ray.Texture2D = undefined;

const Graphic = struct {
    width: i32,
    height: i32,

    pub fn init() Graphic {
        ray.SetTraceLogLevel(ray.LOG_NONE);
        ray.InitWindow(width, height, "Game Boy Color Emulator");
        maskTexture = ray.LoadTexture(maskPath);
        return Graphic{ .width = width, .height = height };
    }

    pub fn WindowShouldClose() bool {
        return ray.WindowShouldClose();
    }

    pub fn CloseWindow() void {
        ray.CloseWindow();
    }

    pub fn GetFrameTime() f32 {
        return ray.GetFrameTime();
    }
};
