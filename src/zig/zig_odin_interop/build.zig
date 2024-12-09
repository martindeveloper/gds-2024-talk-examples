const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zig_odin_interop",
        .root_source_file = b.path("./main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib_build_arg_debug = switch (optimize) {
        .Debug => "-debug",
        else => "",
    };

    const lib_symbols_ext = switch (builtin.target.os.tag) {
        .windows => "pdb",
        .macos => "dSYM",
        else => "",
    };

    const lib_ext = switch (builtin.target.os.tag) {
        .windows => "dll",
        .macos => "dylib",
        else => "so",
    };

    const lib_prefix = switch (builtin.target.os.tag) {
        .macos => "lib",
        else => "",
    };

    const lib_out_symbols_filename = lib_prefix ++ "odin." ++ lib_symbols_ext;
    const lib_out_filename = lib_prefix ++ "odin." ++ lib_ext;

    // Compile Odin-based library
    const lib_command = b.addSystemCommand(&.{"odin"});
    lib_command.addArgs(&.{"build"});
    lib_command.addDirectoryArg(b.path("odin_lib/"));
    lib_command.addArgs(&.{ "-build-mode:dynamic", "-no-entry-point", "-out:" ++ lib_out_filename, lib_build_arg_debug });

    // Executable depends on the build of the Odin library
    exe.step.dependOn(&lib_command.step);

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

    // Copy the lib to the output directory next to the executable
    const lib_install = b.addInstallBinFile(b.path(lib_out_filename), lib_out_filename);
    lib_install.step.dependOn(&lib_command.step);

    var install_step = b.getInstallStep();
    install_step.dependOn(&lib_install.step);

    if (optimize == .Debug) {
        switch (builtin.target.os.tag) {
            .windows => {
                // On Windows there is PDB file
                const lib_symbols_install = b.addInstallBinFile(b.path(lib_out_symbols_filename), lib_out_symbols_filename);
                install_step.dependOn(&lib_symbols_install.step);
            },
            .macos => {
                // On macOS there is .dSYM directory
                const lib_dsym_install = b.addInstallBinDir(b.path(lib_out_filename ++ ".dSYM"), lib_out_filename ++ ".dSYM");
                install_step.dependOn(&lib_dsym_install.step);
            },
            else => {
                @panic("Unimplemented OS for debug symbols installation");
            },
        }
    }

    b.installArtifact(exe);

    // NOTE(martin.pernica): Currently known issue, at least on macOS, that dylib paths will be hardcoded as absolute paths, this seems not happen on Windows
    // You need to hack the dylib paths, not sure how to force Zig build to not hardcode it
    // install_name_tool -change "/Users/martin/Projects/Flying-Rat/gds-2025-samples/src/zig/zig_odin_interop/libodin.dylib" "@rpath/libodin.dylib" zig-out/bin/zig_odin_interop
    // Windows:
    // List dependencies of executable use `dumpbin /DEPENDENTS zig_odin_interop.exe`
    // List exported symbols use `dumpbin /EXPORTS odin.dll`
}
