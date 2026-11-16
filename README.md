# AI-s

Repositori kerja harian untuk mencatat aktivitas pengembangan dengan **ZCode**, **opencode**, dan **Antigravity**.

## Tujuan

Repo ini menjadi tempat mencatat setiap sesi kerja, baik berupa catatan, potongan kode, maupun hasil eksperimen — sehingga jejak pekerjaan tersimpan rapi dan riwayat kontribusi tercatat.

## Struktur

```
AI-s/
├── README.md
├── .gitignore
├── catat.ps1                  # skrip sekali-jalan: commit + push otomatis
├── log/                       # catatan sesi per tanggal
│   └── YYYY-MM-DD.md
├── catatan/                   # catatan bebas, ide, temuan
├── eksperimen/                # potongan kode & percobaan
└── riset/                     # hasil riset & laporan
```

## Cara Mencatat Sesi

Cara tercepat — jalankan satu perintah dari folder repo:

```powershell
.\catat.ps1 "menyelesaikan latihan sorting"
```

Skrip akan otomatis membuat/memperbarui `log/<tanggal>.md`, menambahkan baris catatan, lalu commit dan push ke GitHub.

Tanpa pesan khusus:

```powershell
.\catat.ps1
```

Skrip akan memakai pesan bawaan beserta cap waktu.

## Catatan Penting

- Identitas commit sudah diatur ke nama dan email noreply GitHub.
- Autentikasi memakai kredensial `gh` yang tersimpan di keyring sistem.
- Tidak ada kredensial yang ditulis di dalam repo ini.

## Alat yang Dipakai

| Alat | Peran |
|---|---|
| ZCode | Asisten pengodean berbasis desktop |
| opencode | Asisten pengodean berbasis desktop |
| Antigravity | IDE untuk menulis dan menjalankan kode |
| Git + GitHub CLI | Version control dan autentikasi |

## Lisensi

Belum ditentukan.
