// ============================================================
// main.js  ── Presentation Layer JavaScript
// ============================================================

// Sidebar toggle (mobil)
function toggleSidebar() {
    document.getElementById('sidebar').classList.toggle('open');
}

// Flash mesajları 4 saniye sonra otomatik kapat
document.addEventListener('DOMContentLoaded', () => {
    // Flash alerts
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(a => {
        setTimeout(() => {
            a.style.transition = 'opacity .4s';
            a.style.opacity = '0';
            setTimeout(() => a.remove(), 400);
        }, 4000);
    });

    // Aktif nav item'ı sidebar'da görünür yap
    const activeNav = document.querySelector('.nav-item.active');
    if (activeNav) {
        activeNav.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
    }

    // Tarih inputları için bugünü varsayılan yap
    const dateInputs = document.querySelectorAll('input[type="date"]');
    const today = new Date().toISOString().split('T')[0];
    dateInputs.forEach(inp => {
        if (!inp.value && !inp.required) {
            inp.value = today;
        }
    });

    // Tablo satırlarına hover efekti (clickable)
    document.querySelectorAll('.clickable-row').forEach(row => {
        row.style.cursor = 'pointer';
    });

    // Form submit — çift submit engelle
    document.querySelectorAll('form').forEach(form => {
        form.addEventListener('submit', function () {
            const btn = this.querySelector('button[type="submit"]');
            if (btn) {
                btn.disabled = true;
                btn.style.opacity = '.6';
                setTimeout(() => { btn.disabled = false; btn.style.opacity = ''; }, 3000);
            }
        });
    });
});

// Sayı formatla (₺)
function formatCurrency(num) {
    return '₺' + parseFloat(num || 0).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}
