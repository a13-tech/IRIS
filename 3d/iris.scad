// =====================================================================
// IRIS - Inventory Recognition & Information System
// Casing parametrik: modul elektronik (atas) + modul 2 laci (bawah)
// Satuan: mm.  Sumbu: X = kanan, Y = belakang (muka depan casing di Y=0), Z = atas.
//
// Pilih bagian dengan:  openscad -D 'part="lid"' -o lid.stl iris.scad
//   part = body | lid | module | drawer1 | drawer2 | rack | pinion | assembly
//   print = true  -> orientasi untuk cetak 3D (lihat build.py)
//   open1/open2   -> (tidak dipakai lagi; bukaan laci disimulasikan di iris_viewer.html)
// =====================================================================

part  = "assembly";
print = false;
open1 = 0;
open2 = 0;

$fn = 48;

// ---------- dimensi utama ----------
W = 200;  D = 100;          // lebar x dalam (kotak)
HD = 50;                    // tinggi modul laci
HE = 60;                    // tinggi modul elektronik (badan + tutup)
WALL = 2.5;                 // tebal dinding
LIDT = 3;                   // tebal tutup atas
CLR  = 0.4;                 // toleransi pas

POST = [[6,6],[W-6,6],[6,D-6],[W-6,D-6]];   // tiang sekrup tutup (M3)

// ---------- bay laci ----------
BAY_W = (W - 3*WALL)/2;                     // 96.25
BAYC  = [WALL + BAY_W/2, W - WALL - BAY_W/2]; // pusat x tiap bay

// ---------- tutup atas: posisi komponen ----------
LCD_C   = [52, 76];         // pusat jendela LCD
LCD_WIN = [71, 24];         // jendela LCD 16x2
LCD_HOLE= [75, 31];         // jarak lubang sekrup modul LCD 16x2
LCD_SO  = 9;                // tinggi standoff LCD (dari sisi bawah tutup)
BTN     = 12.4;             // lubang tombol persegi 12 mm + toleransi
BTN_POS = [[22,30],[42,30]];  // IN, OUT
LED_D   = 5.2;
LED_POS = [[98,38],[110,38],[122,38]];  // R, G, B
BUZ_D   = 12;  BUZ_POS = [110,20];
ANT_D   = 9.4; ANT_POS = [125,88];       // lubang antena di tutup atas
VENT_X  = [167.5,175,182.5]; VENT_Y = 83; VENT_L = 22; VENT_W = 2.5;

// ---------- servo SG90 + rack & pinion ----------
M  = 1.5;  GZ = 13;                  // modul gigi & jumlah gigi pinion
PR = M*GZ/2;                         // jari-jari pitch = 9.75
GP = PI*M;                           // pitch gigi = 4.712
TRAVEL = PI*PR;                      // jarak buka laci pada servo 180 derajat = 30.6
SRV_X = 3 + PR;                      // as servo relatif pusat bay (x)
SRV_Y = 62;                          // as servo (y)
SRV_BODY = [12.2, 22.5];             // badan servo: lebar x, panjang y
SRV_SHAFT_FROM_END = 6;              // as servo dari ujung depan badan
SRV_EAR = 4.7;                       // telinga di tiap ujung
BLOCK_TOP = 19;                      // tinggi bantalan servo dari dasar Z=0
BODY_BELOW_EAR = 13.4;
BODY_TOP = BLOCK_TOP - BODY_BELOW_EAR + 22.7;  // = 28.3, puncak badan servo
PIN_T = 6;                           // tebal pinion
RACK_Y0 = 51.7;                      // pusat gigi rack pertama
RACK_END = 96.5;
HP = 0.95;                           // setengah lebar gigi di garis pitch (celah/backlash ~0.4 mm per sisi)
HR_ROOT = HP + 1.25*M*tan(20);       // setengah lebar di akar
HR_TIP  = HP - M*tan(20);            // setengah lebar di ujung
PHASE = 180 + asin((SRV_Y - (RACK_Y0 + GP*2.5))/PR);   // fase pinion saat laci tertutup

// ---------- laci ----------
DR_PANEL = [95.5, 3, 46.4];          // panel depan x,y,tinggi (z 3..49.4)
DR_W = 92;
DR_Z0 = 3;  DR_H = 40;
DR_BACK = 4;                         // dinding belakang laci (tempat rack)

// =====================================================================
module rbox(p, s) { translate(p) cube(s); }

// ---------------- modul elektronik ----------------
module e_body() {
  h = HE - LIDT;
  difference() {
    union() {
      difference() {
        cube([W, D, h]);
        translate([WALL, WALL, WALL]) cube([W-2*WALL, D-2*WALL, h]);
      }
      for (p = POST) translate([p[0], p[1], WALL]) cylinder(d=6.5, h=h-WALL);
    }
    for (p = POST) translate([p[0], p[1], h-12]) cylinder(d=2.6, h=13);
    // celah kabel servo -> ke modul laci
    for (c = BAYC) translate([c + SRV_X - 7, 80, -1]) cube([14, 10, WALL+2]);
  }
}

