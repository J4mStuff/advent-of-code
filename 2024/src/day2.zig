const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

const Errors = error{ ReportInvalid, SingleValueNotExpected };

pub fn run() !void {
    var file = try std.fs.cwd().openFile("data/day2_data.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [256]u8 = undefined;
    var safeCount: u16 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (try parseLine(line)) {
            safeCount += 1;
        }
    }

    print("Safe reports {}.\n", .{safeCount});
}

fn parseLine(line: []const u8) !bool {
    var it = std.mem.splitSequence(u8, line, " ");
    var array: [10]u32 = undefined;
    var index: usize = 0;

    while (it.next()) |item| {
        array[index] = try std.fmt.parseInt(u32, item, 10);
        index += 1;
    }

    const reportIsUp = array[0] < array[1];

    var valid = try iterate(&array, index, reportIsUp, false);

    if (!valid) {
        print("First iteration invalid\n", .{});
        valid = try iterate(&array, index, !reportIsUp, true);
    }

    print("\n", .{});

    return valid;
}

fn iterate(array: []u32, index: usize, reportIsUp: bool, sensitive: bool) !bool {
    var hadBadReport = sensitive;
    for (1..index) |i| {
        const resultOk = try compareReports(array[i - 1], array[i], reportIsUp);
        if (!resultOk) {
            if (hadBadReport) {
                print("BAD - {any} {} {} {}\n", .{ array[0..index], array[i - 1], array[i], reportIsUp });
                return false;
            }
            const retryOk = try compareReports(array[i - 1], array[i + 1], reportIsUp);
            if (!retryOk) {
                print("BAD - {any} {} {} {}\n", .{ array[0..index], array[i - 1], array[i + 1], reportIsUp });
                return false;
            } else {
                print("Tolerance - {} {} {}\n", .{ array[i - 1], array[i + 1], reportIsUp });
                hadBadReport = true;
                continue;
            }
        }
        continue;
    }

    print("\nOK - {any}\n", .{array[0..index]});
    return true;
}

fn compareReports(previous: u32, current: u32, reportIsUp: bool) !bool {
    var difference: u32 = 0;
    const goesUp = current > previous;

    if (reportIsUp and goesUp) {
        difference = current - previous;
    } else if (!reportIsUp and !goesUp) {
        difference = previous - current;
    }

    if (difference >= 1 and difference <= 3) {
        return true;
    }

    //print("{} {} {}\n", .{ previous, current, difference });
    return false;
}

test "parse test 1" {
    const result = try parseLine("7 6 4 2 1");
    try expect(result);
}

test "parse test 2" {
    const result = try parseLine("1 2 7 8 9");
    try expect(!result);
}

test "parse test 3" {
    const result = try parseLine("9 7 6 2 1");
    try expect(!result);
}

test "parse test 4" {
    const result = try parseLine("1 3 2 4 5");
    try expect(result);
}

test "parse test 5" {
    const result = try parseLine("8 6 4 4 1");
    try expect(result);
}

test "parse test 6" {
    const result = try parseLine("1 3 6 7 9");
    try expect(result);
}

test "parse bad" {
    const result = try parseLine("1 1 1 1 1");
    try expect(!result);
}

test "parse good" {
    const result = try parseLine("1 2 3 4 5");
    try expect(result);
}

test "iterate good" {
    var array: [5]u32 = .{ 7, 6, 4, 2, 1 };
    const index = 5;
    const resportIsUp = false;

    const result = try iterate(&array, index, resportIsUp, false);
    try expect(result);
}

test "iterate worst" {
    var array: [5]u32 = .{ 80, 81, 76, 73, 72 };
    const index = 5;
    const resportIsUp = false;

    const result = try iterate(&array, index, resportIsUp, false);
    try expect(!result);
}

test "compare reports" {
    var result = try compareReports(10, 10, false);
    try expect(!result);
    result = try compareReports(10, 10, true);
    try expect(!result);
}
