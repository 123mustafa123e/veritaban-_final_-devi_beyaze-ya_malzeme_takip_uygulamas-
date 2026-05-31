# ============================================================
# dal/caliskan_dal.py  ── Data Access Layer
# ============================================================
from .db_connection import execute_sp


class CalisanDAL:

    @staticmethod
    def listele(calisan_id=None, departman_id=None, aktif_mi=None):
        params = {}
        if calisan_id:   params["CalisanID"]   = calisan_id
        if departman_id: params["DepartmanID"]  = departman_id
        if aktif_mi is not None: params["AktifMi"] = aktif_mi
        return execute_sp("sp_CalisanListele", params if params else None)

    @staticmethod
    def ekle(ad, soyad, tckn, departman_id, gorev,
             maas, ise_giris, telefon=None, email=None):
        return execute_sp("sp_CalisanEkle", {
            "Ad":             ad,
            "Soyad":          soyad,
            "TCKN":           tckn,
            "DepartmanID":    departman_id,
            "Gorev":          gorev,
            "Maas":           maas,
            "IseGirisTarihi": ise_giris,
            "Telefon":        telefon,
            "Email":          email,
        })

    @staticmethod
    def guncelle(calisan_id, ad, soyad, departman_id, gorev,
                 maas, telefon=None, email=None, aktif_mi=1):
        return execute_sp("sp_CalisanGuncelle", {
            "CalisanID":   calisan_id,
            "Ad":          ad,
            "Soyad":       soyad,
            "DepartmanID": departman_id,
            "Gorev":       gorev,
            "Maas":        maas,
            "Telefon":     telefon,
            "Email":       email,
            "AktifMi":     aktif_mi,
        })

    @staticmethod
    def sil(calisan_id):
        return execute_sp("sp_CalisanSil", {"CalisanID": calisan_id})
