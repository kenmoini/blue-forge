# Blue Forge - Ansible and Terraform powered IBM Cloud Deployments

## QuickStart Examples - Prerequisites

- An SSH key pair located at `~/.ssh/id_rsa{.pub}` - otherwise, modify `vars/examples.yml` to reflect the path to your key pair

## QuickStart Examples - How to Use

1. Export IBM Cloud API Key (required) and Region (optional)

```bash
export IC_API_KEY=<YOUR_API_KEY_HERE>
export IC_REGION=<REGION_NAME_HERE>
```

2. Pull in needed Collections (once)

```bash
ansible-galaxy install -r collections/requirements.yml
```

3. Run Playbooks

```bash
ansible-playbook example_list_vsi_images_and_profiles.yaml # to test access
ansible-playbook example_create_simple_vm_ssh.yaml # to test basic functions
ansible-playbook example_destroy_simple_vm_ssh.yaml # to undo test of basic functions
```

## Good tl;dr things to know

1. The IBM Cloud Ansible Collection/Modules seem to be built off of and use Terraform to do most of the heavy lifting, the Python here for the Ansible modules basically acts as a bridge to Terraform.  This seems to be a considerable bottleneck, if you're looking for performant interaction with the IBM Cloud you may want to automate via their API or CLI.
2. IBM Cloud has a few different set of cloud offerings, some of which can be used together, some of which cannot fully.
    - There is a "Classic Infrastructure" Cloud, or the v1 IBM Cloud, based on the SoftLayer acquisition.  It's a pretty simple cloud, not as robust as the newer cloud services but still offer a lot of powerful capabilities.  If you're used to DigitalOcean/Linode sort of offerings, these services will seem familiar to you.
    - The newer Cloud service offerings will have things such as tagging, and managing services into Resource Groups, etc.  If you're used to AWS/Azure/GCP this will seem a bit more familiar, and includes a lot of the newer PaaS/SaaS offerings like OpenShift, Serverless, VPCs, etc.
3. If you're here via RHPDS/OpenTLC/Project Tatooine, the IBM Cloud environment doesn't have DNS services, you'll need to deploy that to some nodes yourself and coordinate the sub-zones.  There are assets in the `ws-kubernetes101` role that show how do deploy the DNS nodes, glue it together with an external zone hosted at AWS Route53 or DigitalOcean, and configure the other nodes to access it via split-horizon resolution.
---

## Using in Ansible Tower

You'll need to add the passlib package to your Ansible Tower virtualenv - do the following as root:

```bash
# source /var/lib/awx/venv/ansible/bin/activate
# umask 0022
# pip install --upgrade passlib
# deactivate
```

## Workshops

The primary workloads Blue Forge supports are ones the deploy and configure workshop environments.  These are the workshops this platform supports on the IBM Cloud:

- [Working] Containers 101
- [Beta] Kubernetes 101
- [Alpha] Ansible Automation - needs some post-config work to make an easier workshop
- [TBA] Ansible for Windows
- [TBA] DevOps on OpenShift
- [TBA] DevSecOps - Secure Software Factories

---

### Containers 101

#### Prerequisites

- boto, jq, Python 3, and Pip installed on the Ansible Control Node
- An AWS or DigitalOcean account with a Domain Zone hosted there and API key to utilize it

#### Environment

With N being number of Students, this environment will make the following:

| QTY     | Asset                   | Hostname                   |
|---------|-------------------------|----------------------------|
| 1       | Proctor Bastion         | bastion.[GUID].[DOMAIN]    |
| 2       | DNS Nodes               | ns[NUM]-[GUID].[DOMAIN]    |
| 1 Per N | Bastion/Container Host  | student[N].[GUID].[DOMAIN] |

#### Minimum `extra_vars.yaml` file found in `vars/example_workshop_containers101.yml`

```bash
ansible-galaxy install -r collections/requirements.yml
cp vars/example_workshop_containers101.yml containers101.extra_vars.yml
## Edit the containers101.extra_vars.yml file
ansible-playbook -e "@containers101.extra_vars.yml" workshop_create_containers101.yaml
ansible-playbook -e "@containers101.extra_vars.yml" workshop_destroy_containers101.yaml
```

---

### Kubernetes 101

#### Prerequisites

- boto, jq, Python 3, and Pip installed on the Ansible Control Node
- An AWS or DigitalOcean account with a Domain Zone hosted there and API key to utilize it

#### Environment

With N being number of Students, this environment will make the following:

| QTY     | Asset                   | Hostname, Additional A Records                                                                |
|---------|-------------------------|-----------------------------------------------------------------------------------------------|
| 1       | Proctor Bastion         | bastion.[GUID].[DOMAIN]                                                                       |
| 2       | DNS Nodes               | ns[NUM]-[WORKSHOP_SHORTCODE]-[GUID].[DOMAIN]                                                  |
| 1 Per N | Load Balancer/Bastion   | student[N].[GUID].[DOMAIN], *.apps.student[N].[GUID].[DOMAIN], api.student[N].[GUID].[DOMAIN] |
| Y Per N | K8s Control Plane Nodes | student[N]-cp[Y].[GUID].[DOMAIN]                                                              |
| Z Per N | K8s Application Nodes   | student[N]-app[Z].[GUID].[DOMAIN]                                                             |

