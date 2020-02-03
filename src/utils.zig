
const builtin = @import("builtin");

fn deconst(comptime T: type) type {
    switch (@typeInfo(T)) {
        .Pointer => |p_info| {
            var no_const = p_info;
            no_const.is_const = false;
            return @Type(builtin.TypeInfo{ .Pointer = no_const });
        },
        else => @compileError("Not a pointer: " ++ @typeName(T)),
    }
}

pub fn removeConst(ptr: var) deconst(@TypeOf(ptr)) {
    return @intToPtr(deconst(@TypeOf(ptr)), @ptrToInt(ptr));
}