const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const ArrayList = std.ArrayList;

const Error = error{ ReportInvalid, SingleValueNotExpected, IterationOk };

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
    print("\nLine - {s}\n", .{line});

    var it = std.mem.splitSequence(u8, line, " ");
    const allocator = std.heap.page_allocator;
    var itemList = ArrayList(u32).init(allocator);
    defer itemList.deinit();

    var index: usize = 0;

    while (it.next()) |item| {
        const itemU32 = try std.fmt.parseInt(u32, item, 10);

        try itemList.append(itemU32);
        index += 1;
    }

    var reportIsUp = itemList.items[0] < itemList.items[1];

    const badIndex = iterate(itemList.items, index, reportIsUp) catch {
        return true;
    };

    //Failed comparing i vs i+1 so one of them is an issue
    //First try removing i from list
    print("Attempt #2 - bad index {}\n", .{badIndex});
    var list2 = ArrayList(u32).init(allocator);
    defer list2.deinit();
    try list2.appendSlice(itemList.items[0..badIndex]);
    try list2.appendSlice(itemList.items[badIndex + 1 ..]);
    reportIsUp = list2.items[0] < list2.items[1];

    _ = iterate(list2.items, index - 1, reportIsUp) catch {
        return true;
    };

    //If the above didn't work then try with i+1 removed
    print("Attempt #3 - bad index {}\n", .{badIndex + 1});
    var list3 = ArrayList(u32).init(allocator);
    defer list3.deinit();
    try list3.appendSlice(itemList.items[0 .. badIndex + 1]);
    try list3.appendSlice(itemList.items[badIndex + 2 ..]);
    reportIsUp = list3.items[0] < list3.items[1];

    _ = iterate(list3.items, index - 1, reportIsUp) catch {
        return true;
    };

    //If either of those didn't work there's probably another issue, so it's not valid
    return false;
}

//OUG OUG MONKE BRAIN RETURN ERROR WHEN NO ERROR
//RETURN NO ERROR WHEN ERROR BECAUSE EASY HANDLE
//OUG OUG OUG
fn iterate(array: []u32, index: usize, reportIsUp: bool) Error!usize {
    print("Iterating - {any} - {} - {}\n", .{ array, index, reportIsUp });
    for (0..index - 1) |i| {
        try compareReports(array[i], array[i + 1], reportIsUp) catch {
            print("BAD - {any} {} {} {}\n", .{ array[0..index], array[i], array[i + 1], reportIsUp });
            return i;
        };
        continue;
    }

    print("OK - {any}\n", .{array[0..index]});
    return Error.IterationOk;
}

fn compareReports(current: u32, next: u32, reportIsUp: bool) Error!void {
    var difference: u32 = 0;
    const goesUp = next > current;

    if (reportIsUp and goesUp) {
        difference = next - current;
    } else if (!reportIsUp and !goesUp) {
        difference = current - next;
    }

    if (difference > 0 and difference < 4) {
        return;
    }

    print("P-{} C-{} D-{}\n", .{ current, next, difference });
    return Error.ReportInvalid;
}

test "parse test 0" {
    print("\n\nNew test run:\n", .{});
    const result = try parseLine("62 68 70 71 73");
    print("Result {}\n", .{result});
    try expect(result);
}

test "parse test #-1" {
    print("\n\nNew test run:\n", .{});
    const result = try parseLine("57 60 62 64 63 64 65");
    print("Result {}\n", .{result});
    try expect(result);
}

test "parse test 1" {
    print("\n\nNew test run:\n", .{});
    const result = try parseLine("7 6 4 2 1");
    print("Result {}\n", .{result});
    try expect(result);
}

test "parse test 2" {
    print("\n\nNew test run:\n", .{});
    const result = try parseLine("1 2 7 8 9");
    print("Result {}\n", .{result});
    try expect(!result);
}

test "parse test 3" {
    print("\n\nNew test run:\n", .{});
    const result = try parseLine("9 7 6 2 1");
    print("Result {}\n", .{result});
    try expect(!result);
}

test "parse test 4" {
    print("\n\nNew test run:\n", .{});
    const result = try parseLine("1 3 2 4 5");
    print("Result {}\n", .{result});
    try expect(result);
}

test "parse test 5" {
    print("\n\nNew test run:\n", .{});
    const result = try parseLine("8 6 4 4 1");
    print("Result {}\n", .{result});
    try expect(result);
}

test "parse test 6" {
    print("\n\nNew test run:\n", .{});
    const result = try parseLine("1 3 6 7 9");
    print("Result {}\n", .{result});
    try expect(result);
}

test "parse bad" {
    print("\n\nNew test run:\n", .{});
    const result = try parseLine("1 1 1 1 1");
    print("Result {}\n", .{result});
    try expect(!result);
}

test "parse good" {
    print("\n\nNew test run:\n", .{});
    const result = try parseLine("1 2 3 4 5");
    print("Result {}\n", .{result});
    try expect(result);
}

test "iterate good" {
    print("\n\nNew test run:\n", .{});
    var array: [5]u32 = .{ 7, 6, 4, 2, 1 };
    const index = 5;
    const resportIsUp = false;

    _ = iterate(&array, index, resportIsUp) catch |err| {
        print("Error expected {}", .{err});
        try expect(err == Error.IterationOk);
    };
}

test "iterate worst" {
    print("\n\nNew test run:\n", .{});
    var array: [5]u32 = .{ 80, 81, 76, 73, 72 };
    const index = 5;
    const resportIsUp = false;

    const result = try iterate(&array, index, resportIsUp);
    print("Result {}\n", .{result});
    try expect(result == 0);
}

test "compare reports" {
    print("\n\nNew test run:\n", .{});
    var result = try compareReports(10, 10, false);
    try expect(!result);
    result = try compareReports(10, 10, true);
    print("Result {}\n", .{result});
    try expect(!result);
}
