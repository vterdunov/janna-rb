# Janna
This application will deploy your VM on VMware. Your VM should be OVA file.

### Configuration
See [.env](https://github.com/vterdunov/janna/blob/master/.env) file.

### API
| Endpoint | Description |
| ---- | --------------- |
| GET / | Get app name. |
| GET /health | Check health. Return 200 OK. |
| POST /vm?address=[ova_address]&vmname=[VM_name] | Create VM with `VM_name` from OVA(`ova_address`). |

### Development
##### Pre-requirements
Docker and docker-compose needs to be installed.

##### Commands
`make start` rebuild and run application in ineractive mode.  
`make shell <api|worker>` shell access into the specified container.

### Production
##### Build image
`docker build -t janna .`
##### Start container
`docker-compose up -d`
