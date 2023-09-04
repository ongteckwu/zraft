const core = @import("core.zig");

pub const RaftMessages = enum {
    RequestVote,
    RequestVoteResponse,
    AppendEntries,
    AppendEntriesResponse,
    Heartbeat,
    HeartbeatResponse,
    CommitEntries,
    CommitEntriesResponse,
};

pub const RequestVote = struct {
    term: u64,
    candidate_id: u64,
    last_log_index: u64,
    last_log_term: u64,
};

pub const RequestVoteResponse = struct {
    term: u64,
    vote_granted: bool,
};

pub const AppendEntries = struct {
    term: u64,
    leader_id: u64,
    prev_log_index: u64,
    prev_log_term: u64,
    entries: []core.LogEntry,
    leader_commit: u64,
};

pub const AppendEntriesResponse = struct {
    term: u64,
    success: bool,
    match_index: u64,
};

pub const Heartbeat = struct {
    term: u64,
    leader_id: u64,
};

pub const HeartbeatResponse = struct {
    term: u64,
};

pub const CommitEntries = struct {
    term: u64,
    leader_id: u64,
    entries: []core.LogEntry,
    leader_commit: u64,
};

pub const CommitEntriesResponse = struct {
    term: u64,
    success: bool,
    match_index: u64,
};
