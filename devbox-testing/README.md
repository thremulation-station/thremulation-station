# Development Box Testing

WIP!


### requirements

- get access to core-dev wg network (see Slack)
- install dependencies
    - fedora: 
        - vagrant install **from .rpm file**: https://releases.hashicorp.com/vagrant/
        - vagrant plugin install winrm
        - vagrant plugin install winrm-fs
- jump into `devbox-testing` dir
- download all .box files from the latest commit folder on webserver @ tailscaleip
    - `curl -LO http://<WGIP>/35a1cbd/boxes.tar.gz ./boxes`


### extract and delete tar
- tar xzvf boxes.tar.gz
- rm boxes.tar.gz


### import boxes

```
vagrant box add --name dev-centos7 virtualbox-dev-centos7-1634356024.box
vagrant box add --name dev-redops virtualbox-dev-debian11-red-1634353128.box
vagrant box add --name dev-elastic virtualbox-dev-elastic-1634353447.box
vagrant box add --name dev-windows10 virtualbox-dev-windows10-1634356065.box

```

- TODO: make a cool loop for this, had issues with the `add` arg requiring a local name

- confirm import:

```
[admin@localhost devbox-testing]$ vagrant box list
dev-centos7          (virtualbox, 0)
dev-redops           (virtualbox, 0)
dev-elastic          (virtualbox, 0)
dev-windows10        (virtualbox, 0)
```


<!-- ### run devbox-testing vagrant file

working dir: `thremulation-station/devbox-testing`   -->

- spin range using local dev-boxes: `vagrant up`
