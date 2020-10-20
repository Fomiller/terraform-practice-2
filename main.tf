terraform {
  required_providers {
    aws = {
      sourve = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region = "us-west-2"
}

resource "aws_s3_bucket" "s3_static" {
  bucket  = "cigna-ng-test"
  acl     = "public-read"
  # delete all files inside bucket when destroy command is run
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# METHOD 1

# working with null_resource and aws CLI
  # what i learned here... null resource will run first if the command does not contain any variables from other resources.
  # If the null resource command relys on a variable from other resources terraform will wait for that variable to become available before it runs.

# resource "null_resource" "s3_static" {
#   provisioner "local-exec" {
#     command = "aws s3 sync ./ng-app/dist/ng-app s3://${aws_s3_bucket.s3_static.bucket}"
#   }
# }

# METHOD 2
# resource "aws_s3_bucket_object" "fileUpload" {
#   for_each = fileset(var.upload_directory, "**/*.*")

#   acl = "public-read"
#   force_destroy = true
  
#   bucket = aws_s3_bucket.s3_static.bucket
#   key = each.value
#   source = "${var.upload_directory}${each.value}"
# }

output "fileset-results" {
  value = fileset("${path.module}/ng-app/dist/ng-app", "**/*.*")
}

# METHOD 3
# same as above but includes more attributes
# in this method each file is a aws_s3_bucket_object
resource "aws_s3_bucket_object" "website_files" {
  # loop over directory each value is equal to a value
  # returns array of files and any nested files ie. index.html or assets/exampleImage.jpeg
  for_each      = fileset(var.upload_directory, "**/*.*")
  # name of the bucket that is being referenced
  bucket        = aws_s3_bucket.s3_static.bucket
  # fullpath for the object inside the bucket
  # replace is ensuring that each key is only the name of the file and if a full path is attached to the file that it is removed
  # this seems unnecesary given how i understand fileset return statement works, but i could be wrong 
  key           = replace(each.value, var.upload_directory, "")
  # where the value of each key is coming from ?
  source        = "${var.upload_directory}${each.value}"
  # access control list
  acl           = "public-read"
  # creates a has that is used to check if the file was uploaded completely and correctly i.e not curropted?
  # Used to trigger updates. from documentation
  # an etag is essentially a hash so less data is sent around servers instead of the whole file.
  etag          = filemd5("${var.upload_directory}${each.value}")
  # checks to see if file type meeets the allowed file types to be uploaded
  content_type  = lookup(var.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}


