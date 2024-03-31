const cube = @import("cube.zig");
const std = @import("std");




//prune table g0
//c_o + distance 64u + 8u
//e_o + distance 64u + 32u + 8u
//e[0..8] _slice if e > 8 -> 1 64u + u8
// prune table g1
//c + distance 64u + 8u
//e[0..8] + distance 64u + 8u
//e[8..12] + distance 32u+ 8u
//
//


pub fn corner_shrink(state: cube.cube) u32 {
    //corner is between 0..7, and there is 8 slots
    //so 8*4 = 32
    var c: u32 = 0;
    var i: u32 = 0;
    while (i < 8) : (i += 1) {
        //use some fancy saturating shifts and adds
        var next = @as(u32, state.c[i]) & 0xf;
        next <<|= (i << 2);
        c +|= next;
    }
    return c;
}

test "corner_shrink" {
    var state = cube.cube.init();

    const expected :u32 = 0x76543210;

    var actual = corner_shrink(state);
    
    try std.testing.expect(expected == actual);
}
pub fn corner_o_shrink(state: cube.cube) u32 
{
    //corner orientation is between 0..2, and there is 8 slots
    //so 8*3 = 24, use u32 
    var o: u32 = 0;
    var i: u32 = 0;
    while (i < 8) : (i += 1) {
        //o += @as(u32, state.c_o[i]) << (i << 4);
        var next = @as(u32, state.c_o[i]) & 0xf;
        next <<|= (i << 2);
        o +|= next;
    }
    return o;
}

pub fn edge_o_shrink(state: cube.cube) u32 {
    //0..2 orientations times 12 edges 
    //use 2bits per edge to fit in u32
    var o: u32 = 0;
    var i: u32 = 0;

    while (i < 12) : (i += 1) {
        //o += @as(u32, state.e_o[i]) << (i << 2);
        var next = @as(u32, state.e_o[i]) & 0xf;
        next <<|= i;
        o +|= next;
    }
    return o;
}
//only edges not on E slice
pub fn edge_shrink(state: cube.cube) u32 {
    //0..7 edges times 8 locations 
    //use 4bits per edge to fit in u32
    var o: u32 = 0;
    var i: u32 = 0;

    while (i < 8) : (i += 1) {
        //o += @as(u32, state.e[i]) << (i << 4);
        var next = @as(u32, state.e[i]) & 0xf;
        next <<|= (i << 2);
        o +|= next;
    }
    return o;
}

//for g0 phase E slice edges we are only interested are they on E or not
pub fn ud_g0_shrink(state: cube.cube) u32 {
    var g0: u32 = 0;
    var i: u32 = 0;
    while (i < 12) : (i += 1) {
        var tmp : u32 = switch (@as(u32, state.e[i])) {
            0...7 => 0,
            else => 1,
        };
        //wrong?
        //g0 += tmp << (i << 1);
        tmp <<|= i;
        g0 +|= tmp;
    }
    return g0;
}
//for g1 phace for E slice edges we can ignore other 8 edges
pub fn ud_g1_shrink(state: cube.cube) u32 {
    var g1: u32 = 0;
    var i: u32 = 0;
    while (i < 4) : (i += 1) {
        //g1 += @as(u32, state.e_o[i+8]) << (i << 4);
        var next = @as(u32, state.e[i+8]) & 0xf;
        next <<|= (i << 2);
        g1 +|= next;
    }
    return g1;
}

pub const state32 = struct {
    s: u32,
    dist: u32,
};
//sorted by bit pattern
fn order_state32(_: void, a: state32, b: state32) std.math.Order{
    return std.math.order(a.s, b.s);
    //return a.s < b.s;
}
fn lessthan_state32(_: void, a: state32, b: state32) bool{
    
    if (a.s < b.s) {
        return true;
    }
    else {
        return false;
    }
}

