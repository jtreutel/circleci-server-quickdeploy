# circleci-server-quickdeploy
Terraform plan to quickly stand up infra for CircleCI Server 3.x.

## Server 3.x Quick Setup Instructions

In `main/`:

```sh
cp terraform.tfvars.example terraform.tfvars
#--- fill out terraform.tfvars ---#
terraform init
terraform apply -target module.ssh_key #because the Nomad module doesn't support dynamically creating an SSH key in the same TF plan
terraform apply
```
Outputs will show the values you need to enter into the kots console.

Install CircleCI Server on your new EKS cluster:
`kubectl kots install circleci-server -n circleci-server --kubeconfig ./kubeconfig`
Fill out all the values.  You will still need to:
* Choose to let Let's Encrypt manage certs, and then enter an email address
* Create signing/auth keys using the Docker commands
* Create a new Github OAuth app
When finished, deploy your config.

Check whether the external service LBs are up with `kubectl get svc -n circleci-server --kubeconfig ./kubeconfig`
Once you see DNS names under `EXTERNAL-IP` for the following services, you can go ahead and run the DNS plan:
* circleci-server-traefik
* nomad-server-external
* output-processor
* vm-service

To run the DNS plan, navigate to the `dns/` directory and do the following:
```
cp terraform.tfvars.example terraform.tfvars
#--- fill out terraform.tfvars ---#
terraform init
terraform apply
```
Note the 3 outputs.  Return to the kots console, click "Config", and enter the DNS names shown in the outputs in the correct fields.
Deploy your new config. 

`kubectl delete po -l app=nomad-server -n circleci-server` to restart Nomad server pods and make sure that advertisement addresses are correctly set based on updated DNS records.
Verify that Nomad clients are up and running by `kubectl exec $(kubectl get po -l app=nomad-server -n circleci-server -o jsonpath='{.items[0].metadata.name}') -n circleci-server -- nomad node status`

At this point, your new server should be up and running.  To smoke test, fork [realitycheck](https://github.com/circleci/realitycheck) run [this script](https://github.com/jtreutel/circleci-realitycheck-prep), and then trigger a pipeline for realitycheck.