# Module 1: Terraform Infrastructure as Code (IaC)

## 🧠 Why are we doing this?
**Terraform** is an open-source Infrastructure as Code (IaC) tool. Instead of manually clicking through the Google Cloud Platform (GCP) UI to create buckets and datasets, we declare what we want in our `main.tf` file.
* **Why IaC?** It makes our cloud infrastructure reproducible, version-controllable (via Git), and easily shareable. If we accidentally delete a bucket, we can recreate it in seconds with a single command.
* **The Goal:** Provision a Google Cloud Storage (GCS) Data Lake bucket and a BigQuery Dataset, which will serve as our data warehouse.

---

## 🔐 Modern Authentication (No JSON Keys!)
The original Zoomcamp material uses downloaded JSON service account keys, which is an outdated and less secure practice. In this repository, we use the modern **Service Account Impersonation** approach.

Instead of managing a physical key file, we authenticate locally with our personal Google account and configure the Terraform Google provider to *impersonate* a specific Service Account that has the required permissions.

### Prerequisites (One-time setup)
1. Install the [Google Cloud CLI (`gcloud`)](https://cloud.google.com/sdk/docs/install).
2. Create a GCP Project.
3. Create a Service Account and grant it the necessary roles (e.g., `Storage Admin`, `BigQuery Admin`).
4. **Crucial step:** Grant your personal Google user account the **Service Account Token Creator** role on that specific Service Account so you are allowed to impersonate it.
5. Authenticate your local environment by running:
```bash
gcloud auth application-default login
```

---

## ⚙️ Configuration & Variables
Instead of hardcoding values like project IDs or region names directly into `main.tf`, this repository uses **variables** to keep the code clean and reusable.

1. **`variables.tf`**: This file *declares* the variables Terraform expects to receive.
2. **`terraform.tfvars`**: This file *assigns* the actual values to those variables. 

Because `terraform.tfvars` can contain environment-specific details, it is typically excluded via `.gitignore`. **You must create your own `terraform.tfvars` file locally** in this folder before running Terraform. 

**Example `terraform.tfvars` structure:**
```hcl
project         = "your-gcp-project-id"
region          = "us-central1"
location        = "US"
bq_dataset_name = "demo_dataset"
gcs_bucket_name = "your_unique_bucket_name"

# The service account Terraform will impersonate:
service_account = "your-service-account@your-gcp-project-id.iam.gserviceaccount.com"
```

---

## 🚀 The Workflow: What to run and How

### 1. Initialize Terraform
Navigate to the directory containing your Terraform files and run:
```bash
terraform init
```
* **What it does:** Initializes the working directory. It looks at your configuration and downloads the necessary provider plugins (e.g., the Google provider plugin to interact with GCP APIs).

### 2. Plan the Infrastructure
Before making any changes to the cloud, see what Terraform *intends* to do using your `.tfvars` values:
```bash
terraform plan
```
* **What it does:** Compares your declared configuration against the actual current state of your GCP project. 
* **Why?** It acts as a dry-run/safety check. It will output exactly what resources will be created, updated, or destroyed, giving you a chance to review them without affecting your live environment.

### 3. Apply the Changes
If the plan looks correct, execute it:
```bash
terraform apply
```
* **What it does:** Re-runs the plan and asks for confirmation (type `yes`). Once confirmed, it makes API calls to GCP to create your GCS bucket and BigQuery dataset using the impersonated service account.

### 4. Teardown (Clean up)
To avoid incurring unnecessary cloud costs when you are completely done with the project:
```bash
terraform destroy
```
* **What it does:** Looks at the state file and deletes all the infrastructure that was previously provisioned by Terraform.