pub const prune = struct {
    alloc: std.mem.Allocator,
    g0_ct : []state32,
    g0_et : []state32,
    g0_ud : []state32,
    g1_ct : []state32,
    g1_et : []state32,
    g1_ud : []state32,
    g0_ct_fill : usize,
    g1_ct_fill : usize,
    g0_et_fill : usize,
    g1_et_fill : usize,
    g0_ud_fill : usize,
    g1_ud_fill : usize,
    pub fn init(allocator: std.mem.Allocator) !prune {
        //const g0_ct = try allocator.alloc(state32, 2187);
        //const g0_et = try allocator.alloc(state32, 2048);
        //const g0_ud = try allocator.alloc(state32, 494);
        //const g1_ct = try allocator.alloc(state32, 40320);
        //const g1_et = try allocator.alloc(state32, 40320);
        //const g1_ud = try allocator.alloc(state32, 24);
        const g0_ct = try allocator.alloc(state32, 2187*2);
        const g0_et = try allocator.alloc(state32, 2048*2);
        const g0_ud = try allocator.alloc(state32, 2048);
        const g1_ct = try allocator.alloc(state32, 40320);
        const g1_et = try allocator.alloc(state32, 40320);
        const g1_ud = try allocator.alloc(state32, 24);

        return prune{
        .alloc = allocator,
        .g0_ct = g0_ct,
        .g0_et = g0_et,
        .g0_ud = g0_ud,
        .g1_ct = g1_ct,
        .g1_et = g1_et,
        .g1_ud = g1_ud,
        .g0_ct_fill = 0,
        .g1_ct_fill = 0,
        .g0_et_fill = 0,
        .g1_et_fill = 0,
        .g0_ud_fill = 0,
        .g1_ud_fill = 0};
    }
    pub fn deinit(self: *prune) void {
        defer self.alloc.free(self.g0_ct);
        defer self.alloc.free(self.g1_ct);
        defer self.alloc.free(self.g0_et);
        defer self.alloc.free(self.g1_et);
        defer self.alloc.free(self.g0_ud);
        defer self.alloc.free(self.g1_ud);
    }

    pub fn g0_dist(self: *prune, state: cube.cube) u32 {
        const c_o = state32 {.s = corner_o_shrink(state), .dist = 0};
        const e_o = state32 {.s = edge_o_shrink(state), .dist = 0};
        const ud = state32 {.s = ud_g0_shrink(state), .dist = 0}; 

        var x: u32 = 12;
        var y: u32 = 12;
        var z: u32 = 12;


        if (std.sort.binarySearch(state32, c_o, self.g0_ct[0..self.g0_ct_fill], {}, order_state32)) |pos| {
            x = self.g0_ct[pos].dist;
        }
        if (std.sort.binarySearch(state32, e_o, self.g0_et[0..self.g0_et_fill], {}, order_state32) ) |pos1| {
            y = self.g0_et[pos1].dist;
        }
        if (std.sort.binarySearch(state32, ud, self.g0_ud[0..self.g0_ud_fill], {}, order_state32)) |pos2| {
            z = self.g0_ud[pos2].dist;
        }
        
        //convert state to g0 values
        //find index in g0 tables
        //distance shall be x+y+z or max(x,y,z)
        return @max(@max(x,y),z);
        //return x+y+z;
    }
    pub fn g1_dist(self: *prune, state: cube.cube) u32 {
        const c = state32 {.s = corner_shrink(state), .dist = 0};
        const e = state32 {.s = edge_shrink(state), .dist = 0};
        const ud = state32 {.s = ud_g1_shrink(state), .dist = 0}; 

        var x: u32 = 18;
        var y: u32 = 18;
        var z: u32 = 18;


        if (std.sort.binarySearch(state32, c, self.g1_ct[0..self.g1_ct_fill], {}, order_state32)) |pos| {
            x = self.g1_ct[pos].dist;
        }
        if (std.sort.binarySearch(state32, e, self.g1_et[0..self.g1_et_fill], {}, order_state32) ) |pos1| {
            y = self.g1_et[pos1].dist;
        }
        if (std.sort.binarySearch(state32, ud, self.g1_ud[0..self.g1_ud_fill], {}, order_state32)) |pos2| {
            z = self.g1_ud[pos2].dist;
        }
        
        //distance shall be x+y+z or max(x,y,z)
        //return x+y+z;
        return @max(@max(x,y),z);
    }
    pub fn insert_g0_prune(self: *prune, state: cube.cube, dist: u32) bool{
        var unique: bool = false;
        const c_o = state32 {.s = corner_o_shrink(state), .dist = dist};
        const e_o = state32 {.s = edge_o_shrink(state), .dist = dist};
        const ud = state32 {.s = ud_g0_shrink(state), .dist = dist}; 

        //type, key, data, context, orderfn 
        const pos = std.sort.binarySearch(state32, c_o, self.g0_ct[0..self.g0_ct_fill], {}, order_state32);
        if (pos == null) {
            if (self.g0_ct_fill < self.g0_ct.len) {
                unique = true;
                self.g0_ct[self.g0_ct_fill] = c_o;
                self.g0_ct_fill += 1;
                std.sort.insertion(state32, self.g0_ct[0..self.g0_ct_fill], {},lessthan_state32);
            }
        }
        const pos1 = std.sort.binarySearch(state32, e_o, self.g0_et[0..self.g0_et_fill], {}, order_state32);
        if (pos1 == null) {
            if (self.g0_et_fill < self.g0_et.len) {
                unique = true;
                self.g0_et[self.g0_et_fill] = e_o;
                self.g0_et_fill += 1;
                std.sort.insertion(state32, self.g0_et[0..self.g0_et_fill], {}, lessthan_state32);
            }
        }
        const pos2 = std.sort.binarySearch(state32, ud, self.g0_ud[0..self.g0_ud_fill], {}, order_state32);
        if (pos2 == null) {
            if (self.g0_ud_fill < self.g0_ud.len) {
                unique = true;
                self.g0_ud[self.g0_ud_fill] = ud;
                self.g0_ud_fill += 1;
                std.sort.insertion(state32, self.g0_ud[0..self.g0_ud_fill], {},lessthan_state32);
            }
        }
        return unique;

    }
    pub fn insert_g1_prune(self: *prune, state: cube.cube, dist: u32) bool {
        var unique: bool = false;
        const c = state32 {.s = corner_shrink(state), .dist = dist};
        const e = state32 {.s = edge_shrink(state), .dist = dist};
        const ud = state32 {.s = ud_g1_shrink(state), .dist = dist}; 

        //type, key, data, context, orderfn 
        const pos = std.sort.binarySearch(state32, c, self.g1_ct[0..self.g1_ct_fill], {}, order_state32);
        if (pos == null) {
            if (self.g1_ct_fill < self.g1_ct.len) {
                unique = true;
                self.g1_ct[self.g1_ct_fill] = c;
                self.g1_ct_fill += 1;
                std.sort.insertion(state32, self.g1_ct[0..self.g1_ct_fill], {},lessthan_state32);
            }
        }
        const pos1 = std.sort.binarySearch(state32, e, self.g1_et[0..self.g1_et_fill], {}, order_state32);
        if (pos1 == null) {
            if (self.g1_et_fill < self.g1_et.len) {
                unique = true;
                self.g1_et[self.g1_et_fill] = e;
                self.g1_et_fill += 1;
                std.sort.insertion(state32, self.g1_et[0..self.g1_et_fill], {}, lessthan_state32);
            }
        }
        const pos2 = std.sort.binarySearch(state32, ud, self.g1_ud[0..self.g1_ud_fill], {}, order_state32);
        if (pos2 == null) {
            if (self.g1_ud_fill < self.g1_ud.len) {
                unique = true;
                self.g1_ud[self.g1_ud_fill] = ud;
                self.g1_ud_fill += 1;
                std.sort.insertion(state32, self.g1_ud[0..self.g1_ud_fill], {},lessthan_state32);
            }
        }
        return unique;
    }
    pub fn gen_g0_prune_tables(self: *prune) !void {
    //search all permutations up to depth 12

    //pseudo code
    // state = cube.cube.init()
    // insert_prune(state, 0)
    // states = append(state)
    // while depth <= 12
    //      for state in states
    //          var i = 0;
    //          while i < 19
    //              new_state = apply_move(state, i)
    //              insert_prune(new_state, depth)
    //              next_states.append(new_state)
    //      states = next_states //replace for next depth
    //
        var state = cube.cube.init();
        var states = std.ArrayList(cube.cube).init(self.alloc);
        defer states.deinit();
        try states.append(state);
        _ = self.insert_g0_prune(state, 0);
        var depth : u32 = 1;
        //while (depth < 12) : (depth += 1) {
        while (depth < 12) : (depth += 1) {
            var next_states = std.ArrayList(cube.cube).init(self.alloc);
            defer next_states.deinit();
            while (states.items.len > 0) {
                state = states.pop();
                var i: u8 = 0;
                while (i < 18) : (i += 1) {
                    var new_state = state;
                    new_state.rotate(i); 
                    var unique = self.insert_g0_prune(new_state, depth);
                    //until depth 6 insert all
                    if (depth < 6) {
                        try next_states.append(new_state);
                    }
                    //insert only if not already inserted
                    else if (unique) {
                        try next_states.append(new_state);
                    }
                }
            }
            while (next_states.items.len > 0) {
                try states.append(next_states.pop());
            }
            std.debug.print("depth {}\n", .{depth});
            std.debug.print("self.g0_ct {} \n", .{self.g0_ct_fill});
            std.debug.print("self.g0_et {} \n", .{self.g0_et_fill});
            std.debug.print("self.g0_ud {} \n", .{self.g0_ud_fill});
        }
    }
    pub fn gen_g1_prune_tables(self: *prune) !void {
    //search all permutations up to depth 12

    //pseudo code
    // state = cube.cube.init()
    // insert_prune(state, 0)
    // states = append(state)
    // while depth <= 12
    //      for state in states
    //          var i = 0;
    //          while i < 19
    //              new_state = apply_move(state, i)
    //              insert_prune(new_state, depth)
    //              next_states.append(new_state)
    //      states = next_states //replace for next depth
    //
        var state = cube.cube.init();
        var states = std.ArrayList(cube.cube).init(self.alloc);
        defer states.deinit();
        try states.append(state);
        _ = self.insert_g1_prune(state, 0);
        var depth : u32 = 1;
        //while (depth < 12) : (depth += 1) {
        while (depth < 18) : (depth += 1) {
            var next_states = std.ArrayList(cube.cube).init(self.alloc);
            defer next_states.deinit();
            while (states.items.len > 0) {
                state = states.pop();
                var i: u8 = 8;
                while (i < 18) : (i += 1) {
                    var new_state = state;
                    new_state.rotate(i); 
                    var unique = self.insert_g1_prune(new_state, depth);
                    //until depth 7 insert all
                    if (depth < 7) {
                        try next_states.append(new_state);
                    }
                    //insert only if not already inserted
                    else if (unique) {
                        try next_states.append(new_state);
                    }
                }
            }
            while (next_states.items.len > 0) {
                try states.append(next_states.pop());
            }
            std.debug.print("depth {}\n", .{depth});
            std.debug.print("self.g1_ct {} \n", .{self.g1_ct_fill});
            std.debug.print("self.g1_et {} \n", .{self.g1_et_fill});
            std.debug.print("self.g1_ud {} \n", .{self.g1_ud_fill});
        }
    }

};

