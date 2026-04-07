{*
* bwhealthcheck - Health Check Report Generator for PrestaShop
*}

<div class="panel">
    <div class="panel-heading">
        <i class="icon icon-heartbeat"></i> {l s='Health Check Report' mod='bwhealthcheck'}
    </div>
    <div class="panel-body">
        <!-- Action Buttons -->
        <div class="row">
            <div class="col-md-12" style="padding-bottom: 25px; margin-bottom: 25px; border-bottom: 1px solid #eee;">
                <form method="post" action="" style="display: inline;">
                    <button type="submit" name="submit_healthcheck_pdf" class="btn btn-primary" style="margin-right: 10px;">
                        <i class="icon icon-file-pdf-o" style="margin-right: 6px;"></i>{l s='Generate PDF Report' mod='bwhealthcheck'}
                    </button>
                    <button type="button" class="btn btn-info" style="margin-right: 10px;" data-toggle="modal" data-target="#bwhealthcheck_modal">
                        <i class="icon icon-envelope" style="margin-right: 6px;"></i>{l s='Send Report to bwlab' mod='bwhealthcheck'}
                    </button>
                    <button type="submit" name="submit_healthcheck_refresh" class="btn btn-default">
                        <i class="icon icon-refresh" style="margin-right: 6px;"></i>{l s='Refresh Data' mod='bwhealthcheck'}
                    </button>
                </form>
            </div>
        </div>

        <style>
            .hc-table td:first-child { width: 40%; }
            .hc-table td:last-child { width: 60%; text-align: left; }
        </style>

        <!-- Section 1: Version Information -->
        <div class="row" style="margin-bottom: 10px; padding-bottom: 15px; border-bottom: 1px solid #eee;">
            <div class="col-md-12">
                <h3>{l s='1. System Information' mod='bwhealthcheck'}</h3>
                <table class="table table-striped hc-table">
                    <tbody>
                        <tr>
                            <td><strong>{l s='PrestaShop Version' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.versions.prestashop}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='PHP Version' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.versions.php}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='MySQL/MariaDB Version' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.versions.mysql}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Latest Stable Version' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.versions.latest_stable}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Section 2: Image Statistics -->
        <div class="row" style="margin-bottom: 10px; padding-bottom: 15px; border-bottom: 1px solid #eee;">
            <div class="col-md-12">
                <h3>{l s='2. Image Statistics' mod='bwhealthcheck'}</h3>
                <table class="table table-striped hc-table">
                    <tbody>
                        <tr>
                            <td><strong>{l s='Total Images' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.images.total_images}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Products with Images' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.images.products_with_images}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Products without Images' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.images.products_without_images}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Average Images per Product' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.images.avg_images_per_product}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Section 3: E-commerce Statistics -->
        <div class="row" style="margin-bottom: 10px; padding-bottom: 15px; border-bottom: 1px solid #eee;">
            <div class="col-md-12">
                <h3>{l s='3. E-commerce Statistics' mod='bwhealthcheck'}</h3>
                <table class="table table-striped hc-table">
                    <tbody>
                        <tr>
                            <td><strong>{l s='Total Orders' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.ecommerce.total_orders}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Total Customers' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.ecommerce.total_customers}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Total Addresses' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.ecommerce.total_addresses}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Anonymous Carts' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.ecommerce.carts_anonymous}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Registered Carts' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.ecommerce.carts_registered}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Avg Order Value (last 3 months)' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.ecommerce.avg_order_value_3m}</td>
                        </tr>
                    </tbody>
                </table>

                <h4>{l s='Languages' mod='bwhealthcheck'}</h4>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>{l s='Name' mod='bwhealthcheck'}</th>
                            <th>{l s='ISO Code' mod='bwhealthcheck'}</th>
                            <th>{l s='Status' mod='bwhealthcheck'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from=$data.ecommerce.languages item=lang}
                        <tr>
                            <td>{$lang.name}</td>
                            <td><code>{$lang.iso_code}</code></td>
                            <td>{if $lang.active}<span class="badge badge-success">{l s='Active' mod='bwhealthcheck'}</span>{else}<span class="badge badge-secondary">{l s='Inactive' mod='bwhealthcheck'}</span>{/if}</td>
                        </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Section 4: Theme -->
        <div class="row" style="margin-bottom: 10px; padding-bottom: 15px; border-bottom: 1px solid #eee;">
            <div class="col-md-12">
                <h3>{l s='4. Active Theme' mod='bwhealthcheck'}</h3>
                <table class="table table-striped hc-table">
                    <tbody>
                        <tr>
                            <td><strong>{l s='Theme Name' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.theme.name}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Theme Version' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.theme.version}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Parent Theme' mod='bwhealthcheck'}</strong></td>
                            <td>{if $data.theme.parent}{$data.theme.parent}{else}—{/if}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Theme Directory' mod='bwhealthcheck'}</strong></td>
                            <td><code>{$data.theme.directory}</code></td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Is Child Theme' mod='bwhealthcheck'}</strong></td>
                            <td>{if $data.theme.is_child_theme}<span class="badge badge-info">{l s='Yes' mod='bwhealthcheck'} — parent: {$data.theme.parent}</span>{else}<span class="badge badge-secondary">{l s='No' mod='bwhealthcheck'}</span>{/if}</td>
                        </tr>
                    </tbody>
                </table>

                {if !empty($data.theme.child_themes)}
                <h4>{l s='Child Themes Found' mod='bwhealthcheck'}</h4>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>{l s='Name' mod='bwhealthcheck'}</th>
                            <th>{l s='Directory' mod='bwhealthcheck'}</th>
                            <th>{l s='Parent' mod='bwhealthcheck'}</th>
                            <th>{l s='Version' mod='bwhealthcheck'}</th>
                            <th>{l s='Status' mod='bwhealthcheck'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from=$data.theme.child_themes item=child}
                        <tr>
                            <td>{$child.name}</td>
                            <td><code>{$child.directory}</code></td>
                            <td>{$child.parent}</td>
                            <td>{$child.version}</td>
                            <td>{if $child.is_active}<span class="badge badge-success">{l s='Active' mod='bwhealthcheck'}</span>{else}<span class="badge badge-secondary">{l s='Inactive' mod='bwhealthcheck'}</span>{/if}</td>
                        </tr>
                        {/foreach}
                    </tbody>
                </table>
                {else}
                <p class="alert alert-success">{l s='No child themes detected.' mod='bwhealthcheck'}</p>
                {/if}
            </div>
        </div>

        <!-- Section 5: Modules -->
        <div class="row" style="margin-bottom: 10px; padding-bottom: 15px; border-bottom: 1px solid #eee;">
            <div class="col-md-12">
                <h3>{l s='5. Modules' mod='bwhealthcheck'}</h3>
                <p>
                    <strong>{l s='Active Modules' mod='bwhealthcheck'}:</strong> {$data.modules.count_active} |
                    <strong>{l s='Inactive Modules' mod='bwhealthcheck'}:</strong> {$data.modules.count_inactive}
                </p>

                {if $data.modules.count_active > 0}
                <h4>{l s='Active Modules' mod='bwhealthcheck'}</h4>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>{l s='Module Name' mod='bwhealthcheck'}</th>
                            <th>{l s='Display Name' mod='bwhealthcheck'}</th>
                            <th>{l s='Version' mod='bwhealthcheck'}</th>
                            <th>{l s='Author' mod='bwhealthcheck'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from=$data.modules.active item=module}
                        <tr>
                            <td><code>{$module.name}</code></td>
                            <td>{$module.display_name}</td>
                            <td>{$module.version}</td>
                            <td>{$module.author}</td>
                        </tr>
                        {/foreach}
                    </tbody>
                </table>
                {/if}

                {if $data.modules.count_inactive > 0}
                <h4>{l s='Inactive Modules' mod='bwhealthcheck'}</h4>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>{l s='Module Name' mod='bwhealthcheck'}</th>
                            <th>{l s='Display Name' mod='bwhealthcheck'}</th>
                            <th>{l s='Version' mod='bwhealthcheck'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from=$data.modules.inactive item=module}
                        <tr>
                            <td><code>{$module.name}</code></td>
                            <td>{$module.display_name}</td>
                            <td>{$module.version}</td>
                        </tr>
                        {/foreach}
                    </tbody>
                </table>
                {/if}
            </div>
        </div>

        <!-- Section 3: Overrides -->
        <div class="row" style="margin-bottom: 10px; padding-bottom: 15px; border-bottom: 1px solid #eee;">
            <div class="col-md-12">
                <h3>{l s='6. System Overrides' mod='bwhealthcheck'}</h3>

                {if !empty($data.overrides.system)}
                <h4>{l s='Core Overrides' mod='bwhealthcheck'}</h4>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>{l s='Class' mod='bwhealthcheck'}</th>
                            <th>{l s='File' mod='bwhealthcheck'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from=$data.overrides.system item=override}
                        <tr>
                            <td><code>{$override.class}</code></td>
                            <td><code>{$override.file}</code></td>
                        </tr>
                        {/foreach}
                    </tbody>
                </table>
                {else}
                <p class="alert alert-success">{l s='No system overrides detected.' mod='bwhealthcheck'}</p>
                {/if}

                {if !empty($data.overrides.by_modules)}
                <h4>{l s='Module Overrides' mod='bwhealthcheck'}</h4>
                {foreach from=$data.overrides.by_modules key=moduleName item=overrides}
                <h5>{l s='Module' mod='bwhealthcheck'}: <code>{$moduleName}</code></h5>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>{l s='Class' mod='bwhealthcheck'}</th>
                            <th>{l s='File' mod='bwhealthcheck'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from=$overrides item=override}
                        <tr>
                            <td><code>{$override.class}</code></td>
                            <td><code>{$override.file}</code></td>
                        </tr>
                        {/foreach}
                    </tbody>
                </table>
                {/foreach}
                {/if}
            </div>
        </div>


        <!-- Last Update Info -->
        <div class="row">
            <div class="col-md-12">
                <p class="text-muted">
                    <small>
                        {l s='Last updated' mod='bwhealthcheck'}: {$data.generated_at}
                    </small>
                </p>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Send Report to bwlab -->
