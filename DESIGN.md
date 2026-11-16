# DESIGN: NARA

> **NARA** · Power for the journey.

| Item | Nilai |
|---|---|
| Status | Draft v0.2 |
| Terkait | [PRD.md](PRD.md) |
| Tanggal | 2026-11-16 |

Keputusan TBD-D01…D09 sudah dijawab, lihat bagian 10.

---

## 1. Brand Personality

NARA bukan brand yang terasa seperti perusahaan energi yang kaku.

| Karakter | Artinya di produk |
|---|---|
| **Simple** | Mudah dipahami sejak pertama membuka aplikasi. Satu layar = satu tujuan utama. |
| **Helpful** | Membantu pengguna melanjutkan perjalanan. Selalu ada langkah berikutnya yang jelas. |
| **Modern** | Pakai teknologi tanpa terlihat rumit. Istilah teknis (OCPP, connector ID) disembunyikan. |
| **Calm** | Charging terasa jelas, tidak membingungkan. Tanpa animasi berlebihan atau warna alarm yang tidak perlu. |
| **Optimistic** | Identik dengan masa depan mobilitas yang lebih baik. Nada positif, bahkan saat error. |

## 2. Warna

### 2.1 Palet

| Token | Fungsi | Warna | Hex |
|---|---|---|---|
| `primary` | Primary | Deep Blue | `#2563EB` |
| `primaryDark` | Primary Dark | Navy | `#1E3A8A` |
| `accent` | Accent | Fresh Mint | `#2DD4BF` |
| `background` | Background | Soft White | `#F8FAFC` |
| `surface` | Surface | White | `#FFFFFF` |
| `textPrimary` | Primary Text | Slate | `#172033` |
| `textSecondary` | Secondary Text | Gray | `#64748B` |
| `success` | Success / Charging | Green | `#22C55E` |
| `error` | Error | Red | `#EF4444` |
| `warning` | Warning / In use | Amber | `#F59E0B` |
| `danger` | Fill tombol merah | Red 600 | `#DC2626` |
| `border` | Border / divider | Slate 200 | `#E2E8F0` |

### 2.2 Aturan pemakaian

- **Primary**: tombol utama, link, elemen aktif (tab terpilih, chip terpilih).
- **Primary Dark**: header penting, teks di atas latar `accent`, state pressed tombol primary.
- **Accent**: highlight kecil: ikon petir, progress ring, badge "baru". **Bukan untuk teks.**
- **Success**: status *Tersedia* dan *Charging*, progress energi. Dipakai sebagai fill/ikon, teks di atasnya pakai `textPrimary` atau putih tebal.
- **Error**: teks/border error & status *Faulted*. Hanya untuk masalah nyata, bukan dekorasi (sesuai karakter *Calm*).
- **Danger**: fill tombol merah (Stop charging). `#EF4444` + teks putih hanya 3.8:1, jadi fill pakai `#DC2626` (4.8:1).
- Satu layar maksimal **satu** tombol primary.

### 2.3 Kontras (WCAG AA)

| Kombinasi | Rasio ± | Boleh untuk |
|---|---|---|
| Putih di atas `primary` | 5.2 : 1 | Teks tombol |
| `textPrimary` di atas `background` | 15.6 : 1 | Semua teks |
| `textSecondary` di atas `surface` | 4.8 : 1 | Teks body |
| `error` di atas `surface` | 3.8 : 1 | Teks ≥ 18px / bold 14px saja |
| Putih di atas `danger` | 4.8 : 1 | Teks tombol |
| `textPrimary` di atas `warning` | 7.6 : 1 | Teks di atas amber |
| `success` di atas `surface` | 2.3 : 1 | Ikon/fill saja, **bukan teks** |
| `accent` di atas `surface` | 1.9 : 1 | Dekorasi saja, **bukan teks** |

### 2.4 Status connector

| Status | Warna | Catatan |
|---|---|---|
| Available | `success` | |
| In use | `warning` | |
| Faulted | `error` | |
| Offline | `textSecondary` | |

Status tidak boleh hanya dibedakan lewat warna, selalu sertakan label teks/ikon.

### 2.5 Dark mode

