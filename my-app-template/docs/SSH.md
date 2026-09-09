# [SSH config](https://github.com/my-repository-vendor-name/my-repository-app-name/blob/master/docs/SSH.md)

`${HOME}/.ssh/config`:

````
## my-app https://github.com/my-repository-vendor-name/my-repository-app-name/blob/master/docs/SSH.md
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
