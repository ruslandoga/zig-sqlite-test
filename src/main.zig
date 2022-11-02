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

    while (true) {
        rc = c.sqlite3_step(stmt);
        switch (rc) {
            c.SQLITE_DONE => break,
            c.SQLITE_ROW => {
                std.debug.print("selected version: {s}\n", .{
                    c.sqlite3_column_text(stmt, 0),
                });
            },
            else => unreachable,
        }
    }

    rc = c.sqlite3_finalize(stmt);
    try testing.expectEqual(rc, c.SQLITE_OK);

    rc = c.sqlite3_close(db);
    try testing.expectEqual(rc, c.SQLITE_OK);
}

test "create table and insert data" {
    var db: ?*c.sqlite3 = undefined;
    var rc: c_int = undefined;
    var err_msg: [*c]u8 = undefined;
    rc = c.sqlite3_open(":memory:", &db);
    defer _ = c.sqlite3_close(db);

    const sql =
        \\drop table if exists cats;
        \\create table cats(id int, name text, price int);
        \\insert into cats values (1, 'audi', 52642);
        \\insert into cats values (2, 'mercedes', 57234);
        \\insert into cats values (3, 'skoda', 9000);
    ;

    rc = c.sqlite3_exec(db, sql, null, null, &err_msg);
    defer _ = c.sqlite3_free(err_msg);
    try testing.expectEqual(rc, c.SQLITE_OK);
}
