# ============================================================
# dal/tedarikci_dal.py  ── Data Access Layer
# dal/caliskan_dal.py  ── Data Access Layer
# dal/kategori_dal.py  ── Data Access Layer
# ============================================================
from .db_connection import execute_sp


class TedarikciDAL:

    @staticmethod
    def listele(tedarikci_id=None, aktif_mi=None):
        params = {}
        if tedarikci_id: params["TedarikciID"] = tedarikci_id
        if aktif_mi is not None: params["AktifMi"] = aktif_mi
        return execute_sp("sp_TedarikciListele", params if params else None)

    @staticmethod
    def ekle(firma_adi, vergi_no, yetkili_adi, telefon,
             email, adres, odeme_vadesi=30):
        return execute_sp("sp_TedarikciEkle", {
            "FirmaAdi":    firma_adi,
            "VergiNo":     vergi_no,
            "YetkiliAdi":  yetkili_adi,
            "Telefon":     telefon,
            "Email":       email,
            "Adres":       adres,
            "OdemeVadesi": odeme_vadesi,
        })

    @staticmethod
    def guncelle(tedarikci_id, firma_adi, vergi_no, yetkili_adi,
                 telefon, email, adres, odeme_vadesi, aktif_mi=1):
        return execute_sp("sp_TedarikciGuncelle", {
            "TedarikciID":  tedarikci_id,
            "FirmaAdi":     firma_adi,
            "VergiNo":      vergi_no,
            "YetkiliAdi":   yetkili_adi,
            "Telefon":      telefon,
            "Email":        email,
            "Adres":        adres,
            "OdemeVadesi":  odeme_vadesi,
            "AktifMi":      aktif_mi,
        })

    @staticmethod
    def sil(tedarikci_id):
        return execute_sp("sp_TedarikciSil", {"TedarikciID": tedarikci_id})