pub const solution = struct {
    depth: u32,
    moves: []u8,
};

pub fn search_g1(state: cube.cube, path: *std.ArrayList(cube.cube), depth: u32, bound: u32, p: *prune, sol: *solution) !cube.cube {
    var node = state;
    var min = state;
    //var cost = path.items.len;
    var h = p.g0_dist(node);
    var g = depth;
    var f = g + h;
    var min_dist = h;
    var min_step : u8 = 0;
    if (f > bound) {
        return node;
    }
       
    //std.debug.print("search h {} \n", .{h});

    if (h == 0) {
        sol.depth = depth;
        return node;
    }

    var i: u8 = 0;
    outer: while (i < 18) : (i += 1) {
        var new_state = node;
        new_state.rotate(i); 

        //optionally check that we haven't visited this state
        var j: usize = path.items.len;
        while (j > 0) : (j -= 1) {
            if (new_state.equal(path.items[j-1])) {
                continue :outer;
            }
        }
        try path.append(new_state);
        sol.moves[sol.depth] = i;
        sol.depth +=1;


        new_state = try search_g1(new_state, path, depth+1, bound, p, sol);
        h = p.g0_dist(new_state);
        if (h == 0) {
            //solution.depth = depth + 1;
            return new_state;
        }
        if (h < min_dist) {
            min = new_state;
            min_dist = h;
            min_step = i;
        }
        sol.depth -=1;
        _ =  path.popOrNull();

    }
    //std.debug.print("min {} \n", .{min_dist});
    return min;

}

