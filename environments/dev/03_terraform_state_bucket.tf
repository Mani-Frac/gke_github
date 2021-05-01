terraform {
  backend "gcs" {
    bucket = "github-actions-poc1-gh-actions-gke-tfstate"
    prefix = "env/dev"
  }
}
