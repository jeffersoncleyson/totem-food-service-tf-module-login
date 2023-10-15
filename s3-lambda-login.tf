resource "random_pet" "lambda_login_bucket_name" {
  prefix = "login-terraform-demo"
  length = 4
}

resource "aws_s3_bucket" "lambda_login_bucket" {
  bucket        = random_pet.lambda_login_bucket_name.id
  force_destroy = true

  tags = {
    App = var.application_name,
    Environment = var.environment,
    OwnerTeam = var.owner_team
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_login_bucket_acl_ownership" {
  bucket = aws_s3_bucket.lambda_login_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "lambda_login_bucket_acl" {
  bucket     = aws_s3_bucket.lambda_login_bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_login_bucket_acl_ownership]
}

data "archive_file" "lambda_login_demo_file" {
  type = "zip"

  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"

  depends_on = [ null_resource.lambda_dependencies ]
}

resource "aws_s3_object" "lambda_login_demo" {
  bucket = aws_s3_bucket.lambda_login_bucket.id

  key    = "lambda.zip"
  source = data.archive_file.lambda_login_demo_file.output_path

  etag = filemd5(data.archive_file.lambda_login_demo_file.output_path)

  tags = {
    App = var.application_name,
    Environment = var.environment,
    OwnerTeam = var.owner_team
  }
}

resource "null_resource" "lambda_dependencies" {
  provisioner "local-exec" {
    command = "cd ${path.module}/lambda && npm install"
  }

  triggers = {
    index = sha256(file("${path.module}/lambda/login.js"))
    package = sha256(file("${path.module}/lambda/package.json"))
    lock = sha256(file("${path.module}/lambda/package-lock.json"))
    node = sha256(join("",fileset(path.module, "lambda/**/*.js")))
  }
}
