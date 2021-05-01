terraform {
  backend "gcs" {
    bucket = "franky-gke-tfstate"
    prefix = "env/dev"
  }
} 