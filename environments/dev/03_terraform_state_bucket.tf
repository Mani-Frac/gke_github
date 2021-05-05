terraform {
  backend "gcs" {
    bucket = "github-actions-poc-gke-05-gh-actions-gke-tfstate"
    prefix = "env/dev"
  }
}