pub fn solve_g0(alloc: std.mem.Allocator, max_depth: u32,state: cube.cube, p: *prune) !solution{
    
    var old_state = state;
    var moves = try alloc.alloc(u8, max_depth);
    var sol = solution{.depth = 0, .moves = moves};
    //IDA star 
    var bound: u32 = p.g0_dist(state) + 2;
    var i: u32= 0;
    var path = std.ArrayList(cube.cube).init(alloc);
    try path.append(state);
    defer path.deinit();
    while (i < max_depth) : (i += 1) {
        std.debug.print("depth {} \n", .{i});
        var new_state = try search_g1(old_state, &path, 0, bound, p, &sol);
        var dist = p.g0_dist(new_state);
        if (dist==0) {
            break;
        }
        old_state = new_state;
        bound = dist+i;

    }
    return sol;
}

pub fn search_g2(state: cube.cube, path: *std.ArrayList(cube.cube), depth: u32, bound: u32, p: *prune, sol: *solution) !cube.cube {
    var node = state;
    var min = state;
    //var cost = path.items.len;
    var h = p.g1_dist(node);
    var g = depth;
    var f = g + h;
    var min_dist = h;
    var min_step : u8 = 0;
    if (f > bound) {
        return node;
    }
       
    //std.debug.print("search h2 {} \n", .{h});

    if (h == 0) {
        sol.depth = depth;
        return node;
    }

    var i: u8 = 8;
    outer: while (i < 18) : (i += 1) {
        var new_state = node;
        new_state.rotate(i); 

        //optionally check that we haven't visited this state
        var j: usize = path.items.len;
        while (j > 0) : (j -= 1) {
            if (new_state.equal(path.items[j-1])) {
                continue :outer;
            }
        }
        //dont use same move twice
        if (sol.depth > 0 and i == sol.moves[sol.depth-1]) {
            continue;
        }
        try path.append(new_state);
        sol.moves[sol.depth] = i;
        sol.depth +=1;

        //new_state = try search_g2(new_state, path, depth+1, bound, p, sol);
        new_state = try search_g2(new_state, path, depth+1, bound, p, sol);
        h = p.g1_dist(new_state);
        if (h == 0) {
            //solution.depth = depth + 1;
            return new_state;
        }
        if (h < min_dist) {
            min = new_state;
            min_dist = h;
            min_step = i;
        }
        sol.depth -=1;
        _ =  path.popOrNull();

    }
    //std.debug.print("min2 {} \n", .{min_dist});
    return min;

}
pub fn solve_full(alloc: std.mem.Allocator, max_depth: u32,state: cube.cube, p: *prune) !solution{
    
    var old_state = state;
    var g0_solved = false;
    var g0_depth : u32 = 0;
    var moves = try alloc.alloc(u8, max_depth);
    var sol = solution{.depth = 0, .moves = moves};
    //IDA star 
    var bound: u32 = p.g0_dist(state);
    var i: u32= 0;
    var path = std.ArrayList(cube.cube).init(alloc);
    try path.append(state);
    defer path.deinit();
    while (i < 18) : (i += 1) {
        std.debug.print("depth {} \n", .{i});
        var new_state = try search_g1(old_state, &path, 0, bound, p, &sol);
        var dist = p.g0_dist(new_state);
        if (dist==0) {
            g0_solved = true;
            old_state = new_state;
            g0_depth = sol.depth;
            std.debug.print("g0 solution depth: {} \n", .{sol.depth});
            break;
        }
        //old_state = new_state;
        //bound = dist+i; why +i?
        //bound = dist;
        bound = bound + dist;

    }
    if (!g0_solved) {
        std.debug.print("cant find g0 solution{} \n", .{i});
        return sol;
    }
    bound = g0_depth + p.g1_dist(old_state);
    //var path2 = std.ArrayList(cube.cube).init(alloc);
    //try path.append(old_state);
    //defer path2.deinit();
    i = 0;
    while (i < max_depth) : (i += 1) {
        std.debug.print("depth {} \n", .{i});
        //var new_state = try search_g2(old_state, &path2, 0, bound, p, &sol);
        var new_state = try search_g2(old_state, &path, g0_depth, bound, p, &sol);
        var dist = p.g1_dist(new_state);
        if (dist==0) {
            std.debug.print("solved solution depth: {} \n", .{sol.depth});
            break;
        }
        //old_state = new_state;
        //bound = dist+i; why +i?
        //bound = dist;
        bound = bound + dist + 1;
        std.debug.print(" g1 bound: {} \n", .{bound});

    }

    return sol;
}

