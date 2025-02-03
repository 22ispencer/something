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
    _ = c.start_color();

    _ = c.init_pair(1, c.COLOR_BLACK, c.COLOR_GREEN);

    _ = c.keypad(stdwin, true);

    const lines: u16 = @intCast(c.getmaxy(stdwin));
    const cols: u16 = @intCast(c.getmaxx(stdwin));

    var buf = std.ArrayList(u8).init(alloc);
    defer buf.deinit();

    var wins = std.ArrayList(?*c.WINDOW).init(alloc);
    defer wins.deinit();

    var panels = std.ArrayList(?*c.PANEL).init(alloc);
    defer panels.deinit();

    try wins.append(c.newwin(lines, cols, 0, 10));
    try panels.append(c.new_panel(wins.items[0]));

    _ = c.wbkgd(wins.items[0], @intCast(c.COLOR_PAIR(1)));

    _ = c.update_panels();
    _ = c.doupdate();

    std.time.sleep(std.time.ns_per_s * 2);
}
