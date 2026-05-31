# ============================================================
# dal/fatura_dal.py  ── Data Access Layer
# FATURA ve ODEME Stored Procedure çağrıları
# ============================================================
from .db_connection import execute_sp


class FaturaDAL:

    @staticmethod
    def listele(fatura_id=None, musteri_id=None, odeme_durumu=None):
        params = {}
        if fatura_id:    params["FaturaID"]     = fatura_id
        if musteri_id:   params["MusteriID"]    = musteri_id
        if odeme_durumu: params["OdemeDurumu"]  = odeme_durumu
        return execute_sp("sp_FaturaListele", params if params else None)

    @staticmethod
    def ekle(siparis_id, fatura_no, fatura_tarihi, vade_tarihi):
        return execute_sp("sp_FaturaEkle", {
            "SatisSiparisID": siparis_id,
            "FaturaNo":       fatura_no,
            "FaturaTarihi":   fatura_tarihi,
            "VadeTarihi":     vade_tarihi,
        })

    @staticmethod
    def guncelle(fatura_id, vade_tarihi, fatura_no):
        return execute_sp("sp_FaturaGuncelle", {
            "FaturaID":   fatura_id,
            "VadeTarihi": vade_tarihi,
            "FaturaNo":   fatura_no,
        })

    @staticmethod
    def sil(fatura_id):
        return execute_sp("sp_FaturaSil", {"FaturaID": fatura_id})

    # ── Ödeme ──────────────────────────────────────────────
    @staticmethod
    def odeme_listele(fatura_id=None):
        params = {"FaturaID": fatura_id} if fatura_id else None
        return execute_sp("sp_OdemeListele", params)

    @staticmethod
    def odeme_ekle(fatura_id, odeme_tarihi, odeme_yontemi, odenen_tutar, aciklama=None):
        return execute_sp("sp_OdemeEkle", {
            "FaturaID":     fatura_id,
            "OdemeTarihi":  odeme_tarihi,
            "OdemeYontemi": odeme_yontemi,
            "OdenenTutar":  odenen_tutar,
            "Aciklama":     aciklama,
        })

    @staticmethod
    def odeme_sil(odeme_id):
        return execute_sp("sp_OdemeSil", {"OdemeID": odeme_id})
