output "user" {
  value = "${aws_iam_user.user.name}"
}

output "key" {
  value = "${aws_iam_access_key.user_key.id}"
  sensitive   = true
}

output "secret" {
  value = "${aws_iam_access_key.user_key.secret}"
  sensitive   = true
}

output "role" {
  value = "${aws_iam_role.iam_emr_service_role.arn}"
}

output "profile" {
  value = "${aws_iam_instance_profile.emr_profile.arn}"
}

output "asg" {
  value = "${aws_security_group.main.id}"
}