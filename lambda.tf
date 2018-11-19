# Simple AWS Lambda Terraform Example
# requires 'index.js' in the same directory
# to test: run `terraform plan`
# to deploy: run `terraform apply`

variable "aws_region" {
  default = "eu-central-1"
}

provider "aws" {
  region          = "${var.aws_region}"
}

data "archive_file" "lambda_zip" {
    type          = "zip"
    source_file   = "index.js"
    output_path   = "lambda_function.zip"
}

resource "aws_lambda_function" "stop_diablo" {
  filename         = "lambda_function.zip"
  function_name    = "stop_diablo"
  role             = "${aws_iam_role.lambda_stop_diablo.arn}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  runtime          = "nodejs6.10"
}

resource "aws_iam_role" "lambda_stop_diablo" {
  name = "lambda_stop_diablo"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_stop_diablo_policy" {
  name = "lambda_stop_diablo_policy"
  role = "${aws_iam_role.lambda_stop_diablo.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:DescribeInstances",
          "ec2:StopInstances",
          "ec2:StartInstances"
        ],
        "Resource": "*"
      }
    ]
}
EOF
}

resource "aws_cloudwatch_event_rule" "stop_diablo_instance" {
    name                = "stop_diablo_instance"
    description         = "Fires every weekdays"
    schedule_expression = "cron(00 12 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "stop_diablo_every_weekdays" {
    rule      = "${aws_cloudwatch_event_rule.stop_diablo_instance.name}"
    target_id = "stop_diablo"
    arn       = "${aws_lambda_function.stop_diablo.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_stop_diablo" {
    statement_id  = "AllowExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.stop_diablo.function_name}"
    principal     = "events.amazonaws.com"
    source_arn    = "${aws_cloudwatch_event_rule.stop_diablo_instance.arn}"
}
