# IRIS 3D: casing + 2 laci servo

Model 3D dari sketsa *Inventory Recognition & Information System*.
Satuan mm. Muka depan casing = sisi Y=0.

| File | Isi |
|---|---|
| `iris_viewer.html` | Viewer 3D interaktif (buka di browser, bisa offline): putar, zoom, buka laci 1/2, tembus pandang, urai |
| `iris.scad` | Sumber parametrik OpenSCAD (ubah ukuran di bagian atas file) |
| `stl/iris_*.stl` | Bagian siap cetak, sudah dalam orientasi cetak |
| `stl/iris_assembly.stl` | Rakitan lengkap (laci tertutup), hanya referensi |
| `build.py` | Membuat ulang semua STL + viewer: `THREE_DIR=<folder paket npm three@0.128.0> python3 3d/build.py` |

## Ukuran
- Total **200 × 100 × 110 mm**: modul elektronik 60 mm (badan 57 + tutup 3) di atas modul laci 50 mm.
- 2 laci, masing-masing ruang dalam sekitar 88 × 43 × 38 mm.
- Dinding 2,5 mm. Toleransi pas 0,4 mm.

## Tata letak tutup atas (sesuai sketsa)
LCD 16×2 (jendela 71×24) kiri atas, VENT (3 slot) kanan atas, tombol IN/OUT (lubang persegi 12,4 mm) kiri bawah,
LED R/G/B (Ø5,2 mm) tengah, BUZZER (Ø12 mm) bawah, lubang antena Ø9,4 mm di atas, 4 sekrup M3 di sudut.
Di bawah tutup ada 4 standoff LCD (tinggi 9 mm, lubang pilot untuk sekrup M3 pendek / self-tapping 2,5 mm).
Tampak depan dan samping polos (tanpa lubang USB, sesuai permintaan).

## Mekanisme laci (rack and pinion, tanpa pegas)
- Servo SG90 duduk di bantalan di lantai modul laci, as menghadap ke atas.
- Pinion (m=1,5, 13 gigi) dipasang di spline servo. Rack tercetak di belakang laci.
- Servo **0° = laci tertutup, 180° = laci keluar 30,6 mm**. Putaran berlawanan arah jarum jam dilihat dari atas.
  Jika servo Anda berputar terbalik, pasang pinion dan sesuaikan sudut di kode ESP32 (0 ↔ 180).
- Kabel servo naik lewat celah 14 × 10 mm di lantai badan elektronik.
- Pinion dan rack sudah diuji tanpa tabrakan di seluruh langkah 0–30,6 mm.

## Orientasi cetak dan perakitan
| Bagian | Jumlah | Catatan |
|---|---|---|
| `iris_body` | 1 | Posisi tegak |
| `iris_lid` | 1 | Sudah terbalik (permukaan atas di bed). Standoff LCD menghadap ke atas |
| `iris_module` | 1 | Posisi tegak. Terbuka di atas dan depan, tidak ada bridging |
| `iris_drawer1`, `iris_drawer2` | 1 + 1 | Posisi tegak, tanpa support |
| `iris_rack` | 2 | Cetak rebah. Tenon masuk mortise di dinding belakang laci, rekatkan |
| `iris_pinion` | 2 | Lubang Ø4,9 mm untuk spline SG90. Beri sedikit lem atau sekrup horn jika longgar |

Rekatkan **badan elektronik di atas modul laci** (lantai badan menjadi langit-langit bay). Tutup dipasang 4 sekrup M3.
Karena tidak ada lubang USB, tutup perlu dibuka untuk memprogram ESP32.

## Asumsi (cek kalau komponen Anda berbeda)
- LCD 16×2 standar: PCB 80×36, jarak lubang 75×31, bingkai 71,3×24,2, tinggi standoff 9 mm.
- Servo SG90 (badan 22,5 × 12,2, telinga 4,7 mm tiap ujung). MG90S memiliki dimensi sama.
- Baterai dan posisi ESP32/breadboard di dalam badan diatur sendiri (tidak ada dudukan).
- Sketsa tidak berskala; tampak atas dipakai sebagai acuan rasio (2:1).
