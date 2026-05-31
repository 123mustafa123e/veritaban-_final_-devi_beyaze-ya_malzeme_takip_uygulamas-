# ============================================================
# app.py  ── Presentation Layer (Flask Rotaları)
# AKEL Beyaz Eşya Toptancılık A.Ş. - Web Yönetim Sistemi
#
# MİMARİ: Presentation → Business Layer → DAL → Stored Procedure → DB
# Hiçbir rotada doğrudan SQL kullanılmaz!
# ============================================================

from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
from config import SECRET_KEY, DEBUG

# Business Layer importları
from business.urun_bl    import UrunBL
from business.musteri_bl import MusteriBL, SiparisBL, FaturaBL

# DAL (yalnızca dropdown verileri için)
from dal.kategori_dal import KategoriDAL, MarkaDAL, DepartmanDAL
from dal.caliskan_dal import CalisanDAL
from dal.tedarikci_dal import TedarikciDAL
from dal.siparis_dal   import SiparisDAL
from dal.fatura_dal    import FaturaDAL

app = Flask(__name__)
app.secret_key = SECRET_KEY


@app.context_processor
def inject_builtins():
    return dict(str=str)

# ============================================================
# DASHBOARD
# ============================================================
@app.route("/")
def dashboard():
    try:
        urunler    = UrunBL.listele()
        musteriler = MusteriBL.listele()
        siparisler = SiparisBL.listele()
        faturalar  = FaturaDAL.listele()
        kritikler  = UrunBL.kritik_stoklar()

        stats = {
            "toplam_urun":       len(urunler),
            "toplam_musteri":    len(musteriler),
            "toplam_siparis":    len(siparisler),
            "odenmemis_fatura":  sum(1 for f in faturalar if f["OdemeDurumu"] == "Odenmedi"),
            "kritik_stok":       len(kritikler),
            "bugun_siparis":     sum(1 for s in siparisler
                                     if str(s["SiparisTarihi"])[:10] ==
                                        __import__("datetime").date.today().strftime("%Y-%m-%d")),
        }
        son_siparisler = siparisler[:8]
        return render_template("dashboard.html", stats=stats,
                               son_siparisler=son_siparisler,
                               kritik_stoklar=kritikler[:5])
    except Exception as e:
        flash(f"Veritabanı bağlantı hatası: {e}", "danger")
        return render_template("dashboard.html", stats={}, son_siparisler=[], kritik_stoklar=[])


# ============================================================
# ÜRÜNLER
# ============================================================
@app.route("/urunler")
def urunler_listele():
    kategori_id = request.args.get("kategori_id")
    marka_id    = request.args.get("marka_id")
    try:
        urunler    = UrunBL.listele(kategori_id=kategori_id, marka_id=marka_id)
        kategoriler = KategoriDAL.listele()
        markalar   = MarkaDAL.listele()
        return render_template("urunler/liste.html", urunler=urunler,
                               kategoriler=kategoriler, markalar=markalar,
                               sec_kategori=kategori_id, sec_marka=marka_id)
    except Exception as e:
        flash(str(e), "danger")
        return render_template("urunler/liste.html", urunler=[], kategoriler=[], markalar=[])


@app.route("/urunler/ekle", methods=["GET", "POST"])
def urun_ekle():
    form_verileri = UrunBL.form_verileri()
    if request.method == "POST":
        basarili, hatalar = UrunBL.ekle(request.form)
        if basarili:
            flash("Ürün başarıyla eklendi.", "success")
            return redirect(url_for("urunler_listele"))
        for h in hatalar:
            flash(h, "danger")
    return render_template("urunler/form.html", mod="ekle",
                           urun=None, **form_verileri)


@app.route("/urunler/duzenle/<int:urun_id>", methods=["GET", "POST"])
def urun_duzenle(urun_id):
    form_verileri = UrunBL.form_verileri()
    urun_listesi = UrunBL.listele(urun_id=urun_id)
    urun = urun_listesi[0] if urun_listesi else None

    if request.method == "POST":
        basarili, hatalar = UrunBL.guncelle(urun_id, request.form)
        if basarili:
            flash("Ürün güncellendi.", "success")
            return redirect(url_for("urunler_listele"))
        for h in hatalar:
            flash(h, "danger")
    return render_template("urunler/form.html", mod="duzenle",
                           urun=urun, **form_verileri)


