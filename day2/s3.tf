provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "my-buckets" {
  count  = 10
  bucket = "my-argurate-bucket-${count.index + 1}"

}