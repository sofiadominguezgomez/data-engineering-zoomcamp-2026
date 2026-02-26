terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.6.0"
    }
  }
}

provider "google" {
  project                     = var.project
  region                      = var.region
  impersonate_service_account = "terraform-runner-336@project-14e1491f-7fd9-42b8-ade.iam.gserviceaccount.com"
}

# Generate the random code
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "demo-bucket" {
  # Create the bucket unique name using the variable as prefix and the random code generated on top before
  name          = "${var.gcs_bucket_name}-${random_id.bucket_suffix.hex}"
  location      = var.region
  force_destroy = true

  # ------------------------------------------------------------------------------
  # This setting is required because the project enforces "Uniform Bucket-Level Access".
  # It disables old-school ACLs (file-specific permissions) and enforces IAM policies
  # for the entire bucket. Without this = true, the project policy blocks creation.
  # ------------------------------------------------------------------------------
  uniform_bucket_level_access = true

  # -------------------------------------------------------------------------------------------------------------------
  # NOTE TO FUTURE SELF:
  # The rule below is commented out because it deletes ALL data after 3 days.
  # For the zoomcamp i need the dataset i will upload to stay there for homework and projects.
  # If this was enabled it would be wiped, so i would have to redo it and there is no need. different for another prod, but for learning i dont need it
  # -------------------------------------------------------------------------------------------------------------------
  /*
  lifecycle_rule {
    condition {
      age = 3
    }
    action {
      type = "Delete"
    }
  }
  */

  # This rule only aborts uploads that failed and got stuck. so it is safe for the course-work
  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "dataset" {
  # Only Required field
  dataset_id = "demo_dataset"
  # Optional: important for costs and others
  location   = var.location   # This is consumed from the variables and tfvars

  # Optional: Friendly name for the UI
  friendly_name = "Zoomcamp Demo Dataset"
  
  # Optional: Deletes the dataset even if it has tables (Good for learning, bad for prod)
  delete_contents_on_destroy = true
}

/*
The file() function is used on the main.tf (not variables.tf) to paste text from a file, some examples:
1. Big Query Schema: save a schema.json and then load it to the main as:
    schema = file("schemas/taxi_data_schema.json")
2. Load the sql from a separate file as:
    query = file("queries/daily_report.sql")
3. load a bash script on a VM to install software when it boots it as:
    metadata_startup_script = file("setup_python.sh")
*/