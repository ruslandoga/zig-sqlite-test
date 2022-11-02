const c = @cImport(@cInclude("../c_src/sqlite3.h"));

const std = @import("std");
const testing = std.testing;

test "open and query" {
    std.debug.print("\nsqlite3 version: {s}\n", .{c.sqlite3_libversion()});

    var db: ?*c.sqlite3 = undefined;
    var rc: c_int = undefined;
    rc = c.sqlite3_open(":memory:", &db);
    try testing.expectEqual(rc, c.SQLITE_OK);

    var stmt: ?*c.sqlite3_stmt = undefined;
    rc = c.sqlite3_prepare_v2(db, "select sqlite_version()", -1, &stmt, 0);
    try testing.expectEqual(rc, c.SQLITE_OK);

    rc = c.sqlite3_step(stmt);
    try testing.expectEqual(rc, c.SQLITE_ROW);
    std.debug.print("selected version: {s}\n", .{c.sqlite3_column_text(stmt, 0)});

    rc = c.sqlite3_finalize(stmt);
    try testing.expectEqual(rc, c.SQLITE_OK);

    rc = c.sqlite3_close(db);
    try testing.expectEqual(rc, c.SQLITE_OK);
}
