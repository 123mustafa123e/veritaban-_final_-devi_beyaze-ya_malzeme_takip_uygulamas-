# ============================================================
# business/musteri_bl.py  ── Business Layer
# Müşteri iş kuralları ve validasyon
# ============================================================
from dal.musteri_dal import MusteriDAL


class MusteriBL:

    @staticmethod
    def listele(musteri_id=None, musteri_tipi=None, aktif_mi=1):
        return MusteriDAL.listele(musteri_id, musteri_tipi, aktif_mi)

    @staticmethod
    def ekle(form_data: dict):
        hatalar = MusteriBL._validate(form_data)
        if hatalar:
            return False, hatalar
        MusteriDAL.ekle(
            firma_adi     = form_data["firma_adi"],
            vergi_no      = form_data["vergi_no"],
            yetkili_adi   = form_data.get("yetkili_adi"),
            telefon       = form_data["telefon"],
            email         = form_data.get("email"),
            adres         = form_data["adres"],
            kredi_limiti  = float(form_data.get("kredi_limiti", 0)),
            indirim_orani = float(form_data.get("indirim_orani", 0)),
            musteri_tipi  = form_data.get("musteri_tipi", "Bayi"),
        )
        return True, []

    @staticmethod
    def guncelle(musteri_id: int, form_data: dict):
        hatalar = MusteriBL._validate(form_data)
        if hatalar:
            return False, hatalar
        MusteriDAL.guncelle(
            musteri_id    = musteri_id,
            firma_adi     = form_data["firma_adi"],
            vergi_no      = form_data["vergi_no"],
            yetkili_adi   = form_data.get("yetkili_adi"),
            telefon       = form_data["telefon"],
            email         = form_data.get("email"),
            adres         = form_data["adres"],
            kredi_limiti  = float(form_data.get("kredi_limiti", 0)),
            indirim_orani = float(form_data.get("indirim_orani", 0)),
            musteri_tipi  = form_data.get("musteri_tipi", "Bayi"),
            aktif_mi      = int(form_data.get("aktif_mi", 1)),
        )
        return True, []

    @staticmethod
    def sil(musteri_id: int):
        MusteriDAL.sil(musteri_id)
        return True, []

    @staticmethod
    def _validate(data: dict):
        hatalar = []
        if not data.get("firma_adi"):
            hatalar.append("Firma adı zorunludur.")
        if not data.get("vergi_no"):
            hatalar.append("Vergi numarası zorunludur.")
        if not data.get("telefon"):
            hatalar.append("Telefon zorunludur.")
        if not data.get("adres"):
            hatalar.append("Adres zorunludur.")
        return hatalar


# ============================================================
# business/siparis_bl.py  ── Business Layer
# ============================================================
from dal.siparis_dal import SiparisDAL
from dal.musteri_dal import MusteriDAL
from dal.caliskan_dal import CalisanDAL


class SiparisBL:

    @staticmethod
    def listele(siparis_id=None, musteri_id=None, durum=None):
        return SiparisDAL.listele(siparis_id, musteri_id, durum)

    @staticmethod
    def ekle(form_data: dict):
        if not form_data.get("musteri_id"):
            return False, ["Müşteri seçimi zorunludur."]
        if not form_data.get("calisan_id"):
            return False, ["Çalışan seçimi zorunludur."]

        result = SiparisDAL.ekle(
            musteri_id      = int(form_data["musteri_id"]),
            calisan_id      = int(form_data["calisan_id"]),
            talep_teslimat  = form_data.get("talep_teslimat") or None,
            notlar          = form_data.get("notlar"),
        )
        return True, result

    @staticmethod
    def durum_guncelle(siparis_id: int, durum: str):
        SiparisDAL.guncelle(siparis_id, durum)
        return True, []

    @staticmethod
    def iptal_et(siparis_id: int):
        SiparisDAL.sil(siparis_id)
        return True, []

    @staticmethod
    def detay_ekle(siparis_id: int, form_data: dict):
        try:
            SiparisDAL.detay_ekle(
                siparis_id  = siparis_id,
                urun_id     = int(form_data["urun_id"]),
                miktar      = int(form_data["miktar"]),
                birim_fiyat = float(form_data["birim_fiyat"]),
                iskonto     = float(form_data.get("iskonto_orani", 0)),
            )
            return True, []
        except RuntimeError as e:
            return False, [str(e)]

    @staticmethod
    def form_verileri():
        return {
            "musteriler": MusteriDAL.listele(aktif_mi=1),
            "calisanlar": CalisanDAL.listele(aktif_mi=1),
        }


# ============================================================
# business/fatura_bl.py  ── Business Layer
# ============================================================
from dal.fatura_dal import FaturaDAL
from dal.siparis_dal import SiparisDAL
import datetime


class FaturaBL:

    @staticmethod
    def listele(musteri_id=None, odeme_durumu=None):
        return FaturaDAL.listele(musteri_id=musteri_id, odeme_durumu=odeme_durumu)

    @staticmethod
    def fatura_kes(siparis_id: int, vade_gun: int = 30):
        """Sipariş için otomatik fatura numarası üretip fatura oluşturur."""
        bugun = datetime.date.today()
        vade  = bugun + datetime.timedelta(days=vade_gun)
        fatura_no = f"FTR-{bugun.strftime('%Y%m%d')}-{siparis_id:04d}"

        try:
            FaturaDAL.ekle(
                siparis_id    = siparis_id,
                fatura_no     = fatura_no,
                fatura_tarihi = str(bugun),
                vade_tarihi   = str(vade),
            )
            return True, []
        except RuntimeError as e:
            return False, [str(e)]

    @staticmethod
    def odeme_al(fatura_id: int, form_data: dict):
        hatalar = []
        if not form_data.get("odeme_yontemi"):
            hatalar.append("Ödeme yöntemi seçiniz.")
        if not form_data.get("odenen_tutar"):
            hatalar.append("Ödeme tutarı giriniz.")
        if hatalar:
            return False, hatalar

        try:
            FaturaDAL.odeme_ekle(
                fatura_id     = fatura_id,
                odeme_tarihi  = form_data.get("odeme_tarihi") or str(datetime.date.today()),
                odeme_yontemi = form_data["odeme_yontemi"],
                odenen_tutar  = float(form_data["odenen_tutar"]),
                aciklama      = form_data.get("aciklama"),
            )
            return True, []
        except RuntimeError as e:
            return False, [str(e)]
