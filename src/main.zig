const std = @import("std");
const c = @cImport({
    @cInclude("curses.h");
});

pub fn cPrint(list: *std.ArrayList(u8), comptime format: []const u8, args: anytype) !void {
    try list.writer().print(format ++ "\x00", args);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer {
        const status = gpa.deinit();
        if (status == .leak) {
            std.debug.print("Memory leak detected", .{});
        }
    }

    _ = c.set_escdelay(60);
    const stdwin = c.initscr();
    _ = c.noecho();
    _ = c.cbreak();

    _ = c.keypad(stdwin, true);
    defer _ = c.endwin();

    const cols = c.getmaxx(stdwin);
    const lines = c.getmaxy(stdwin);
    const esc_delay = c.get_escdelay();

    var message = std.ArrayList(u8).init(alloc);
    defer message.deinit();

    try cPrint(&message, "Esc Delay: {d}", .{esc_delay});

    _ = c.mvprintw(@divTrunc(lines, 2), @divTrunc(cols - @as(c_int, @intCast(message.items.len)), 2), message.items.ptr);

    _ = c.refresh();

    _ = c.getch();
}
