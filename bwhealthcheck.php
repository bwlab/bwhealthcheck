<?php
/**
 * bwhealthcheck - Health Check Report Generator for PrestaShop
 *
 * @author bwlab <info@bwlab.it>
 * @link https://www.bwlab.it
 * @license Academic Free License (AFL 3.0)
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

require_once __DIR__ . '/classes/HealthCheckCollector.php';
require_once __DIR__ . '/classes/HealthCheckPdfGenerator.php';

class BwHealthCheck extends Module
{
    const TCPDF_PATH = __DIR__ . '/vendor/tcpdf/';
    const CACHE_LIFETIME = 3600; // 1 hour

    public function __construct()
    {
        $this->name = 'bwhealthcheck';
        $this->tab = 'administration';
        $this->version = '1.1.1';
        $this->author = 'bwlab, Xpert Tech Agency';
        $this->need_instance = 1;
        $this->ps_versions_compliancy = array('min' => '1.7.0.0', 'max' => _PS_VERSION_);
        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->trans('Health Check Report Generator', array(), 'Modules.Bwhealthcheck.Admin');
        $this->description = $this->trans('Generate a comprehensive health check report of your PrestaShop installation', array(), 'Modules.Bwhealthcheck.Admin');
        $this->confirmUninstall = $this->trans('Are you sure?', array(), 'Modules.Bwhealthcheck.Admin');
    }

    /**
     * Install module
     */
    public function install()
    {
        if (Shop::isFeatureActive()) {
            Shop::setContext(Shop::CONTEXT_ALL);
        }

        return parent::install();
    }

    /**
     * Uninstall module
     */
    public function uninstall()
    {
        return parent::uninstall();
    }

    /**
     * Get module configuration page content
     */
    public function getContent()
    {
        $output = '';

        // Handle form submissions
        if (Tools::isSubmit('submit_healthcheck_pdf')) {
            $this->postProcess();
        }

        // Handle AJAX request for sending report
        if (Tools::getValue('action') === 'send_report' && Tools::isSubmit('token')) {
            $this->handleSendReport();
        }

        // Load collector to get data
        $collector = new HealthCheckCollector();

        // Check if data needs refresh
        if (Tools::isSubmit('submit_healthcheck_refresh')) {
            // Force refresh by not using cache
            $data = $collector->collectAllData(true);
            $output .= $this->displayConfirmation($this->trans('Data refreshed successfully', array(), 'Modules.Bwhealthcheck.Admin'));
        } else {
            $data = $collector->collectAllData(false);
        }

        // Get admin info for modal preload
        $context = Context::getContext();
        $employee = $context->employee;

        // Render template
        $this->context->smarty->assign(array(
            'data' => $data,
            'module_name' => $this->name,
            'ps_version' => _PS_VERSION_,
            'php_version' => phpversion(),
            'admin_email' => $employee->email,
            'admin_name' => $employee->firstname . ' ' . $employee->lastname,
            'shop_name' => Configuration::get('PS_SHOP_NAME'),
            'token' => Tools::getAdminTokenLite('AdminModules'),
            'ajax_url' => $this->context->link->getAdminLink('AdminModules') . '&configure=' . $this->name . '&tab=admin_modules',
        ));

        return $output . $this->display(__FILE__, 'views/templates/admin/configure.tpl');
    }

    /**
     * Process form submission (generate PDF)
     */
    public function postProcess()
    {
        $output = '';

        // Generate PDF
        if (Tools::isSubmit('submit_healthcheck_pdf')) {
            try {
                $collector = new HealthCheckCollector();
                $data = $collector->collectAllData(false);
                $generator = new HealthCheckPdfGenerator();
                $generator->generate($data);
            } catch (Exception $e) {
                $output .= $this->displayError($this->trans('Error generating PDF: %s', array($e->getMessage()), 'Modules.Bwhealthcheck.Admin'));
            }
        }

        return $output;
    }

    /**
     * Handle AJAX request to send report to bwlab
     */
    public function handleSendReport()
    {
        // Verify CSRF token
        $token = Tools::getValue('token', '');
        if ($token !== Tools::getAdminTokenLite('AdminModules')) {
            $this->ajaxResponse(false, $this->trans('Invalid security token', array(), 'Modules.Bwhealthcheck.Admin'));
        }

        // Validate input
        $email = Tools::getValue('email', '');
        $name = Tools::getValue('name', '');
        $company = Tools::getValue('company', '');
        $phone = Tools::getValue('phone', '');

        if (!$email || !$name || !$company || !$phone || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $this->ajaxResponse(false, $this->trans('Please provide valid email, name, company and phone', array(), 'Modules.Bwhealthcheck.Admin'));
        }

        try {
            // Generate health check data
            $collector = new HealthCheckCollector();
            $data = $collector->collectAllData(false);

            // Create temporary JSON file
            $tmpDir = _PS_ROOT_DIR_ . '/var/cache/';
            if (!is_dir($tmpDir)) {
                mkdir($tmpDir, 0755, true);
            }
            $jsonFile = $tmpDir . 'healthcheck_' . time() . '.json';
            file_put_contents($jsonFile, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));

            // Prepare email data
            $shopName = Configuration::get('PS_SHOP_NAME');
            $shopDomain = Configuration::get('PS_SHOP_DOMAIN');
            $subject = $this->trans('Health Check Report - %s (%s)', array($shopName, $shopDomain), 'Modules.Bwhealthcheck.Admin');

            // Prepare email body
            $emailBody = "Nuovo Health Check Report ricevuto:\n\n";
            $emailBody .= "Nome: " . pSQL($name) . "\n";
            $emailBody .= "Email: " . pSQL($email) . "\n";
            $emailBody .= "Società: " . pSQL($company) . "\n";
            $emailBody .= "Telefono: " . (pSQL($phone) ?: 'Non fornito') . "\n";
            $emailBody .= "Shop: " . pSQL($shopName) . "\n";
            $emailBody .= "Dominio: " . pSQL($shopDomain) . "\n";
            $emailBody .= "Data: " . date('Y-m-d H:i:s') . "\n\n";
            $emailBody .= "I dati completi del report sono allegati in formato JSON.\n";

            // Prepare attachments - Mail::send expects array of arrays with content/name/mime
            $jsonContent = file_get_contents($jsonFile);
            $attachments = array(
                array(
                    'content' => $jsonContent,
                    'name' => 'healthcheck_' . $shopDomain . '_' . date('Y-m-d') . '.json',
                    'mime' => 'application/json',
                ),
            );

            // Send email using PrestaShop Mail::send()
            $result = Mail::send(
                Context::getContext()->language->id,
                'contact',
                $subject,
                array('{message}' => nl2br($emailBody), '{email}' => $email),
                'commerciale@bwlab.it',
                'bwlab',
                Configuration::get('PS_SHOP_EMAIL'),
                Configuration::get('PS_SHOP_NAME'),
                $attachments
            );

            // Clean up temporary file
            if (file_exists($jsonFile)) {
                unlink($jsonFile);
            }

            if ($result) {
                $this->ajaxResponse(true, $this->trans('Report sent successfully. We will contact you soon!', array(), 'Modules.Bwhealthcheck.Admin'));
            } else {
                $this->ajaxResponse(false, $this->trans('Error sending email. Please try again later.', array(), 'Modules.Bwhealthcheck.Admin'));
            }
        } catch (Exception $e) {
            $this->ajaxResponse(false, $this->trans('An error occurred: %s', array($e->getMessage()), 'Modules.Bwhealthcheck.Admin'));
        }
    }

    /**
     * Send JSON response for AJAX requests
     */
    private function ajaxResponse($success, $message)
    {
        header('Content-Type: application/json');
        echo json_encode(array(
            'success' => (bool)$success,
            'message' => $message,
        ));
        exit;
    }

    /**
     * Translate helper
     */
    public function trans($string, $params = array(), $domain = null, $locale = null)
    {
        if ($domain === null) {
            $domain = 'Modules.Bwhealthcheck.Admin';
        }

        return parent::trans($string, $params, $domain, $locale);
    }
}
