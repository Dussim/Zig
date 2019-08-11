const std = @import("std");
const sort = std.sort;
const warn = std.debug.warn;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

const Edge = struct {
    from: i32,
    to: i32,
    distance: i32,
    const Self = @This();

    pub fn asc(l: Edge, r: Edge) bool {
        return l.distance < r.distance;
    }

    pub fn dsc(l: Edge, r: Edge) bool {
        return l.distance > r.distance;
    }

    pub fn equals(self: Self, other: Edge) bool {
        return (self.from == other.from) and (self.to == other.to) and (self.distance == other.distance);
    }
};

const Tree = struct {
    parent: usize,
    rank: usize,
};

const UnionFindForest = struct {
    forest: []Tree,
    const Self = @This();

    pub fn find(self: Self, i: usize) usize {
        const f = self.forest;
        if (f[i].parent != i) {
            f[i].parent = self.find(f[i].parent);
        }
        return f[i].parent;
    }

    pub fn isSameTree(self: Self, e: Edge) bool {
        const from = @intCast(usize, e.from);
        const to = @intCast(usize, e.to);
        return self.find(from) == self.find(to);
    }

    pub fn merge(self: UnionFindForest, e: Edge) void {
        const from = @intCast(usize, e.from);
        const to = @intCast(usize, e.to);
        const f = self.forest;
        const x = self.find(from);
        const y = self.find(to);
        if (f[x].rank < f[y].rank) {
            f[x].parent = y;
        } else if (f[x].rank > f[y].rank) {
            f[y].parent = x;
        } else {
            f[y].parent = x;
            f[x].rank += 1;
        }
    }

    pub fn init(size: usize, allocator: *Allocator) !Self {
        const a = try allocator.alloc(Tree, size);
        for (a) |_, i| {
            a[i] = Tree{
                .parent = i,
                .rank = 1,
            };
        }
        return Self{ .forest = a };
    }
};

inline fn edge(from: i32, to: i32, distance: i32) Edge {
    return Edge{
        .from = from,
        .to = to,
        .distance = distance,
    };
}

pub fn kruskal(edges: []const Edge, size: usize, allocator: *Allocator) !?[]const Edge {
    const forest = try UnionFindForest.init(size, allocator);
    var mst = try allocator.alloc(Edge, size - 1);
    var j: usize = 0;
    for (edges) |e| {
        if (j == size - 1) {
            return mst;
        }
        if (!forest.isSameTree(e)) {
            forest.merge(e);
            mst[j] = e;
            j += 1;
        }
    }
    return null;
}

test "Minimal Spanning Tree test" {
    var directAllocator = std.heap.DirectAllocator.init();
    defer directAllocator.deinit();

    sort.sort(Edge, &graph, Edge.asc);

    const optional_mst = try kruskal(&graph, vertices, &directAllocator.allocator);
    assert(optional_mst != null);
    if (optional_mst) |mst| {
        for (mst) |e, i| {
            assert(e.equals(minimalSpanningTree[i]));
        }
    }
}
const vertices = 11;
var graph = []const Edge{
    edge(0, 1, 2),
    edge(0, 3, 5),
    edge(1, 3, 1),
    edge(1, 2, 4),
    edge(1, 4, 7),
    edge(4, 8, 2),
    edge(4, 9, 1),
    edge(7, 8, 1),
    edge(7, 10, 8),
    edge(8, 10, 2),
    edge(8, 9, 3),
    edge(9, 5, 5),
    edge(9, 6, 3),
    edge(5, 6, 2),
    edge(5, 10, 4),
    edge(9, 10, 5),
};

const minimalSpanningTree = []const Edge{
    edge(1, 3, 1),
    edge(4, 9, 1),
    edge(7, 8, 1),
    edge(0, 1, 2),
    edge(4, 8, 2),
    edge(8, 10, 2),
    edge(5, 6, 2),
    edge(9, 6, 3),
    edge(1, 2, 4),
    edge(1, 4, 7),
};
