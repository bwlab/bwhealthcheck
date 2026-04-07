<?php
/**
 * HealthCheckCollector - Collects all system data for health check
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

class HealthCheckCollector
{
    const CACHE_DIR = _PS_ROOT_DIR_ . '/var/cache/healthcheck/';
    const CACHE_FILE = 'healthcheck_data.json';
    const CACHE_LIFETIME = 3600; // 1 hour

    /**
     * Collect all data for health check report
     *
     * @param bool $force Force refresh, ignore cache
     * @return array Complete health check data
     */
    public function collectAllData($force = false)
    {
        $data = array();

        if (!$force && $this->isCacheValid()) {
            return json_decode(file_get_contents($this->getCacheFilePath()), true);
        }

        // Section 1: Version Info
        $data['versions'] = $this->getVersionsInfo();

        // Section 2: Modules
        $data['modules'] = $this->getModulesInfo();

        // Section 3: Overrides
        $data['overrides'] = $this->getOverridesInfo();

        // Section 4: Theme
        $data['theme'] = $this->getThemeInfo();

        // Section 5: Product Images
        $data['images'] = $this->getImagesInfo();

        // Section 6: E-commerce Statistics
        $data['ecommerce'] = $this->getEcommerceStats();

        // Metadata
        $data['generated_at'] = date('Y-m-d H:i:s');
        $data['shop_url'] = Configuration::get('PS_SHOP_DOMAIN');

        // Cache the data
        $this->cacheData($data);

        return $data;
    }

    /**
     * Get versions information
     */
    private function getVersionsInfo()
    {
        $info = array(
            'prestashop' => _PS_VERSION_,
            'php' => phpversion(),
            'mysql' => $this->getMySQLVersion(),
            'latest_stable' => '9.0.0', // Hardcoded, update per release
        );

        return $info;
    }

    /**
     * Get MySQL/MariaDB version
     */
    private function getMySQLVersion()
    {
        try {
            $result = Db::getInstance()->executeS('SELECT VERSION() as version');
            return isset($result[0]['version']) ? $result[0]['version'] : 'Unknown';
        } catch (Exception $e) {
            return 'Unknown';
        }
    }

    /**
     * Get modules information
     */
    private function getModulesInfo()
    {
        $modules = array(
            'active' => array(),
            'inactive' => array(),
            'count_active' => 0,
            'count_inactive' => 0,
        );

        try {
            $results = Db::getInstance()->executeS(
                'SELECT m.id_module, m.name, m.version, m.active
                FROM ' . _DB_PREFIX_ . 'module m
                INNER JOIN ' . _DB_PREFIX_ . 'module_shop ms ON m.id_module = ms.id_module
                WHERE ms.id_shop = ' . (int)Context::getContext()->shop->id .
                ' ORDER BY m.name ASC'
            );

            if ($results) {
                foreach ($results as $module) {
                    $moduleInstance = Module::getInstanceByName($module['name']);
                    $moduleInfo = array(
                        'name' => $module['name'],
                        'version' => $module['version'] ?: 'Unknown',
                        'author' => ($moduleInstance ? $moduleInstance->author : 'Unknown'),
                        'display_name' => ($moduleInstance ? $moduleInstance->displayName : $module['name']),
                    );

                    if ($module['active']) {
                        $modules['active'][] = $moduleInfo;
                        $modules['count_active']++;
                    } else {
                        $modules['inactive'][] = $moduleInfo;
                        $modules['count_inactive']++;
                    }
                }
            }
        } catch (Exception $e) {
            // Silent fail, return empty
        }

        return $modules;
    }

    /**
     * Get module display name (tab name)
     */
    private function getModuleDisplayName($moduleName)
    {
        try {
            $result = Db::getInstance()->executeS(
                'SELECT name FROM ' . _DB_PREFIX_ . 'module_lang
                WHERE id_module = (SELECT id_module FROM ' . _DB_PREFIX_ . 'module WHERE name = "' . pSQL($moduleName) . '")
                LIMIT 1'
            );
            return isset($result[0]['name']) ? $result[0]['name'] : $moduleName;
        } catch (Exception $e) {
            return $moduleName;
        }
    }

    /**
     * Get overrides information
     */
    private function getOverridesInfo()
    {
        $overrides = array(
            'system' => array(),
            'by_modules' => array(),
        );

        // System overrides in /override/
        $overrides['system'] = $this->scanOverridesDir(_PS_ROOT_DIR_ . '/override/');

        // Module overrides
        $moduleDir = _PS_ROOT_DIR_ . '/modules/';
        if (is_dir($moduleDir)) {
            $modules = array_diff(scandir($moduleDir), array('.', '..'));
            foreach ($modules as $module) {
                $moduleOverridePath = $moduleDir . $module . '/override/';
                if (is_dir($moduleOverridePath)) {
                    $moduleOverrides = $this->scanOverridesDir($moduleOverridePath);
                    if (!empty($moduleOverrides)) {
                        $overrides['by_modules'][$module] = $moduleOverrides;
                    }
                }
            }
        }

        return $overrides;
    }

    /**
     * Scan override directory recursively
     */
    private function scanOverridesDir($basePath)
    {
        $overrides = array();

        if (!is_dir($basePath)) {
            return $overrides;
        }

        $this->scanDir($basePath, '', $overrides, $basePath);

        return $overrides;
    }

    /**
     * Recursive directory scanner for overrides
     */
    private function scanDir($path, $prefix, &$result, $basePath)
    {
        $files = scandir($path);
        foreach ($files as $file) {
            if ($file === '.' || $file === '..' || $file === 'index.php') {
                continue;
            }

            $fullPath = $path . $file;
            $relativePath = str_replace($basePath, '', $fullPath);

            if (is_dir($fullPath)) {
                $this->scanDir($fullPath . '/', $prefix, $result, $basePath);
            } elseif (pathinfo($file, PATHINFO_EXTENSION) === 'php') {
                // Extract class name from file
                $className = $this->extractClassName($fullPath);
                if ($className) {
                    $result[] = array(
                        'class' => $className,
                        'file' => $relativePath,
                    );
                }
            }
        }
    }

    /**
     * Extract class name from PHP file
     */
    private function extractClassName($filePath)
    {
        $content = file_get_contents($filePath);
        if (preg_match('/class\s+(\w+)/i', $content, $matches)) {
            return $matches[1];
        }
        return null;
    }

    /**
     * Get theme information
     */
    private function getThemeInfo()
    {
        $themeInfo = array(
            'name' => 'Unknown',
            'version' => 'Unknown',
            'parent' => null,
            'directory' => 'Unknown',
            'is_child_theme' => false,
            'child_themes' => array(),
        );

        try {
            // PS 8.x: theme_name from Shop object, no ps_theme table
            $shop = Context::getContext()->shop;
            $themeName = '';
            if (!empty($shop->theme_name)) {
                $themeName = $shop->theme_name;
            } elseif (!empty($shop->theme) && method_exists($shop->theme, 'getName')) {
                $themeName = $shop->theme->getName();
            }

            if ($themeName) {
                $themeInfo['directory'] = $themeName;
                $themePath = _PS_ROOT_DIR_ . '/themes/' . $themeName . '/';
                $configFile = $themePath . 'config/theme.yml';

                if (file_exists($configFile)) {
                    $config = $this->parseYaml($configFile);
                    if (isset($config['display_name'])) {
                        $themeInfo['name'] = $config['display_name'];
                    } elseif (isset($config['name'])) {
                        $themeInfo['name'] = $config['name'];
                    } else {
                        $themeInfo['name'] = $themeName;
                    }
                    if (isset($config['version'])) {
                        $themeInfo['version'] = $config['version'];
                    }
                    if (isset($config['parent'])) {
                        $themeInfo['parent'] = $config['parent'];
                        $themeInfo['is_child_theme'] = true;
                    }
                } else {
                    $themeInfo['name'] = $themeName;
                }

                // Scan all themes to find child themes
                $themesDir = _PS_ROOT_DIR_ . '/themes/';
                if (is_dir($themesDir)) {
                    $dirs = glob($themesDir . '*', GLOB_ONLYDIR);
                    foreach ($dirs as $dir) {
                        $dirName = basename($dir);
                        $childConfig = $dir . '/config/theme.yml';
                        if (file_exists($childConfig)) {
                            $childParsed = $this->parseYaml($childConfig);
                            if (!empty($childParsed['parent'])) {
                                $childInfo = array(
                                    'name' => isset($childParsed['name']) ? $childParsed['name'] : $dirName,
                                    'directory' => $dirName,
                                    'parent' => $childParsed['parent'],
                                    'version' => isset($childParsed['version']) ? $childParsed['version'] : 'Unknown',
                                    'is_active' => ($dirName === $themeName),
                                );
                                $themeInfo['child_themes'][] = $childInfo;
                            }
                        }
                    }
                }
            }
        } catch (Exception $e) {
            // Silent fail
        }

        return $themeInfo;
    }

    /**
     * Simple YAML parser for theme.yml
     */
    private function parseYaml($filePath)
    {
        $config = array();
        $content = file_get_contents($filePath);
        $lines = explode("\n", $content);

        foreach ($lines as $line) {
            $line = trim($line);
            if (empty($line) || strpos($line, '#') === 0) {
                continue;
            }

            if (preg_match('/^(\w+):\s*(.+)$/', $line, $matches)) {
                $key = strtolower($matches[1]);
                $value = trim($matches[2], '\'" ');
                $config[$key] = $value;
            }
        }

        return $config;
    }

    /**
     * Get product images information
     */
    private function getImagesInfo()
    {
        $info = array(
            'total_images' => 0,
            'products_with_images' => 0,
            'products_without_images' => 0,
            'avg_images_per_product' => 0,
        );

        try {
            // Total images
            $result = Db::getInstance()->executeS(
                'SELECT COUNT(*) as count FROM ' . _DB_PREFIX_ . 'image'
            );
            $info['total_images'] = (int)$result[0]['count'];

            // Products with images
            $result = Db::getInstance()->executeS(
                'SELECT COUNT(DISTINCT id_product) as count FROM ' . _DB_PREFIX_ . 'image'
            );
            $info['products_with_images'] = (int)$result[0]['count'];

            // Total products
            $result = Db::getInstance()->executeS(
                'SELECT COUNT(*) as count FROM ' . _DB_PREFIX_ . 'product p
                WHERE p.active = 1'
            );
            $totalProducts = (int)$result[0]['count'];

            // Products without images
            $info['products_without_images'] = max(0, $totalProducts - $info['products_with_images']);

            // Average images per product
            if ($info['products_with_images'] > 0) {
                $info['avg_images_per_product'] = round($info['total_images'] / $info['products_with_images'], 2);
            }
        } catch (Exception $e) {
            // Silent fail
        }

        return $info;
    }

    /**
     * Get e-commerce statistics
     */
    private function getEcommerceStats()
    {
        $stats = array(
            'total_orders' => 0,
            'total_customers' => 0,
            'total_addresses' => 0,
            'carts_anonymous' => 0,
            'carts_registered' => 0,
            'avg_order_value_3m' => '0.00',
            'languages' => array(),
        );

        try {
            $result = Db::getInstance()->getRow(
                'SELECT COUNT(*) as cnt FROM ' . _DB_PREFIX_ . 'orders'
            );
            $stats['total_orders'] = (int)$result['cnt'];

            $result = Db::getInstance()->getRow(
                'SELECT COUNT(*) as cnt FROM ' . _DB_PREFIX_ . 'customer WHERE deleted = 0'
            );
            $stats['total_customers'] = (int)$result['cnt'];

            $result = Db::getInstance()->getRow(
                'SELECT COUNT(*) as cnt FROM ' . _DB_PREFIX_ . 'address WHERE deleted = 0'
            );
            $stats['total_addresses'] = (int)$result['cnt'];

            // Carts: anonymous (id_customer = 0) vs registered
            $result = Db::getInstance()->getRow(
                'SELECT
                    SUM(CASE WHEN id_customer = 0 THEN 1 ELSE 0 END) as anonymous,
                    SUM(CASE WHEN id_customer > 0 THEN 1 ELSE 0 END) as registered
                FROM ' . _DB_PREFIX_ . 'cart'
            );
            $stats['carts_anonymous'] = (int)$result['anonymous'];
            $stats['carts_registered'] = (int)$result['registered'];

            // Average order value last 3 months
            $threeMonthsAgo = date('Y-m-d H:i:s', strtotime('-3 months'));
            $result = Db::getInstance()->getRow(
                'SELECT ROUND(AVG(total_paid_tax_incl), 2) as avg_val
                FROM ' . _DB_PREFIX_ . 'orders
                WHERE valid = 1 AND date_add >= \'' . pSQL($threeMonthsAgo) . '\''
            );
            if ($result && $result['avg_val'] !== null) {
                $stats['avg_order_value_3m'] = $result['avg_val'];
            }

            $langs = Db::getInstance()->executeS(
                'SELECT l.name, l.iso_code, l.active FROM ' . _DB_PREFIX_ . 'lang l ORDER BY l.active DESC, l.name ASC'
            );
            if ($langs) {
                foreach ($langs as $lang) {
                    $stats['languages'][] = array(
                        'name' => $lang['name'],
                        'iso_code' => $lang['iso_code'],
                        'active' => (bool)$lang['active'],
                    );
                }
            }
        } catch (Exception $e) {
            // Silent fail
        }

        return $stats;
    }

    /**
     * Check if cache is still valid
     */
    private function isCacheValid()
    {
        $cacheFile = $this->getCacheFilePath();
        if (!file_exists($cacheFile)) {
            return false;
        }

        $fileTime = filemtime($cacheFile);
        return (time() - $fileTime) < self::CACHE_LIFETIME;
    }

    /**
     * Get cache file path
     */
    private function getCacheFilePath()
    {
        if (!is_dir(self::CACHE_DIR)) {
            @mkdir(self::CACHE_DIR, 0755, true);
        }
        return self::CACHE_DIR . self::CACHE_FILE;
    }

    /**
     * Cache data to file
     */
    private function cacheData($data)
    {
        try {
            $cacheFile = $this->getCacheFilePath();
            file_put_contents($cacheFile, json_encode($data));
        } catch (Exception $e) {
            // Silent fail, caching is optional
        }
    }
}
