const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zig_odin_interop",
        .root_source_file = b.path("./main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Compile Odin-based library
    const odin_lib_cmd = b.addSystemCommand(&.{"odin"});
    odin_lib_cmd.addArgs(&.{"build"});
    odin_lib_cmd.addDirectoryArg(b.path("odin_lib/"));
    odin_lib_cmd.addArgs(&.{ "-build-mode:dynamic", "-no-entry-point", "-out:libodin.dylib" });

    // Executable depends on the build of the Odin library
    exe.step.dependOn(&odin_lib_cmd.step);

    // Add the current directory to the library path
    // This is necessary to find the dylib at runtime
    // In practice you would like to use static lib if you can, but Odin can not produce static libraries on macOS for now
    exe.addLibraryPath(b.path("./"));
    exe.linkSystemLibrary2("odin", .{
        .needed = true,
        .weak = false,
        .preferred_link_mode = .dynamic,
        .search_strategy = .no_fallback,
    });
    exe.root_module.addRPathSpecial("@executable_path/");

    exe.linkLibC();

    // Copy the dylib to the output directory next to the executable
    const odin_lib_install = b.addInstallBinFile(b.path("libodin.dylib"), "libodin.dylib");
    odin_lib_install.step.dependOn(&odin_lib_cmd.step);

    var install_step = b.getInstallStep();
    install_step.dependOn(&odin_lib_install.step);

    b.installArtifact(exe);

    // TODO(martin.pernica): Ask about this on Zig Discord
    // You need to hack the dylib paths, not sure how to force Zig build to not hardcode it
    // install_name_tool -change "/Users/martin/Projects/Flying-Rat/gds-2025-samples/src/zig/zig_odin_interop/libodin.dylib" "@rpath/libodin.dylib" zig-out/bin/zig_odin_interop
}