<div class="modal fade" id="bwhealthcheck_modal" tabindex="-1" role="dialog" aria-labelledby="bwhealthcheck_modal_label" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="bwhealthcheck_modal_label">
                    {l s='Send Health Check Report to bwlab' mod='bwhealthcheck'}
                </h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>{l s='Authorize bwlab to analyze your shop data and contact you for free consultation.' mod='bwhealthcheck'}</p>

                <form id="bwhealthcheck_form" method="post">
                    <!-- Email Field -->
                    <div class="form-group">
                        <label for="bwhealthcheck_email">{l s='Email' mod='bwhealthcheck'} <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" id="bwhealthcheck_email" name="email" value="{$admin_email|escape:'html'}" required>
                    </div>

                    <!-- Name Field -->
                    <div class="form-group">
                        <label for="bwhealthcheck_name">{l s='Name' mod='bwhealthcheck'} <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="bwhealthcheck_name" name="name" value="{$admin_name|escape:'html'}" required>
                    </div>

                    <!-- Company Field -->
                    <div class="form-group">
                        <label for="bwhealthcheck_company">{l s='Company' mod='bwhealthcheck'} <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="bwhealthcheck_company" name="company" value="{$shop_name|escape:'html'}" required>
                    </div>

                    <!-- Phone Field (optional) -->
                    <div class="form-group">
                        <label for="bwhealthcheck_phone">{l s='Phone' mod='bwhealthcheck'} <span class="text-danger">*</span></label>
                        <input type="tel" class="form-control" id="bwhealthcheck_phone" name="phone" value="" required>
                    </div>

                    <!-- Privacy Checkbox -->
                    <div class="form-group">
                        <div class="custom-control custom-checkbox">
                            <input type="checkbox" class="custom-control-input" id="bwhealthcheck_privacy" name="privacy" required>
                            <label class="custom-control-label" for="bwhealthcheck_privacy">
                                {l s='I have read and accept the' mod='bwhealthcheck'}
                                <a href="https://www.bwlab.it/articoli/privacy-policy" target="_blank" rel="noopener">
                                    {l s='Privacy Policy' mod='bwhealthcheck'}
                                </a>
                                <span class="text-danger">*</span>
                            </label>
                        </div>
                    </div>

                    <!-- Hidden token for CSRF -->
                    <input type="hidden" name="token" value="{$token|escape:'html'}">
                    <input type="hidden" name="action" value="send_report">
                </form>

                <!-- Success/Error Message -->
                <div id="bwhealthcheck_message" class="alert" role="alert" style="display:none;"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">
                    {l s='Cancel' mod='bwhealthcheck'}
                </button>
                <button type="button" class="btn btn-primary" id="bwhealthcheck_submit" disabled>
                    {l s='Send Report' mod='bwhealthcheck'}
                </button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
