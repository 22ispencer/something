const std = @import("std");
const c = @cImport({
    @cInclude("curses.h");
});

pub fn main() !void {
    const stdwin = c.initscr();
    defer _ = c.endwin();

    const cols = c.getmaxx(stdwin);
    const lines = c.getmaxy(stdwin);

    const message = "Hello, World!";

    _ = c.mvprintw(@divTrunc(lines, 2), @divTrunc(cols - @as(c_int, message.len), 2), message);

    _ = c.refresh();

    _ = c.getch();
}