Mengikuti setting sistem (`ThemeMode.system`).

| Token | Light | Dark | Catatan |
|---|---|---|---|
| `primary` | `#2563EB` | `#60A5FA` | Biru lebih terang agar kontras di latar gelap (7.4:1) |
| `onPrimary` | `#FFFFFF` | `#0B1220` | Teks tombol primary |
| `primaryDark` | `#1E3A8A` | `#1E3A8A` | Banner sesi aktif, teks putih |
| `accent` | `#2DD4BF` | `#2DD4BF` | |
| `background` | `#F8FAFC` | `#0B1220` | |
| `surface` | `#FFFFFF` | `#111A2E` | |
| `textPrimary` | `#172033` | `#E2E8F0` | 15.2:1 di latar gelap |
| `textSecondary` | `#64748B` | `#94A3B8` | 6.8:1 di surface gelap |
| `border` | `#E2E8F0` | `#23304A` | |
| `success` | `#22C55E` | `#22C55E` | |
| `warning` | `#F59E0B` | `#F59E0B` | |
| `error` | `#EF4444` | `#F87171` | 6.3:1 di surface gelap |
| `danger` | `#DC2626` | `#DC2626` | |

## 3. Tipografi

Font: **Plus Jakarta Sans** (Google Fonts, OFL). Dibundel sebagai asset (bukan download runtime) agar tampil benar saat offline.

| Peran | Weight | Pemakaian |
|---|---|---|
| Heading | SemiBold (600) | Judul layar, judul section, nama SPKLU |
| Body | Regular (400) | Teks umum, alamat, deskripsi |
| Button | Medium (500) | Label tombol, tab, chip |
| Number / kWh | Bold (700) | kWh, Rupiah, durasi, saldo |

### 3.1 Skala (usulan)

| Style | Size / Line height | Weight | Contoh |
|---|---|---|---|
| Display | 40 / 48 | Bold | Angka kWh di layar charging |
| Headline | 24 / 32 | SemiBold | Judul layar |
| Title | 18 / 26 | SemiBold | Nama SPKLU, judul card |
| Body | 16 / 24 | Regular | Teks umum |
| Body Small | 14 / 20 | Regular | Alamat, keterangan |
| Label | 14 / 20 | Medium | Tombol, chip |
| Caption | 12 / 16 | Regular | ID transaksi, timestamp |

Angka memakai **tabular figures** (`FontFeature.tabularFigures()`) agar kWh/durasi tidak "goyang" saat update real-time.

## 4. Gaya UI

### 4.1 Clean & banyak ruang kosong
- Skala spacing kelipatan 4: `4 · 8 · 12 · 16 · 24 · 32 · 48`.
- Margin layar: 16 (default), 24 untuk layar fokus (login, charging).
- Hindari divider berlebihan; pisahkan dengan spacing dan card.

### 4.2 Rounded, tapi tidak berlebihan
Tujuannya ramah tanpa terlalu playful.

| Elemen | Radius |
|---|---|
| Button | 12–16 (default **14**) |
| Card | 16–20 (default **18**) |
| Input | **12** |
| Chip / badge | penuh (pill) |
| Bottom sheet | 20 (sudut atas) |

- Elevation rendah: card pakai `surface` di atas `background` + border tipis `#E2E8F0` atau shadow sangat halus. Tanpa shadow tebal.
- Tinggi tombol minimum 48, area sentuh minimum 48×48.

### 4.3 Charging sebagai fokus visual
Saat pengguna sedang charging, halaman harus sangat sederhana. Informasi utama langsung terlihat tanpa perlu mencari-cari.

Hierarki layar **Sesi Charging**:
1. **Status** dalam kalimat natural: "You're charging."
2. **Angka utama besar**: kWh (Display, Bold), dengan indikator progress/animasi halus berwarna `success`/`accent`.
3. **Info sekunder**: durasi & estimasi biaya (Title, Bold).
4. **Satu aksi**: tombol *Stop charging* merah penuh (`danger`) di bawah.
5. Detail teknis (charger, connector, ID transaksi) di bawah atau dilipat.

