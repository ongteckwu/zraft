const std = @import("std");
const raft_core = @import("core.zig");
const raft_server = @import("server.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const deinit_status = gpa.deinit();
        _ = deinit_status;
    }

    var server = try raft_server.Server.init();
    defer server.deinit();

    const client_thread = try std.Thread.spawn(.{}, raft_server.sendMsgToServer, .{server.stream_server.listen_address});
    defer client_thread.join();

    try server.accept(allocator);
}

test "simple test" {
    // var list = std.ArrayList(i32).init(std.testing.allocator);
    // defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    // try list.append(42);
    // try std.testing.expectEqual(@as(i32, 42), list.pop());
}
