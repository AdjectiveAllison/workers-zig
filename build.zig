const std = @import("std");
const LibraryOptions = std.Build.SharedLibraryOptions;

pub fn build(b: *std.Build) void {
    const wasm_build_options = LibraryOptions{
        .name = "zig",
        .root_source_file = std.Build.LazyPath.relative("lib/main.zig"),
        .optimize = std.builtin.OptimizeMode.ReleaseSmall,
        .target = std.zig.CrossTarget{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding,
        },
        //.main_pkg_path = std.Build.LazyPath.relative("lib"),
    };

    // ensure main is building
    const wasm_build = b.addSharedLibrary(wasm_build_options);
    b.installArtifact(wasm_build);

    const tests_build_options = LibraryOptions{
        .name = "zigWASM",
        .root_source_file = std.Build.LazyPath.relative("lib/tests.zig"),
        .optimize = std.builtin.OptimizeMode.ReleaseSmall,
        .target = std.zig.CrossTarget{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding,
        },
    };
    // build tests for freestanding wasm
    const tests_build = b.addSharedLibrary(tests_build_options);

    tests_build.addAnonymousModule("workers-zig", .{ .source_file = std.Build.LazyPath.relative("lib/main.zig") });

    b.installArtifact(tests_build);

    const tests_wasi_build_options = LibraryOptions{
        .name = "zigWASI",
        .root_source_file = std.Build.LazyPath.relative("lib/testsWASI.zig"),
        .optimize = std.builtin.OptimizeMode.ReleaseSmall,
        .target = std.zig.CrossTarget{ .cpu_arch = .wasm32, .os_tag = .wasi },
    };

    // build tests for wasi wasm
    const tests_wasi_build = b.addSharedLibrary(tests_wasi_build_options);
    tests_wasi_build.addAnonymousModule("workers-zig", .{ .source_file = std.Build.LazyPath.relative("lib/main.zig") });

    b.installArtifact(tests_wasi_build);

    const exe_tests = b.addTest(.{ .root_source_file = std.Build.LazyPath.relative("lib/main.zig") });

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