Tidak ada: banner promosi, navigasi lain yang bersaing, atau angka teknis yang tidak dibutuhkan user.

## 5. Tone of Voice

Bahasa sederhana dan natural. Bicara seperti teman yang membantu, bukan sistem.

| Hindari | Gunakan |
|---|---|
| "Charging session initialization has been successfully completed." | "Charging started." |
| "Inisialisasi sesi pengisian telah berhasil dilakukan." | "Pengisian daya sudah dimulai." |

Prinsip:
- Bahasa UI: **English**. Bila nanti ada Bahasa Indonesia, sapa pengguna dengan **"kamu"**.
- Kalimat pendek, kata kerja aktif, sapa langsung ("you").
- Error: jelaskan apa yang terjadi + apa yang bisa dilakukan. Jangan menyalahkan user, jangan tampilkan kode error mentah.
- **Tanpa emoticon/emoji** di teks UI (tombol, judul, pesan, notifikasi). Nada positif dibangun lewat kata, bukan simbol. Butuh simbol visual? Pakai Material Icons.
- **Tanpa em-dash (U+2014)**. Pecah jadi dua kalimat, atau pakai titik, koma, titik dua, atau `·` sebagai pemisah info.
- Hindari jargon: "connector" → boleh; "OCPP", "RemoteStartTransaction" → tidak pernah tampil.

### 5.1 Microcopy

| Situasi | EN (dipakai) | ID (untuk nanti) |
|---|---|---|
| Charger tersedia | Ready when you are. | Siap kapan pun kamu siap. |
| Charging dimulai | You're charging. | Pengisian daya sudah dimulai. |
| Charging berjalan | Charging in progress. | Sedang mengisi daya. |
| Charging selesai | You're ready to go. | Siap melanjutkan perjalanan. |
| Tidak ada charger | No available chargers nearby. | Belum ada charger tersedia di dekatmu. |
| Error umum | Something went wrong. Let's try again. | Ada yang tidak beres. Yuk, coba lagi. |
| Charger offline | This charger is offline right now. | Charger ini sedang offline. |
| Saldo kurang | Top up to start charging. | Isi saldo dulu untuk mulai mengisi daya. |
| Pembayaran berhasil | Payment complete. | Pembayaran berhasil. |

Bahasa aplikasi: English (TBD-D03). Kolom ID disimpan untuk lokalisasi nanti.

## 6. Komponen Inti

| Komponen | Spesifikasi |
|---|---|
| **Primary Button** | Fill `primary`, teks putih Medium 16, radius 14, tinggi 52, full-width di layar fokus |
| **Secondary Button** | Outline 1px `primary`, teks `primary` |
| **Danger Button** (Stop) | Fill `danger` `#DC2626`, teks putih Medium 16, radius 14, tinggi 52 |
| **Input** | Fill `surface`, border `#E2E8F0`, focus border `primary` 2px, radius 12, label di atas |
| **Card** | `surface`, radius 18, padding 16, border/shadow halus |
| **Status Chip** | Pill, dot warna status + label teks |
| **Metric** | Label Caption `textSecondary` + angka Bold `textPrimary` |
| **Bottom Nav** | 4 tab (SPKLU · Scan · Riwayat · Akun), aktif = `primary` |
| **Active Session Banner** | Di atas bottom nav, latar `primaryDark`, teks putih, ikon petir `accent` |
| **Snackbar** | Latar `textPrimary`, teks `background` (terbalik di dark mode), pesan sesuai tone of voice |
| **Empty State** | Ikon Material dalam lingkaran tint `primary` 12% + pesan `textSecondary` |

## 7. Ikon & Ilustrasi

- Ikon: **Material Icons** bawaan Flutter (`Icons.*`), ukuran 24 default. Varian `_rounded` boleh dipakai bila tersedia.
- Ilustrasi: belum ada, empty state & sukses pakai ikon Material dalam lingkaran (komponen *Empty State*).
- Logo & app icon: belum ada. Sementara pakai ikon `bolt_rounded` warna `accent` + wordmark "NARA" teks.

## 8. Motion

Semua komponen motion ada di `lib/core/motion.dart`. Semua otomatis statis bila setting "reduce motion" device aktif.

