# ============================================================
# dal/siparis_dal.py  ── Data Access Layer
# SATISSIPARISI ve SATISSIPARISDETAY Stored Procedure çağrıları
# ============================================================
from .db_connection import execute_sp


class SiparisDAL:

    @staticmethod
    def listele(siparis_id=None, musteri_id=None, durum=None,
                baslangic=None, bitis=None):
        params = {}
        if siparis_id: params["SatisSiparisID"]  = siparis_id
        if musteri_id: params["MusteriID"]        = musteri_id
        if durum:      params["Durum"]            = durum
        if baslangic:  params["BaslangicTarih"]   = baslangic
        if bitis:      params["BitisTarih"]       = bitis
        return execute_sp("sp_SatisSiparisListele", params if params else None)

    @staticmethod
    def ekle(musteri_id, calisan_id, talep_teslimat=None, notlar=None):
        params = {"MusteriID": musteri_id, "CalisanID": calisan_id}
        if talep_teslimat: params["TalepEdilenTeslimat"] = talep_teslimat
        if notlar:         params["Notlar"]              = notlar
        return execute_sp("sp_SatisSiparisEkle", params)

    @staticmethod
    def guncelle(siparis_id, durum, talep_teslimat=None, notlar=None):
        return execute_sp("sp_SatisSiparisGuncelle", {
            "SatisSiparisID":      siparis_id,
            "Durum":               durum,
            "TalepEdilenTeslimat": talep_teslimat,
            "Notlar":              notlar,
        })

    @staticmethod
    def sil(siparis_id):
        return execute_sp("sp_SatisSiparisSil", {"SatisSiparisID": siparis_id})

    # ── Detay ──────────────────────────────────────────────
    @staticmethod
    def detay_listele(siparis_id=None):
        params = {"SatisSiparisID": siparis_id} if siparis_id else None
        return execute_sp("sp_SatisDetayListele", params)

    @staticmethod
    def detay_ekle(siparis_id, urun_id, miktar, birim_fiyat, iskonto=0):
        return execute_sp("sp_SatisDetayEkle", {
            "SatisSiparisID":  siparis_id,
            "UrunID":          urun_id,
            "Miktar":          miktar,
            "BirimSatisFiyati": birim_fiyat,
            "IskontoOrani":    iskonto,
        })

    @staticmethod
    def detay_guncelle(detay_id, miktar, birim_fiyat, iskonto):
        return execute_sp("sp_SatisDetayGuncelle", {
            "DetayID":         detay_id,
            "Miktar":          miktar,
            "BirimSatisFiyati": birim_fiyat,
            "IskontoOrani":    iskonto,
        })

    @staticmethod
    def detay_sil(detay_id):
        return execute_sp("sp_SatisDetaySil", {"DetayID": detay_id})
