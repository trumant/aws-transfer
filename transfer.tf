provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
  profile = "the_item"
}

resource "aws_iam_role" "transfer_role" {
  name = "tf-test-transfer-server-iam-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "transfer_role_policy" {
  name = "tf-test-transfer-server-iam-policy"
  role = "${aws_iam_role.transfer_role.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "AllowFullAccesstoCloudWatchLogs",
        "Effect": "Allow",
        "Action": [
            "logs:*"
        ],
        "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_transfer_server" "transfer_service" {
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = "${aws_iam_role.transfer_role.arn}"
  endpoint_type          = "PUBLIC"

  tags = {
    NAME = "tbt-transfer-server"
    ENV  = "test"
  }
}

resource "aws_iam_role" "transfer_user_role" {
  name = "transfer-user-iam-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "transfer_user_policy" {
  name = "transfer-user-iam-policy"
  role = "${aws_iam_role.transfer_user_role.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowListingOfUserFolder",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::tbt-theitem"
            ]
        },
        {
            "Sid": "HomeDirObjectAccess",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObjectVersion",
                "s3:DeleteObject",
                "s3:GetObjectVersion"
            ],
            "Resource": "arn:aws:s3:::tbt-theitem/*"
        }
    ]
}
POLICY
}

resource "aws_transfer_user" "test-user" {
  server_id = "${aws_transfer_server.transfer_service.id}"
  user_name = "tbt-test"
  role      = "${aws_iam_role.transfer_user_role.arn}"
  home_directory = "/tbt-theitem/"

  tags = {
    NAME = "tbt-test"
  }
}

resource "aws_transfer_ssh_key" "test-user-ssh" {
  server_id = "${aws_transfer_server.transfer_service.id}"
  user_name = "${aws_transfer_user.test-user.user_name}"
  body      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFbI6OyFEc7X8JBFBDU7t1vM7IXyrGoFQN+GP5+t3MrgZUVsUXpWN+m29g53bah9JbZ/ScZtRTa0nFUQBa/EncYieE6Ju7x5ofzk1Zhmg+X3OozSgGhSN+QdtsTP6Os3dmeiZvcrWOxRCQrxft8iykfxKaTzNDtcShD798IgiWFUxxmIdwc5KbBMlxOoA/rqs5wpqjai/cpsAWYVDyI+OpgdPL6Qf++KHgY8u4+NzEJrrre0N+34cWNGh7vvZ1xCfciMD6VzAJ5AiraARnJFKCRCFIYeChbB/ENdZbQ1nGFXhTCtZmpd7KoqxUqpfiuNMgkuBREWGMvbiXOvb5nxBjVfM25W1WY7ZwYMeEJdbLPe0tYmV/iLltXEK9ybAAHTsF+OHS+vwKLmu27GkPE452d82jdyW8k4tOpkjKahXxaDOdyYqZHHcO3NUTR0B9BpdsSrau+eWP5ZNdNR0kUHE7QhWNno1jxLJCKkDaJAOpuh5mWaWPU7qnoyFcCSqBZanMzyoaazzj6m5e3PPPyTIkDXf0gS+QOKe/c3Wu/OLM+TWwtEzPyavGbzJoyZ+CaplaPKTgmKF/icDuFt3/MFKZe3O8iFstPaLPFd4zV0LeAWKZuA7XFifKHF0JH1gw+1OmX31bBKsK0EZiE1ndxfnU5ZbQvUqs1bcRQlA+TokCtw== travis_truman@comcast.com"
}