module lid_asm() {          // sisi atas tutup di z = LIDT, standoff ke bawah
  lipH = 2;  t = 1.6;  o = WALL + CLR;
  difference() {
    union() {
      cube([W, D, LIDT]);
      // bibir pengunci ke dalam badan
      translate([0,0,-lipH]) difference() {
        translate([o,o,0]) cube([W-2*o, D-2*o, lipH+0.01]);
        translate([o+t,o+t,-1]) cube([W-2*(o+t), D-2*(o+t), lipH+2]);
        for (p = POST) translate([p[0],p[1],-1]) cylinder(d=9, h=lipH+2);
      }
      // standoff LCD
      for (dx=[-1,1], dy=[-1,1])
        translate([LCD_C[0]+dx*LCD_HOLE[0]/2, LCD_C[1]+dy*LCD_HOLE[1]/2, -LCD_SO])
          cylinder(d=6, h=LCD_SO+0.01);
    }
    // jendela LCD
    translate([LCD_C[0]-LCD_WIN[0]/2, LCD_C[1]-LCD_WIN[1]/2, -1]) cube([LCD_WIN[0], LCD_WIN[1], LIDT+2]);
    // pilot standoff
    for (dx=[-1,1], dy=[-1,1])
      translate([LCD_C[0]+dx*LCD_HOLE[0]/2, LCD_C[1]+dy*LCD_HOLE[1]/2, -LCD_SO-1])
        cylinder(d=2.4, h=8);
    // tombol IN / OUT
    for (b = BTN_POS) translate([b[0]-BTN/2, b[1]-BTN/2, -1]) cube([BTN, BTN, LIDT+2]);
    // LED RGB
    for (l = LED_POS) translate([l[0], l[1], -1]) cylinder(d=LED_D, h=LIDT+2);
    // buzzer
    translate([BUZ_POS[0], BUZ_POS[1], -1]) cylinder(d=BUZ_D, h=LIDT+2);
    // antena
    translate([ANT_POS[0], ANT_POS[1], -1]) cylinder(d=ANT_D, h=LIDT+2);
    // ventilasi
    for (x = VENT_X) translate([x-VENT_W/2, VENT_Y-VENT_L/2, -1]) cube([VENT_W, VENT_L, LIDT+2]);
    // sekrup tutup (countersink)
    for (p = POST) translate([p[0], p[1], -1]) {
      cylinder(d=3.4, h=LIDT+2);
      translate([0,0,LIDT+1-1.8]) cylinder(d1=3.4, d2=6.4, h=1.81);
    }
    // label (ukiran 0.5 mm)
    lbl("IN",  22, 40); lbl("OUT", 42, 40);
    lbl("R", 98, 46);  lbl("G", 110, 46); lbl("B", 122, 46);
    lbl("BUZZER", 110, 9);
    lbl("VENT", 175, 68);
    lbl("ANT", 125, 78);
    lbl("LCD", LCD_C[0], LCD_C[1]-LCD_WIN[1]/2-5);
    lbl("IRIS", 165, 45, 9);
  }
}
module lbl(s, x, y, sz=3.5) {
  translate([x, y, LIDT-0.5]) linear_extrude(1)
    text(s, size=sz, halign="center", valign="center", font="DejaVu Sans:style=Bold");
}

// ---------------- modul laci (bay terbuka di atas & depan) ----------------
module cradle() {   // bantalan servo SG90 (koordinat lokal bay, origin x = pusat bay)
  by0 = SRV_Y - SRV_SHAFT_FROM_END;               // ujung depan badan
  difference() {
    translate([SRV_X-9, 51, WALL-0.01]) cube([18, 33, BLOCK_TOP-WALL+0.01]);
    // kantong badan servo (tembus ke atas)
    translate([SRV_X-SRV_BODY[0]/2-0.2, by0-0.3, BLOCK_TOP-14]) cube([SRV_BODY[0]+0.4, SRV_BODY[1]+0.6, 20]);
    // lubang pilot sekrup telinga
    for (y = [by0-2.4, by0+SRV_BODY[1]+2.4]) translate([SRV_X, y, BLOCK_TOP-6]) cylinder(d=1.6, h=7);
  }
}
module d_module() {
  difference() {
    cube([W, D, HD]);
    for (c = BAYC) translate([c-BAY_W/2, -1, WALL]) cube([BAY_W, D-WALL+1, HD]);
  }
  for (c = BAYC) translate([c, 0, 0]) cradle();
}

