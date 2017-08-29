terraform remote config \
  -backend=S3 \
  -backend-config="bucket=haleym-terraform-state" \
  -backend-config="key=global/s3/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true" \
  
