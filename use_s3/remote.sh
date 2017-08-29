terraform remote config \
  -backend=S3 \
  -backend-config="bucket=xxxx" \
  -backend-config="key=global/s3/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true" \
  
