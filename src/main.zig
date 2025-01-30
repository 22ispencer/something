const std = @import("std");
const c = @cImport({
    @cInclude("curses.h");
});

pub fn main() !void {
    const stdwin = c.initscr();
    defer _ = c.endwin();

    const cols = c.getmaxx(stdwin);
    const lines = c.getmaxy(stdwin);
    const esc_delay = c.get_escdelay();

    var buf = std.mem.zeroes([1024:0]u8);

    const buf_len = (try std.fmt.bufPrint(&buf, "Escape Delay: {d}", .{esc_delay})).len;

    _ = c.mvprintw(@divTrunc(lines, 2), @divTrunc(cols - @as(c_int, @intCast(buf_len)), 2), &buf);

    _ = c.refresh();

    _ = c.getch();
}
