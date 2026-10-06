# Beer Pong Şampiyonası 🏆

Kara tahta görünümlü, tek sayfalık beer pong turnuva uygulaması. Veriler **Supabase**'te durur, sayfa **GitHub Pages** üzerinden yayınlanır. Derleme/sunucu gerekmez.

## Dosyalar

| Dosya | Ne işe yarar |
|---|---|
| `index.html` | Uygulamanın tamamı (arayüz + mantık) |
| `config.js` | Supabase adresi ve anon anahtarı |
| `schema.sql` | Supabase tabloları, güvenlik politikaları, canlı güncelleme |

## Kurulum

### 1) Supabase
1. [supabase.com](https://supabase.com) → **New project**.
2. **SQL Editor** → `schema.sql` içeriğini yapıştır → **Run**.
3. **Project Settings → API** sayfasından **Project URL** ve **anon public** anahtarını kopyala.
4. `config.js` dosyasındaki iki alana yapıştır. (`service_role` anahtarını asla koyma.)

### 2) GitHub Pages
1. Yeni bir GitHub deposu aç ve bu dört dosyayı yükle (`index.html`, `config.js`, `schema.sql`, `README.md`).
2. **Settings → Pages → Build and deployment**: *Deploy from a branch* → `main` / `(root)` → **Save**.
3. Birkaç dakika sonra `https://KULLANICI.github.io/DEPO/` adresinde açılır.

> `config.js` boş kalırsa uygulama **Demo modu**nda çalışır (veriler sadece o tarayıcıda tutulur). Denemek için `index.html`'i çift tıklayıp açman yeterli.

## Turnuva kuralları

- Takım adı ve **1–10 zorluk seviyesi** elle girilir. Çöp kutusu simgesi her zaman **onay sorar**.
- **1. ve 2. tur** zorluk seviyesine göre eşleşir. Varsayılan: benzer seviyeler karşılaşır. Başlatmadan önce *Güçlü ↔ zayıf* seçeneğine geçebilirsin.
- **3. turdan finale kadar** eşleşmeler rastgeledir.
- Bir turdaki takım sayısı **tek** ise rastgele biri otomatik **bay** geçer (tabloda "BAY" yazar).
- **3 masa** (Kırmızı, Mavi, Beyaz) → aynı anda en fazla 6 takım / 3 maç oynar. Bir maç bitince sıradaki maç boşalan masaya otomatik atanır.
- Maç bitince masadaki kazanan takıma dokun → onayla → kazanan üst tura geçer. Tur bitince sonraki tur otomatik oluşur; final sonunda şampiyon görünür.
- Turnuva başladıktan sonra bir takımı silersen, oynamadığı maçta rakibi **hükmen** kazanır.

## İzleme ekranı

Adresin sonuna `?view=1` ekle (örn. `…/DEPO/?view=1`). Düzenleme düğmeleri gizlenir; televizyon ya da başka telefonda sadece tabloyu gösterir ve canlı güncellenir.

## Güvenlik notu

`schema.sql`, sayfa adresini bilen herkesin yazmasına izin verir (arkadaş grubu / tek seferlik etkinlik için pratik). `?view=1` yalnızca arayüzü gizler, yetki vermez veya kısıtlamaz. Adresi herkese açık paylaşacaksan Supabase Auth ile yazma iznini giriş yapmış yöneticiye bağlamak gerekir.
