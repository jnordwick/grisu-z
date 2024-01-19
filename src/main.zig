const std = @import("std");
const diy = @import("diyfp.zig");

const DiyFp64 = diy.DiyFp64;

const BaseExp = struct {
    base: u64,
    exp: i32,
    is_neg: bool,
};
