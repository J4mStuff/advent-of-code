const std = @import("std");
const print = std.debug.print;

const Error = error{UnexpectedNull};

pub fn run() !void {
    _ = parse_data() catch {
        return;
    };
}

fn parse_data() !void {
    const result = try std.process.Child.run(.{
        .allocator = std.heap.page_allocator,
        .argv = &[_][]const u8{ "grep", "-oE", "mul\\([0-9]+,[0-9]+\\)", "/home/n3kk/code/advent-of-code/2024/data/day3_data.txt" },
    });

    var it = std.mem.splitSequence(u8, result.stdout, "\n");

    var multiplicationResult: u32 = 0;

    while (it.next()) |line| {
        if (line.len < 1) continue;
        const sliceWithNumbers = line[4 .. line.len - 1];
        var splitSequence = std.mem.splitSequence(u8, sliceWithNumbers, ",");

        const first = splitSequence.first();
        const second = splitSequence.next() orelse undefined;

        if (first.len == 0 or second.len == 0) {
            print("ERR: Got zeros in '{s}' or '{s}' from '{s}'\n", .{ first, second, line });
            return Error.UnexpectedNull;
        }

        const n1: u32 = try std.fmt.parseInt(u32, first, 10);
        const n2: u32 = try std.fmt.parseInt(u32, second, 10);

        print("Multi: {} * {}\n", .{ n1, n2 });
        multiplicationResult += n1 * n2;
    }

    print("Multiplication Result - {}\n", .{multiplicationResult});
}
