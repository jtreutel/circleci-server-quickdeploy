
# Cheat scripts for a bit-quicker installation of CircleCI

ORIGINAL SOURCE: https://gist.github.com/makotom/930e29b709e2e976dc3b433df95ca299

These assets automate what the author otherwise carries out manually.
It assumes that you already have installed `eksctl`, `kubectl` and KOTS, and that you have a RSA-based SSH keypair at `~/.ssh/id_rsa`.

# Design paradigm

`cluster.yaml` for `eksctl` is expected to be heavily customized based on your network configuration/requirements.
See comments there to learn how to customize it.

`main.tf` for Terraform is _not_ expected to be customized. Any customization for Terraform is expected to happen within `locals.tf` (for immutable environment-dependent parameters) and `terraform.tfvars` (mutable parameters).

# Step-by-step instruction

1.  `eksctl create cluster -f cluster.yaml` to spin-up your K8s cluster.
2.  `aws eks update-kubeconfig --name << cluster name >> --region << cluster region >>` or equivalent to update your kubeconfig.
3.  `kubectl kots install circleci-server -n circleci-server` to install CircleCI on top of your cluster.
4.  Go to your KOTS console to upload your licence file, and STOP at the page of KOTS admin console where you are prompted for initial configuration values.
5.  Edit `locals.tf` accordingly, then `terraform init` and `terraform apply`.
6.  Terraform should output all the infrastructure-wise configuration parameters you will need on KOTS. Resume configuring your CircleCI at your KOTS admin console.
7.  After confirming that Service (`svc`) resources are created, run the following command, and then `terraform apply`.

    ```
    cat <<EOD | tee terraform.tfvars
    front_lb_dns_name = "$(kubectl get svc circleci-server-traefik -n circleci-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
    nomad_lb_dns_name = "$(kubectl get svc nomad-server-external -n circleci-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
    op_lb_dns_name    = "$(kubectl get svc output-processor -n circleci-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
    vms_lb_dns_name   = "$(kubectl get svc vm-service -n circleci-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
    EOD
    ```

8.  `kubectl delete po -l app=nomad-server -n circleci-server` to restart Nomad server pods and make sure that advertisement addresses are correctly set based on updated DNS RRs.
9.  Run the following command, then `terraform apply` again.

    ```
    echo -e '
    nomadc_replicas = 10 # Number of Nomad clients you want to spin up' | tee -a terraform.tfvars
    ```

10. Verify that Nomad clients are up and running by `kubectl exec $(kubectl get po -l app=nomad-server -n circleci-server -o jsonpath='{.items[0].metadata.name}') -n circleci-server -- nomad node status`
11. Run `realitycheck` and make sure that your instance is healthy.