@app.route("/urunler/sil/<int:urun_id>", methods=["POST"])
def urun_sil(urun_id):
    UrunBL.sil(urun_id)
    flash("Ürün pasife alındı.", "warning")
    return redirect(url_for("urunler_listele"))


# ============================================================
# MÜŞTERİLER
# ============================================================
@app.route("/musteriler")
def musteriler_listele():
    try:
        musteriler = MusteriBL.listele(aktif_mi=None)
        return render_template("musteriler/liste.html", musteriler=musteriler)
    except Exception as e:
        flash(str(e), "danger")
        return render_template("musteriler/liste.html", musteriler=[])


@app.route("/musteriler/ekle", methods=["GET", "POST"])
def musteri_ekle():
    if request.method == "POST":
        basarili, hatalar = MusteriBL.ekle(request.form)
        if basarili:
            flash("Müşteri eklendi.", "success")
            return redirect(url_for("musteriler_listele"))
        for h in hatalar:
            flash(h, "danger")
    return render_template("musteriler/form.html", mod="ekle", musteri=None)


@app.route("/musteriler/duzenle/<int:musteri_id>", methods=["GET", "POST"])
def musteri_duzenle(musteri_id):
    musteri_listesi = MusteriBL.listele(musteri_id=musteri_id)
    musteri = musteri_listesi[0] if musteri_listesi else None

    if request.method == "POST":
        basarili, hatalar = MusteriBL.guncelle(musteri_id, request.form)
        if basarili:
            flash("Müşteri güncellendi.", "success")
            return redirect(url_for("musteriler_listele"))
        for h in hatalar:
            flash(h, "danger")
    return render_template("musteriler/form.html", mod="duzenle", musteri=musteri)


@app.route("/musteriler/sil/<int:musteri_id>", methods=["POST"])
def musteri_sil(musteri_id):
    MusteriBL.sil(musteri_id)
    flash("Müşteri pasife alındı.", "warning")
    return redirect(url_for("musteriler_listele"))


# ============================================================
# SİPARİŞLER
# ============================================================
@app.route("/siparisler")
def siparisler_listele():
    durum = request.args.get("durum")
    try:
        siparisler = SiparisBL.listele(durum=durum)
        return render_template("siparisler/liste.html",
                               siparisler=siparisler, sec_durum=durum)
    except Exception as e:
        flash(str(e), "danger")
        return render_template("siparisler/liste.html", siparisler=[], sec_durum=None)


@app.route("/siparisler/yeni", methods=["GET", "POST"])
def siparis_yeni():
    form_verileri = SiparisBL.form_verileri()
    if request.method == "POST":
        basarili, result = SiparisBL.ekle(request.form)
        if basarili:
            # Yeni oluşan siparişin ID'sini bul
            yeni_siparis = SiparisBL.listele()
            if yeni_siparis:
                yeni_id = yeni_siparis[0]["SatisSiparisID"]
                flash("Sipariş oluşturuldu. Ürün ekleyebilirsiniz.", "success")
                return redirect(url_for("siparis_detay", siparis_id=yeni_id))
        else:
            for h in result:
                flash(h, "danger")
    return render_template("siparisler/yeni.html", **form_verileri)


@app.route("/siparisler/<int:siparis_id>")
def siparis_detay(siparis_id):
    siparis_listesi = SiparisBL.listele(siparis_id=siparis_id)
    siparis  = siparis_listesi[0] if siparis_listesi else None
    detaylar = SiparisDAL.detay_listele(siparis_id)
    urunler  = UrunBL.listele()
    return render_template("siparisler/detay.html",
                           siparis=siparis, detaylar=detaylar, urunler=urunler)


@app.route("/siparisler/<int:siparis_id>/detay-ekle", methods=["POST"])
def siparis_detay_ekle(siparis_id):
    basarili, hatalar = SiparisBL.detay_ekle(siparis_id, request.form)
    if basarili:
        flash("Ürün siparişe eklendi.", "success")
    else:
        for h in hatalar:
            flash(h, "danger")
    return redirect(url_for("siparis_detay", siparis_id=siparis_id))


