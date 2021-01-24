# Blue Forge - Ansible-powered IBM Cloud Deployments

## NOTE: This repository is being refitted from full Ansible deployers to staged Ansible > Terraform > Ansible deployments due to the IBM Cloud Collections taking too long to complete

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
ansible-galaxy install -r requirements.yml
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

---

## Workshops

The primary workloads Blue Forge supports are ones the deploy and configure workshop environments.  These are the workshops this platform supports on the IBM Cloud:

- [Beta] Containers 101 - Should be working, minus DNS
- [WIP, 85%] Kubernetes 101
- [TBA] Ansible Automation
- [TBA] Ansible for Windows
- [TBA] DevOps on OpenShift
- [TBA] DevSecOps - Secure Software Factories

---

### Containers 101

#### Minimum `extra_vars.yaml` file

```yaml
guid: lol42
workshop_id: containers101
workshop_shortcode: c101

student_count: 2

region: us-south
regional_zone: us-south-3

generation_directory: "/tmp/.blue-forge/{{ workshop_id }}/{{ guid }}"
```

##### Available and Default Variables

```yaml
guid: lol42
workshop_id: containers101
workshop_shortcode: c101

proctor_bastion_vsi_profile: cx2-2x4
proctor_bastion_vsi_image: ibm-redhat-8-1-minimal-amd64-1

proctor_username: workshopProctor
proctor_password: noPrizeFor5thBestCloud

student_username_prefix: student
student_username_suffix:
student_password: noPrizeFor5thBestCloud

student_vsi_profile: bx2-2x8
student_vsi_image: ibm-redhat-8-1-minimal-amd64-1
student_count: 2

vpc_total_ipv4_address_count: 256
region: us-south
regional_zone: us-south-3

generation_directory: "/tmp/.blue-forge/{{ workshop_id }}/{{ guid }}"

base_install_packages:
  - nano
  - wget
  - curl
```

#### Environment

With N being number of Students, this environment will make the following:

| QTY     | Asset                   | Hostname                   |
|---------|-------------------------|----------------------------|
| 1       | Proctor Bastion         | bastion.[GUID].[DOMAIN]    |
| 2       | DNS Nodes               | ns[NUM]-[GUID].[DOMAIN]    |
| 1 Per N | Bastion/Container Host  | student[N].[GUID].[DOMAIN] |

#### Deployment

To deploy the Containers 101 workshop to the IBM Cloud you need an IBM Cloud API Key.  Then follow the next steps:

1. Copy `extra_vars.yml.example` to `extra_vars.yml`
2. Modify `extra_vars.yml` replacing the LongString with your API Key
3. Add any additional variables in the `extra_vars.yml` from the reference above to override any defaults
4. Deploy with `ansible-playbook -e "@extra_vars.yml" workshop_create_containers101.yaml`
4. Destroy with `ansible-playbook -e "@extra_vars.yml" workshop_destroy_containers101.yaml`

---

### Kubernetes 101

#### Prerequisites

- jq, Python 3, and Pip installed on the Ansible Control Node
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

#### Minimal `extra_vars.yaml` file

```yaml
---
domain: ibm.example.com
ibmcloud_api_key: loooongString

# guid is used to coordinate resources and organize separate environments
guid: lol42
# Mostly used for organization purposes
workshop_id: kubernetes101
workshop_shortcode: k8s101
student_count: 2

generation_directory: "/tmp/.blue-forge/{{ workshop_id }}/{{ guid }}"

region: us-east
regional_zone: us-east-3

# dnsnb_provider: aws or digitalocean
dnsnb_provider: aws

dnsnb_aws_access_key: AKIAYELOLWUTWTFHAXF7
dnsnb_aws_secret_key: 2zQZ4j8k3lfsy7tisU5AWYw0qXnutIf5ZDkguyG

dnsnb_do_pat: reallyReallyLongString

dnsnb_persistent_zone: "{{ domain }}"
dnsnb_delegated_zone: "{{ guid }}"

```