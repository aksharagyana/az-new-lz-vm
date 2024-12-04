resource "azurerm_linux_virtual_machine" "this" {
  admin_username        = var.admin_username
  location              = var.location
  name                  = var.name
  network_interface_ids = [for interface in azurerm_network_interface.virtualmachine_network_interfaces : interface.id]
  resource_group_name   = var.resource_group_name
  size                  = var.sku_size
  admin_password                                         = (var.disable_password_authentication ? null : var.admin_password)
  allow_extension_operations                             = var.allow_extension_operations
  bypass_platform_safety_checks_on_user_schedule_enabled = var.bypass_platform_safety_checks_on_user_schedule_enabled
  computer_name                                          = coalesce(var.computer_name, var.name)
  disable_password_authentication                        = var.disable_password_authentication
  disk_controller_type                                   = var.disk_controller_type
  encryption_at_host_enabled                             = var.encryption_at_host_enabled
  eviction_policy                                        = var.eviction_policy
  extensions_time_budget                                 = var.extensions_time_budget
  license_type                                           = var.license_type
  max_bid_price                                          = var.max_bid_price
  patch_assessment_mode                                  = var.patch_assessment_mode
  patch_mode                                             = var.patch_mode
  priority                                               = var.priority
  provision_vm_agent                                     = var.provision_vm_agent
  reboot_setting                                         = var.reboot_setting
  secure_boot_enabled                                    = var.secure_boot_enabled
  source_image_id                                        = var.source_image_resource_id
  tags                                                   = var.tags
  vm_agent_platform_updates_enabled                      = var.vm_agent_platform_updates_enabled
  vtpm_enabled                                           = var.vtpm_enabled
  zone                                                   = var.zone

  os_disk {
    caching                          = var.os_disk.caching
    storage_account_type             = var.os_disk.storage_account_type
    disk_encryption_set_id           = var.os_disk.disk_encryption_set_id
    disk_size_gb                     = var.os_disk.disk_size_gb
    name                             = var.os_disk.name
    secure_vm_disk_encryption_set_id = var.os_disk.secure_vm_disk_encryption_set_id
    security_encryption_type         = var.os_disk.security_encryption_type
    write_accelerator_enabled        = var.os_disk.write_accelerator_enabled

    dynamic "diff_disk_settings" {
      for_each = var.os_disk.diff_disk_settings == null ? [] : ["diff_disk_settings"]

      content {
        option    = var.os_disk.diff_disk_settings.option
        placement = var.os_disk.diff_disk_settings.placement
      }
    }
  }
  dynamic "admin_ssh_key" {
    for_each = var.admin_ssh_keys

    content {
      public_key = admin_ssh_key.value.public_key
      username   = admin_ssh_key.value.username
    }
  }

  dynamic "gallery_application" {
    for_each = { for app, app_details in var.gallery_applications : app => app_details }

    content {
      version_id             = gallery_application.value.version_id
      configuration_blob_uri = gallery_application.value.configuration_blob_uri
      order                  = gallery_application.value.order
      tag                    = gallery_application.value.tag
    }
  }
  dynamic "plan" {
    for_each = var.plan == null ? [] : ["plan"]

    content {
      name      = var.plan.name
      product   = var.plan.product
      publisher = var.plan.publisher
    }
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_resource_id == null ? ["source_image_reference"] : []

    content {
      offer     = var.source_image_reference.offer
      publisher = var.source_image_reference.publisher
      sku       = var.source_image_reference.sku
      version   = var.source_image_reference.version
    }
  }

}

resource "azurerm_network_interface" "virtualmachine_network_interfaces" {
  for_each = var.network_interfaces

  location                       = var.location
  name                           = each.value.name
  resource_group_name            = coalesce(each.value.resource_group_name, var.resource_group_name)
  accelerated_networking_enabled = each.value.accelerated_networking_enabled
  dns_servers                    = each.value.dns_servers
  internal_dns_name_label        = each.value.internal_dns_name_label
  ip_forwarding_enabled          = each.value.ip_forwarding_enabled
  tags                           = var.tags

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations

    content {
      name                                               = ip_configuration.value.name
      private_ip_address_allocation                      = ip_configuration.value.private_ip_address_allocation
      primary                                            = ip_configuration.value.is_primary_ipconfiguration
      private_ip_address                                 = ip_configuration.value.private_ip_address
      private_ip_address_version                         = ip_configuration.value.private_ip_address_version
      subnet_id                                          = ip_configuration.value.private_ip_subnet_resource_id
    }
  }
}