@app.route("/siparisler/<int:siparis_id>/durum", methods=["POST"])
def siparis_durum(siparis_id):
    durum = request.form.get("durum")
    SiparisBL.durum_guncelle(siparis_id, durum)
    flash(f"Sipariş durumu '{durum}' olarak güncellendi.", "success")
    return redirect(url_for("siparis_detay", siparis_id=siparis_id))


@app.route("/siparisler/<int:siparis_id>/fatura-kes", methods=["POST"])
def fatura_kes(siparis_id):
    vade = int(request.form.get("vade_gun", 30))
    basarili, hatalar = FaturaBL.fatura_kes(siparis_id, vade)
    if basarili:
        flash("Fatura oluşturuldu.", "success")
        return redirect(url_for("faturalar_listele"))
    for h in hatalar:
        flash(h, "danger")
    return redirect(url_for("siparis_detay", siparis_id=siparis_id))


# ============================================================
# FATURALAR
# ============================================================
@app.route("/faturalar")
def faturalar_listele():
    odeme_durumu = request.args.get("odeme_durumu")
    try:
        faturalar = FaturaBL.listele(odeme_durumu=odeme_durumu)
        return render_template("faturalar/liste.html",
                               faturalar=faturalar, sec_durum=odeme_durumu)
    except Exception as e:
        flash(str(e), "danger")
        return render_template("faturalar/liste.html", faturalar=[], sec_durum=None)


@app.route("/faturalar/<int:fatura_id>/odeme", methods=["GET", "POST"])
def odeme_al(fatura_id):
    fatura_listesi = FaturaDAL.listele(fatura_id=fatura_id)
    fatura = fatura_listesi[0] if fatura_listesi else None
    odemeler = FaturaDAL.odeme_listele(fatura_id)

    if request.method == "POST":
        basarili, hatalar = FaturaBL.odeme_al(fatura_id, request.form)
        if basarili:
            flash("Ödeme kaydedildi.", "success")
            return redirect(url_for("faturalar_listele"))
        for h in hatalar:
            flash(h, "danger")
    return render_template("faturalar/odeme.html",
                           fatura=fatura, odemeler=odemeler)


# ============================================================
# TEDARİKÇİLER
# ============================================================
@app.route("/tedarikci")
def tedarikci_listele():
    try:
        tedarikciler = TedarikciDAL.listele()
        return render_template("tedarikci/liste.html", tedarikciler=tedarikciler)
    except Exception as e:
        flash(str(e), "danger")
        return render_template("tedarikci/liste.html", tedarikciler=[])


@app.route("/tedarikci/ekle", methods=["GET", "POST"])
def tedarikci_ekle():
    if request.method == "POST":
        try:
            TedarikciDAL.ekle(
                firma_adi    = request.form["firma_adi"],
                vergi_no     = request.form["vergi_no"],
                yetkili_adi  = request.form.get("yetkili_adi"),
                telefon      = request.form["telefon"],
                email        = request.form.get("email"),
                adres        = request.form["adres"],
                odeme_vadesi = int(request.form.get("odeme_vadesi", 30)),
            )
            flash("Tedarikçi eklendi.", "success")
            return redirect(url_for("tedarikci_listele"))
        except Exception as e:
            flash(str(e), "danger")
    return render_template("tedarikci/form.html", mod="ekle", tedarikci=None)


@app.route("/tedarikci/duzenle/<int:tedarikci_id>", methods=["GET", "POST"])
def tedarikci_duzenle(tedarikci_id):
    t_listesi = TedarikciDAL.listele(tedarikci_id=tedarikci_id)
    tedarikci = t_listesi[0] if t_listesi else None

    if request.method == "POST":
        try:
            TedarikciDAL.guncelle(
                tedarikci_id = tedarikci_id,
                firma_adi    = request.form["firma_adi"],
                vergi_no     = request.form["vergi_no"],
                yetkili_adi  = request.form.get("yetkili_adi"),
                telefon      = request.form["telefon"],
                email        = request.form.get("email"),
                adres        = request.form["adres"],
                odeme_vadesi = int(request.form.get("odeme_vadesi", 30)),
            )
            flash("Tedarikçi güncellendi.", "success")
            return redirect(url_for("tedarikci_listele"))
        except Exception as e:
            flash(str(e), "danger")
    return render_template("tedarikci/form.html", mod="duzenle", tedarikci=tedarikci)