test "gen prune tables" {
    const allocator = std.testing.allocator;
    var p = try prune.init(allocator);
    defer p.deinit();
    try p.gen_g0_prune_tables();
    try p.gen_g1_prune_tables();
    var state = cube.cube.init();
    state.right();
    state.front();
    state.up();
    state.down();
    state.front();
    state.right();
    state.front();
    state.up();
    //var sol = try solve_g0(allocator, 30, state, &p);
    var sol = try solve_full(allocator, 60, state, &p);
    var i: usize = 0;
    std.debug.print("solution: ", .{});
    while (i < sol.depth) : (i += 1) {
        var move = switch (sol.moves[i]) {
            0 => "F",
            1 => "F'",
            2 => "B",
            3 => "B'",
            4 => "R",
            5 => "R'",
            6 => "L",
            7 => "L'",
            8 => "U",
            9 => "U'",
            10 => "D",
            11 => "D'",
            12 => "U2",
            13 => "R2",
            14 => "F2",
            15 => "D2",
            16 => "L2",
            17 => "B2",
            else => "",
        };
        std.debug.print("{s} ", .{move});
    }
    std.debug.print(" depth: {} \n", .{sol.depth});
    defer allocator.free(sol.moves);
}


test "init and deinit prune" {
    const allocator = std.testing.allocator;
    var p = try prune.init(allocator);
    defer p.deinit();
}

