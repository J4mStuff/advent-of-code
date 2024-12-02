const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const ArrayList = std.ArrayList;

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
    const allocator = std.heap.page_allocator;
    var itemList = ArrayList(u32).init(allocator);
    defer itemList.deinit();

    var index: usize = 0;

    while (it.next()) |item| {
        itemList.append(try std.fmt.parseInt(u32, item, 10));
        index += 1;
    }

    const reportIsUp = itemList[0] < itemList[1];

    const badIndex = try iterate(&itemList, index, reportIsUp, false);

    if (badIndex == 0) {
        return 1;
    }

    var list2 = ArrayList(u32);
    list2.appendSlice(itemList[0 .. badIndex - 1]);
    list2.appendSlice(itemList[badIndex..index]);

    const attempt2 = try iterate(&list2, index, reportIsUp, false);

    if (attempt2 == 0) {
        return 1;
    }

    var list3 = ArrayList(u32);
    list3.appendSlice(itemList[0..badIndex]);
    list3.appendSlice(itemList[badIndex + 1 .. index]);

    const attempt3 = try iterate(&list3, index, reportIsUp, false);

    if (attempt3 == 0) {
        return 1;
    }
}

fn iterate(array: []u32, index: usize, reportIsUp: bool) !usize {
    for (0..index - 1) |i| {
        const resultOk = try compareReports(array[i], array[i + 1], reportIsUp);
        if (!resultOk) {
            print("BAD - {any} {} {} {}\n", .{ array[0..index], array[i], array[i + 1], reportIsUp });
            return i;
        }
        continue;
    }

    print("\nOK - {any}\n", .{array[0..index]});
    return 0;
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

test "parse test 0" {
    const result = try parseLine("62 68 70 71 73");
    try expect(result);
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