# ============================================================
# ÇALIŞANLAR
# ============================================================
@app.route("/calisanlar")
def calisanlar_listele():
    try:
        calisanlar  = CalisanDAL.listele()
        departmanlar = DepartmanDAL.listele()
        return render_template("calisanlar/liste.html",
                               calisanlar=calisanlar, departmanlar=departmanlar)
    except Exception as e:
        flash(str(e), "danger")
        return render_template("calisanlar/liste.html", calisanlar=[], departmanlar=[])


@app.route("/calisanlar/ekle", methods=["GET", "POST"])
def calisan_ekle():
    departmanlar = DepartmanDAL.listele()
    if request.method == "POST":
        try:
            CalisanDAL.ekle(
                ad          = request.form["ad"],
                soyad       = request.form["soyad"],
                tckn        = request.form["tckn"],
                departman_id = int(request.form["departman_id"]),
                gorev       = request.form["gorev"],
                maas        = float(request.form["maas"]),
                ise_giris   = request.form["ise_giris"],
                telefon     = request.form.get("telefon"),
                email       = request.form.get("email"),
            )
            flash("Çalışan eklendi.", "success")
            return redirect(url_for("calisanlar_listele"))
        except Exception as e:
            flash(str(e), "danger")
    return render_template("calisanlar/form.html", mod="ekle",
                           calisan=None, departmanlar=departmanlar)


@app.route("/calisanlar/duzenle/<int:calisan_id>", methods=["GET", "POST"])
def calisan_duzenle(calisan_id):
    departmanlar = DepartmanDAL.listele()
    c_listesi    = CalisanDAL.listele(calisan_id=calisan_id)
    calisan      = c_listesi[0] if c_listesi else None

    if request.method == "POST":
        try:
            CalisanDAL.guncelle(
                calisan_id   = calisan_id,
                ad           = request.form["ad"],
                soyad        = request.form["soyad"],
                departman_id = int(request.form["departman_id"]),
                gorev        = request.form["gorev"],
                maas         = float(request.form["maas"]),
                telefon      = request.form.get("telefon"),
                email        = request.form.get("email"),
            )
            flash("Çalışan güncellendi.", "success")
            return redirect(url_for("calisanlar_listele"))
        except Exception as e:
            flash(str(e), "danger")
    return render_template("calisanlar/form.html", mod="duzenle",
                           calisan=calisan, departmanlar=departmanlar)


@app.route("/calisanlar/sil/<int:calisan_id>", methods=["POST"])
def calisan_sil(calisan_id):
    CalisanDAL.sil(calisan_id)
    flash("Çalışan pasife alındı.", "warning")
    return redirect(url_for("calisanlar_listele"))


# ============================================================
# KATEGORİLER
# ============================================================
@app.route("/kategoriler")
def kategoriler_listele():
    try:
        kategoriler = KategoriDAL.listele()
        markalar    = MarkaDAL.listele()
        return render_template("kategoriler.html",
                               kategoriler=kategoriler, markalar=markalar)
    except Exception as e:
        flash(str(e), "danger")
        return render_template("kategoriler.html", kategoriler=[], markalar=[])


@app.route("/kategoriler/ekle", methods=["POST"])
def kategori_ekle():
    KategoriDAL.ekle(request.form["kategori_adi"], request.form.get("aciklama"))
    flash("Kategori eklendi.", "success")
    return redirect(url_for("kategoriler_listele"))


@app.route("/markalar/ekle", methods=["POST"])
def marka_ekle():
    MarkaDAL.ekle(request.form["marka_adi"], request.form.get("ulke_kodu", "TR"))
    flash("Marka eklendi.", "success")
    return redirect(url_for("kategoriler_listele"))


# ============================================================
if __name__ == "__main__":
    app.run(debug=DEBUG, host="0.0.0.0", port=5000)
