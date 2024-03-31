// src/main.zig
const ray = @cImport(@cInclude("raylib.h"));
const cube = @import("cube.zig");
const prune = @import("prune.zig");
const std = @import("std");



pub fn faceAsRayColor(code: u8) ray.Color{
    return switch (code) {
        0 => ray.YELLOW,
        1 => ray.WHITE,
        2 => ray.GREEN,
        3 => ray.BLUE,
        4 => ray.RED,
        5 => ray.ORANGE,
        else => ray.BLACK,
    };
}

pub fn drawRubiks(colors: []u8) void {
    if (colors.len != 9*6) {
        return;
    }
    //debug colors
    //unwrap rubiks cube tiles into cross shape
    //upside of cube 3x3 pattern
    ray.DrawRectangle(100, 50, 20, 20, faceAsRayColor(colors[0]));
    ray.DrawRectangle(130, 50, 20, 20, faceAsRayColor(colors[1]));
    ray.DrawRectangle(160, 50, 20, 20, faceAsRayColor(colors[2]));
    ray.DrawRectangle(100, 80, 20, 20, faceAsRayColor(colors[3]));
    ray.DrawRectangle(130, 80, 20, 20, faceAsRayColor(colors[4]));
    ray.DrawRectangle(160, 80, 20, 20, faceAsRayColor(colors[5]));
    ray.DrawRectangle(100, 110, 20, 20,faceAsRayColor(colors[6]));
    ray.DrawRectangle(130, 110, 20, 20,faceAsRayColor(colors[7]));
    ray.DrawRectangle(160, 110, 20, 20,faceAsRayColor(colors[8]));

    //front face 3x3
    ray.DrawRectangle(100, 140, 20, 20, faceAsRayColor(colors[9]));
    ray.DrawRectangle(130, 140, 20, 20, faceAsRayColor(colors[10]));
    ray.DrawRectangle(160, 140, 20, 20, faceAsRayColor(colors[11]));
    ray.DrawRectangle(100, 170, 20, 20, faceAsRayColor(colors[12]));
    ray.DrawRectangle(130, 170, 20, 20, faceAsRayColor(colors[13]));
    ray.DrawRectangle(160, 170, 20, 20, faceAsRayColor(colors[14]));
    ray.DrawRectangle(100, 200, 20, 20, faceAsRayColor(colors[15]));
    ray.DrawRectangle(130, 200, 20, 20, faceAsRayColor(colors[16]));
    ray.DrawRectangle(160, 200, 20, 20, faceAsRayColor(colors[17]));

    //down face 3x3
    ray.DrawRectangle(100, 230, 20, 20, faceAsRayColor(colors[18]));
    ray.DrawRectangle(130, 230, 20, 20, faceAsRayColor(colors[19]));
    ray.DrawRectangle(160, 230, 20, 20, faceAsRayColor(colors[20]));
    ray.DrawRectangle(100, 260, 20, 20, faceAsRayColor(colors[21]));
    ray.DrawRectangle(130, 260, 20, 20, faceAsRayColor(colors[22]));
    ray.DrawRectangle(160, 260, 20, 20, faceAsRayColor(colors[23]));
    ray.DrawRectangle(100, 290, 20, 20, faceAsRayColor(colors[24]));
    ray.DrawRectangle(130, 290, 20, 20, faceAsRayColor(colors[25]));
    ray.DrawRectangle(160, 290, 20, 20, faceAsRayColor(colors[26]));

    //left face 3x3
    ray.DrawRectangle(10, 140, 20, 20, faceAsRayColor(colors[27]));
    ray.DrawRectangle(40, 140, 20, 20, faceAsRayColor(colors[28]));
    ray.DrawRectangle(70, 140, 20, 20, faceAsRayColor(colors[29]));
    ray.DrawRectangle(10, 170, 20, 20, faceAsRayColor(colors[30]));
    ray.DrawRectangle(40, 170, 20, 20, faceAsRayColor(colors[31]));
    ray.DrawRectangle(70, 170, 20, 20, faceAsRayColor(colors[32]));
    ray.DrawRectangle(10, 200, 20, 20, faceAsRayColor(colors[33]));
    ray.DrawRectangle(40, 200, 20, 20, faceAsRayColor(colors[34]));
    ray.DrawRectangle(70, 200, 20, 20, faceAsRayColor(colors[35]));

    //right face 3x3
    ray.DrawRectangle(10+180, 140, 20, 20, faceAsRayColor(colors[36]));
    ray.DrawRectangle(40+180, 140, 20, 20, faceAsRayColor(colors[37]));
    ray.DrawRectangle(70+180, 140, 20, 20, faceAsRayColor(colors[38]));
    ray.DrawRectangle(10+180, 170, 20, 20, faceAsRayColor(colors[39]));
    ray.DrawRectangle(40+180, 170, 20, 20, faceAsRayColor(colors[40]));
    ray.DrawRectangle(70+180, 170, 20, 20, faceAsRayColor(colors[41]));
    ray.DrawRectangle(10+180, 200, 20, 20, faceAsRayColor(colors[42]));
    ray.DrawRectangle(40+180, 200, 20, 20, faceAsRayColor(colors[43]));
    ray.DrawRectangle(70+180, 200, 20, 20, faceAsRayColor(colors[44]));

    ray.DrawRectangle(10+180+90, 140, 20, 20, faceAsRayColor(colors[45]));
    ray.DrawRectangle(40+180+90, 140, 20, 20, faceAsRayColor(colors[46]));
    ray.DrawRectangle(70+180+90, 140, 20, 20, faceAsRayColor(colors[47]));
    ray.DrawRectangle(10+180+90, 170, 20, 20, faceAsRayColor(colors[48]));
    ray.DrawRectangle(40+180+90, 170, 20, 20, faceAsRayColor(colors[49]));
    ray.DrawRectangle(70+180+90, 170, 20, 20, faceAsRayColor(colors[50]));
    ray.DrawRectangle(10+180+90, 200, 20, 20, faceAsRayColor(colors[51]));
    ray.DrawRectangle(40+180+90, 200, 20, 20, faceAsRayColor(colors[52]));
    ray.DrawRectangle(70+180+90, 200, 20, 20, faceAsRayColor(colors[53]));
}

