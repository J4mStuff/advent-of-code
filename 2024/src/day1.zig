const std = @import("std");
const mem = std.mem;

const Error = error{ColumnEmpty};

pub fn run() !void {
    var file = try std.fs.cwd().openFile("data/day1_data.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [256]u8 = undefined;
    var arr1: [1000]u32 = undefined;
    var arr2: [1000]u32 = undefined;
    var index: usize = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.splitSequence(u8, line, "   ");
        arr1[index] = try std.fmt.parseInt(u32, it.first(), 10);
        arr2[index] = try std.fmt.parseInt(u32, it.next() orelse return Error.ColumnEmpty, 10);

        index += 1;
    }

    sort(&arr1, 0, arr1.len - 1);
    sort(&arr2, 0, arr2.len - 1);

    var diff: u32 = 0;
    var similarityScore: u32 = 0;
    for (0..index) |i| {
        if (arr1[i] > arr2[i]) {
            diff += arr1[i] - arr2[i];
        } else {
            diff += arr2[i] - arr1[i];
        }

        var count: u32 = 0;
        for (0..index) |j| {
            if (arr1[i] == arr2[j]) {
                const str = try std.fmt.bufPrint(&buf, "{}", .{arr1[i]});
                std.debug.print("{s}\n", .{str});

                count += 1;
            }
        }

        similarityScore += arr1[i] * count;
    }

    var str = try std.fmt.bufPrint(&buf, "{}", .{diff});
    std.debug.print("Sum of differences: {s}\n", .{str});

    str = try std.fmt.bufPrint(&buf, "{}", .{similarityScore});
    std.debug.print("Similarity score: {s}\n", .{str});
}

pub fn sort(array: []u32, low: usize, high: usize) void {
    if (low < high) {
        const p = partition(array, low, high);
        sort(array, low, @min(p, p -% 1));
        sort(array, p + 1, high);
    }
}

pub fn partition(array: []u32, low: usize, high: usize) usize {
    const pivot = array[high];
    var i = low;
    var j = low;
    while (j < high) : (j += 1) {
        if (array[j] < pivot) {
            mem.swap(u32, &array[i], &array[j]);
            i = i + 1;
        }
    }
    mem.swap(u32, &array[i], &array[high]);
    return i;
}
