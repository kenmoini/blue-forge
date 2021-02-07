# Blue Forge - Ansible and Terraform powered IBM Cloud Deployments

The following QuickStart Examples are great to do an initial test of your IBM Cloud account access - for more robust environment automation skip down to the ***Workshops*** section.

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

---

## Good tl;dr things to know

1. The IBM Cloud Ansible Collection/Modules seem to be built off of and use Terraform to do most of the heavy lifting, the Python here for the Ansible modules basically acts as a bridge to Terraform.  This seems to be a considerable bottleneck, if you're looking for performant interaction with the IBM Cloud you may want to automate via their API or CLI.
2. IBM Cloud has a few different set of cloud offerings, some of which can be used together, some of which cannot fully.
    - There is a "Classic Infrastructure" Cloud, or the v1 IBM Cloud, based on the SoftLayer acquisition.  It's a pretty simple cloud, not as robust as the newer cloud services but still offer a lot of powerful capabilities.  If you're used to DigitalOcean/Linode sort of offerings, these services will seem familiar to you.
    - The newer Cloud service offerings will have things such as tagging, and managing services into Resource Groups, etc.  If you're used to AWS/Azure/GCP this will seem a bit more familiar, and includes a lot of the newer PaaS/SaaS offerings like OpenShift, Serverless, VPCs, etc.
3. If you're here via RHPDS Open Environments, the IBM Cloud environment doesn't have DNS services, you'll need to deploy that to some nodes yourself and coordinate the sub-zones.  There are assets in the `ws-kubernetes101` role that show how do deploy the DNS nodes, glue it together with an external zone hosted at AWS Route53 or DigitalOcean, and configure the other nodes to access it via split-horizon resolution.

---

## Using Blue Forge in Ansible Tower

You'll need to add the passlib package to your Ansible Tower virtualenv - do the following as root:

```bash
# source /var/lib/awx/venv/ansible/bin/activate
# umask 0022
# pip install --upgrade passlib
# deactivate
```

---

## Workshop Environments

The primary workloads Blue Forge supports are ones the deploy and configure workshop environments.  These are the workshops this platform supports on the IBM Cloud:

- [95%] Containers 101 - Needs curriculum compiled and associated
- [80%] Kubernetes 101 - Needs lb config and optional k8s provisioning
- [Alpha] Ansible Automation - needs some post-config work to make an easier workshop
- [WIP] OpenShift 4 HA Cluster
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

If you're utilizing this repo with RHPDS Open Environments and wanting to deploy OpenShift there are a number of challenges:

1. No Fedora/Red Hat CoreOS Instance Images available
2. No access to Cloud Object Storage to upload custom image - need to use a personal/shared COS resource that's publicly available
3. No other mechanism for modifying VPC networking specs such as DNS/PXE.
4. No way to use anything other than cloud-init, like Afterburner or Ignition which is what CoreOS uses...

So with that, there are a few prerequisites to using Blue Forge to deploy OpenShift 4 to IBM Cloud:

### 1. Architect the full environment with Static IPs

