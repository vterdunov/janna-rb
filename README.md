# Janna
Janna is a little REST API interface for VMware.  
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
| network | (*Optional) Network name |
| datacenter | (*Optional) Datacenter name |
| datastore | (*Optional) Datastore name |
| cluster | (*Optional) Cluster name |
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
| network | (*Optional) Network name |
| datacenter | (*Optional) Datacenter name |
| datastore | (*Optional) Datastore name |
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
`cp .env.example .env.local` Copy and edit local configuration.  
`make start` rebuild and run application in ineractive mode.  
`make shell <api|worker>` shell access into the specified container.

### Production
##### Build janna image
`docker build -t janna .`
##### Start containers
`docker-compose up -d`
