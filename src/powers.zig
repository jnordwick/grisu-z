const S = @import("std");
const SM = S.math;

const diy = @import("diyfp.zig");
const DiyFp64 = diy.DiyFp64;

const bits_per_10 = @log10(2.0);

const pow5 = [_]u64{
    1,
    5,
    25,
    125,
    625,
    3125,
    15625,
    78125,
    390625,
    1953125,
    9765625,
    48828125,
    244140625,
    1220703125,
    6103515625,
    30517578125,
    152587890625,
    762939453125,
    3814697265625,
    19073486328125,
    95367431640625,
    476837158203125,
    2384185791015625,
    11920928955078125,
    59604644775390625,
    298023223876953125,
    1490116119384765625,
    7450580596923828125,
};

const pow10 = [_]u64{
    1,
    10,
    100,
    1000,
    10000,
    100000,
    1000000,
    10000000,
    100000000,
    1000000000,
    10000000000,
    100000000000,
    1000000000000,
    10000000000000,
    100000000000000,
    1000000000000000,
    10000000000000000,
    100000000000000000,
    1000000000000000000,
};

const pow64f_start_exp10: i32 = -348;
const pow64f = [_]DiyFp64{
    DiyFp64.from_parts(0xfa8fd5a0081c0288, -1220),
    DiyFp64.from_parts(0xbaaee17fa23ebf76, -1193),
    DiyFp64.from_parts(0x8b16fb203055ac76, -1166),
    DiyFp64.from_parts(0xcf42894a5dce35ea, -1140),
    DiyFp64.from_parts(0x9a6bb0aa55653b2d, -1113),
    DiyFp64.from_parts(0xe61acf033d1a45df, -1087),
    DiyFp64.from_parts(0xab70fe17c79ac6ca, -1060),
    DiyFp64.from_parts(0xff77b1fcbebcdc4f, -1034),
    DiyFp64.from_parts(0xbe5691ef416bd60c, -1007),
    DiyFp64.from_parts(0x8dd01fad907ffc3c, -980),
    DiyFp64.from_parts(0xd3515c2831559a83, -954),
    DiyFp64.from_parts(0x9d71ac8fada6c9b5, -927),
    DiyFp64.from_parts(0xea9c227723ee8bcb, -901),
    DiyFp64.from_parts(0xaecc49914078536d, -874),
    DiyFp64.from_parts(0x823c12795db6ce57, -847),
    DiyFp64.from_parts(0xc21094364dfb5637, -821),
    DiyFp64.from_parts(0x9096ea6f3848984f, -794),
    DiyFp64.from_parts(0xd77485cb25823ac7, -768),
    DiyFp64.from_parts(0xa086cfcd97bf97f4, -741),
    DiyFp64.from_parts(0xef340a98172aace5, -715),
    DiyFp64.from_parts(0xb23867fb2a35b28e, -688),
    DiyFp64.from_parts(0x84c8d4dfd2c63f3b, -661),
    DiyFp64.from_parts(0xc5dd44271ad3cdba, -635),
    DiyFp64.from_parts(0x936b9fcebb25c996, -608),
    DiyFp64.from_parts(0xdbac6c247d62a584, -582),
    DiyFp64.from_parts(0xa3ab66580d5fdaf6, -555),
    DiyFp64.from_parts(0xf3e2f893dec3f126, -529),
    DiyFp64.from_parts(0xb5b5ada8aaff80b8, -502),
    DiyFp64.from_parts(0x87625f056c7c4a8b, -475),
    DiyFp64.from_parts(0xc9bcff6034c13053, -449),
    DiyFp64.from_parts(0x964e858c91ba2655, -422),
    DiyFp64.from_parts(0xdff9772470297ebd, -396),
    DiyFp64.from_parts(0xa6dfbd9fb8e5b88f, -369),
    DiyFp64.from_parts(0xf8a95fcf88747d94, -343),
    DiyFp64.from_parts(0xb94470938fa89bcf, -316),
    DiyFp64.from_parts(0x8a08f0f8bf0f156b, -289),
    DiyFp64.from_parts(0xcdb02555653131b6, -263),
    DiyFp64.from_parts(0x993fe2c6d07b7fac, -236),
    DiyFp64.from_parts(0xe45c10c42a2b3b06, -210),
    DiyFp64.from_parts(0xaa242499697392d3, -183),
    DiyFp64.from_parts(0xfd87b5f28300ca0e, -157),
    DiyFp64.from_parts(0xbce5086492111aeb, -130),
    DiyFp64.from_parts(0x8cbccc096f5088cc, -103),
    DiyFp64.from_parts(0xd1b71758e219652c, -77),
    DiyFp64.from_parts(0x9c40000000000000, -50),
    DiyFp64.from_parts(0xe8d4a51000000000, -24),
    DiyFp64.from_parts(0xad78ebc5ac620000, 3),
    DiyFp64.from_parts(0x813f3978f8940984, 30),
    DiyFp64.from_parts(0xc097ce7bc90715b3, 56),
    DiyFp64.from_parts(0x8f7e32ce7bea5c70, 83),
    DiyFp64.from_parts(0xd5d238a4abe98068, 109),
    DiyFp64.from_parts(0x9f4f2726179a2245, 136),
    DiyFp64.from_parts(0xed63a231d4c4fb27, 162),
    DiyFp64.from_parts(0xb0de65388cc8ada8, 189),
    DiyFp64.from_parts(0x83c7088e1aab65db, 216),
    DiyFp64.from_parts(0xc45d1df942711d9a, 242),
    DiyFp64.from_parts(0x924d692ca61be758, 269),
    DiyFp64.from_parts(0xda01ee641a708dea, 295),
    DiyFp64.from_parts(0xa26da3999aef774a, 322),
    DiyFp64.from_parts(0xf209787bb47d6b85, 348),
    DiyFp64.from_parts(0xb454e4a179dd1877, 375),
    DiyFp64.from_parts(0x865b86925b9bc5c2, 402),
    DiyFp64.from_parts(0xc83553c5c8965d3d, 428),
    DiyFp64.from_parts(0x952ab45cfa97a0b3, 455),
    DiyFp64.from_parts(0xde469fbd99a05fe3, 481),
    DiyFp64.from_parts(0xa59bc234db398c25, 508),
    DiyFp64.from_parts(0xf6c69a72a3989f5c, 534),
    DiyFp64.from_parts(0xb7dcbf5354e9bece, 561),
    DiyFp64.from_parts(0x88fcf317f22241e2, 588),
    DiyFp64.from_parts(0xcc20ce9bd35c78a5, 614),
    DiyFp64.from_parts(0x98165af37b2153df, 641),
    DiyFp64.from_parts(0xe2a0b5dc971f303a, 667),
    DiyFp64.from_parts(0xa8d9d1535ce3b396, 694),
    DiyFp64.from_parts(0xfb9b7cd9a4a7443c, 720),
    DiyFp64.from_parts(0xbb764c4ca7a44410, 747),
    DiyFp64.from_parts(0x8bab8eefb6409c1a, 774),
    DiyFp64.from_parts(0xd01fef10a657842c, 800),
    DiyFp64.from_parts(0x9b10a4e5e9913129, 827),
    DiyFp64.from_parts(0xe7109bfba19c0c9d, 853),
    DiyFp64.from_parts(0xac2820d9623bf429, 880),
    DiyFp64.from_parts(0x80444b5e7aa7cf85, 907),
    DiyFp64.from_parts(0xbf21e44003acdd2d, 933),
    DiyFp64.from_parts(0x8e679c2f5e44ff8f, 960),
    DiyFp64.from_parts(0xd433179d9c8cb841, 986),
    DiyFp64.from_parts(0x9e19db92b4e31ba9, 1013),
    DiyFp64.from_parts(0xeb96bf6ebadf77d9, 1039),
};

