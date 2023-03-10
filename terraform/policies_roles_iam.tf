#------------------------------------Lambda iam------------------------------#

# This is a role for the scraper lambda function
resource "aws_iam_role" "lambda_role_s3" {
  name = "lambda_s3_role"
  path = "/"

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

# This policy allows lambda to write logs to cloudwatch, access to redshift and write files to S3
resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "lambda-s3-policy"
  description = "Policy for lambda access to S3"


  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "logs:*"
        ],
        "Resource": "arn:aws:logs:*:*:*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "s3:*"
        ],
        "Resource": "arn:aws:s3:::*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "redshift:*"
        ],
        "Resource": "arn:aws:redshift:::*"
    }
]

} 
EOF
}

# This will attach the policy into the role
resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = aws_iam_role.lambda_role_s3.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}


#---------------------------Redshift iam-----------------------------------------------#

resource "aws_iam_role" "project_redshift_role" {

  name = "project_redshift_role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "redshift.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy" "redshift_s3_policy" {

  name = "redshift_s3_policy"
  role = aws_iam_role.project_redshift_role.id

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": "s3:*",
           "Resource": "*"
       }
   ]
}
EOF
}