|                      | Zone 1         | Zone 2         | Zone 3         | Hostname Format                                                | Additional Notes                                        |
|----------------------|----------------|----------------|----------------|----------------------------------------------------------------|---------------------------------------------------------|
| CIDR                 | 10.128.10.0/24 | 10.128.20.0/24 | 10.128.30.0/24 |                                                                |                                                         |
| Proctor Bastion      | 10.128.10.4    |                |                | bastion.{{ guid }}.{{ domain }}                                |                                                         |
| Bootstrap Node       | 10.128.10.7    |                |                | bootstrap.{{ guid }}.{{ domain }}                              |                                                         |
| Load Balancer        | 10.128.10.9    |                |                | lb.{{ guid }}.{{ domain }}                                     | Also Pilot Light Server                                 |
| DNS                  | 10.128.10.10   | 10.128.20.10   | 10.128.30.10   | ns{{ index }}-{{ workshop_shortcode }}-{{ guid }}.{{ domain }} |                                                         |
| RH IDM Server        | 10.128.10.11   | 10.128.20.11   | 10.128.30.11   | idm{{ index }}.{{ guid }}.{{ domain }}                         | If enabled, BIND DNS upstream is changed to IDM servers |
| Control Plane Node   | 10.128.10.20   | 10.128.20.20   | 10.128.30.20   | ctrlp-{{ index }}.{{ guid }}.{{ domain }}                      |                                                         |
|                      | 10.128.10.21   | 10.128.20.21   | 10.128.30.21   |                                                                | Additional Optional Control Plane Nodes                 |
| Infrastructure Nodes | 10.128.10.30   | 10.128.20.30   | 10.128.30.30   | infra-{{ index }}.{{ guid }}.{{ domain }}                      | Optional Infrastructure Nodes                           |
|                      | 10.128.10.31   | 10.128.20.31   | 10.128.30.31   |                                                                | Additional Optional Infrastructure Nodes                |
| Application Nodes    | 10.128.10.40   | 10.128.20.40   | 10.128.30.40   | app-node-{{ index }}.{{ guid }}.{{ domain }}                   |                                                         |
|                      | 10.128.10.41   | 10.128.20.41   | 10.128.30.41   |                                                                | Additional Optional Application Nodes, in sets of 3     |
|                      | 10.128.10.42   | 10.128.20.42   | 10.128.30.42   |                                                                |                                                         |
|                      | 10.128.10.43   | 10.128.20.43   | 10.128.30.43   |                                                                |                                                         |
|                      | 10.128.10.44   | 10.128.20.44   | 10.128.30.44   |                                                                |                                                         |
|                      | 10.128.10.45   | 10.128.20.45   | 10.128.30.45   |                                                                |                                                         |
| Minio S3 Server      | 10.128.10.61   |                |                | s3.{{ guid }}.{{ domain }}                                     |                                                         |
| GitLab Server        | 10.128.10.62   |                |                | gitlab.{{ guid }}.{{ domain }}                                 |                                                         |
| NFS Server           | 10.128.10.63   |                |                | nfs.{{ guid }}.{{ domain }}                                    |                                                         |

***TODO***: Explore OCS for storage

### 2. Create a custom RHCOS Image for IBM Cloud

1. Download the [RHCOS QEMU QCow](https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/)
2. Use `guestfish` to modify the Grub boot kernel arguments and dracut to:
    - Use DHCP
    - Manually set DNS at `10.128.10.10`, `10.128.20.10`, and `10.128.30.10` - we'll deploy a few DIY DNS servers to map things properly
    - Have RHCOS pull ignition from the first DNS server which runs a service called [Pilot Light](https://github.com/kenmoini/pilot-light) at port 8082 that generates and serves Ignition files based on Reverse DNS/Hostname mappings

    The whole set of commands looks like this:

    ```bash
    wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-qemu.x86_64.qcow2.gz
    gunzip rhcos-qemu.x86_64.qcow2.gz
    guestfish -a rhcos-qemu.x86_64.qcow2
    
    ><fs> launch
    ><fs> mount /dev/sda1 /
    ><fs> vi /ignition.firstboot
    ```

    INSERT the following into the /ignition.firstboot file:
    
    ```
    set ignition_network_kcmdline='coreos.firstboot=1 rd.neednet=1 ip=dhcp nameserver=10.128.10.10 nameserver=10.128.20.10 nameserver=10.128.30.10 ignition.platform.id=metal ignition.config.url=http://10.128.10.9:8082/ignition-generator'
    ```
    
    Then `ESC` and `:wq` out of INSERT mode and vi.  Exit guestfish with the following:
    
    ```bash
    ><fs> shutdown
    ><fs> exit
    ```

3. Now with that modified QCow2 image, you can upload it to a Cloud Object Store bucket in your personal IBM Cloud account.  Make sure to make the image publicly available if you're accessing from a different account such as one provisioned by RHPDS.  You'll need the `cos://` link.

### 3. Deploy with Blue Forge

Blue Forge's OpenShift deployments are already architected with the above layout, and will stage the infrastructure in the proper order.

All that you need to bring is: 

1. A modified RHCOS image `cos://` link - you may have a friend who has one they can share...
2. An IBM Cloud API Key
3. External DNS provided by AWS or DigitalOcean
4. Red Hat Cloud Pull Secret for OpenShift
