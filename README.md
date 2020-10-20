# Directory outline

in this directory I have created a terraform main file using the standard hashicorp/aws provider

I used the aws_s3_bucket resource

and then accessed the aws_s3_bucket_object resource. with this I performed a loop
over all the files in a given directory and created the file inside the s3_bucket

This works. But I believe there to be a more efficent way to do this possibly with the aws. This is proof of a working concept that needs to be refined.