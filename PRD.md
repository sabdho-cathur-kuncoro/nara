# PRD: EV Charging Mobile App (MVP)

| Item | Nilai |
|---|---|
| Produk | NARA: Mobile App EV Charging (SPKLU) |
| Platform | Android & iOS (Flutter) |
| Status | Draft v0.2 |
| Sumber | `Workflow MVP EV Charging.pdf` |
| Tanggal | 2026-11-16 |

> Item bertanda **[TBD-xx]** belum dijelaskan di dokumen sumber. Lihat bagian 11 (Pertanyaan Terbuka).

---

## 1. Latar Belakang & Tujuan

User kendaraan listrik butuh cara mudah menemukan SPKLU, memulai/menghentikan charging, membayar, dan melihat riwayat, semua dari ponsel.

**Tujuan MVP mobile app:**
1. User dapat menemukan SPKLU dan melihat ketersediaan charger secara real-time.
2. User dapat memulai charging lewat scan QR tanpa bantuan operator.
3. User dapat memantau sesi charging (status, durasi, kWh, estimasi biaya) secara real-time.
4. User dapat menghentikan charging, membayar, dan melihat riwayat transaksi.

**Metrik sukses:** [TBD-01]

## 2. Ruang Lingkup

### 2.1 In-scope (Mobile App)
- Login
- Peta & daftar SPKLU (lokasi, charger, connector, status)
- Scan QR charger/connector
- Start charging
- Monitoring charging real-time
- Stop charging
- Pembayaran
- Riwayat transaksi

### 2.2 Out-of-scope (dokumen ini)
- CSMS / OCPP server (hanya dikonsumsi lewat Business Backend)
- Admin Dashboard (lokasi, charger, tarif, laporan, bagi hasil)
- OCPI / roaming (termasuk PLN Mobile)
- Load management
- Membership

## 3. Persona

| Persona | Deskripsi |
|---|---|
| Pengemudi EV | Pemilik/pengguna mobil atau motor listrik yang butuh charging di SPKLU publik. [TBD-02: mobil saja atau juga motor?] |

## 4. Arsitektur (konteks mobile)

```
Mobile App
   ↓ REST API + Real-time Event
Business Backend
   ↓ Command / Event
CSMS / OCPP Server
   ↓ OCPP 1.6J (WebSocket)
EV Charging Station → EV
```

Mobile app **hanya** berkomunikasi dengan Business Backend. Tidak ada koneksi langsung ke CSMS/charger.

### 4.1 Strategi Dummy Data (fase awal)
Kontrak API, desain Figma, payment gateway, dan provider peta belum diputuskan. Development dimulai dengan:
- Layer repository dengan implementasi **mock** (JSON lokal / data in-memory) yang bisa diganti implementasi API asli tanpa ubah UI.
- Mock WebSocket: stream simulasi status sesi (Starting → Charging dengan kWh/durasi/biaya naik → Completed).
- Mock pembayaran: simulasi sukses/gagal/pending untuk postpaid & prepaid.
- Mock data SPKLU: beberapa lokasi dengan variasi status connector (Available, Charging, Faulted, Offline).
- Mock QR: daftar ID charger valid/invalid/offline untuk uji skenario.
- Flag environment `mock` / `dev` / `prod` untuk switch sumber data.

- Protokol real-time: **WebSocket** (status charger & sesi charging). Auto-reconnect saat koneksi putus.
- Kontrak API: belum ada → fase awal pakai **dummy data** (lihat 4.1).

## 5. User Flow End-to-End

```
Login → Cari SPKLU → Scan QR → Validasi charger → Start Charging
→ Monitoring real-time → Stop Charging → Hitung tarif → Pembayaran → Riwayat
```

## 6. Kebutuhan Fungsional

