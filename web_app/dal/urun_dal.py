# ============================================================
# dal/urun_dal.py  ── Data Access Layer
# URUN tablosu Stored Procedure çağrıları
# ============================================================
from .db_connection import execute_sp


class UrunDAL:

    @staticmethod
    def listele(urun_id=None, kategori_id=None, marka_id=None, aktif_mi=None):
        params = {}
        if urun_id:     params["UrunID"]     = urun_id
        if kategori_id: params["KategoriID"] = kategori_id
        if marka_id:    params["MarkaID"]    = marka_id
        if aktif_mi is not None: params["AktifMi"] = aktif_mi
        return execute_sp("sp_UrunListele", params if params else None)

    @staticmethod
    def ekle(urun_kodu, urun_adi, kategori_id, marka_id, birim_fiyat,
             kdv_orani=18, stok_miktari=0, min_stok_esigi=10, birim="Adet"):
        return execute_sp("sp_UrunEkle", {
            "UrunKodu":     urun_kodu,
            "UrunAdi":      urun_adi,
            "KategoriID":   kategori_id,
            "MarkaID":      marka_id,
            "BirimFiyat":   birim_fiyat,
            "KDVOrani":     kdv_orani,
            "StokMiktari":  stok_miktari,
            "MinStokEsigi": min_stok_esigi,
            "Birim":        birim,
        })

    @staticmethod
    def guncelle(urun_id, urun_adi, kategori_id, marka_id, birim_fiyat,
                 kdv_orani, min_stok_esigi, birim, aktif_mi=1):
        return execute_sp("sp_UrunGuncelle", {
            "UrunID":       urun_id,
            "UrunAdi":      urun_adi,
            "KategoriID":   kategori_id,
            "MarkaID":      marka_id,
            "BirimFiyat":   birim_fiyat,
            "KDVOrani":     kdv_orani,
            "MinStokEsigi": min_stok_esigi,
            "Birim":        birim,
            "AktifMi":      aktif_mi,
        })

    @staticmethod
    def sil(urun_id):
        return execute_sp("sp_UrunSil", {"UrunID": urun_id})

    @staticmethod
    def kritik_stok_listele():
        """Stok miktarı min eşiğin altındaki ürünler"""
        tumunu = UrunDAL.listele(aktif_mi=1)
        return [u for u in tumunu if u["StokMiktari"] <= u["MinStokEsigi"]]
