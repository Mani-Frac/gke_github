terraform {
  backend "gcs" {
    bucket = "github-actions-poc-gke-07-gh-actions-gke-tfstate"
    prefix = "env/dev"
  }
}