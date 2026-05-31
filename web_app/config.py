# ============================================================
# config.py - Veritabanı Bağlantı Ayarları
# ============================================================

# MS SQL Server bağlantı ayarları
# Gerekirse SERVER ve DATABASE alanlarını güncelleyin
DB_CONFIG = {
    "DRIVER":   "{ODBC Driver 17 for SQL Server}",
    "SERVER":   "localhost",          # veya BILGISAYAR_ADI\SQLEXPRESS
    "DATABASE": "BeyazEsyaToptanci",
    "TRUSTED":  "yes",                # Windows Authentication
    # Kullanıcı adı/şifre ile bağlanmak için aşağıdakileri kullanın:
    # "UID": "sa",
    # "PWD": "sifreniz",
    # "TRUSTED": "no",
}

SECRET_KEY = "beyaz_esya_toptanci_2026"
DEBUG = True
