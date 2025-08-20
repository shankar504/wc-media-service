terraform {
  backend "s3" {
    region = "us-west-2"
    bucket = "terraform-remote-tfstates-duclo-nonprod"
    dynamodb_table = "terraform-tfstates-lock-nonprod"
    key = "dev-media-clipper/terraform.state"
    skip_metadata_api_check = false
  }
}
