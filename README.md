# DEPRECATED This is no longer supported, please consider using [janna-api](https://github.com/vterdunov/janna-api) instead
---
# Janna

Janna provides an HTTP interface to some VMware functions.  
Janna can deploy your VM from OVA file or Template and send notification into Slack when your Virtual machine will be ready.  
Also Janna can destroy VMs, show information about VMs or change their power state.

### Configuration
See [.env](https://github.com/vterdunov/janna/blob/master/.env.example) file.

### API
| Endpoint | Description |
| ---- | --------------- |
| **GET /v1/vm** | **Get Information about Virtual machine** |
| _Parameter_ | _Description_|
| provider_type | Hypervisor provider type. Values: `vmware` |
| vmname | Virtual Machine name |
| datacenter | (*Optional) Datacenter name |
| vm_folder | (*Optional) Folder name where VM placed |
|||
| **PUT /v1/vm** | **Change VM Power state** |
| _Parameter_ | _Description_|
| provider_type | Hypervisor provider type. Values: `vmware` |
| vmname | Virtual Machine name |
| state | State of VM. Values: `on\|off\|reset\|suspend` |
| datacenter | (*Optional) Datacenter name |
| vm_folder | (*Optional) Folder name where VM placed |
| **POST /v1/vm** | **Create VM from OVA file** |
| _Parameter_ | _Description_|
| provider_type | Hypervisor provider type. Values: `vmware` |
| vmname | Virtual Machine name |
| ova_url | URL to OVA file |
| network | (*Optional) Map the network to all OVF networks |
| networks | (*Optional) Comma separated string of custom network mapping between OVF network and ESXi system network ('OVF-VM-Network-Name' --> 'Yours-ESXi-VM-Network-Name'). Overrides `network` parameter. E.g.: `OVF-VM-Network-Name,Yours-ESXi-VM-Network-Name` |
| datacenter | (*Optional) Datacenter name |
| datastores | (*Optional) Datastores names. Comma separated string. E.g.: `datastore1, datastore2, datastore3` |
| computer_path | (*Optional) Cluster name to deploy VM |
| computer | (*Optional) Host from the Cluster to deploy VM |
| vm_folder | (*Optional) Folder name where VM will be created |
| message_to | (*Optional) Name or Channel to send messages |
| **DELETE /v1/vm** | **Delete VM** |
| _Parameter_ | _Description_|
| provider_type | Hypervisor provider type. Values: `vmware` |
| vmname | Virtual Machine name |
|  |  |
| **POST /v1/template** | **Create VM from Template** |
| _Parameter_ | _Description_|
|  |  |
| provider_type | Hypervisor provider type. Values: `vmware` |
| vmname | Virtual Machine name |
| template_name | Name of Template |
| template_path | Path to Templates folder |
| network | (*Optional) Map the network to all OVF networks |
| datacenter | (*Optional) Datacenter name |
| datastores | (*Optional) Datastores names. Comma separated string. E.g.: `datastore1, datastore2, datastore3` |
| cluster | (*Optional) Cluster name |
| vm_folder | (*Optional) Folder name where VM will be created |
| message_to | (*Optional) Name or Channel to send messages |
|  |  |
| **GET /health** | **Check application health. Return 200 OK.** |
|  |  |
| **GET /v1/jobs** | **Get list of background jobs** |
| **GET /v1/jobs/:id** | **Get background job info by ID** |

##### Pre-requirements
Docker and docker-compose needs to be installed.

### Development
##### Commands
- `cp .env.example .env.local` Copy and edit local configuration.
- `make start` rebuild and run application in ineractive mode.
- `make shell <api|worker>` shell access into the specified container.

### Production
##### Build janna image
`docker build -t janna .`
##### Start containers
`docker-compose up -d`
