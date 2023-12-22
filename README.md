## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_bigquery_dataset.customer_dataset](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset) | resource |
| [google_compute_subnetwork_iam_member.vpc_subnetwork_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork_iam_member) | resource |
| [google_kms_crypto_key.customer_crypto_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key_iam_member.key_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_project_iam_member.big_query_job_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.dataproc_worker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.portrait_engine_sa_allow_bq_connector_push_down](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.tenant_dataplane_bigquery_job_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.tenant_dataplane_dataproc_editor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.tenant_dataplane_dataproc_worker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.tenant_dataplane_service_account_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.tenant_orchestration_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.tenant_dataplane_workload_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_storage_bucket.customer_build_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket.customer_input_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket.customer_output_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_policy.customer_build_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_policy) | resource |
| [google_storage_bucket_iam_policy.customer_input_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_policy) | resource |
| [google_storage_bucket_iam_policy.customer_output_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_policy) | resource |
| [kubernetes_namespace.tenant_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service_account.tenant_ksa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [google_iam_policy.customer_build_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |
| [google_iam_policy.customer_input_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |
| [google_iam_policy.customer_output_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |
| [google_project.control_plane_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_project.data_plane_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_service_account.ingestion_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |
| [google_storage_project_service_account.data_plane_gcs_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/storage_project_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_build_subnet_self_link"></a> [build\_subnet\_self\_link](#input\_build\_subnet\_self\_link) | The self link to the regional subnet this customer should use | `string` | n/a | yes |
| <a name="input_control_plane_project"></a> [control\_plane\_project](#input\_control\_plane\_project) | The GCP project in which customer data will be processed. | `string` | n/a | yes |
| <a name="input_control_plane_service_account"></a> [control\_plane\_service\_account](#input\_control\_plane\_service\_account) | Kubernetes Service Account name to configure WorkloadIdentity with the Control-Plane/Google-Service-Account | `string` | `"orchestration"` | no |
| <a name="input_country_code"></a> [country\_code](#input\_country\_code) | The ISO 3166-1 two character country code (https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes) | `string` | n/a | yes |
| <a name="input_data_editors"></a> [data\_editors](#input\_data\_editors) | The users, groups & service accounts that should have read & write access to this customers data | <pre>object({<br>    service_accounts = list(string)<br>    groups           = list(string)<br>    users            = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_data_plane_project"></a> [data\_plane\_project](#input\_data\_plane\_project) | The GCP project in which customer data will be stored. | `string` | n/a | yes |
| <a name="input_data_retention_period_days"></a> [data\_retention\_period\_days](#input\_data\_retention\_period\_days) | The number of days this customers data will be stored before its automatically deleted | `number` | `0` | no |
| <a name="input_data_viewers"></a> [data\_viewers](#input\_data\_viewers) | The users, groups & service accounts that should have read only access to this customers data | <pre>object({<br>    service_accounts = list(string)<br>    groups           = list(string)<br>    users            = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment this infrastructure is supported (One of: dev, staging or prod) | `string` | n/a | yes |
| <a name="input_ingestion_service_account_name"></a> [ingestion\_service\_account\_name](#input\_ingestion\_service\_account\_name) | The service account attached to the cloud function that will copy customer data to this bucket. | `string` | n/a | yes |
| <a name="input_installation_name"></a> [installation\_name](#input\_installation\_name) | n/a | `string` | `"portrait-engine"` | no |
| <a name="input_key_rotation_period_days"></a> [key\_rotation\_period\_days](#input\_key\_rotation\_period\_days) | The frequency at which the crypto key will automatically rotate (days) | `number` | `90` | no |
| <a name="input_kms_self_link"></a> [kms\_self\_link](#input\_kms\_self\_link) | The KMS instance to store this customer & countries key in | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The human readable customer name | `string` | n/a | yes |
| <a name="input_network_self_link"></a> [network\_self\_link](#input\_network\_self\_link) | n/a | `string` | `null` | no |
| <a name="input_organisation_id"></a> [organisation\_id](#input\_organisation\_id) | Liveramp CAC/Organisation-id | `string` | n/a | yes |
| <a name="input_storage_location"></a> [storage\_location](#input\_storage\_location) | The storage location for BigQuery and GCS. | `string` | n/a | yes |

## Outputs

No outputs.
