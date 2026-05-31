# ============================================================
# business/urun_bl.py  ── Business Layer
# Ürün iş kuralları ve validasyon
# ============================================================
from dal.urun_dal import UrunDAL
from dal.kategori_dal import KategoriDAL, MarkaDAL


class UrunBL:

    @staticmethod
    def listele(urun_id=None, kategori_id=None, marka_id=None, aktif_mi=1):
        return UrunDAL.listele(urun_id, kategori_id, marka_id, aktif_mi)

    @staticmethod
    def kritik_stoklar():
        return UrunDAL.kritik_stok_listele()

    @staticmethod
    def ekle(form_data: dict):
        hatalar = UrunBL._validate(form_data)
        if hatalar:
            return False, hatalar

        UrunDAL.ekle(
            urun_kodu    = form_data["urun_kodu"],
            urun_adi     = form_data["urun_adi"],
            kategori_id  = int(form_data["kategori_id"]),
            marka_id     = int(form_data["marka_id"]),
            birim_fiyat  = float(form_data["birim_fiyat"]),
            kdv_orani    = float(form_data.get("kdv_orani", 18)),
            stok_miktari = int(form_data.get("stok_miktari", 0)),
            min_stok_esigi = int(form_data.get("min_stok_esigi", 10)),
            birim        = form_data.get("birim", "Adet"),
        )
        return True, []

    @staticmethod
    def guncelle(urun_id: int, form_data: dict):
        hatalar = UrunBL._validate(form_data)
        if hatalar:
            return False, hatalar

        UrunDAL.guncelle(
            urun_id      = urun_id,
            urun_adi     = form_data["urun_adi"],
            kategori_id  = int(form_data["kategori_id"]),
            marka_id     = int(form_data["marka_id"]),
            birim_fiyat  = float(form_data["birim_fiyat"]),
            kdv_orani    = float(form_data.get("kdv_orani", 18)),
            min_stok_esigi = int(form_data.get("min_stok_esigi", 10)),
            birim        = form_data.get("birim", "Adet"),
            aktif_mi     = int(form_data.get("aktif_mi", 1)),
        )
        return True, []

    @staticmethod
    def sil(urun_id: int):
        UrunDAL.sil(urun_id)
        return True, []

    @staticmethod
    def form_verileri():
        """Form için kategori ve marka listelerini döndür."""
        return {
            "kategoriler": KategoriDAL.listele(),
            "markalar":    MarkaDAL.listele(),
        }

    @staticmethod
    def _validate(data: dict):
        hatalar = []
        if not data.get("urun_adi"):
            hatalar.append("Ürün adı zorunludur.")
        if not data.get("birim_fiyat"):
            hatalar.append("Birim fiyat zorunludur.")
        else:
            try:
                f = float(data["birim_fiyat"])
                if f <= 0:
                    hatalar.append("Birim fiyat 0'dan büyük olmalıdır.")
            except ValueError:
                hatalar.append("Birim fiyat geçerli bir sayı olmalıdır.")
        return hatalar