pub const edgecolor = struct {
    color: [2]u8
};
pub const cornercolor = struct {
    color: [3]u8
};

//UFR URB UBL ULF DRF DFL DLB DBR 
//        0 => ray.YELLOW,
//        1 => ray.WHITE,
//        2 => ray.GREEN,
//        3 => ray.BLUE,
//        4 => ray.RED,
//        5 => ray.ORANGE,
//
//              [ 0][ 1][ 2]
//              [ 3][ 4][ 5]
//              [ 6][ 7][ 8]
// [27][28][29] [ 9][10][11] [36][37][38] [45][46][47]
// [30][31][32] [12][13][14] [39][40][41] [48][49][50]
// [33][34][35] [15][16][17] [42][43][44] [51][52][53]
//              [18][19][20]
//              [21][22][23]
//              [24][25][26]
//
pub fn getCubeFaces(colors: []u8, state: cube.cube) void
{
    //corner
    const tileidx1= [24]u8 { 
        8, 11, 36, //UFR
        2, 38, 45, //URB
        0, 47, 27, //UBL
        6, 29, 9, //ULF
        20, 42, 17, //DRF
        18, 15, 35, //DFL
        24, 33, 53, //DLB
        26, 51, 44, //DBR
    }; 
    //edge
    const tileidx= [24]u8 { 
        7, 10, //UF
        5, 37, //UR
        1, 46, //UB
        3, 28, //UL
        19, 16, //DF
        23, 43, //DR
        25, 52, //DB
        21, 34, //DL
        14, 39, //FR
        12, 32, //FL
        48, 41, //BR
        50, 30, //BL
        }; 
    const edgecolors = [12]edgecolor{
        .{ .color = [_]u8{0, 2} }, //UF
        .{ .color = [_]u8{0, 5} }, //UR
        .{ .color = [_]u8{0, 3} }, //UB
        .{ .color = [_]u8{0, 4} }, //UL

        .{ .color = [_]u8{1, 2} }, //DF
        .{ .color = [_]u8{1, 5} }, //DR
        .{ .color = [_]u8{1, 3} }, //DB
        .{ .color = [_]u8{1, 4} }, //DL

        .{ .color = [_]u8{2, 5} }, //FR
        .{ .color = [_]u8{2, 4} }, //FL
        .{ .color = [_]u8{3, 5} }, //BR
        .{ .color = [_]u8{3, 4} }, //BL
    };
    const cornercolors = [8]cornercolor{
        .{ .color = [_]u8{0, 2, 5} }, //UFR
        .{ .color = [_]u8{0, 5, 3} }, //URB
        .{ .color = [_]u8{0, 3, 4} }, //UBL
        .{ .color = [_]u8{0, 4, 2} }, //ULF
        //
        .{ .color = [_]u8{1, 5, 2} }, //DRF
        .{ .color = [_]u8{1, 2, 4} }, //DFL
        .{ .color = [_]u8{1, 4, 3} }, //DLB
        .{ .color = [_]u8{1, 3, 5} }  //DBR
    };

    if (colors.len != 54) {
        return;
    }
    //fill edge stickers
    var i: u32 = 0;
    while (i < 12) : (i += 1) {
        var edge = state.e[i];
        var twist = state.e_o[i];
        var primary = edgecolors[edge].color[twist];
        var secondary = edgecolors[edge].color[(twist + 1) % 2];
        var tile0 = tileidx[i*2];
        var tile1 = tileidx[i*2 + 1];
        colors[tile0] = primary;
        colors[tile1] = secondary;
    }
    i = 0;
    while (i < 8) : (i += 1) {
        var corner = state.c[i];
        var twist = state.c_o[i];
        var primary = cornercolors[corner].color[twist];
        var secondary = cornercolors[corner].color[(twist + 1) % 3];
        var tertiary = cornercolors[corner].color[(twist + 2) % 3];
        var tile0 = tileidx1[i*3];
        var tile1 = tileidx1[i*3 + 1];
        var tile2 = tileidx1[i*3 + 2];
        colors[tile0] = primary;
        colors[tile1] = secondary;
        colors[tile2] = tertiary;
    }

}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var p = try prune.prune.init(allocator);
    defer p.deinit();
    try p.gen_g0_prune_tables();
    try p.gen_g1_prune_tables();
    var state = cube.cube.init();
    //perform superflip to test performance of full solve
    state.up();
    state.right();
    state.right();
    state.front();
    state.front();
    state.front();
    state.right();
    state.down();
    state.down();
    state.down();
    state.left();
    state.back();
    state.back();
    state.back();
    state.right();
    state.up();
    state.up();
    state.up();
    state.right();
    state.up();
    state.up();
    state.up();
    state.down();
    state.front();
    state.front();
    state.front();
    state.up();
    state.front();
    state.front();
    state.front();
    state.up();
    state.up();
    state.up();
    state.down();
    state.down();
    state.down();
    state.back();
    state.left();
    state.left();
    state.left();
    state.front();
    state.front();
    state.front();
    state.back();
    state.back();
    state.back();
    state.down();
    state.down();
    state.down();
    state.left();
    state.left();
    state.left();

    //var sol = try solve_g0(allocator, 30, state, &p);
    var sol = try prune.solve_full(allocator, 60, state, &p);
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

    var cubecolors = [_]u8{0} ** 54;
    const screen_width: f32 = 800;
    const screen_height: f32 = 600;
    ray.InitWindow(screen_width, screen_height, "My Window Name");
    ray.SetTargetFPS(60);
    defer ray.CloseWindow();

    var j: u32 = 0;
    while (j < 54) : (j += 1) {
        cubecolors[j] = switch(j) {
            0...8 => 0,
            9...17 => 2,
            18...26 => 1,
            27...35 => 4,
            36...44 => 5,
            else => 3
        };
    }
    getCubeFaces(&cubecolors, state);
    

    while (!ray.WindowShouldClose()) {
    	ray.BeginDrawing();
            defer ray.EndDrawing();

    	ray.ClearBackground(ray.BLACK);
            
            drawRubiks(cubecolors[0..]);
            ray.DrawText("Hello World", 190, 190, 20, ray.RED);

            ray.DrawFPS(10,10);

	}
}

