const std = @import("std");
const c = @cImport({
    @cInclude("locale.h");
    @cInclude("panel.h");
    @cInclude("curses.h");
});

const Application = struct {
    const Self = @This();
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
    pub fn deinit(_: Self) void {
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

    std.time.sleep(std.time.ns_per_s * 3);
}
