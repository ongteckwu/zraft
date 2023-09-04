const std = @import("std");

const Message = struct {
    event: []const u8,
    data: []const u8,
};

pub const Server = struct {
    stream_server: std.net.StreamServer,

    pub fn init() !Server {
        const address = std.net.Address.initIp4([4]u8{ 127, 0, 0, 1 }, 8080);

        var server = std.net.StreamServer.init(.{ .reuse_address = true });
        try server.listen(address);

        return Server{ .stream_server = server };
    }

    pub fn deinit(self: *Server) void {
        self.stream_server.deinit();
    }

    pub fn accept(self: *Server, allocator: std.mem.Allocator) !void {
        const conn = try self.stream_server.accept();
        defer conn.stream.close();

        var buf: [1024]u8 = undefined;
        const msg_size = try conn.stream.read(buf[0..]);

        const message = try std.json.parseFromTokenSource(Message, allocator, buf[0..msg_size]);
        const client_msg = Message{ .event = "Hello", .data = "Sample Data" };

        try std.testing.expectEqualStrings(client_msg.event, message.event);

        const server_msg = Message{ .event = "Good Bye", .data = "Response Data" };
        const server_msg_json = try std.json.stringify(
            server_msg,
            .{},
            conn.stream,
        );
        _ = try conn.stream.write(server_msg_json);
    }
};

pub fn sendMsgToServer(server_address: std.net.Address) !void {
    const conn = try std.net.tcpConnectToAddress(server_address);
    defer conn.close();

    var buf_string: [100]u8 = undefined;
    const writer = std.io.bufferedWriter(buf_string).writer();
    const client_msg = Message{ .event = "Hello", .data = "Sample Data" };
    try std.json.stringify(
        client_msg,
        .{},
        writer,
    );
    const result = buf_string[0..writer.offset];

    _ = try conn.write(result);

    var buf: [1024]u8 = undefined;
    const resp_size = try conn.read(buf[0..]);

    const server_msg = try std.json.decodeString(Message, buf[0..resp_size]);

    const expected_server_msg = Message{ .event = "Good Bye", .data = "Response Data" };
    try std.testing.expectEqualStrings(expected_server_msg.event, server_msg.event);
}
