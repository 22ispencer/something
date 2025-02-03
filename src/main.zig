const std = @import("std");
const c = @cImport({
    @cInclude("locale.h");
    @cInclude("panel.h");
    @cInclude("curses.h");
});

pub fn cPrint(list: *std.ArrayList(u8), comptime format: []const u8, args: anytype) !void {
    try list.writer().print(format ++ "\x00", args);
}

pub fn cAppend(list: *std.ArrayList(u8), char: u8) !void {
    if (list.items.len > 0 and list.getLast() == 0) {
        _ = list.pop();
    }

    try list.append(char);
    try list.append(0);
}

pub fn cWriteAll(list: *std.ArrayList(u8), str: []const u8) !void {
    if (list.items.len > 0 and list.getLast() == 0) {
        _ = list.pop();
    }

    try list.writer().writeAll(str);
    try list.append(0);
}

const Application = struct {
    stdwin: ?*c.WINDOW,
    lines: u16,
    cols: u16,
    alloc: std.mem.Allocator,
    pub fn init(alloc: std.mem.Allocator) Application {
        _ = c.setlocale(c.LC_ALL, "");
        _ = c.set_escdelay(60);
        const stdwin = c.initscr();
        _ = c.noecho();
        _ = c.cbreak();

        _ = c.keypad(stdwin, true);

        const lines: u16 = @intCast(c.getmaxy(stdwin));
        const cols: u16 = @intCast(c.getmaxx(stdwin));
        return .{
            .stdwin = stdwin,
            .lines = lines,
            .cols = cols,
            .alloc = alloc,
        };
    }
    fn deinit() void {
        _ = c.endwin();
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer {
        const status = gpa.deinit();
        if (status == .leak) {
            std.debug.print("Memory leak detected", .{});
        }
    }
    var app = Application.init(alloc);
    defer app.deinit();

    var buf = std.ArrayList(u8).init(alloc);
    defer buf.deinit();

    while (true) {
        var char: c.wint_t = undefined;
        _ = c.get_wch(&char);

        if (char < std.math.maxInt(u8)) {
            try cAppend(&buf, @intCast(char));
        } else if (buf.items.len > 1 and char == c.KEY_BACKSPACE) {
            _ = buf.orderedRemove(buf.items.len - 2);
            _ = c.clear();
        }
        _ = c.mvprintw(@divTrunc(app.lines, 2), @divTrunc(app.cols - @as(c_int, @intCast(buf.items.len)), 2), buf.items.ptr);

        _ = c.refresh();
    }
}
