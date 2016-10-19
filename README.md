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
Rebuild and run app ineractive `make start`  
Access into specify container `make shell <container name>`

### Production mode
##### Build image
`docker build -t janna .`
##### Start container
`docker-compose up -d`
