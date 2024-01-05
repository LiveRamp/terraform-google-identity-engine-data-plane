output "bigquery_dataset_name" {
  value = customer_dataset.name
}

output "input_bucket_name" {
  value = customer_input_bucket.name
}

output "build_bucket_name" {
  value = customer_build_bucket.name
}

output "output_bucket_name" {
  value = customer_output_bucket.name
}

output "orchestration_service_account_name" {
  value = tenant_orchestration_service_account.name
}
