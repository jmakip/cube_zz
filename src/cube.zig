const std = @import("std");

const edge_orient = enum(u1) {
    edge_normal,
    edge_flipped,
};
const corner_orient = enum(u2) {
    corner_normal,
    corner_flipped1,
    corner_flipped2,
};
//cube edges
//const edges = enum(u8) {
//    edge_uf, //Up Front
//    edge_ur, //Up Right
//    edge_ub, //Up Back
//    edge_ul, //Up left
//
//    edge_df, //Down Front
//    edge_dr, //down right
//    edge_db, //Down Back
//    edge_dl, //Down left
//
//    edge_fr, //Front Right
//    edge_fl, //Front Left
//    edge_br, //Back Right
//    edge_bl, //Back Left
//};
const edge_uf : usize = 0;
const edge_ur : usize = 1;
const edge_ub : usize = 2;
const edge_ul : usize = 3;
const edge_df : usize = 4;
const edge_dr : usize = 5;
const edge_db : usize = 6;
const edge_dl : usize = 7;
const edge_fr : usize = 8;
const edge_fl : usize = 9;
const edge_br : usize = 10;
const edge_bl : usize = 11;

//UFR URB UBL ULF DRF DFL DLB DBR 
//const corners = enum(u8) {
//    corner_ufr, //Up Front Right
//    corner_urb, //Up Right Back
//    corner_ubl, //Up Back Left
//    corner_ulf, //Up Left Front
//    corner_drf, //Down Front Right
//    corner_dbl, //Down Back Left
//    corner_dlb, //Down Left Back
//    corner_drb, //Down Right Back
//};
const corner_ufr : usize = 0; //Up Front Right
const corner_urb : usize = 1; //Up Right Back
const corner_ubl : usize = 2; //Up Back Left
const corner_ulf : usize = 3; //Up Left Front
const corner_drf : usize = 4; //Down Front Right
const corner_dlf : usize = 5; //Down Back Left
const corner_dlb : usize = 6; //Down Left Back
const corner_drb : usize = 7; //Down Right Back

//reason why moves are in this order is that g1 phase can only use moves that
//are between 8...18
pub const    move_f : u8 = 0;
pub const    move_fi : u8 = 1; //inverse
pub const    move_b : u8 = 2;
pub const    move_bi : u8 = 3; //inverse
pub const    move_r : u8 = 4;
pub const    move_ri : u8 = 5; //inverse
pub const    move_l : u8 = 6;
pub const    move_li : u8 = 7; //inverse
pub const    move_u : u8 = 8;
pub const    move_ui : u8 = 9; //inverse
pub const    move_d : u8 = 10;
pub const    move_di : u8 = 11; //inverse
pub const    move_u2 : u8 = 12;
pub const    move_r2 : u8 = 13;
pub const    move_f2 : u8 = 14;
pub const    move_d2 : u8 = 15;
pub const    move_l2 : u8 = 16;
pub const    move_b2 : u8 = 17;

pub fn edge_twist(orientation: u8) u8 {
    const t = (orientation + 1) % 2;
    return t;
}
pub fn corner_twist(orientation: u8) u8 {
    const t = (orientation + 1) % 3;
    return t;
}