// ---------------- laci (origin lokal: x = pusat bay, y = muka depan, z = lantai) ----------------
module drawer(label) {
  difference() {
    union() {
      // panel depan
      translate([-DR_PANEL[0]/2, 0, DR_Z0]) cube(DR_PANEL);
      // badan laci
      translate([-DR_W/2, 3, DR_Z0]) cube([DR_W, 47, DR_H]);
    }
    // rongga
    translate([-DR_W/2+2, 3, DR_Z0+2]) cube([DR_W-4, 43, DR_H]);
    // takik jari
    translate([0, -1, DR_Z0+DR_PANEL[2]]) rotate([-90,0,0]) cylinder(d=22, h=5);
    // mortise rack
    translate([-5.15, 45, 22.9]) cube([6.4, 6, 11.5]);
    // label depan
    translate([0, 0.5, 22]) rotate([90,0,0]) linear_extrude(1)
      text(label, size=7, halign="center", valign="center", font="DejaVu Sans:style=Bold");
  }
}

module rack() {          // origin sama dengan laci
  difference() {
    union() {
      translate([-5, 46, 23]) cube([6.125, RACK_END-46, 11.3]);
      for (i = [0:9]) translate([0, RACK_Y0 + GP*i, BODY_TOP]) rotate([0,0,0])
        translate([0,0,0]) linear_extrude(PIN_T)
          polygon([[1.125,-HR_ROOT],[4.5,-HR_TIP],[4.5,HR_TIP],[1.125,HR_ROOT]]);
    }
  }
}

module pinion() {       // origin = as servo, z=0 dasar (menumpu di puncak badan servo)
  r_root = PR - 1.25*M;  r_tip = PR + M;
  difference() {
    linear_extrude(PIN_T) union() {
      circle(r=r_root);
      for (k=[0:GZ-1]) rotate(PHASE + k*360/GZ)
        polygon([[r_root-0.3,-HR_ROOT],[r_tip,-HR_TIP],[r_tip,HR_TIP],[r_root-0.3,HR_ROOT]]);
    }
    translate([0,0,-1]) cylinder(d=4.9, h=PIN_T+2);        // lubang spline servo
    translate([0,0,-0.01]) cylinder(d=12.4, h=2);           // cekungan boss servo
  }
}

// ---------------- referensi (bukan untuk dicetak) ----------------
module servo_ref() {    // koordinat lokal bay
  by0 = SRV_Y - SRV_SHAFT_FROM_END;
  translate([SRV_X-SRV_BODY[0]/2, by0, BLOCK_TOP-BODY_BELOW_EAR]) cube([SRV_BODY[0], SRV_BODY[1], 22.7]);
  translate([SRV_X-SRV_BODY[0]/2, by0-SRV_EAR, BLOCK_TOP]) cube([SRV_BODY[0], SRV_BODY[1]+2*SRV_EAR, 2.5]);
  translate([SRV_X, SRV_Y, BODY_TOP]) cylinder(d=11.5, h=1.5);
  translate([SRV_X, SRV_Y, BODY_TOP]) cylinder(d=4.8, h=4);
}
module lcd_ref() {      // koordinat absolut tutup
  translate([LCD_C[0]-40, LCD_C[1]-18, -LCD_SO-1.6]) cube([80,36,1.6]);
  translate([LCD_C[0]-35.65, LCD_C[1]-12.1, -LCD_SO]) cube([71.3, 24.2, LCD_SO-0.01]);
}

// ---------------- keluaran ----------------
if (part == "body")    { translate(print ? [0,0,0] : [0,0,HD]) e_body(); }
else if (part == "lid") {
  if (print) translate([0, D, LIDT]) rotate([180,0,0]) lid_asm();
  else translate([0,0,HD+HE-LIDT]) lid_asm();
}
else if (part == "module")  { d_module(); }
else if (part == "drawer1") { translate(print ? [0,0,-DR_Z0] : [0,0,0]) drawer("LACI 1"); }
else if (part == "drawer2") { translate(print ? [0,0,-DR_Z0] : [0,0,0]) drawer("LACI 2"); }
else if (part == "rack")    { if (print) rotate([0,-90,0]) rack(); else rack(); }
else if (part == "pinion")  { pinion(); }
else if (part == "servo")   { servo_ref(); }
else if (part == "lcd")     { translate([0,0,HD+HE-LIDT]) lcd_ref(); }
else if (part == "assembly") {
  d_module();
  translate([0,0,HD]) e_body();
  translate([0,0,HD+HE-LIDT]) lid_asm();
  for (i=[0:1]) {
    op = (i==0) ? open1 : open2;
    translate([BAYC[i], -op, 0]) { drawer(i==0 ? "LACI 1" : "LACI 2"); rack(); }
    translate([BAYC[i],0,0]) servo_ref();
    translate([BAYC[i], 0, 0]) place_pinion_local(op);
  }
}
module place_pinion_local(op) {
  translate([SRV_X, SRV_Y, BODY_TOP]) rotate([0,0, op/PR*180/PI]) pinion();
}
