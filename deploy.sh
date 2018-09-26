rm calculator.zip
zip calculator.zip calculator.py
aws s3 cp calculator.zip s3://astik-anand-bucket/basic_calculator_terraform_source/calculator.zip 
terraform apply -auto-approve