### F1. Login
| ID | Kebutuhan |
|---|---|
| F1.1 | User login; backend memvalidasi akun dan mengembalikan token sesi. |
| F1.2 | Token disimpan aman (Keychain/Keystore) dan dipakai di setiap request. |
| F1.3 | Sesi tetap aktif saat app dibuka ulang sampai token kedaluwarsa/logout. |
| F1.4 | Metode login: **Email + password**, **Google Sign-In**, **Sign in with Apple** (wajib di iOS bila ada social login). |
| F1.5 | Registrasi email + password, lupa password (reset via email), logout. |
| F1.6 | Verifikasi email saat registrasi: [TBD-06] |
| F1.7 | Edit profil & hapus akun (hapus akun wajib App Store bila ada registrasi): [TBD-06] |

**Acceptance:** login valid → masuk Home; login gagal → pesan error jelas; token kedaluwarsa → kembali ke login [TBD-07: refresh token?].

### F2. Peta & Daftar SPKLU
| ID | Kebutuhan |
|---|---|
| F2.1 | App meminta daftar lokasi SPKLU + status charger ke backend. |
| F2.2 | Tampilkan peta dengan marker SPKLU. |
| F2.3 | Detail SPKLU: nama, alamat, daftar charger, connector (tipe, daya), status ketersediaan. |
| F2.4 | Status connector minimal: Available, Charging/Occupied, Unavailable/Faulted, Offline (dipetakan dari status OCPP 1.6J oleh backend). |
| F2.5 | Tampilkan tarif per connector/lokasi. [TBD-08: apakah tarif tampil sebelum charging?] |
| F2.6 | Navigasi ke lokasi (buka Google Maps / Apple Maps). [TBD-09] |
| F2.7 | Pencarian, filter (tipe connector, daya, status), daftar terdekat. [TBD-10] |

**Acceptance:** marker tampil sesuai lokasi; status diperbarui tanpa restart app [TBD-11: interval/real-time?].

### F3. Scan QR
| ID | Kebutuhan |
|---|---|
| F3.1 | User membuka kamera untuk scan QR di charger. |
| F3.2 | QR mengidentifikasi charger atau connector; app mengirim ID ke backend. |
| F3.3 | Backend memvalidasi charger dan mengembalikan status terkini. |
| F3.4 | Tersedia → tampilkan konfirmasi (charger, connector, tarif) + tombol Start. |
| F3.5 | Tidak tersedia/offline → tampilkan pesan sesuai alasan. |
| F3.6 | Minta izin kamera; tangani izin ditolak. |
| F3.7 | Format isi QR: [TBD-12: URL / deep link / string ID? per charger atau per connector?] |
| F3.8 | Fallback input manual ID charger jika QR rusak: [TBD-13] |
| F3.9 | Mulai charging dari detail SPKLU di peta (tanpa scan): [TBD-14] |

### F4. Start Charging
| ID | Kebutuhan |
|---|---|
| F4.1 | User menekan Start Charging; app kirim request start (charger + connector). |
| F4.2 | Backend memvalidasi user, charger, connector, aturan transaksi. |
| F4.3 | App menampilkan state "Memulai…" sampai backend konfirmasi status charging. |
| F4.4 | Gagal (charger menolak, timeout, kabel belum terpasang) → pesan error + opsi coba lagi. |
| F4.5 | Satu user hanya boleh satu sesi aktif. [TBD-15] |
| F4.6 | Timeout menunggu respons charger: [TBD-16] |
| F4.7 | Prasyarat sebelum start: mode **prepaid** → saldo wallet ≥ saldo minimum [TBD-17]; mode **postpaid** → tidak ada tagihan tertunggak [TBD-24]. |
| F4.8 | Opsi batas charging (kWh / nominal Rp / durasi / sampai penuh): [TBD-18] |

### F5. Monitoring Charging
| ID | Kebutuhan |
|---|---|
| F5.1 | App menerima update real-time dari backend. |
| F5.2 | Tampilkan: status, durasi, energi (kWh), estimasi biaya. |
| F5.3 | Sesi aktif tetap bisa dibuka setelah app ditutup/dibuka ulang (resume dari backend). |
| F5.4 | Push notification (charging dimulai, selesai/penuh, berhenti karena error): [TBD-19] |
| F5.5 | Data tambahan (daya kW, SoC %): [TBD-20, tergantung dukungan charger] |
| F5.6 | Koneksi internet putus → tampilkan data terakhir + indikator offline, sinkron ulang saat online. |