//shall describe 3x3x3 cube which has 8 corner pieces and 12 edges
pub const cube = struct {
    c :[8] u8, //corners
    e :[12] u8, //edges
    c_o :[8] u8, //corner orient
    e_o :[12] u8, //edge orient
    pub fn init() cube {
        //solved state
        return cube {
            .c = [8] u8 {0, 1, 2, 3, 4, 5, 6, 7},
            .e = [12] u8 {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11},
            .c_o = [8] u8 {0, 0, 0, 0, 0, 0, 0, 0},
            .e_o = [12] u8 {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        };
    }
    pub fn equal(self: *cube, other: cube) bool {
        if (std.mem.eql(u8, &self.c, &other.c) and
            std.mem.eql(u8, &self.e, &other.e) and
            std.mem.eql(u8, &self.c_o, &other.c_o) and
            std.mem.eql(u8, &self.e_o, &other.e_o)) {
            return true;
        }
        return false;
    }
    pub fn scramble(self: *cube, moves: []u8) void {
        for (moves) |m| {
            self.rotate(m);
        }
    }
    pub fn scramble_str(self: *cube, moves: []const u8) void {
        var it = std.mem.splitSequence(u8, moves, " ");
        while (it.next()) |m| {
            if(std.mem.eql(u8, m, "F" )) {
                self.rotate(move_f);
            }
            else if(std.mem.eql(u8, m, "U")) {
                self.rotate(move_u);
            }
            else if(std.mem.eql(u8, m, "D")) {
                self.rotate(move_d);
            }
            else if(std.mem.eql(u8, m, "B")) {
                self.rotate(move_b);
            }
            else if(std.mem.eql(u8, m, "R")) {
                self.rotate(move_r);
            }
            else if(std.mem.eql(u8, m, "L")) {
                self.rotate(move_l);
            }
            else if(std.mem.eql(u8, m, "F2")) {
                self.rotate(move_f2);
            }
            else if(std.mem.eql(u8, m, "B2")) {
                self.rotate(move_b2);
            }
            else if(std.mem.eql(u8, m, "U2")) {
                self.rotate(move_u2);
            }
            else if(std.mem.eql(u8, m, "D2")) {
                self.rotate(move_d2);
            }
            else if(std.mem.eql(u8, m, "L2")) {
                self.rotate(move_l2);
            }
            else if(std.mem.eql(u8, m, "R2")) {
                self.rotate(move_r2);
            }
            else if(std.mem.eql(u8, m, "L'")) {
                self.rotate(move_li);
            }
            else if(std.mem.eql(u8, m, "R'")) {
                self.rotate(move_ri);
            }
            else if(std.mem.eql(u8, m, "U'")) {
                self.rotate(move_ui);
            }
            else if(std.mem.eql(u8, m, "D'")) {
                self.rotate(move_di);
            }
            else if(std.mem.eql(u8, m, "F'")) {
                self.rotate(move_fi);
            }
            else if(std.mem.eql(u8, m, "B'")) {
                self.rotate(move_bi);
            }
        }
    }

    pub fn rotate(self: *cube, move: u8) void {
        switch (move) {
            move_f => {
                self.front();
            },
            move_b => {
                self.back();
            },
            move_r => {
                self.right();
            },
            move_l => {
                self.left();
            },
            move_u => {
                self.up();
            },
            move_d => {
                self.down();
            },
            move_u2 => {
                self.up();
                self.up();
            },
            move_r2 => {
                self.right();
                self.right();
            },
            move_f2 => {
                self.front();
                self.front();
            },
            move_d2 => {
                self.down();
                self.down();
            },
            move_l2 => {
                self.left();
                self.left();
            },
            move_b2 => {
                self.back();
                self.back();
            },
            move_fi => {
                self.front();
                self.front();
                self.front();
            },
            move_bi => {
                self.back();
                self.back();
                self.back();
            },
            move_ri => {
                self.right();
                self.right();
                self.right();
            },
            move_li => {
                self.left();
                self.left();
                self.left();
            },
            move_ui => {
                self.up();
                self.up();
                self.up();
            },
            move_di => {
                self.down();
                self.down();
                self.down();
            },
            else => { },
        }
    }
    pub fn up(self: *cube) void {
        const n_e = [4] u8 { self.e[1], self.e[2], self.e[3], self.e[0]};
        const n_c = [4] u8 { self.c[1], self.c[2], self.c[3], self.c[0]};
        const n_eo = [4] u8 { self.e_o[1], self.e_o[2], self.e_o[3], self.e_o[0]};
        const n_co = [4] u8 { self.c_o[1], self.c_o[2], self.c_o[3], self.c_o[0]};
        var i : usize = 0;
        while(i < 4) : (i += 1) {
            self.e[i] = n_e[i];
            self.c[i] = n_c[i];
            self.e_o[i] = n_eo[i];
            self.c_o[i] = n_co[i];
        }
    }
    pub fn down(self: *cube) void {
        const n_e = [4] u8 { self.e[7], self.e[4], self.e[5], self.e[6]};
        const n_c = [4] u8 { self.c[5], self.c[6], self.c[7], self.c[4]};
        const n_eo = [4] u8 { self.e_o[7], self.e_o[4], self.e_o[5], self.e_o[6]};
        const n_co = [4] u8 { self.c_o[5], self.c_o[6], self.c_o[7], self.c_o[4]};
        var i : usize = 0;
        while(i < 4) : (i += 1) {
            self.e[i + 4] = n_e[i];
            self.c[i + 4] = n_c[i];
            self.e_o[i + 4 ] = n_eo[i];
            self.c_o[i + 4 ] = n_co[i];
        }
    }
    pub fn right(self: *cube) void {
        
        var n_e = self.e[0..12].*;
        var n_eo = self.e_o[0..12].*;
        var n_c = self.c[0..8].*;
        var n_co = self.c_o[0..8].*;

        n_e[edge_ur] = self.e[edge_fr];
        n_e[edge_br] = self.e[edge_ur];
        n_e[edge_dr] = self.e[edge_br];
        n_e[edge_fr] = self.e[edge_dr];
        n_eo[edge_ur] = self.e_o[edge_fr];
        n_eo[edge_br] = self.e_o[edge_ur];
        n_eo[edge_dr] = self.e_o[edge_br];
        n_eo[edge_fr] = self.e_o[edge_dr];
        self.e = n_e;
        self.e_o = n_eo;

        n_c[corner_ufr] = self.c[corner_drf];
        n_c[corner_urb] = self.c[corner_ufr];
        n_c[corner_drb] = self.c[corner_urb];
        n_c[corner_drf] = self.c[corner_drb];

        n_co[corner_ufr] = corner_twist(corner_twist(self.c_o[corner_drf]));
        n_co[corner_urb] = corner_twist(self.c_o[corner_ufr]);
        n_co[corner_drb] = corner_twist(corner_twist(self.c_o[corner_urb]));
        n_co[corner_drf] = corner_twist(self.c_o[corner_drb]);


        self.c = n_c;
        self.c_o = n_co;

    }
    pub fn left(self: *cube) void {
        var n_e = self.e[0..12].*;
        var n_eo = self.e_o[0..12].*;
        var n_c = self.c[0..8].*;
        var n_co = self.c_o[0..8].*;

        n_e[edge_ul] = self.e[edge_bl];
        n_e[edge_dl] = self.e[edge_fl];
        n_e[edge_fl] = self.e[edge_ul];
        n_e[edge_bl] = self.e[edge_dl];

        n_eo[edge_ul] = self.e_o[edge_bl];
        n_eo[edge_dl] = self.e_o[edge_fl];
        n_eo[edge_fl] = self.e_o[edge_ul];
        n_eo[edge_bl] = self.e_o[edge_dl];
        
        n_c[corner_ubl] = self.c[corner_dlb];
        n_c[corner_ulf] = self.c[corner_ubl];
        n_c[corner_dlf] = self.c[corner_ulf];
        n_c[corner_dlb] = self.c[corner_dlf];

        n_co[corner_ubl] = corner_twist(corner_twist(self.c_o[corner_dlb]));
        n_co[corner_ulf] = corner_twist(self.c_o[corner_ubl]);
        n_co[corner_dlf] = corner_twist(corner_twist(self.c_o[corner_ulf]));
        n_co[corner_dlb] = corner_twist(self.c_o[corner_dlf]);
        self.e = n_e;
        self.e_o = n_eo;

        self.c = n_c;
        self.c_o = n_co;
    }
    pub fn front(self: *cube) void {
        var n_e = self.e[0..12].*;
        var n_eo = self.e_o[0..12].*;
        var n_c = self.c[0..8].*;
        var n_co = self.c_o[0..8].*;
        n_e[edge_uf] = self.e[edge_fl];
        n_e[edge_fr] = self.e[edge_uf];
        n_e[edge_df] = self.e[edge_fr];
        n_e[edge_fl] = self.e[edge_df];

        n_eo[edge_uf] = edge_twist(self.e_o[edge_fl]);
        n_eo[edge_fr] = edge_twist(self.e_o[edge_uf]);
        n_eo[edge_df] = edge_twist(self.e_o[edge_fr]);
        n_eo[edge_fl] = edge_twist(self.e_o[edge_df]);

        n_c[corner_ufr] = self.c[corner_ulf];
        n_c[corner_drf] = self.c[corner_ufr];
        n_c[corner_dlf] = self.c[corner_drf];
        n_c[corner_ulf] = self.c[corner_dlf];

        n_co[corner_ufr] = corner_twist(self.c_o[corner_ulf]);
        n_co[corner_drf] = corner_twist(corner_twist(self.c_o[corner_ufr]));
        n_co[corner_dlf] = corner_twist(self.c_o[corner_drf]);
        n_co[corner_ulf] = corner_twist(corner_twist(self.c_o[corner_dlf]));
        self.e = n_e;
        self.e_o = n_eo;

        self.c = n_c;
        self.c_o = n_co;
    }
    pub fn back(self: *cube) void {
        var n_e = self.e[0..12].*;
        var n_eo = self.e_o[0..12].*;
        var n_c = self.c[0..8].*;
        var n_co = self.c_o[0..8].*;

        n_e[edge_ub] = self.e[edge_br];
        n_e[edge_br] = self.e[edge_db];
        n_e[edge_db] = self.e[edge_bl];
        n_e[edge_bl] = self.e[edge_ub];

        n_eo[edge_ub] = edge_twist(self.e_o[edge_br]);
        n_eo[edge_br] = edge_twist(self.e_o[edge_db]);
        n_eo[edge_db] = edge_twist(self.e_o[edge_bl]);
        n_eo[edge_bl] = edge_twist(self.e_o[edge_ub]);
        
        n_c[corner_urb] = self.c[corner_drb];
        n_c[corner_ubl] = self.c[corner_urb];
        n_c[corner_dlb] = self.c[corner_ubl];
        n_c[corner_drb] = self.c[corner_dlb];

        n_co[corner_urb] = corner_twist(corner_twist(self.c_o[corner_drb]));
        n_co[corner_ubl] = corner_twist(self.c_o[corner_urb]);
        n_co[corner_dlb] = corner_twist(corner_twist(self.c_o[corner_ubl]));
        n_co[corner_drb] = corner_twist(self.c_o[corner_dlb]);
        self.e = n_e;
        self.e_o = n_eo;

        self.c = n_c;
        self.c_o = n_co;
    }
};
