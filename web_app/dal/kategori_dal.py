# ============================================================
# dal/kategori_dal.py  ── Data Access Layer
# ============================================================
from .db_connection import execute_sp


class KategoriDAL:

    @staticmethod
    def listele(kategori_id=None):
        params = {"KategoriID": kategori_id} if kategori_id else None
        return execute_sp("sp_KategoriListele", params)

    @staticmethod
    def ekle(kategori_adi, aciklama=None):
        return execute_sp("sp_KategoriEkle", {
            "KategoriAdi": kategori_adi,
            "Aciklama":    aciklama,
        })

    @staticmethod
    def guncelle(kategori_id, kategori_adi, aciklama=None):
        return execute_sp("sp_KategoriGuncelle", {
            "KategoriID":  kategori_id,
            "KategoriAdi": kategori_adi,
            "Aciklama":    aciklama,
        })

    @staticmethod
    def sil(kategori_id):
        return execute_sp("sp_KategoriSil", {"KategoriID": kategori_id})


class MarkaDAL:

    @staticmethod
    def listele(marka_id=None):
        params = {"MarkaID": marka_id} if marka_id else None
        return execute_sp("sp_MarkaListele", params)

    @staticmethod
    def ekle(marka_adi, ulke_kodu):
        return execute_sp("sp_MarkaEkle", {
            "MarkaAdi": marka_adi,
            "UlkeKodu": ulke_kodu,
        })

    @staticmethod
    def guncelle(marka_id, marka_adi, ulke_kodu):
        return execute_sp("sp_MarkaGuncelle", {
            "MarkaID":  marka_id,
            "MarkaAdi": marka_adi,
            "UlkeKodu": ulke_kodu,
        })

    @staticmethod
    def sil(marka_id):
        return execute_sp("sp_MarkaSil", {"MarkaID": marka_id})


class DepartmanDAL:

    @staticmethod
    def listele(departman_id=None):
        params = {"DepartmanID": departman_id} if departman_id else None
        return execute_sp("sp_DepartmanListele", params)

    @staticmethod
    def ekle(departman_adi, aciklama=None):
        return execute_sp("sp_DepartmanEkle", {
            "DepartmanAdi": departman_adi,
            "Aciklama":     aciklama,
        })
