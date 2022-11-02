const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("zig-sqlite", "src/main.zig");
    lib.addCSourceFile("c_src/sqlite3.c", &[_][]const u8{"-std=c99"});
    lib.linkLibC();
    lib.addIncludePath("c_src");
    lib.setBuildMode(mode);
    lib.install();

    const main_tests = b.addTest("src/main.zig");
    main_tests.addCSourceFile("c_src/sqlite3.c", &[_][]const u8{"-std=c99"});
    main_tests.linkLibC();
    main_tests.addIncludePath("c_src");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
