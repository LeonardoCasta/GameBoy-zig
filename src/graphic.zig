const std = @import("std");
const Btns = @import("btns.zig").Btns;
const ray = @cImport({
    @cInclude("raylib.h");
});

const width: u32 = 693;
const height: u32 = 1111;
const maskPath = "../../images/final/mask.png";
var maskTexture: ray.Texture2D = undefined;
const startPath = "../../images/final/start.png";
var startTexture: ray.Texture2D = undefined;
const startPressedPath = "../../images/final/startPressed.png";
var startPressedTexture: ray.Texture2D = undefined;
const aPath = "../../images/final/a.png";
var aTexture: ray.Texture2D = undefined;
const aPressedPath = "../../images/final/aPressed.png";
var aPressedTexture: ray.Texture2D = undefined;
const bPath = "../../images/final/b.png";
var bTexture: ray.Texture2D = undefined;
const bPressedPath = "../../images/final/bPressed.png";
var bPressedTexture: ray.Texture2D = undefined;
const dpadPath = "../../images/final/dpad.png";
var dpadTexture: ray.Texture2D = undefined;
const dpadPressedPath = "../../images/final/dpadPressed.png";
var dpadPressedTexture: ray.Texture2D = undefined;

pub const Graphic = struct {
    width: i32 = width,
    height: i32 = height,

    pub fn init() void {
        ray.SetTraceLogLevel(ray.LOG_NONE);
        ray.InitWindow(width, height, "Game Boy Color Emulator");
        maskTexture = ray.LoadTexture(maskPath);
        if (maskTexture.id <= 0) {
            std.debug.print("Error: Failed to load mask!\n", .{});
        }
        startTexture = ray.LoadTexture(startPath);
        if (startTexture.id <= 0) {
            std.debug.print("Error: Failed to load start!\n", .{});
        }
        startPressedTexture = ray.LoadTexture(startPressedPath);
        if (startPressedTexture.id <= 0) {
            std.debug.print("Error: Failed to load start pressed!\n", .{});
        }
        aTexture = ray.LoadTexture(aPath);
        if (aTexture.id <= 0) {
            std.debug.print("Error: Failed to load a!\n", .{});
        }
        aPressedTexture = ray.LoadTexture(aPressedPath);
        if (aPressedTexture.id <= 0) {
            std.debug.print("Error: Failed to load a pressed!\n", .{});
        }
        bTexture = ray.LoadTexture(bPath);
        if (bTexture.id <= 0) {
            std.debug.print("Error: Failed to load b!\n", .{});
        }
        bPressedTexture = ray.LoadTexture(bPressedPath);
        if (bPressedTexture.id <= 0) {
            std.debug.print("Error: Failed to load b pressed!\n", .{});
        }
        dpadTexture = ray.LoadTexture(dpadPath);
        if (dpadTexture.id <= 0) {
            std.debug.print("Error: Failed to load dpad!\n", .{});
        }
        dpadPressedTexture = ray.LoadTexture(dpadPressedPath);
        if (dpadPressedTexture.id <= 0) {
            std.debug.print("Error: Failed to load dpad pressed!\n", .{});
        }
    }

    pub fn draw(btns: *Btns) void {
        ray.BeginDrawing();
        ray.ClearBackground(ray.BLACK);
        ray.DrawTexture(maskTexture, 0, 0, ray.WHITE);
        ray.DrawTexture(if (!btns.start) startTexture else startPressedTexture, 254 - 4, 893 - 4, ray.WHITE);
        ray.DrawTexture(if (!btns.select) startTexture else startPressedTexture, 365 - 4, 893 - 4, ray.WHITE);
        ray.DrawTexture(if (!btns.a) aTexture else aPressedTexture, 544 - 13, 661 - 9, ray.WHITE);
        ray.DrawTexture(if (!btns.b) bTexture else bPressedTexture, 423 - 7, 715 - 9, ray.WHITE);
        ray.DrawTexture(if (!(btns.up or btns.down or btns.left or btns.right)) dpadTexture else dpadPressedTexture, 78 - 6, 644 - 8, ray.WHITE);

        //add screen draw
        ray.EndDrawing();
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
