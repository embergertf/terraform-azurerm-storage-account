# Changelog
<!-- markdownlint-disable MD024 -->

[[_TOC_]]

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## [Unreleased]
### Added
### Changed
### Removed -->

## [1.2.2] - 2024-11-14 - Cycle error fix

### Modified

- Removed `depends_on = [azurerm_storage_container.this]` from `azurerm_storage_container` resource

## [1.2.1] - 2024-11-14 - Modified `azurerm_storage_account` & `additional_tags` processing

### Modified

- `additional_tags` processing moved to base module
- Added to `azurerm_storage_account`:
  - `blob_properties.delete_retention_policy.permanent_delete_enabled` = `true`
  - `share_properties` block
  - `queue_properties` block

## [1.2.0] - 2024-11-11 - Added `private_link_access` block + fixed `additional_tags` logic

### Added

- Variables:
  - `private_link_accesses` (default: `{}`)
  - `blobs_retention_policy` (default: `7`)
  - `blobs_versioning_enabled` (default: `false`)
  - `blobs_change_feed_enabled` (default: `false`)

- Outputs:
  - `resource_group_name`
  - `location`
  - in DEBUG mode:
    - `naming_module_tags`
    - `st_acct_tags`

### Modified

- Storage account `additional_tags` logic fixed
- `blob_properties` now uses variables for `delete_retention_policy`, `container_delete_retention_policy`, `versioning_enabled`, `change_feed_enabled`
- Added to `azurerm_storage_account_network_rules` a `private_link_access` dynamic block

## [1.1.1] - 2024-11-08 - Modified `blob_properties` to defaults

### Modified

- In `main.tf`: `blob_properties.versioning_enabled` and `blob_properties.change_feed_enabled` changed from `true` to `false`

## [1.1.0] - 2024-11-03 - Updated module version + added outputs

### Added

- Outputs for `containers`, `blobs`, `queues`, `file_shares`, `tables`

### Modified

- Version constraint on module `module` `"st_on_kv_ra"` (Role assignments)

## [1.0.0] - 2024-11-03 - Module Creation

### Added

- Added Storage Account module
