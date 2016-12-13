# Janna
This application will deploy your VM on VMware. Your VM should be OVA file.  
Janna will sent you slack notification when your Virtual machine will be ready.

### Configuration
See [.env](https://github.com/vterdunov/janna/blob/master/.env.example) file.

### API
| Endpoint | Description |
| ---- | --------------- |
| **GET /health** | **Check health. Return 200 OK.** |
|||
| **POST /v1/vm** | **Create VM** |
| Parameter | Description|
| provider_type | Hypervisor provider type. Possible values: `vmware` |
| vmname | Virtual Machine name |
| ova_url | URL to OVA file |
| vsphere_network | (*Optional) Network name |
| vsphere_datacenter | (*Optional) Datacenter name |
| vsphere_datastore | (*Optional) Datastore name |
| vsphere_cluster | (*Optional) Cluster name |
| vsphere_vm_folder | (*Optional) Folder name where VM will be created |
| message_to | (*Optional) Name or Channel to send messages |

##### Pre-requirements
Docker and docker-compose needs to be installed.

### Development
##### Commands
`make start` rebuild and run application in ineractive mode.  
`make shell <api|worker>` shell access into the specified container.

### Production
##### Build janna image
`docker build -t janna .`
##### Start containers
`docker-compose up -d`
