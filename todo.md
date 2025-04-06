# ✅ TODO List - Garong UTS Mobile Programming

## 📦 Fitur Utama yang Sudah Selesai
- [x] Splash Screen
- [x] Login / Register (Firebase Auth)
- [x] Navigasi: Bottom Navbar & Drawer
- [x] Home Page (Dummy produk & kategori)
- [x] Profile Page basic
- [x] Edit Profile (tanpa upload foto)
- [x] Routing antar halaman
- [x] About Page
- [x] Logout berfungsi
- [x] Drawer menu lengkap
- [x] Cart Page dasar
- [x] Detail Produk (kuantitas + info produk)

---

## 🔨 Fitur yang Sedang Dikerjakan
- [ x] **Cart Page Finalisasi**
  - [x ] Integrasi dari detail produk ke keranjang
  - [ x] Logika kupon diskon:
    - `maul` → diskon 5%
    - `naila` → diskon 2%
    - `amel` → diskon 10%
  - [ x] Perhitungan:
    - Subtotal
    - Ongkir
    - Diskon
    - Total bayar akhir

---

## 🧾 Pembayaran
- [ ] Halaman **Data Pembayaran**
  - [ ] Otomatis isi nama & email dari Firebase
  - [ ] Pilihan: `Pick-Up` / `Delivery` (Dropdown)
  - [ ] Tombol lanjutkan ke “Pembayaran Berhasil”

- [ ] Halaman **Pembayaran Berhasil**
  - [ ] Pesan "Pembayaran sukses!"
  - [ ] Tombol kembali ke Home
  - [ ] Simpan data order ke Firebase (opsional)

---

## 🚚 My Order & Riwayat
- [ ] **My Order Page**
  - [ ] Timer simulasi status: Proses → Antar → Sampai (10 detik per status)
  - [ ] Dummy GMaps atau gambar lokasi

- [ ] **Riwayat Order (History)**
  - [ ] Tampilkan list order sebelumnya
  - [ ] Warna status:
    - Hijau = Selesai
    - Kuning = Proses
    - Merah = Dibatalkan

---

## 🧍 Edit Profile (lanjutan)
- [ ] Upload foto profil dengan `image_picker`
- [ ] Simpan ke Firebase Storage
- [ ] Ambil URL dan tampilkan di profile

---

## 🧭 Guide & UX Enhancer
- [ ] Tutorial onboarding (pakai `flutter_overboard` atau `tutorial_coach_mark`)
- [ ] Tampilkan saat user pertama kali install

---

## 🛍️ UI Enhancement (Home)
- [ ] Search bar di halaman Home
- [ ] Carousel banner promo
- [ ] Kategori produk dalam grid 2x2

---

## 🧪 Testing & Optimasi
- [ ] Tes semua flow dari login → checkout → history
- [ ] Handle error & loading state
- [ ] Rapiin folder & nama file biar clean

---

## 📎 Catatan
- Gunakan state management ringan seperti `Provider` (jika diperlukan)
- Jaga konsistensi desain UI (warna, radius, padding)
- Pastikan semua `TextField` ada validasi inputnya

---

