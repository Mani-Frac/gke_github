terraform {
  backend "gcs" {
    bucket = "github-actions-poc-gke-gh-actions-gke-tfstate"
    prefix = "env/dev"
  }
}