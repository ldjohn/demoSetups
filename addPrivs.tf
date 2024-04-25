# use in lx def: iam_instance_profile   = aws_iam_instance_profile.JWAPICallprofileLX.name

# Create the IAM role/profile for the API Call
resource "aws_iam_instance_profile" "JWAPICallprofileLX" {
  name = "JWAPICall_profileLX"
  role = aws_iam_role.JWAPICallroleLX.name
}
resource "aws_iam_role" "JWAPICallroleLX" {
  name = "JWAPICall_roleLX"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
              "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "JWAPICallpolicyLX" {
  name        = "JWAPICall_policyLX"
  path        = "/"
  description = "Policies for the FGT APICall Role"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeTags",
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "JWAPICall-attachLX" {
  name       = "JWAPICall_attachLX"
  roles      = [aws_iam_role.JWAPICallroleLX.name]
  policy_arn = aws_iam_policy.JWAPICallpolicyLX.arn
}
