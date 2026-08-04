# [SSH config](https://github.com/my-name/my-app/blob/main/docs/SSH.md)

`${HOME}/.ssh/config`:

````
## my-app
Host my-app.prd
HostName my-app.com
#Port 22
#User my-name
#ProxyJump my-name@proxy.my-app.com:22

Host my-app-db.prd
HostName my-app.com

Host my-app.stg
HostName next.my-app.com
````