(function($) {
    'use strict';

    $(document).ready(function() {
        var $modal = $('#bwhealthcheck_modal');
        var $form = $('#bwhealthcheck_form');
        var $privacyCheckbox = $('#bwhealthcheck_privacy');
        var $submitBtn = $('#bwhealthcheck_submit');
        var $messageDiv = $('#bwhealthcheck_message');

        // Enable/disable submit button based on privacy checkbox
        $privacyCheckbox.on('change', function() {
            $submitBtn.prop('disabled', !this.checked);
        });

        // Handle form submission
        $submitBtn.on('click', function() {
            // Basic validation
            var email = $('#bwhealthcheck_email').val().trim();
            var name = $('#bwhealthcheck_name').val().trim();
            var company = $('#bwhealthcheck_company').val().trim();

            var phone = $('#bwhealthcheck_phone').val().trim();

            if (!email || !name || !company || !phone) {
                $messageDiv.removeClass('alert-success').addClass('alert-danger').show();
                $messageDiv.text('{l s="Please fill all required fields" mod="bwhealthcheck"}');
                return;
            }

            if (!$privacyCheckbox.prop('checked')) {
                $messageDiv.removeClass('alert-success').addClass('alert-danger').show();
                $messageDiv.text('{l s="You must accept the privacy policy" mod="bwhealthcheck"}');
                return;
            }

            // Disable submit button while processing
            $submitBtn.prop('disabled', true).html('<i class="icon icon-spinner icon-spin"></i> {l s="Sending..." mod="bwhealthcheck"}');

            // Send AJAX request
            $.ajax({
                type: 'POST',
                url: '{$ajax_url|escape:'javascript'}',
                dataType: 'json',
                data: $form.serialize(),
                success: function(response) {
                    if (response.success) {
                        $messageDiv.removeClass('alert-danger').addClass('alert-success').show();
                        $messageDiv.html('<strong>{l s="Success!" mod="bwhealthcheck"}</strong> ' + response.message);

                        // Reset form after 3 seconds
                        setTimeout(function() {
                            $form[0].reset();
                            $privacyCheckbox.prop('checked', false);
                            $submitBtn.prop('disabled', true).html('{l s="Send Report" mod="bwhealthcheck"}');
                            $modal.modal('hide');
                        }, 3000);
                    } else {
                        $messageDiv.removeClass('alert-success').addClass('alert-danger').show();
                        $messageDiv.html('<strong>{l s="Error!" mod="bwhealthcheck"}</strong> ' + response.message);
                        $submitBtn.prop('disabled', !$privacyCheckbox.prop('checked')).html('{l s="Send Report" mod="bwhealthcheck"}');
                    }
                },
                error: function() {
                    $messageDiv.removeClass('alert-success').addClass('alert-danger').show();
                    $messageDiv.text('{l s="An error occurred while sending the report" mod="bwhealthcheck"}');
                    $submitBtn.prop('disabled', !$privacyCheckbox.prop('checked')).html('{l s="Send Report" mod="bwhealthcheck"}');
                }
            });
        });
    });
})(jQuery);
</script>
