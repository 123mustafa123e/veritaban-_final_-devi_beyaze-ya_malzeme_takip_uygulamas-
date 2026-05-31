# ============================================================
# dal/musteri_dal.py  ── Data Access Layer
# MUSTERI tablosu Stored Procedure çağrıları
# ============================================================
from .db_connection import execute_sp


class MusteriDAL:

    @staticmethod
    def listele(musteri_id=None, musteri_tipi=None, aktif_mi=None):
        params = {}
        if musteri_id:  params["MusteriID"]   = musteri_id
        if musteri_tipi: params["MusteriTipi"] = musteri_tipi
        if aktif_mi is not None: params["AktifMi"] = aktif_mi
        return execute_sp("sp_MusteriListele", params if params else None)

    @staticmethod
    def ekle(firma_adi, vergi_no, yetkili_adi, telefon, email,
             adres, kredi_limiti, indirim_orani, musteri_tipi):
        return execute_sp("sp_MusteriEkle", {
            "FirmaAdi":     firma_adi,
            "VergiNo":      vergi_no,
            "YetkiliAdi":   yetkili_adi,
            "Telefon":      telefon,
            "Email":        email,
            "Adres":        adres,
            "KrediLimiti":  kredi_limiti,
            "IndirimOrani": indirim_orani,
            "MusteriTipi":  musteri_tipi,
        })

    @staticmethod
    def guncelle(musteri_id, firma_adi, vergi_no, yetkili_adi,
                 telefon, email, adres, kredi_limiti, indirim_orani,
                 musteri_tipi, aktif_mi=1):
        return execute_sp("sp_MusteriGuncelle", {
            "MusteriID":    musteri_id,
            "FirmaAdi":     firma_adi,
            "VergiNo":      vergi_no,
            "YetkiliAdi":   yetkili_adi,
            "Telefon":      telefon,
            "Email":        email,
            "Adres":        adres,
            "KrediLimiti":  kredi_limiti,
            "IndirimOrani": indirim_orani,
            "MusteriTipi":  musteri_tipi,
            "AktifMi":      aktif_mi,
        })

    @staticmethod
    def sil(musteri_id):
        return execute_sp("sp_MusteriSil", {"MusteriID": musteri_id})
