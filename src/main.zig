const std = @import("std");
const c = @cImport({
    @cInclude("locale.h");
    @cInclude("panel.h");
    @cInclude("curses.h");
});

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer {
        const status = gpa.deinit();
        if (status == .leak) {
            std.debug.print("Memory leak detected", .{});
        }
    }
    _ = c.setlocale(c.LC_ALL, "");
    _ = c.set_escdelay(60);
    const stdwin = c.initscr();
    defer _ = c.endwin();
    _ = c.noecho();
    _ = c.cbreak();

    _ = c.keypad(stdwin, true);

    const lines: u16 = @intCast(c.getmaxy(stdwin));
    const cols: u16 = @intCast(c.getmaxx(stdwin));

    var buf = std.ArrayList(u8).init(alloc);
    defer buf.deinit();

    try buf.writer().print("{d}, {d}\x00", .{ lines, cols });

    _ = c.addstr(buf.items.ptr);
    _ = c.refresh();

    _ = c.getch();
}
