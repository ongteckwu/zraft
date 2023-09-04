const std = @import("std");

pub const NodeState = enum {
    Follower,
    Candidate,
    Leader,
};

pub const RaftConfig = struct {
    allocator: std.mem.Allocator,
    node_id: u64,
    node_count: u64,
    election_timeout: u64,
    heartbeat_timeout: u64,
    neighbour_urls: []const u8,
};

pub const RaftState = struct {
    allocator: std.mem.Allocator,
    current_term: u64,
    voted_for: ?u64,
    config: RaftConfig,
    log: Log,
    commit_index: u64,
    last_applied: u64,
    next_index: []u64,
    match_index: []u64,
    node_state: NodeState,
};

pub const LogEntry = struct {
    term: u64,
    command: []const u8,
};

pub const Log = struct {
    allocator: std.mem.Allocator,
    entries: []LogEntry,
};

pub const RaftNode = struct {
    allocator: std.mem.Allocator,
    config: RaftConfig,
    state: RaftState,

    pub fn init(allocator: std.mem.Allocator, config: RaftConfig) !RaftNode {
        var node: RaftNode = undefined;
        node.allocator = allocator;
        node.config = config;

        node.state.allocator = allocator;
        node.state.config = config;
        node.state.log.allocator = allocator;

        node.state.log.entries = try allocator.alloc(u8, 0);
        node.state.next_index = try allocator.alloc(u64, config.node_count);
        node.state.match_index = try allocator.alloc(u64, config.node_count);

        return node;
    }
};
