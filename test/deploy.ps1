if (Test-Path ./lb.tf) {
    Move-item ./lb.tf ./lb.tf.bak
}
if (Test-Path ./tfplan) {
    Remove-Item ./tfplan
}
terraform plan -out=tfplan
terraform apply --auto-approve -input=false tfplan

if (Test-Path ./lb.tf.bak) {
    Move-item ./lb.tf.bak ./lb.tf
}
if (Test-Path ./tfplan) {
    Remove-Item ./tfplan
}
terraform plan -out=tfplan
terraform apply --auto-approve -input=false tfplan
