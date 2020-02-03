const c =  @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("gdnative_api_struct.gen.h");
});

const std = @import("std");
const testing = std.testing;
const warn = std.debug.warn;
const removeConst = @import("./utils.zig").removeConst;

var api: ?*const c.godot_gdnative_core_api_struct = undefined;
var gdnlib: ?*const c.godot_object = undefined;
var core_1_1_api: ?*const c.godot_gdnative_core_1_1_api_struct = undefined;
var core_1_2_api: ?*const c.godot_gdnative_core_1_2_api_struct = undefined;

var nativescript_api: ?*const c.godot_gdnative_ext_nativescript_api_struct = undefined;
var nativescript_1_1_api: ?*const c.godot_gdnative_ext_nativescript_1_1_api_struct = undefined;
var pluginscript_api: ?*const c.godot_gdnative_ext_pluginscript_api_struct = undefined;
var android_api: ?*const c.godot_gdnative_ext_android_api_struct = undefined;
var arvr_api: ?*const c.godot_gdnative_ext_arvr_api_struct = undefined;
var videodecoder_api: ?*const c.godot_gdnative_ext_videodecoder_api_struct = undefined;
var net_api: ?*const c.godot_gdnative_ext_net_api_struct = undefined;
var net_3_2_api: ?*const c.godot_gdnative_ext_net_3_2_api_struct = undefined;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

export fn test_constructor(obj: ?*c.godot_object, method_data: ?*c_void) ?*c_void {
    warn("test.constructor\n", .{});
    return null;
}

export fn test_destructor(obj: ?*c.godot_object, method_data: ?*c_void, user_data: ?*c_void) void {
    warn("test.destructor\n", .{});
}

export fn test_ready(obj: ?*c.godot_object, method_data: ?*c_void, user_data: ?*c_void, num_args: c_int, args: [*c][*c]c.godot_variant) c.godot_variant {
    var ret: c.godot_variant = undefined;
    if (api) |a| {
        if (a.godot_variant_new_nil) |f| {
            f(&ret);
        }
    }
    warn("_ready()\n", .{});
    return ret;
}

export fn some_test_procedure(data: *u8, args: *c.godot_array) c.godot_variant {
    var ret: c.godot_variant = undefined;
    if (api) |a| {
        if (a.godot_variant_new_int) |f| {
            f(&ret, 42);
        }
    }
    return ret;
}

test "basic add functionality" {
    testing.expect(add(3, 7) == 10);
}

export fn godot_gdnative_init(o: *c.godot_gdnative_init_options) void {
    api = o.*.api_struct;
    gdnlib = o.*.gd_native_library;

    if (api) |a| {
        var core_extensions = a.next;

        while (core_extensions) |ext| {
            if (ext.*.version.major == 1 and ext.*.version.minor == 1) {
                warn("found 1.1\n", .{});
                core_1_1_api = @ptrCast(*const c.godot_gdnative_core_1_1_api_struct, ext);
            } else if (ext.*.version.major == 1 and ext.*.version.minor == 2) {
                warn("found 1.2\n", .{});
                core_1_2_api = @ptrCast(*const c.godot_gdnative_core_1_2_api_struct, ext);
            }
            core_extensions = ext.*.next;
        }

        var i: c_uint = 0;
        while (i < a.num_extensions) : (i += 1) {
            switch (@intToEnum(c.GDNATIVE_API_TYPES, @intCast(c_int, a.extensions[i].*.type)))  {
                .GDNATIVE_EXT_NATIVESCRIPT => {
                    nativescript_api = @ptrCast(*const c.godot_gdnative_ext_nativescript_api_struct, a.extensions[i]);
                    // Next is 1_1.
                    if (a.extensions[i].*.next) |ns| {
                        nativescript_1_1_api = @ptrCast(*const c.godot_gdnative_ext_nativescript_1_1_api_struct, ns);
                    }
                },
                .GDNATIVE_EXT_PLUGINSCRIPT => {
                    pluginscript_api = @ptrCast(*const c.godot_gdnative_ext_pluginscript_api_struct, a.extensions[i]);
                },
                .GDNATIVE_EXT_ANDROID => {
                    android_api = @ptrCast(*const c.godot_gdnative_ext_android_api_struct, a.extensions[i]);
                },
                .GDNATIVE_EXT_ARVR => {
                    arvr_api = @ptrCast(*const c.godot_gdnative_ext_arvr_api_struct, a.extensions[i]);
                },
                .GDNATIVE_EXT_VIDEODECODER => {
                    videodecoder_api = @ptrCast(*const c.godot_gdnative_ext_videodecoder_api_struct, a.extensions[i]);
                },
                .GDNATIVE_EXT_NET => {
                    net_api = @ptrCast(*const c.godot_gdnative_ext_net_api_struct, a.extensions[i]);
                    // Next is 3_2.
                    if (a.extensions[i].*.next) |net| {
                        net_3_2_api = @ptrCast(*const c.godot_gdnative_ext_net_3_2_api_struct, net);
                    }
                },
                else => {

                }
            }
        }
    }
}

export fn godot_gdnative_terminate(o: *c.godot_gdnative_terminate_options) void {
}

export fn godot_nativescript_init(desc: *c_void) void {
    warn("nativescript init\n", .{});

    var destroy_func = c.godot_instance_destroy_func {
        .destroy_func = test_destructor,
        .method_data = null,
        .free_func = null,
    };
    var create_func = c.godot_instance_create_func {
        .create_func = null,
        .method_data = null,
        .free_func = null,
    };
    warn("bytes {x} {x} {x}\n", .{@ptrToInt(create_func.create_func), @ptrToInt(create_func.method_data), @ptrToInt(create_func.free_func)});

    if (nativescript_api) |a| {
        if (a.godot_nativescript_register_class) |f| {
            warn("Adding SimpleClass\n", .{});
            f(desc, "SimpleClass", "Node", create_func, destroy_func);
            warn("Done adding SimpleClass\n", .{});
        }
    }

    if (false) {
        const method = c.godot_instance_method {
            .method = test_ready,
            .method_data = null,
            .free_func = null,
        };

        const attr = c.godot_method_attributes {
            .rpc_type = .GODOT_METHOD_RPC_MODE_DISABLED
        };

        if (nativescript_api) |a| {
            if (a.godot_nativescript_register_method) |f| {
                f(desc, "SimpleClass", "_ready", attr, method);
            }
        }
    }   
}