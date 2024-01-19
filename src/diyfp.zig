const S = @import("std");
const SD = S.debug;
const assert = SD.assert;

const FloatTraits = struct {
    float_type: type,
    frac_uint: type,
    mul_uint: type,
    exp_int: type,

    total_bits: u32,
    frac_bits: u32,
    exp_bits: u32,
    exp_bias: i32,
    frac_mask: u64,
    exp_mask: u64,
    hidden_bit: u64,
};

const FloatTraits64 = FloatTraits{
    .float_type = f64,
    .frac_uint = u64,
    .mul_uint = u128,
    .exp_int = i32,

    .total_bits = 64,
    .frac_bits = 52,
    .exp_bits = 11,
    .exp_bias = 1023 + 52,
    .frac_mask = 0x000FFFFF_FFFFFFFF,
    .exp_mask = 0x7FF00000_00000000,
    .hidden_bit = 0x00100000_00000000,
};

const DiyFp64 = DiyFp(FloatTraits64);

fn DiyFp(comptime traits: FloatTraits) type {
    return struct {
        const This = @This();
        const tr = traits;
        const Float = tr.float_type;
        const Frac = tr.frac_uint;
        const BigFrac = tr.mul_uint;
        const Exp = tr.exp_int;

        frac: Frac,
        exp: Exp,
        // no sign these should all be positive

        pub fn from_parts(f: Frac, e: Exp) This {
            return .{ f, e };
        }

        pub fn from_val(val: Float) This {
            assert(val >= 0);
            const bits: Frac = @bitCast(val);
            const raw_e: Exp = @intCast(bits >> tr.frac_bits);
            const raw_f: Frac = bits & tr.frac_mask;
            var new_f: Frac = undefined;
            var new_e: Exp = undefined;
            if (raw_e != 0) {
                // normalized
                new_f = raw_f | tr.hidden_bit;
                new_e = raw_e - tr.exp_bias;
            } else {
                // denormalized
                new_f = raw_f;
                new_e = 1 + -tr.exp_bias;
            }
            return This{ .frac = new_f, .exp = new_e };
        }

        pub fn minus_ulp(t: This) This {
            return This{ t.f - 1, t.e };
        }

        pub fn plus_ulp(t: This) This {
            return This{ t.f + 1, t.e };
        }

        pub fn multiply(x: This, y: This) This {
            const plus1: BigFrac = comptime {
                @as(BigFrac, 1) << (Frac.bits - 1);
            };
            var ff: BigFrac = @as(BigFrac, x.frac) * @as(BigFrac, y.frac);
            ff += plus1;
            const upper_ff: Frac = @intCast(ff >> Frac.bits);
            const ee: Exp = x.exp + y.exp + 64;
            return .{ upper_ff, ee };
        }

        pub fn minus(x: This, y: This) This {
            assert(x.exp == y.exp);
            assert(x.frac >= y.frac);
            return .{ x.frac - y.frac, x.exp };
        }

        pub fn normalize(s: This) This {
            var n = @clz(s.frac);
            return .{ s.frac << n, s.exp - n };
        }

        pub fn normalizePlus(s: This) This {
            const p: This = .{ (s.frac << 1) + 1, s.exp - 1 };
            return p.normalize();
        }

        pub fn normalizeMinus(s: This) This {
            var p: This = undefined;
            if (s.frac == s.tr.hidden_bit) {
                p = .{ (s.frac << 2) - 1, s.e - 2 };
            } else {
                p = .{ (s.frac << 1) - 1, s.e - 1 };
            }
            return p.normalize();
        }
    };
}

// --- --- TESTING --- ---

const ST = S.testing;
const STEE = ST.expectEqual;

test "diyfp f64 ints" {
    const diy = DiyFp64.from_val(123.0);
    try STEE(diy.frac, 8655355533852672);
    try STEE(diy.exp, -46);
}
