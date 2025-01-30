const std = @import("std");
const c = @cImport({
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

    try message.writer().print("Esc Delay: {d}\x00", .{esc_delay});

    _ = c.mvprintw(@divTrunc(lines, 2), @divTrunc(cols - @as(c_int, @intCast(message.items.len)), 2), message.items.ptr);

    _ = c.refresh();

    _ = c.getch();
}
