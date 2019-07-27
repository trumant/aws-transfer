# Terraform for setting up AWS Transfer Service

This sets-up a Transfer service endpoint with a single user `tbt-test`
that is granted permission to upload and download files from the S3 bucket
`tbt-theitem`

# Dependencies

Install Terraform from terraform.io

# Usage

Create an S3 bucket, in this example, the bucket name is `tbt-theitem`

Edit the `transfer.tf` file to set your own username, ssh public key and S3 bucket

Ensure you have AWS credentials setup in your profile. Change the profile name
on line 4 of `transfer.tf` to specify the name of the AWS CLI profile that contains your credentials.

```sh
terraform init
terraform plan
terraform apply
```

Once Terraform has created the service, you can retrieve the SFTP endpoint from the AWS Console

# Testing the endpoint

In the example below the username we will use to access the endpoint is `tbt-test` and the
endpoint itself is `s-6bfb9e0c304b4cb9b.server.transfer.us-east-1.amazonaws.com`

```sh
sftp tbt-test@s-6bfb9e0c304b4cb9b.server.transfer.us-east-1.amazonaws.com
Connected to tbt-test@s-6bfb9e0c304b4cb9b.server.transfer.us-east-1.amazonaws.com.
sftp> pwd
Remote working directory: /tbt-theitem
sftp> ls
camper-packing-list.pdf
sftp> put LyftReceipt.pdf
Uploading LyftReceipt.pdf to /tbt-theitem/LyftReceipt.pdf
LyftReceipt.pdf                                                                                                                           100%  249KB 951.9KB/s   00:00
sftp> bye
```
