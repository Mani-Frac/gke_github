terraform {
  backend "gcs" {
    bucket = "github-actions-poc-gke-2-gh-actions-gke-tfstate"
    prefix = "env/dev"
  }
}