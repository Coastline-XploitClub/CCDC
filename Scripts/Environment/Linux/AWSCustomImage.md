# AWS VM Import

## **Configure AWS CLI**

Windows Install:

```powershell
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

Linux Install:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Confirm Version

```bash
aws --version
```

Configure

```console
aws configure
<Access Key ID>
<Secret Access Key>
<Default Region Name>
```

## **Create Required Service Role**

Create a file named `trust-policy.json` containing the following policy:

```json
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": { "Service": "vmie.amazonaws.com" },
         "Action": "sts:AssumeRole",
         "Condition": {
            "StringEquals":{
               "sts:Externalid": "vmimport"
            }
         }
      }
   ]
}
```

Use the create-role command to create a role named vmimport and grant VM Import/Export access to it.

```bash
aws iam create-role --role-name vmimport --assume-role-policy-document "file://C:\import\trust-policy.json"
```

Create a file named `role-policy.json` with the following policy:

```json
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect": "Allow",
         "Action": [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket"
         ],
         "Resource": [
            "arn:aws:s3:::coastlinelab-test",
            "arn:aws:s3:::coastlinelab-test/*"
         ]
      },
      {
         "Effect": "Allow",
         "Action": [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:PutObject",
            "s3:GetBucketAcl"
         ],
         "Resource": [
            "arn:aws:s3:::coastlinelab-exports",
            "arn:aws:s3:::coastlinelab-exports/*"
         ]
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*"
         ],
         "Resource": "*"
      }
   ]
}
```

Use the following `put-role-policy` command to attach the policy to the role created above.

```bash
aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file://C:\import\role-policy.json"
```

## **Upload VM to S3**

```bash
aws s3api put-object --bucket "coastlinelab-test" --key "vm/WRCCDC-2021/vms/<FILE NAME>" --body .\<FILE NAME>
```

## **Import VM as Image**

Use `import-image` to import an image with a single disk:

```bash
aws ec2 import-image --description "My server VM" --disk-containers "file://C:\import\containers.json"
```

Create a `manifest.json` file that specifies the image using an S3 bucket:

```json
[
  {
    "Description": "My Server OVA",
    "Format": "ova",
    "UserBucket": {
        "S3Bucket": "coastlinelab-test",
        "S3Key": "vms/<ova_file>"
    }
  }
]
```

Monitor Import Progress:

```bash
aws ec2 describe-import-image-tasks --import-task-ids <import-id>
```

Once finished, import your image as an EC2 instance custom AMI.

---

References:

```console
https://docs.aws.amazon.com/vm-import/latest/userguide/vmimport-image-import.html
```