resource "azurerm_managed_disk" "this" {
  for_each = var.data_disk_managed_disks

  create_option                     = each.value.create_option
  location                          = var.location
  name                              = each.value.name
  resource_group_name               = coalesce(each.value.resource_group_name, var.resource_group_name)
  storage_account_type              = each.value.storage_account_type
  disk_access_id                    = each.value.disk_access_resource_id
  disk_encryption_set_id            = each.value.disk_encryption_set_resource_id #preview feature to be activated at a later date
  disk_iops_read_only               = each.value.disk_iops_read_only
  disk_iops_read_write              = each.value.disk_iops_read_write
  disk_mbps_read_only               = each.value.disk_mbps_read_only
  disk_mbps_read_write              = each.value.disk_mbps_read_write
  disk_size_gb                      = each.value.disk_size_gb
  gallery_image_reference_id        = each.value.gallery_image_reference_resource_id
  hyper_v_generation                = each.value.hyper_v_generation
  image_reference_id                = each.value.image_reference_resource_id
  logical_sector_size               = each.value.logical_sector_size
  max_shares                        = each.value.max_shares
  network_access_policy             = each.value.network_access_policy
  on_demand_bursting_enabled        = each.value.on_demand_bursting_enabled
  optimized_frequent_attach_enabled = each.value.optimized_frequent_attach_enabled
  os_type                           = each.value.os_type
  performance_plus_enabled          = each.value.performance_plus_enabled
  public_network_access_enabled     = each.value.public_network_access_enabled
  secure_vm_disk_encryption_set_id  = each.value.secure_vm_disk_encryption_set_resource_id
  security_type                     = each.value.security_type
  source_resource_id                = each.value.source_resource_id
  source_uri                        = each.value.source_uri
  storage_account_id                = each.value.storage_account_resource_id
  tags                              = each.value.tags != null && each.value.tags != {} ? each.value.tags : local.tags
  tier                              = each.value.tier
  trusted_launch_enabled            = each.value.trusted_launch_enabled
  upload_size_bytes                 = each.value.upload_size_bytes
  zone                              = var.zone

  dynamic "encryption_settings" {
    for_each = each.value.encryption_settings

    content {
      disk_encryption_key {
        secret_url      = encryption_settings.value.disk_encryption_key_vault_secret_url
        source_vault_id = encryption_settings.value.disk_encryption_key_vault_resource_id
      }
      key_encryption_key {
        key_url         = encryption_settings.value.key_encryption_key_vault_secret_url
        source_vault_id = encryption_settings.value.key_encryption_key_vault_resource_id
      }
    }
  }
}

#attach the disk(s) to the virtual machine
resource "azurerm_virtual_machine_data_disk_attachment" "this_linux" {
  for_each = { for disk, values in var.data_disk_managed_disks : disk => values }

  caching                   = each.value.caching
  lun                       = each.value.lun
  managed_disk_id           = azurerm_managed_disk.this[each.key].id
  virtual_machine_id        = azurerm_linux_virtual_machine.this[0].id
  create_option             = each.value.disk_attachment_create_option
  write_accelerator_enabled = each.value.write_accelerator_enabled
}


resource "azurerm_virtual_machine_extension" "this_extension" {
  for_each = toset([for k, v in nonsensitive(var.extensions) : k]) #forcing to use the map key to address terraform limitation around sensitive values in the map (https://developer.hashicorp.com/terraform/language/meta-arguments/for_each#limitations-on-values-used-in-for_each)

  #using explicit references using the for_each key to get around the secrets issue in the above link
  name                        = var.extensions[each.key].name
  publisher                   = var.extensions[each.key].publisher
  type                        = var.extensions[each.key].type
  type_handler_version        = var.extensions[each.key].type_handler_version
  virtual_machine_id          = azurerm_linux_virtual_machine.this.id
  auto_upgrade_minor_version  = var.extensions[each.key].auto_upgrade_minor_version
  automatic_upgrade_enabled   = var.extensions[each.key].automatic_upgrade_enabled
  failure_suppression_enabled = var.extensions[each.key].failure_suppression_enabled
  protected_settings          = var.extensions[each.key].protected_settings
  provision_after_extensions  = var.extensions[each.key].provision_after_extensions
  settings                    = var.extensions[each.key].settings
  tags                        = var.tags

}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "this" {
  for_each = var.shutdown_schedules

  daily_recurrence_time = each.value.daily_recurrence_time
  location              = var.location
  timezone              = each.value.timezone
  virtual_machine_id    = azurerm_linux_virtual_machine.this.id
  enabled               = each.value.enabled
  tags                  = each.value.tags

  notification_settings {
    enabled         = each.value.notification_settings.enabled
    email           = each.value.notification_settings.email
    time_in_minutes = each.value.notification_settings.time_in_minutes
    webhook_url     = each.value.notification_settings.webhook_url
  }

  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.this_linux
  ]
}
