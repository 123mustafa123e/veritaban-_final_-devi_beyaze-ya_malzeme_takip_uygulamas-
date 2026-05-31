# ============================================================
# dal/db_connection.py  ── Data Access Layer
# Veritabanı bağlantı yöneticisi
# Tüm DAL sınıfları bu modülü kullanır.
# ============================================================

import pyodbc
from config import DB_CONFIG


def get_connection():
    """MS SQL Server'a bağlantı döndürür."""
    conn_str = (
        f"DRIVER={DB_CONFIG['DRIVER']};"
        f"SERVER={DB_CONFIG['SERVER']};"
        f"DATABASE={DB_CONFIG['DATABASE']};"
        f"Trusted_Connection={DB_CONFIG['TRUSTED']};"
        "TrustServerCertificate=yes;"
    )
    return pyodbc.connect(conn_str)


def execute_sp(sp_name: str, params: dict = None):
    """
    Stored Procedure çalıştırır ve sonuçları liste[dict] olarak döndürür.
    INSERT/UPDATE/DELETE SP'leri için boş liste döner.
    """
    conn   = get_connection()
    cursor = conn.cursor()
    try:
        if params:
            placeholders = ", ".join([f"@{k}=?" for k in params])
            sql = f"EXEC {sp_name} {placeholders}"
            cursor.execute(sql, list(params.values()))
        else:
            cursor.execute(f"EXEC {sp_name}")

        # Sonuç seti varsa dön
        try:
            columns = [col[0] for col in cursor.description]
            rows    = cursor.fetchall()
            result  = [dict(zip(columns, row)) for row in rows]
        except Exception:
            result = []

        conn.commit()
        return result
    except pyodbc.Error as e:
        conn.rollback()
        raise RuntimeError(str(e)) from e
    finally:
        cursor.close()
        conn.close()