#### Minimal `extra_vars.yaml` file found in `vars/example_workshop_kubernetes101.yml`

```bash
ansible-galaxy install -r collections/requirements.yml
cp vars/example_workshop_kubernetes101.yml kubernetes101.extra_vars.yml
## Edit the kubernetes101.extra_vars.yml file
ansible-playbook -e "@kubernetes101.extra_vars.yml" workshop_create_kubernetes101.yaml
ansible-playbook -e "@kubernetes101.extra_vars.yml" workshop_destroy_kubernetes101.yaml
```

---

### Ansible Automation

#### Prerequisites

- boto, jq, Python 3, and Pip installed on the Ansible Control Node
- An AWS or DigitalOcean account with a Domain Zone hosted there and API key to utilize it

#### Environment

With N being number of Students, this environment will make the following:

| QTY     | Asset                   | Hostname                           |
|---------|-------------------------|------------------------------------|
| 1       | Proctor Bastion         | bastion.[GUID].[DOMAIN]            |
| 2       | DNS Nodes               | ns[NUM]-[GUID].[DOMAIN]            |
| 1 Per N | Ansible Tower Host      | student[N].[GUID].[DOMAIN]         |
| X Per N | Ansible Target Node     | student[N]-node[X].[GUID].[DOMAIN] |

#### Minimum `extra_vars.yaml` file found in `vars/example_workshop_ansible_automation.yml`

```bash
ansible-galaxy install -r collections/requirements.yml
cp vars/example_workshop_ansible_automation.yml ansible_automation.extra_vars.yml
## Edit the ansible_automation.extra_vars.yml file
ansible-playbook -e "@ansible_automation.extra_vars.yml" workshop_create_ansible_automation.yaml
ansible-playbook -e "@ansible_automation.extra_vars.yml" workshop_destroy_ansible_automation.yaml
```

## OpenShift in IBM Cloud - The Hard Way!

If you're utilizing this repo in Project Tatooine and wanting to deploy OpenShift there are a number of challenges:

1. No Fedora/Red Hat CoreOS Instance Images available
2. No access to Cloud Object Storage to upload custom image - need to use a personal/shared COS resource that's publicly available
3. No other mechanism for modifying VPC networking specs such as DNS/PXE.
4. No way to use anything other than cloud-init, like Ignition which is what CoreOS uses...

So with that, there are a few prerequisites to using Blue Forge to deploy OCP 4 to IBM Cloud:

1. Download the RHCOS QEMU QCow, use `guestfish` to modify the Grub boot kernel arguments and dracut to use DHCP and look for DNS at `10.128.10.10`, `10.128.20.10`, and `10.128.30.10` - this allows any IBM Instance created with the subsequent custom image to generate/pull an Ignition file

### Architecture

|                      | Zone 1         | Zone 2         | Zone 3         | Additional Notes                                        |
|----------------------|----------------|----------------|----------------|---------------------------------------------------------|
| CIDR                 | 10.128.10.0/24 | 10.128.20.0/24 | 10.128.30.0/24 |                                                         |
| Proctor Bastion      | 10.128.10.4    |                |                |                                                         |
| Load Balancer        | 10.128.10.9    |                |                |                                                         |
| DNS                  | 10.128.10.10   | 10.128.20.10   | 10.128.30.10   | Also Pilot Light Servers                                |
| RH IDM Server        | 10.128.10.11   | 10.128.20.11   | 10.128.30.11   | If enabled, BIND DNS upstream is changed to IDM servers |
| Control Plane Node   | 10.128.10.20   | 10.128.20.20   | 10.128.30.20   |                                                         |
|                      | 10.128.10.21   | 10.128.20.21   | 10.128.30.21   | Additional Optional Control Plane Nodes                 |
| Infrastructure Nodes | 10.128.10.30   | 10.128.20.30   | 10.128.30.30   | Optional Infrastructure Nodes                           |
|                      | 10.128.10.31   | 10.128.20.31   | 10.128.30.31   | Additional Optional Infrastructure Nodes                |
| Application Nodes    | 10.128.10.40   | 10.128.20.40   | 10.128.30.40   |                                                         |
|                      | 10.128.10.41   | 10.128.20.41   | 10.128.30.41   |                                                         |
|                      | 10.128.10.42   | 10.128.20.42   | 10.128.30.42   |                                                         |
|                      | 10.128.10.43   | 10.128.20.43   | 10.128.30.43   |                                                         |
|                      | 10.128.10.44   | 10.128.20.44   | 10.128.30.44   |                                                         |
| Minio S3 Server      | 10.128.10.61   |                |                |                                                         |
| GitLab Server        | 10.128.10.62   |                |                |                                                         |
| NFS Server           | 10.128.10.63   |                |                |                                                         |

TODO: Explore OCS for storage