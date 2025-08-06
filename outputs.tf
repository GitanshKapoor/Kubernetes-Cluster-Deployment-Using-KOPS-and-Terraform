output "kops_state_bucket" {
  value = aws_s3_bucket.kops_state.bucket
}

output "kops_instance_public_ip" {
  value = aws_instance.kops.public_ip
}

output "route53_zone_id" {
  value = aws_route53_zone.hosted_zone.zone_id
}

output "Run - kops_create_command on Kops Instance" {
  value = "kops create cluster --name=<example.yourdomain.com> --state=s3://${aws_s3_bucket.kops_state.bucket} --zones=us-east-1a,us-east-1b --node-count=2 --node-size=t3.small --control-plane-size=t3.medium --dns-zone=<example.yourdomain.com> --node-volume-size=12 --control-plane-volume-size=12 --ssh-public-key=/home/ubuntu/.ssh/id_rsa.pub"
}

output "kops_update_command on Kops Instance" {
  value = "kops update cluster --name=<example.yourdomain.com> --state=s3://${aws_s3_bucket.kops_state.bucket} --yes --admin"
}

