# 🗄️ Dokumentasi Struktur Database - Job Desk 3 (Supabase)

Dokumen ini berisi struktur tabel yang sudah diimplementasikan di **Supabase (PostgreSQL)** untuk proyek absensi.

## Informasi Koneksi Awal (Diperlukan oleh JD2 & JD4)

* **Project URL:** [SALIN DARI Supabase Dashboard: Settings -> API]
* **Anon Public Key:** [SALIN DARI Supabase Dashboard: Settings -> API]

---

## Tabel Database (Schema `public`)

### 1. Tabel: `users` (Tabel Pengguna)

| Kolom | Tipe Data | Keterangan | Relasi |
| :--- | :--- | :--- | :--- |
| **`id`** | `uuid` | **Primary Key** - Terhubung langsung dengan ID dari Supabase Auth. | - |
| `nama` | `text` | Nama lengkap pengguna. | - |
| `npm` | `text` | Nomor Pokok Mahasiswa (Unique Constraint). | - |
| **`role`** | `text` | **Peran pengguna:** `'mahasiswa'` atau `'dosen'`. | - |

### 2. Tabel: `courses` (Daftar Matakuliah)

| Kolom | Tipe Data | Keterangan | Relasi |
| :--- | :--- | :--- | :--- |
| **`id`** | `bigint` | Primary Key - Dibuat otomatis. | - |
| `kode_mk` | `text` | Kode unik mata kuliah (misal: 'TI301'). | - |
| `nama_mk` | `text` | Nama mata kuliah. | - |
| **`dosen_id`** | `uuid` | ID Dosen yang mengampu mata kuliah ini. | **Foreign Key** ke `users.id` |
