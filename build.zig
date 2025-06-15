const std = @import("std");

fn configureTests(b: *std.Build, test_step: *std.Build.Step) void {
    // List of test files
    const test_files = [_][]const u8{
        "src/filter.zig",
        "src/map.zig",
    };

    // _ = test_step;
    // Add each test file and depend on its step
    var i: usize = 0;
    while (i < test_files.len) : (i += 1) {
        const t = b.addTest(.{ .root_source_file = .{ .cwd_relative = test_files[i] } });
        const run_t = b.addRunArtifact(t); // Create a run step
        test_step.dependOn(&run_t.step);
    }
}
// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // This creates a "module", which represents a collection of source files alongside
    // some compilation options, such as optimization mode and linked system libraries.
    // Every executable or library we compile will be based on one or more modules.
    const lib_mod = b.createModule(.{
        // `root_source_file` is the Zig "entry point" of the module. If a module
        // only contains e.g. external object files, you can make this `null`.
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zkit",
        .root_module = lib_mod,
    });
    const zkit_mod = b.addModule("zkit", .{
        .root_source_file = .{ .cwd_relative = "src/root.zig" },
        .imports = &.{},
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("zkit", zkit_mod);
    b.default_step.dependOn(&lib.step);

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    // test_step.dependOn(&run_exe_unit_tests.step);

    configureTests(b, &run_lib_unit_tests.step);
}