pub fn index_from_exp2(exp: i32) usize {
    const dk: f64 = -((61 + exp) * bits_per_10 + pow64f_start_exp10);
    const n: usize = @intFromFloat(dk + 1);
    return @divTrunc(n, 8) + 1;
}

pub fn exp10_from_index(i: usize) i32 {
    return -(pow64f_start_exp10 + i * 8);
}

pub fn num_digits_u32(i: u32) u32 {
    var n: u32 = 1;
    var x = i;

    if (x >= 100_000_000) {
        x /= 100_000_000;
        n += 8;
    }
    if (x >= 10_000) {
        x /= 10_000;
        n += 4;
    }
    if (x >= 100) {
        x /= 100;
        n += 2;
    }
    if (x >= 10) {
        x /= 10;
        n += 1;
        S.debug.print("::::: x={d} n={d}\n", .{ x, n });
    }
    S.debug.print("::: ret x={d} n={d}\n", .{ x, n });
    return n;
}

pub fn num_digits(x: anytype) u32 {
    const xti = @typeInfo(@TypeOf(x));
    if (xti == .Int and xti.Int.signedness == .unsigned) {
        return switch (xti.Int.bits) {
            32 => num_digits_u32(x),
            64 => num_digits_u64(x),
            else => @compileError("only u32 and u64 supported"),
        };
    } else {
        @compileError("Only unsigned ints supported");
    }
}

pub fn num_digits_u64(i: u64) u32 {
    var n: u32 = 0;
    var x = i;

    if (x >= 10_000_000_000_000_000) {
        x /= 10_000_000_000_000_000;
        n += 16;
    }

    if (x >= 100_000_000) {
        x /= 100_000_000;
        n += 8;
    }

    const x32: u32 = @intCast(x);
    return n + num_digits_u32(x32);
}

// --- --- TESTS --- ---
const STEE = S.testing.expectEqual;

test "num digits" {
    const nd = num_digits_u64(5770237022830591);
    try STEE(@as(u32, 16), nd);
}
