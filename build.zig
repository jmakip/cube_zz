// build.zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "cube",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    // NOTE: Bring the external library as a dependency
    const raylib_dep = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
        // NOTE: This is how to set options for the external library
        .shared = false,
        //.linux_display_backend = .X11,
    });
    const raylib = raylib_dep.artifact("raylib");
    //exe.addIncludePath(.{ .path = "raylib/src/" });
    exe.linkLibrary(raylib);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