### F6. Stop Charging
| ID | Kebutuhan |
|---|---|
| F6.1 | User menekan Stop Charging (dengan konfirmasi). |
| F6.2 | App menampilkan "Menghentikan…" sampai backend konfirmasi sesi ditutup. |
| F6.3 | Backend menghitung total energi & tarif; app menampilkan ringkasan. |
| F6.4 | Charging berhenti dari sisi charger (kabel dicabut / tombol fisik / penuh) → app tetap menerima status selesai dan ringkasan. |
| F6.5 | Gagal stop (timeout) → pesan + opsi coba lagi / hubungi CS. [TBD-21] |

### F7. Pembayaran
| ID | Kebutuhan |
|---|---|
| F7.1 | Setelah sesi selesai, user melanjutkan/menyelesaikan pembayaran sesuai metode yang diterapkan. |
| F7.2 | Dua model bayar: **Prepaid** (top-up saldo wallet, dipotong otomatis saat sesi selesai) dan **Postpaid** (bayar via payment gateway setelah sesi selesai). |
| F7.2a | Pemilihan model: [TBD-22: dipilih user per sesi, per akun, atau ditentukan per lokasi/charger?] |
| F7.2b | Prepaid: layar saldo, top-up, riwayat mutasi saldo. Nominal top-up & saldo minimum: [TBD-17] |
| F7.2c | Prepaid: saldo habis saat charging → backend stop otomatis? [TBD-38] |
| F7.2d | Refund / sisa saldo wallet: [TBD-39] |
| F7.3 | Payment gateway & metode (VA, QRIS, e-wallet, kartu): [TBD-23] |
| F7.4 | Status pembayaran: pending, berhasil, gagal, kedaluwarsa. |
| F7.5 | Penanganan user tidak membayar / app ditutup sebelum bayar: [TBD-24] |
| F7.6 | Struk/invoice (tampil di app / kirim email / PDF): [TBD-25] |
| F7.7 | Komponen biaya (tarif/kWh, biaya admin, PPN, idle fee): [TBD-26] |

### F8. Riwayat Transaksi
| ID | Kebutuhan |
|---|---|
| F8.1 | Menu Riwayat menampilkan sesi charging yang telah selesai. |
| F8.2 | Per item: lokasi, waktu, durasi, energi (kWh), total transaksi. |
| F8.3 | Detail transaksi + status pembayaran. |
| F8.4 | Pagination / infinite scroll. |
| F8.5 | Filter tanggal / status: [TBD-27] |

## 7. Daftar Layar (usulan)

| # | Layar | Fitur |
|---|---|---|
| 1 | Splash | Cek token |
| 2 | Login (email, Google, Apple) | F1 |
| 2a | Register | F1 |
| 2b | Lupa Password | F1 |
| 3 | Home / Peta SPKLU | F2 |
| 4 | Detail SPKLU | F2 |
| 5 | Scan QR | F3 |
| 6 | Konfirmasi Charger | F3, F4 |
| 7 | Charging Aktif | F4, F5, F6 |
| 8 | Ringkasan Sesi | F6 |
| 9 | Pembayaran (postpaid) | F7 |
| 9a | Wallet: Saldo & Top-up (prepaid) | F7 |
| 9b | Riwayat Mutasi Saldo | F7 |
| 10 | Riwayat | F8 |
| 11 | Detail Transaksi | F8 |
| 12 | Profil / Akun (TBD) | F1 |

Navigasi utama (bottom nav): Stations · Scan · History · Account. Desain UI: DESIGN.md (belum ada Figma).

## 8. State Sesi Charging (sisi app)

```
Idle → Validating → Starting → Charging → Stopping → Completed → PaymentPending → Paid
                     ↓            ↓          ↓                        ↓
                  StartFailed  Interrupted StopFailed             PaymentFailed
```
Nama & mapping status final mengikuti kontrak API backend [TBD-04].

