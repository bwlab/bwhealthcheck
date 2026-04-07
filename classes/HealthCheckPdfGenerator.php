<?php
/**
 * HealthCheckPdfGenerator - Generates PDF report from health check data
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

class HealthCheckPdfGenerator
{
    private $pdf;
    private $data;
    private $shopName;

    /**
     * Generate and download PDF report
     */
    public function generate($data)
    {
        $this->data = $data;
        $this->shopName = Configuration::get('PS_SHOP_NAME');

        require_once(dirname(__FILE__) . '/../vendor/tcpdf/tcpdf.php');

        $this->pdf = new TCPDF('P', 'mm', 'A4', true, 'UTF-8', false);

        $this->pdf->setCreator('bwlab Health Check');
        $this->pdf->setAuthor($this->shopName);
        $this->pdf->setTitle('Health Check Report');
        $this->pdf->setPrintHeader(false);
        $this->pdf->setPrintFooter(false);
        $this->pdf->setMargins(15, 15, 15);
        $this->pdf->setAutoPageBreak(true, 15);
        $this->pdf->addPage();

        $html = $this->buildHtml();
        $this->pdf->writeHTML($html, true, false, true, false, '');

        $filename = 'healthcheck_' . date('Y-m-d_H-i-s') . '.pdf';
        $this->pdf->output($filename, 'D');
        exit;
    }

    private function buildHtml()
    {
        $d = $this->data;
        $shopUrl = htmlspecialchars($d['shop_url']);
        $shopName = htmlspecialchars($this->shopName);
        $date = htmlspecialchars($d['generated_at']);

        $html = '
        <style>
            h1 { font-size: 18px; color: #1a1a1a; text-align: center; }
            h2 { font-size: 13px; color: #ffffff; background-color: #2563eb; padding: 4px 8px; }
            h3 { font-size: 11px; color: #333; margin-top: 6px; }
            .subtitle { font-size: 10px; color: #666; text-align: center; line-height: 1.6; }
            table { border-collapse: collapse; }
            .tbl { width: 100%; font-size: 8px; }
            .tbl td, .tbl th { border: 1px solid #ccc; padding: 3px 5px; }
            .tbl th { background-color: #f0f0f0; font-weight: bold; }
            .tbl tr.alt { background-color: #f9f9f9; }
            .info-tbl { width: 100%; font-size: 9px; }
            .info-tbl td { border: 1px solid #ccc; padding: 4px 6px; }
            .info-tbl .label { background-color: #f0f0f0; font-weight: bold; width: 40%; }
            .footer { font-size: 8px; color: #999; text-align: center; margin-top: 10px; }
            .none { font-size: 9px; color: #38a169; font-style: italic; }
        </style>';

        // Header
        $html .= '<h1>Health Check Report</h1>';
        $html .= '<p class="subtitle">' . $shopName . '<br/>' . $shopUrl . '<br/>' . $date . '</p><br/>';

        // Section 1: System Info
        $html .= '<h2>1. System Information</h2>';
        $html .= '<table class="info-tbl">';
        $html .= $this->infoRow('PrestaShop Version', $d['versions']['prestashop']);
        $html .= $this->infoRow('PHP Version', $d['versions']['php']);
        $html .= $this->infoRow('MySQL/MariaDB', $d['versions']['mysql']);
        $html .= $this->infoRow('Latest Stable', $d['versions']['latest_stable']);
        $html .= $this->infoRow('Active Modules', $d['modules']['count_active']);
        $html .= $this->infoRow('Inactive Modules', $d['modules']['count_inactive']);
        $html .= $this->infoRow('Theme', $d['theme']['name'] . ' (' . $d['theme']['version'] . ')');
        $html .= '</table><br/>';

        // Section 2: Image Statistics
        $html .= '<h2>2. Image Statistics</h2>';
        $html .= '<table class="info-tbl">';
        $html .= $this->infoRow('Total Images', $d['images']['total_images']);
        $html .= $this->infoRow('Products with Images', $d['images']['products_with_images']);
        $html .= $this->infoRow('Products without Images', $d['images']['products_without_images']);
        $html .= $this->infoRow('Avg Images per Product', $d['images']['avg_images_per_product']);
        $html .= '</table><br/>';

        // Section 3: E-commerce Statistics
        $html .= '<h2>3. E-commerce Statistics</h2>';
        $html .= '<table class="info-tbl">';
        $html .= $this->infoRow('Total Orders', $d['ecommerce']['total_orders']);
        $html .= $this->infoRow('Total Customers', $d['ecommerce']['total_customers']);
        $html .= $this->infoRow('Total Addresses', $d['ecommerce']['total_addresses']);
        $html .= $this->infoRow('Anonymous Carts', $d['ecommerce']['carts_anonymous']);
        $html .= $this->infoRow('Registered Carts', $d['ecommerce']['carts_registered']);
        $html .= $this->infoRow('Avg Order Value (3 months)', $d['ecommerce']['avg_order_value_3m']);
        $html .= '</table>';
        if (!empty($d['ecommerce']['languages'])) {
            $html .= '<h3>Languages</h3>';
            $html .= '<table class="tbl"><tr><th>Name</th><th>ISO Code</th><th>Status</th></tr>';
            foreach ($d['ecommerce']['languages'] as $lang) {
                $status = !empty($lang['active']) ? 'Active' : 'Inactive';
                $html .= '<tr><td>' . htmlspecialchars($lang['name']) . '</td>';
                $html .= '<td>' . htmlspecialchars($lang['iso_code']) . '</td>';
                $html .= '<td>' . $status . '</td></tr>';
            }
            $html .= '</table>';
        }
        $html .= '<br/>';

        // Section 4: Theme
        $html .= '<h2>4. Theme</h2>';
        $html .= '<table class="info-tbl">';
        $html .= $this->infoRow('Name', $d['theme']['name']);
        $html .= $this->infoRow('Version', $d['theme']['version']);
        $html .= $this->infoRow('Parent', $d['theme']['parent'] ?: '—');
        $html .= $this->infoRow('Directory', $d['theme']['directory']);
        $html .= $this->infoRow('Is Child Theme', !empty($d['theme']['is_child_theme']) ? 'Yes (parent: ' . $d['theme']['parent'] . ')' : 'No');
        $html .= '</table>';
        if (!empty($d['theme']['child_themes'])) {
            $html .= '<h3>Child Themes Found</h3>';
            $html .= '<table class="tbl"><tr><th>Name</th><th>Directory</th><th>Parent</th><th>Version</th><th>Status</th></tr>';
            foreach ($d['theme']['child_themes'] as $child) {
                $status = !empty($child['is_active']) ? '<b>Active</b>' : 'Inactive';
                $html .= '<tr><td>' . htmlspecialchars($child['name']) . '</td>';
                $html .= '<td>' . htmlspecialchars($child['directory']) . '</td>';
                $html .= '<td>' . htmlspecialchars($child['parent']) . '</td>';
                $html .= '<td>' . htmlspecialchars($child['version']) . '</td>';
                $html .= '<td>' . $status . '</td></tr>';
            }
            $html .= '</table>';
        } else {
            $html .= '<p class="none">No child themes detected</p>';
        }
        $html .= '<br/>';

        // Section 5: Active Modules
        $html .= '<h2>5. Active Modules (' . (int)$d['modules']['count_active'] . ')</h2>';
        if (!empty($d['modules']['active'])) {
            $html .= '<table class="tbl"><tr><th>Module</th><th>Display Name</th><th>Version</th><th>Author</th></tr>';
            $i = 0;
            foreach ($d['modules']['active'] as $m) {
                $alt = ($i++ % 2) ? ' class="alt"' : '';
                $html .= '<tr' . $alt . '><td>' . htmlspecialchars($m['name']) . '</td>';
                $html .= '<td>' . htmlspecialchars($m['display_name']) . '</td>';
                $html .= '<td>' . htmlspecialchars($m['version']) . '</td>';
                $html .= '<td>' . htmlspecialchars($m['author']) . '</td></tr>';
            }
            $html .= '</table><br/>';
        } else {
            $html .= '<p class="none">No active modules</p>';
        }

        // Section 3: Inactive Modules
        $html .= '<h2>6. Inactive Modules (' . (int)$d['modules']['count_inactive'] . ')</h2>';
        if (!empty($d['modules']['inactive'])) {
            $html .= '<table class="tbl"><tr><th>Module</th><th>Display Name</th><th>Version</th></tr>';
            $i = 0;
            foreach ($d['modules']['inactive'] as $m) {
                $alt = ($i++ % 2) ? ' class="alt"' : '';
                $html .= '<tr' . $alt . '><td>' . htmlspecialchars($m['name']) . '</td>';
                $html .= '<td>' . htmlspecialchars($m['display_name']) . '</td>';
                $html .= '<td>' . htmlspecialchars($m['version']) . '</td></tr>';
            }
            $html .= '</table><br/>';
        } else {
            $html .= '<p class="none">No inactive modules</p>';
        }

        // Section 4: System Overrides
        $html .= '<h2>7. System Overrides</h2>';
        if (!empty($d['overrides']['system'])) {
            $html .= '<table class="tbl"><tr><th>Class</th><th>File</th></tr>';
            foreach ($d['overrides']['system'] as $o) {
                $html .= '<tr><td>' . htmlspecialchars($o['class']) . '</td>';
                $html .= '<td>' . htmlspecialchars($o['file']) . '</td></tr>';
            }
            $html .= '</table><br/>';
        } else {
            $html .= '<p class="none">No system overrides detected</p>';
        }

        // Section 5: Module Overrides
        $html .= '<h2>8. Module Overrides</h2>';
        if (!empty($d['overrides']['by_modules'])) {
            foreach ($d['overrides']['by_modules'] as $modName => $overrides) {
                $html .= '<h3>' . htmlspecialchars($modName) . '</h3>';
                $html .= '<table class="tbl"><tr><th>Class</th><th>File</th></tr>';
                foreach ($overrides as $o) {
                    $html .= '<tr><td>' . htmlspecialchars($o['class']) . '</td>';
                    $html .= '<td>' . htmlspecialchars($o['file']) . '</td></tr>';
                }
                $html .= '</table>';
            }
            $html .= '<br/>';
        } else {
            $html .= '<p class="none">No module overrides detected</p>';
        }

        // Footer
        $html .= '<p class="footer">Report generated by bwlab Health Check &mdash; www.bwlab.it</p>';

        return $html;
    }

    private function infoRow($label, $value)
    {
        return '<tr><td class="label">' . htmlspecialchars($label) . '</td><td>' . htmlspecialchars((string)$value) . '</td></tr>';
    }
}
