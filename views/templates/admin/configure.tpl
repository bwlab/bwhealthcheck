{*
* bwhealthcheck - Health Check Report Generator for PrestaShop
*}

<div class="panel">
    <div class="panel-heading">
        <i class="icon icon-heartbeat"></i> {l s='Report Stato di Salute' mod='bwhealthcheck'}
    </div>
    <div class="panel-body">
        <!-- Action Buttons -->
        <div class="row">
            <div class="col-md-12" style="padding-bottom: 25px; margin-bottom: 25px; border-bottom: 1px solid #eee;">
                <form method="post" action="" style="display: inline;">
                    <button type="submit" name="submit_healthcheck_pdf" class="btn btn-primary" style="margin-right: 10px;">
                        <i class="icon icon-file-pdf-o" style="margin-right: 6px;"></i>{l s='Genera Report PDF' mod='bwhealthcheck'}
                    </button>
                    <button type="submit" name="submit_healthcheck_refresh" class="btn btn-default" style="margin-right: 10px;">
                        <i class="icon icon-refresh" style="margin-right: 6px;"></i>{l s='Aggiorna Dati' mod='bwhealthcheck'}
                    </button>
                    <button type="button" class="btn btn-lg btn-success" style="padding: 10px 30px; font-size: 16px; font-weight: bold;" data-toggle="modal" data-target="#bwhealthcheck_modal">
                        <i class="icon icon-envelope" style="margin-right: 8px;"></i>{l s='Invia Report e Richiedi Preventivo' mod='bwhealthcheck'}
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
                <h3>{l s='1. Informazioni di Sistema' mod='bwhealthcheck'}</h3>
                <table class="table table-striped hc-table">
                    <tbody>
                        <tr>
                            <td><strong>{l s='Versione PrestaShop' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.versions.prestashop}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Versione PHP' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.versions.php}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Versione MySQL/MariaDB' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.versions.mysql}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Ultima Versione Stabile' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.versions.latest_stable}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Section 2: Image Statistics -->
        <div class="row" style="margin-bottom: 10px; padding-bottom: 15px; border-bottom: 1px solid #eee;">
            <div class="col-md-12">
                <h3>{l s='2. Statistiche Immagini' mod='bwhealthcheck'}</h3>
                <table class="table table-striped hc-table">
                    <tbody>
                        <tr>
                            <td><strong>{l s='Immagini Totali' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.images.total_images}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Prodotti con Immagini' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.images.products_with_images}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Prodotti senza Immagini' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.images.products_without_images}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Media Immagini per Prodotto' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.images.avg_images_per_product}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Section 3: E-commerce Statistics -->
        <div class="row" style="margin-bottom: 10px; padding-bottom: 15px; border-bottom: 1px solid #eee;">
            <div class="col-md-12">
                <h3>{l s='3. Statistiche E-commerce' mod='bwhealthcheck'}</h3>
                <table class="table table-striped hc-table">
                    <tbody>
                        <tr>
                            <td><strong>{l s='Ordini Totali' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.ecommerce.total_orders}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Clienti Totali' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.ecommerce.total_customers}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Indirizzi Totali' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.ecommerce.total_addresses}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Carrelli Anonimi' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.ecommerce.carts_anonymous}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Carrelli Registrati' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.ecommerce.carts_registered}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Valore Medio Ordine (ultimi 3 mesi)' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.ecommerce.avg_order_value_3m}</td>
                        </tr>
                    </tbody>
                </table>

                <h4>{l s='Lingue' mod='bwhealthcheck'}</h4>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>{l s='Nome' mod='bwhealthcheck'}</th>
                            <th>{l s='ISO Code' mod='bwhealthcheck'}</th>
                            <th>{l s='Stato' mod='bwhealthcheck'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from=$data.ecommerce.languages item=lang}
                        <tr>
                            <td>{$lang.name}</td>
                            <td><code>{$lang.iso_code}</code></td>
                            <td>{if $lang.active}<span class="badge badge-success">{l s='Attivo' mod='bwhealthcheck'}</span>{else}<span class="badge badge-secondary">{l s='Inattivo' mod='bwhealthcheck'}</span>{/if}</td>
                        </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Section 4: Theme -->
        <div class="row" style="margin-bottom: 10px; padding-bottom: 15px; border-bottom: 1px solid #eee;">
            <div class="col-md-12">
                <h3>{l s='4. Tema Attivo' mod='bwhealthcheck'}</h3>
                <table class="table table-striped hc-table">
                    <tbody>
                        <tr>
                            <td><strong>{l s='Nome Tema' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.theme.name}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Versione Tema' mod='bwhealthcheck'}</strong></td>
                            <td>{$data.theme.version}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Tema Genitore' mod='bwhealthcheck'}</strong></td>
                            <td>{if $data.theme.parent}{$data.theme.parent}{else}—{/if}</td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Directory Tema' mod='bwhealthcheck'}</strong></td>
                            <td><code>{$data.theme.directory}</code></td>
                        </tr>
                        <tr>
                            <td><strong>{l s='Child Theme' mod='bwhealthcheck'}</strong></td>
                            <td>{if $data.theme.is_child_theme}<span class="badge badge-info">{l s='Sì' mod='bwhealthcheck'} — parent: {$data.theme.parent}</span>{else}<span class="badge badge-secondary">{l s='No' mod='bwhealthcheck'}</span>{/if}</td>
                        </tr>
                    </tbody>
                </table>

                {if !empty($data.theme.child_themes)}
                <h4>{l s='Child Theme Trovati' mod='bwhealthcheck'}</h4>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>{l s='Nome' mod='bwhealthcheck'}</th>
                            <th>{l s='Cartella' mod='bwhealthcheck'}</th>
                            <th>{l s='Genitore' mod='bwhealthcheck'}</th>
                            <th>{l s='Versione' mod='bwhealthcheck'}</th>
                            <th>{l s='Stato' mod='bwhealthcheck'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from=$data.theme.child_themes item=child}
                        <tr>
                            <td>{$child.name}</td>
                            <td><code>{$child.directory}</code></td>
                            <td>{$child.parent}</td>
                            <td>{$child.version}</td>
                            <td>{if $child.is_active}<span class="badge badge-success">{l s='Attivo' mod='bwhealthcheck'}</span>{else}<span class="badge badge-secondary">{l s='Inattivo' mod='bwhealthcheck'}</span>{/if}</td>
                        </tr>
                        {/foreach}
                    </tbody>
                </table>
                {else}
                <p class="alert alert-success">{l s='Nessun child theme rilevato.' mod='bwhealthcheck'}</p>
                {/if}
            </div>
        </div>

        <!-- Section 5: Modules -->
        <div class="row" style="margin-bottom: 10px; padding-bottom: 15px; border-bottom: 1px solid #eee;">
            <div class="col-md-12">
                <h3>{l s='5. Moduli' mod='bwhealthcheck'}</h3>
                <p>
                    <strong>{l s='Moduli Attivi' mod='bwhealthcheck'}:</strong> {$data.modules.count_active} |
                    <strong>{l s='Moduli Inattivi' mod='bwhealthcheck'}:</strong> {$data.modules.count_inactive}
                </p>

                {if $data.modules.count_active > 0}
                <h4>{l s='Moduli Attivi' mod='bwhealthcheck'}</h4>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>{l s='Nome Modulo' mod='bwhealthcheck'}</th>
                            <th>{l s='Nome Visualizzato' mod='bwhealthcheck'}</th>
                            <th>{l s='Versione' mod='bwhealthcheck'}</th>
                            <th>{l s='Autore' mod='bwhealthcheck'}</th>
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
                <h4>{l s='Moduli Inattivi' mod='bwhealthcheck'}</h4>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>{l s='Nome Modulo' mod='bwhealthcheck'}</th>
                            <th>{l s='Nome Visualizzato' mod='bwhealthcheck'}</th>
                            <th>{l s='Versione' mod='bwhealthcheck'}</th>
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
                <h3>{l s='6. Override di Sistema' mod='bwhealthcheck'}</h3>

                {if !empty($data.overrides.system)}
                <h4>{l s='Override Core' mod='bwhealthcheck'}</h4>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>{l s='Classe' mod='bwhealthcheck'}</th>
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
                <p class="alert alert-success">{l s='Nessun override di sistema rilevato.' mod='bwhealthcheck'}</p>
                {/if}

                {if !empty($data.overrides.by_modules)}
                <h4>{l s='Override dai Moduli' mod='bwhealthcheck'}</h4>
                {foreach from=$data.overrides.by_modules key=moduleName item=overrides}
                <h5>{l s='Modulo' mod='bwhealthcheck'}: <code>{$moduleName}</code></h5>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>{l s='Classe' mod='bwhealthcheck'}</th>
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
                        {l s='Ultimo aggiornamento' mod='bwhealthcheck'}: {$data.generated_at}
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
                    {l s='Invia Report e Richiedi Preventivo' mod='bwhealthcheck'}
                </h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>{l s='Autorizza bwlab ad analizzare i dati del tuo shop e a ricontattarti per un preventivo gratuito.' mod='bwhealthcheck'}</p>

                <form id="bwhealthcheck_form" method="post">
                    <!-- Email Field -->
                    <div class="form-group">
                        <label for="bwhealthcheck_email">{l s='Email' mod='bwhealthcheck'} <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" id="bwhealthcheck_email" name="email" value="{$admin_email|escape:'html'}" required>
                    </div>

                    <!-- Name Field -->
                    <div class="form-group">
                        <label for="bwhealthcheck_name">{l s='Nome' mod='bwhealthcheck'} <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="bwhealthcheck_name" name="name" value="{$admin_name|escape:'html'}" required>
                    </div>

                    <!-- Company Field -->
                    <div class="form-group">
                        <label for="bwhealthcheck_company">{l s='Azienda' mod='bwhealthcheck'} <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="bwhealthcheck_company" name="company" value="{$shop_name|escape:'html'}" required>
                    </div>

                    <!-- Phone Field (optional) -->
                    <div class="form-group">
                        <label for="bwhealthcheck_phone">{l s='Telefono' mod='bwhealthcheck'} <span class="text-danger">*</span></label>
                        <input type="tel" class="form-control" id="bwhealthcheck_phone" name="phone" value="" required>
                    </div>

                    <!-- Privacy Checkbox -->
                    <div class="form-group">
                        <div class="custom-control custom-checkbox">
                            <input type="checkbox" class="custom-control-input" id="bwhealthcheck_privacy" name="privacy" required>
                            <label class="custom-control-label" for="bwhealthcheck_privacy">
                                {l s='Ho letto e accetto la' mod='bwhealthcheck'}
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
                    {l s='Annulla' mod='bwhealthcheck'}
                </button>
                <button type="button" class="btn btn-primary" id="bwhealthcheck_submit" disabled>
                    {l s='Invia Report' mod='bwhealthcheck'}
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
                $messageDiv.text('{l s="Compila tutti i campi obbligatori" mod="bwhealthcheck"}');
                return;
            }

            if (!$privacyCheckbox.prop('checked')) {
                $messageDiv.removeClass('alert-success').addClass('alert-danger').show();
                $messageDiv.text('{l s="Devi accettare la privacy policy" mod="bwhealthcheck"}');
                return;
            }

            // Disable submit button while processing
            $submitBtn.prop('disabled', true).html('<i class="icon icon-spinner icon-spin"></i> {l s="Invio in corso..." mod="bwhealthcheck"}');

            // Send AJAX request
            $.ajax({
                type: 'POST',
                url: '{$ajax_url|escape:'javascript'}',
                dataType: 'json',
                data: $form.serialize(),
                success: function(response) {
                    if (response.success) {
                        $messageDiv.removeClass('alert-danger').addClass('alert-success').show();
                        $messageDiv.html('<strong>{l s="Inviato!" mod="bwhealthcheck"}</strong> ' + response.message);

                        // Reset form after 3 seconds
                        setTimeout(function() {
                            $form[0].reset();
                            $privacyCheckbox.prop('checked', false);
                            $submitBtn.prop('disabled', true).html('{l s="Send Report" mod="bwhealthcheck"}');
                            $modal.modal('hide');
                        }, 3000);
                    } else {
                        $messageDiv.removeClass('alert-success').addClass('alert-danger').show();
                        $messageDiv.html('<strong>{l s="Errore!" mod="bwhealthcheck"}</strong> ' + response.message);
                        $submitBtn.prop('disabled', !$privacyCheckbox.prop('checked')).html('{l s="Send Report" mod="bwhealthcheck"}');
                    }
                },
                error: function() {
                    $messageDiv.removeClass('alert-success').addClass('alert-danger').show();
                    $messageDiv.text('{l s="Si è verificato un errore durante l\'invio del report" mod="bwhealthcheck"}');
                    $submitBtn.prop('disabled', !$privacyCheckbox.prop('checked')).html('{l s="Send Report" mod="bwhealthcheck"}');
                }
            });
        });
    });
})(jQuery);
</script>