| Pola | Komponen | Durasi | Dipakai di |
|---|---|---|---|
| Skeleton loading | `Shimmer` + `SkeletonBox` / `SkeletonCard` / `SkeletonList` | pulse 900 ms | Setiap layar yang mengambil data: peta & list SPKLU, History, aktivitas Wallet |
| Skeleton ke konten | `FadeSwitcher` (fade + geser 2%) | 250 ms | Pergantian loading/data, tab bottom nav, Map/List, kartu SPKLU di peta, judul & tombol layar charging |
| Item list muncul | `FadeSlideIn` (fade + geser naik, jeda 50 ms per item, maks 6) | 350 ms | List SPKLU, History, aktivitas Wallet |
| Angka berubah | `AnimatedNumber` (hitung halus ke nilai baru) | 600 ms | kWh, durasi, biaya di layar charging dan banner; saldo Wallet |
| Pilihan | `SelectableCard` (border & tint), ikon radio scale | 150 sampai 200 ms | Metode bayar, prepaid/postpaid |
| Banner sesi aktif | `AnimatedSize` | 250 ms | Muncul/hilang di atas bottom nav |
| Splash | Fade + scale 92% ke 100% | 500 ms | Splash |
| Transisi halaman | Bawaan platform (Android predictive back, iOS native) | bawaan | Semua navigasi |

Aturan:
- Skeleton meniru bentuk konten aslinya (card, baris teks, chip), bukan spinner. Spinner hanya untuk aksi singkat (dialog `guard`).
- Skeleton memakai pulse lembut, bukan sweep, sesuai karakter *Calm*.
- Easing standar `easeOutCubic`. Tidak ada animasi yang menahan aksi pengguna.

## 9. Implementasi Flutter

Sumber kebenaran token: `lib/core/theme.dart`: `NaraPalette.light/dark` (ThemeExtension), akses via `context.nara`; `buildNaraTheme(Brightness)` dipasang ke `theme` & `darkTheme`. Komponen bersama: `lib/core/widgets.dart` (`StatusChip`, `EmptyState`, `InfoRow`, `SectionTitle`, `SelectableCard`, `BottomAction`) dan `lib/core/motion.dart`.

| Token | `ColorScheme` / `ThemeData` |
|---|---|
| `primary` | `primary` |
| `primaryDark` | `primaryContainer` (teks: `onPrimaryContainer` = putih) |
| `accent` | `secondary` / `tertiary` |
| `background` | `scaffoldBackgroundColor` / `surfaceContainerLowest` |
| `surface` | `surface` |
| `textPrimary` | `onSurface` |
| `textSecondary` | `onSurfaceVariant` |
| `error` | `error` |
| `success`, `warning`, `danger`, `border` | `context.nara.*` (tidak ada slot di `ColorScheme`) |

- Radius lewat `filledButtonTheme`, `outlinedButtonTheme`, `cardTheme`, `inputDecorationTheme`, `bottomSheetTheme`.
- Font: `fontFamily: 'PlusJakartaSans'` di `ThemeData`, file `.ttf` di `assets/fonts/` dan didaftarkan di `pubspec.yaml`.
- Layar memakai `Theme.of(context)` / `context.nara`, tidak ada hex hardcode di widget.
- Angka pakai `copyWith(fontFeatures: tabularFigures)`.

## 10. Keputusan

| ID | Keputusan |
|---|---|
| TBD-D01 | Warna *In use* / warning: Amber `#F59E0B` |
| TBD-D02 | Sapaan "kamu" (untuk versi Bahasa Indonesia nanti) |
| TBD-D03 | Bahasa UI: English |
| TBD-D04 | Tombol Stop: merah penuh (`danger` `#DC2626`) |
| TBD-D05 | Ikon: Material Icons |
| TBD-D06 | Ilustrasi: sederhana dulu (ikon dalam lingkaran) |
| TBD-D07 | Logo & app icon: belum ada, placeholder ikon petir + wordmark |
| TBD-D08 | Dark mode: masuk MVP, ikut setting sistem |
| TBD-D09 | Figma: belum ada, DESIGN.md + kode jadi acuan |