## 9. Kebutuhan Non-Fungsional

| Area | Kebutuhan |
|---|---|
| Platform | Android min SDK [TBD-30], iOS min [TBD-30] |
| Bahasa | English (lihat DESIGN.md). Bahasa Indonesia menyusul, sapaan "kamu" |
| Keamanan | HTTPS; token di secure storage; tidak menyimpan data kartu di device |
| Performa | Update status sesi tampil < [TBD-32] detik setelah event backend |
| Keandalan | Sesi aktif dapat dipulihkan setelah app crash/restart |
| Izin | Lokasi (peta/terdekat), Kamera (QR), Notifikasi |
| Analytics / crash report | [TBD-33: Firebase Crashlytics/Analytics?] |
| Privasi | Kebijakan privasi & syarat layanan di app [TBD-34] |

## 10. Dependensi Eksternal

- Business Backend API + kanal real-time (kontrak belum ada)
- Provider peta: [TBD-35: Google Maps / Mapbox / OSM?]
- Payment gateway: [TBD-23]
- Push notification: [TBD-19]

## 11. Pertanyaan Terbuka

| ID | Pertanyaan |
|---|---|
| TBD-01 | Metrik sukses MVP & target rilis/timeline? |
| TBD-02 | Target kendaraan: mobil saja atau juga motor listrik? |
| TBD-04 | Kontrak API, sementara dummy; kapan backend siap? |
| TBD-06 | Verifikasi email, edit profil, hapus akun termasuk MVP? |
| TBD-07 | Ada refresh token? Masa berlaku token? |
| TBD-08/26 | Struktur tarif (per kWh / per menit / flat), biaya admin, PPN, idle fee, dan ditampilkan sebelum charging? |
| TBD-09/10 | Navigasi ke lokasi, search & filter SPKLU termasuk MVP? |
| TBD-11 | Status peta real-time atau refresh berkala? |
| TBD-12 | Format isi QR & satu QR per charger atau per connector? |
| TBD-13/14 | Input manual ID & start dari detail SPKLU tanpa scan diizinkan? |
| TBD-15 | Boleh lebih dari satu sesi aktif per user? |
| TBD-16/21 | Timeout start/stop & penanganannya? |
| TBD-17 | Saldo minimum untuk start (prepaid) & nominal top-up? |
| TBD-22 | Prepaid vs postpaid dipilih user per sesi, per akun, atau per lokasi? |
| TBD-18 | Ada opsi batas charging (kWh / Rp / waktu)? |
| TBD-19 | Push notification masuk MVP? Event apa saja? |
| TBD-20 | Tampilkan daya kW / SoC %? |
| TBD-23 | Payment gateway & metode bayar? |
| TBD-24 | Kebijakan tagihan tidak terbayar (blokir sesi berikutnya?) |
| TBD-25 | Format struk/invoice? |
| TBD-27 | Filter riwayat? |
| TBD-28/29 | Bottom nav Stations · Scan · History · Account; acuan desain DESIGN.md (belum ada Figma) |
| TBD-30 | Min OS version Android/iOS? |
| TBD-31 | English dulu; Bahasa Indonesia menyusul |
| TBD-32 | Target latency update real-time? |
| TBD-33 | Tools analytics & crash reporting? |
| TBD-34 | Halaman bantuan/CS, kebijakan privasi, T&C? |
| TBD-35 | Provider peta? Sementara OpenStreetMap via `flutter_map` (hanya untuk development, kebijakan tile OSM tidak untuk produksi) |
| TBD-36 | Brand NARA, warna & dark mode di DESIGN.md; logo belum ada |
| TBD-37 | Fitur favorit SPKLU / data kendaraan user (tipe connector default)? |
| TBD-38 | Prepaid: saldo habis saat charging → auto-stop? |
| TBD-39 | Prepaid: kebijakan refund/penarikan saldo? |
