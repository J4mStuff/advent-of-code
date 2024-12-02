const std = @import("std");
const print = std.debug.print;

const Errors = error{ ReportInvalid, SingleValueNotExpected };

pub fn run() !void {
    var file = try std.fs.cwd().openFile("data/day2_data.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [256]u8 = undefined;
    var safeCount: u16 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        safeCount += try parseLine(line);
    }

    const str = try std.fmt.bufPrint(&buf, "{}", .{safeCount});
    print("Safe reports {s}.\n", .{str});
}

fn parseLine(line: []const u8) !u16 {
    print("Testing {s}\n", .{line});

    var it = std.mem.splitSequence(u8, line, " ");
    var previous = try std.fmt.parseInt(u32, it.first(), 10);
    const reportIsUp = previous < try std.fmt.parseInt(u32, it.peek() orelse unreachable, 10);

    while (it.next()) |item| {
        const current = try std.fmt.parseInt(u32, item, 10);
        const resultOk = try compareReports(previous, current, reportIsUp);
        if (!resultOk) {
            print("Line not OK\n", .{});
            return 0;
        }

        previous = current;
        continue;
    }

    print("Line OK\n", .{});
    return 1;
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
        //print("Report Ok\n", .{});
        return true;
    }

    //print("Report invalid\n", .{});
    return false;
}
