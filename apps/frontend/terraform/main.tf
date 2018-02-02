provider "aws" {
  region = "us-east-1"
}

data "template_file" "bucket_policy" {
  template = "${file("templates/policy.json")}"

  vars {
    bucket = "web-app-deploy-example"
  }
}

resource "aws_s3_bucket" "frontend" {
  bucket = "web-app-deploy-example"
  acl    = "public-read"
  policy = "${data.template_file.bucket_policy.rendered}"

  website {
    index_document = "index.html"
  }
}
