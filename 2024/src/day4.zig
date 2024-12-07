const std = @import("std");
const print = std.debug.print;

var characterMap: [140][]u8 = undefined;

pub fn run() !void {
    try readData();

    var count = try countStrings("XMAS");
    count += try countStrings("SAMX");

    print("Count: '{}'\n", .{count});
}

fn countStrings(string: []const u8) !u64 {
    var counter: u64 = 0;

    for (0..characterMap.len) |row| {
        for (0..characterMap[row].len) |column| {
            const hasHorizontal = column + string.len < characterMap[row].len - 1;
            const hasVertical = row + string.len < characterMap.len - 1;

            if (hasHorizontal) {
                const horizontal = characterMap[row][column .. column + string.len];
                if (std.mem.eql(u8, horizontal, string)) {
                    print("Horizontal Match", .{});
                    counter += 1;
                }
            }

            if (hasVertical) {
                const vertical = characterMap[row .. row + string.len][column];

                if (std.mem.eql(u8, vertical, string)) {
                    print("Vertical Match", .{});
                    counter += 1;
                }
            }

            //if (hasVertical and hasHorizontal) {}
        }
    }

    return counter;
}

fn readData() !void {
    var file = try std.fs.cwd().openFile("data/day4_data.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [256]u8 = undefined;
    var index: usize = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        characterMap[index] = line;
        print("Adding {}\n", .{index});
        index += 1;
    }
}
