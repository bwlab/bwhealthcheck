# bwlab Health Check — PrestaShop Module

A free, open-source PrestaShop module that generates a comprehensive health check report of your shop installation. Analyze your PrestaShop setup in seconds — versions, modules, overrides, theme, images, and e-commerce statistics — all in one place.

## Features

### Dashboard (6 sections)

| Section | What it reports |
|---------|----------------|
| **System Information** | PrestaShop, PHP, MySQL/MariaDB versions, latest stable comparison |
| **Image Statistics** | Total images, products with/without images, average per product |
| **E-commerce Statistics** | Orders, customers, addresses, anonymous/registered carts, avg order value (3 months), enabled languages |
| **Active Theme** | Name, version, parent theme, directory, child theme detection |
| **Modules** | Full inventory of active/inactive modules with display name, version, author |
| **System Overrides** | Core overrides + per-module override scan (`modules/{mod}/override/`) |

### Actions

- **Generate PDF Report** — Download a formatted PDF report (powered by TCPDF)
- **Send Report to bwlab** — Send the report to bwlab for a free consultation (modal with contact details, privacy consent, JSON attachment via email)
- **Refresh Data** — Force a data refresh (cached for 1 hour)

## Requirements

- PrestaShop 1.7.6 or later (tested up to 9.x)
- PHP 7.2 or later
- MySQL 5.7+ / MariaDB 10.3+

## Installation

1. Download the latest release ZIP from [Releases](https://github.com/bwlab/bwhealthcheck/releases)
2. Go to your PrestaShop Back Office → **Modules** → **Upload a module**
3. Select the ZIP file and install
4. Click **Configure** to view your health check report

### Manual installation

Copy the `bwhealthcheck/` folder into your PrestaShop `modules/` directory, then install from the Back Office.

## Usage

After installation, go to **Modules → bwhealthcheck → Configure**. The dashboard shows all 6 sections with your shop data.

### Generate PDF

Click **Generate PDF Report** to download a formatted PDF with all sections. The PDF uses HTML rendering with automatic page breaks — no broken tables.

### Send Report to bwlab

Click **Send Report to bwlab** to open a modal with:
- Pre-filled contact details (email, name, company from your admin account)
- Phone number field
- Privacy policy consent checkbox (required)

On submit, the report is sent as a JSON attachment to bwlab's sales team using your shop's configured SMTP.

## Technical Details

- **Pure legacy PHP** — No Symfony controllers, no Composer, no PSR-4 autoloading
- **TCPDF 6.7.5** bundled in `vendor/tcpdf/` — no external downloads
- **No external API calls** — Everything is processed locally (except email sending via your shop's SMTP)
- **Database read-only** — No tables created, no data modified
- **CSRF protection** — Admin token validation on all actions
- **Caching** — Data cached for 1 hour in `/var/cache/healthcheck/`, refreshable on demand

### Theme detection

On PrestaShop 8.x+ the `ps_theme` table does not exist. The module reads the active theme from `Shop::$theme_name` and parses `themes/{name}/config/theme.yml` for version, parent, and display name. All themes directories are scanned to detect child themes.

## Compatibility Matrix

| PrestaShop | PHP | Status |
|------------|-----|--------|
| 1.7.6 – 1.7.8 | 7.2+ | Supported |
| 8.0 – 8.2 | 7.4+ / 8.1+ | Tested |
| 9.0+ | 8.1+ | Supported |

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

You are free to use, modify, and redistribute this module.

## Author

**bwlab, Xpert Tech Agency**
- Website: [www.bwlab.it](https://www.bwlab.it)
- Email: commerciale@bwlab.it
- PrestaShop Partner: [3-star certified](https://experts.prestashop.com/english/experts/partner/2118183/bwlab)
