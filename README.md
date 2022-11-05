### Start here and work your way down one stair at a time
#### Windows 10
- Latest version & fully updated
- Enable `WSL2` | Go to `Programs and features` --> `Turn Windows features on or off` --> `Windows Subsystem for Linux`
- We recommend using a second disk if you have one in your machine to create the custom folder to house the VMDK
- This splits up the I/O between the Windows OS and WSL2 which is just a stripped down virtual machine
- Install Windows Terminal [here](https://docs.microsoft.com/en-us/windows/terminal/install) for easier management and get familiar with the documentation
- Use this [documentation](https://www.windowscentral.com/how-install-ubuntu-2110-wsl-windows-10-and-11) to install the latest `Ubuntu` flavour, don't bother with the Microsoft store ( We recommend `Ubuntu Jammy JellyFish` at this time of writing)
#### Line feed ending hell
- Line feed ending hell can be solved with this VSCode extension [here](https://marketplace.visualstudio.com/items?itemName=vs-publisher-1448185.keyoti-changeallendoflinesequence) or [Dos2Unix](https://www.computerhope.com/unix/dos2unix.htm) as another option
- Windows uses CRLF
- Linux uses LF
- This [Stackoverflow article](https://stackoverflow.com/questions/2920416/configure-bin-shm-bad-interpreter) can help you understand whats going on
- Example error `/bin/sh^M:bad interpreter`
- Suggestion Alert: Set your `VSCode` to `LF` and only use `WSL2` to do all your work
- [Terms & Conditions](https://www.microsoft.com/en-us/Useterms/Retail/Windows/10/UseTerms_Retail_Windows_10_English.htm)

#### Windows 11
- Similar setup to Win10
- Latest version & fully updated
- [Terms & Conditions](https://www.microsoft.com/en-us/UseTerms/Retail/Windows/11/UseTerms_Retail_Windows_11_English.htm)

#### Package Manager for Windows
- [Chocolatey](https://chocolatey.org/)

### Configs for WSL
#### Windows Operating System
`c:\Users\beavis\.wslconfig`
```
# Settings apply across all Linux distros running on WSL 2
[wsl2]

# Limits VM memory to use no more than 4 GB, this can be set as whole numbers using GB or MB
memory=4GB

# Sets the VM to use two virtual processors
processors=2

# Specify a custom Linux kernel to use with your installed distros.
# The default kernel used can be found at https://github.com/microsoft/WSL2-Linux-Kernel
#kernel=C:\\temp\\myCustomKernel

# Sets additional kernel parameters, in this case enabling older Linux base images such as Centos 6
#kernelCommandLine = vsyscall=emulate

# Sets amount of swap storage space to 8GB, default is 25% of available RAM
swap=4GB

# Sets swapfile path location, default is %USERPROFILE%\AppData\Local\Temp\swap.vhdx
swapfile=D:\\wsl\\ubuntu-22-04-lts\\wsl-swap.vhdx

# Disable page reporting so WSL retains all allocated memory claimed from Windows and releases none back when free
pageReporting=false

# Turn off default connection to bind WSL 2 localhost to Windows localhost
localhostforwarding=true

# Disables nested virtualization
nestedVirtualization=false

# Turns on output console showing contents of dmesg when opening a WSL 2 distro for debugging
debugConsole=true
[user]
default = beavis

[automount]
options = "metadata"

# Limits VM memory to use no more than 4 GB, this can be set as whole numbers using GB or MB
memory=4GB

```
#### WSL Ubuntu Linux Virtual Machine
`\etc\wsl.conf`
```
# Automatically mount Windows drive when the distribution is launched
[automount]

# Set to true will automount fixed drives (C:/ or D:/) with DrvFs under the root directory set above. Set to false means drives won't be mounted automatically, but need to be mounted manually or with fstab.
enabled = true

# Sets the directory where fixed drives will be automatically mounted. This example changes the mount location, so your C-drive would be /c, rather than the default /mnt/c.
root = /

# DrvFs-specific options can be specified.
options = "metadata,uid=1003,gid=1003,umask=077,fmask=11,case=off"

# Sets the `/etc/fstab` file to be processed when a WSL distribution is launched.
mountFsTab = true

# Network host settings that enable the DNS server used by WSL 2. This example changes the hostname, sets generateHosts to false, preventing WSL from the default behavior of auto-generating /etc/hosts, and sets generateResolvConf to false, preventing WSL from auto-generating /etc/resolv.conf, so that you can create your own (ie. nameserver 1.1.1.1).
[network]
hostname = DemoHost497686

generateHosts = false
generateResolvConf = false

# Set whether WSL supports interop process like launching Windows apps and adding path variables. Setting these to false will block the launch of Windows processes and block adding $PATH environment variables.
[interop]
enabled = false
appendWindowsPath = false

# Set the user when launching a distribution with WSL.
[user]
default = DemoUser

# Set a command to run when a new WSL instance launches. This example starts the Docker container service.
[boot]
command = service docker start
```

### Linux
#### [Ubuntu](https://ubuntu.com/)
- [Terms & Conditions](https://ubuntu.com/legal/intellectual-property-policy)
#### [CentOS](https://www.centos.org/)
- [Terms & Conditions](https://www.centos.org/legal/licensing-policy/)

### Linux Package Managers
#### [APT](https://manpages.ubuntu.com/manpages/xenial/man8/apt.8.html) for Ubuntu
- [Terms & Conditions](https://ubuntu.com/legal/intellectual-property-policy)
#### [YUM](https://man7.org/linux/man-pages/man8/yum.8.html) for Centos
- [Terms & Conditions](https://www.centos.org/legal/licensing-policy/)

### MacOsS Package Managers
#### [Brew.sh](https://brew.sh/)
- [Terms & Conditions](https://github.com/Homebrew/brew/blob/master/LICENSE.txt)
#### [Macports.org](https://www.macports.org/)
- [Terms & Conditions](https://opensource.org/licenses/BSD-3-Clause)
#### `MANDATORY` [Docker Mac Net Connect](https://github.com/chipmk/docker-mac-net-connect)
- Accessing containers directly by IP (instead of port binding) can be useful and convenient.
- Unlike Docker on Linux, Docker-for-Mac does not expose container networks directly on the macOS host.
- Docker-for-Mac works by running a Linux VM under the hood (using hyperkit) and creates containers within that VM.
- Docker-for-Mac supports connecting to containers over Layer 4 (port binding), but not Layer 3 (by IP address).

***Solution***
- Create a minimal network tunnel between macOS and the Docker Desktop Linux VM.
- The tunnel is implemented using WireGuard.

#### Install via Homebrew
```
brew install chipmk/tap/docker-mac-net-connect
```
#### Run the service and register it to launch at boot
```
brew services start chipmk/tap/docker-mac-net-connect
```
```
sudo brew services start chipmk/tap/docker-mac-net-connect
```

### `OPTIONAL` [Topgrade | Update everything with one command](https://github.com/r-darwish/topgrade)
- [Topgrade Wiki](https://github.com/r-darwish/topgrade/wiki/Step-list)
- Supports all operating systems
- Topgrade config file is here `.config/topgrade.toml`
- All I need to type now on my [`zsh terminal`](https://ohmyz.sh/) is `topgrade`
- It upgrades all my package managers including the packages, Mac store apps and Mac OS updates
- It can do so much more | We will leave you to explore
- [Terms & Conditions](https://github.com/r-darwish/topgrade/blob/master/LICENSE)

### [Devdocs.io | The application command encyclopedia & yes you can access it offline](https://devdocs.io/)
- `Bash, CSS, Docker, Flask, Git, Go, Brew, HTML, HTTP, Java, JavaScript, Markdown, Nginx, Nodejs, npm, Python, Kubectl, Kubernetes` and so much more
- [Terms & Conditions](https://github.com/freeCodeCamp/devdocs/blob/main/LICENSE)

### `OPTIONAL` [WARP](https://www.warp.dev/) The Terminal for the 21st Century
- Documentation is [here](https://docs.warp.dev/getting-started/readme)
- [Terms & Conditions](https://github.com/warpdotdev/Warp/blob/main/LICENSE)

### `OPTIONAL` [SDKMan.io | For managing all things Java | SDKs | JDKs](https://sdkman.io/)
- Usage [here](https://sdkman.io/usage)
- [Terms & Conditions](https://github.com/sdkman/sdk/blob/master/LICENSE)

### `OPTIONAL` [Discord.com](https://discord.com/)
- Discord is global human interaction
- Set yourself up with your very own `Discord server`
- Create a dedicated channel for `Git Guardian alerts`
- `Do this before Git Guardian`
- GitHub webhooks are [here](https://support.discord.com/hc/en-us/articles/228383668)
- [Terms & Conditions](https://discord.com/terms)

### `OPTIONAL` [Git Guardian.com](https://www.gitguardian.com/)
- Set yourself up for free
- This tool will warn you when you accidently put sensitive information on the public internet in your repos
- Go to `VCS Integrations` and add your `GitHub` (You will need to set yourself up on [GitHub](https://github.com) first)
- Go to `Alerting` and setup `Discord` notifications
- Support for `CI|CD` pipelines such as `Azure, Bitbucket, Circle CI, Drone CI, GitHub Actions, GitLab, Jenkins & Travis`
- Support for `Git Hooks`
- Support for `Docker` | [Docker image integration](https://docs.gitguardian.com/internal-repositories-monitoring/integrations/docker/docker_image)
- Alerting for `Discord, Custom Webhook, Jira, Pager Duty, Slack, Splunk`
- Discord integrations are [here](https://docs.gitguardian.com/internal-repositories-monitoring/notifications/discord)
- [Terms & Conditions](https://www.gitguardian.com/legal-terms)

### `OPTIONAL` [YADM.io](https://yadm.io/) Yet Another Dot File Manager
- In Linux you end up with a lot of config files which usually start with `.`
- The dot files have configurations for various application packages installed on your machine
- YADM allows you to keep the dot files of your choice backed up to a repository
- Documentation [here](https://github.com/TheLocehiliosan/yadm/blob/master/yadm.md)
- [Terms & Conditions](https://github.com/TheLocehiliosan/yadm/blob/master/LICENSE)

### Choose between Docker or Podman
- [Read this article to gain a holistic understanding of PodMan vs Docker](https://www.lambdatest.com/blog/podman-vs-docker/)

### [Git-scm.com](https://git-scm.com/)
- Install Git for all things source control
- Set up Git [here](https://docs.github.com/en/get-started/quickstart/set-up-git)
- Get familiar with the basic commands such as pushing and pulling of changes and creating branches
- Use [Devdocs](https://devdocs.io/) and the Git documentation [here](https://git-scm.com/doc)
- [Terms & Conditions](https://git-scm.com/sfc)
- [Software Freedom Conservancy](https://sfconservancy.org/)

#### `.gitconfig` inspiration
```
[core]
	excludesfile = /Users/beavis/.gitignore_global
[alias]
# Make sure you're adding under the [alias] block.
# Git Commit, Add all and Push in one step.
# Using functions in Git
cap = "!f() { git add .; git commit -m \"$@\"; git push; }; f"
# NEW.
new = "!f() { git cap \"📦 NEW: $@\"; }; f"
# IMPROVE.
imp = "!f() { git cap \"👌 IMPROVE: $@\"; }; f"
# FIX.
fix = "!f() { git cap \"🐛 FIX: $@\"; }; f"
# RELEASE.
rlz = "!f() { git cap \"🚀 RELEASE: $@\"; }; f"
# DOC.
doc = "!f() { git cap \"📖 DOC: $@\"; }; f"
# TEST.
tst = "!f() { git cap \"🤖 TEST: $@\"; }; f"
# BREAKING CHANGE.
brk = "!f() { git cap \"‼️ BREAKING: $@\"; }; f"
[user "https://github.com"]
	name = Beavis Zombie
	email = beavis.zombie@allianz.de
[core]
	repositoryformatversion = 0
        filemode = false
        bare = false
        logallrefupdates = false
[init]
  defaultBranch = main
	templatedir = /Users/beavis/.git_template
[pull]
	rebase = false
[credential "https://github.com"]
	helper = store
[credential "https://gist.github.com"]
	helper = store
[help]
	autocorrect = 1
[advice]
	addIgnoredFile = false

[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true
[web]
	browser = firefox
```

### [Agile Delivery Platform Support](https://github.developer.allianz.io/AgileDeliveryPlatform)
- [adp-2fa config and installation](https://github.developer.allianz.io/AgileDeliveryPlatform/2fa/tree/master/adp-2fa)
- adp-2fa provides two-factor authentication to access Github Enterprise from outside sources
- [ADP 101](https://github.developer.allianz.io/AgileDeliveryPlatform/ADP-101/blob/master/getting-started/GETTING-STARTED-GITHUB.md)
- [Git Credential Manager Core](https://github.com/microsoft/Git-Credential-Manager-Core) helps greatly to manage credentials securely
- [Log a GitHub Enterprise support requests](https://github.developer.allianz.io/AgileDeliveryPlatform/Support/issues)

### [VSCode](https://code.visualstudio.com/) IDE
- Download the `VSCode IDE` [here](https://code.visualstudio.com/download)
- Security starts in the IDE
- [Terms & Conditions](https://code.visualstudio.com/License/)

#### Helpful Extensions
- Install `Snyk Security | Code & Open Source Dependencies` scanner [here](https://marketplace.visualstudio.com/items?itemName=snyk-security.snyk-vulnerability-scanner)
- Install `Language Support for Java by Red Hat` [here](https://marketplace.visualstudio.com/items?itemName=redhat.java)
- Install `Yaml` support [here](https://marketplace.visualstudio.com/items?itemName=redhat.java)
- Install `Indent Rainbow` [here](https://marketplace.visualstudio.com/items?itemName=redhat.java)
- Install `Change All End of Line Sequence` [here](https://marketplace.visualstudio.com/items?itemName=vs-publisher-1448185.keyoti-changeallendoflinesequence)
- Install `ToDo Tree` [here](https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree)

### [Docker.com](https://www.docker.com/)
- [Account setup](https://hub.docker.com/signup)
- [Install](https://docs.docker.com/get-docker/)
- Get familiar with the basic commands
- Use [Devdocs](https://devdocs.io/) and the Docker documentation [here](https://docs.docker.com/)
- [Terms & Conditions](https://www.docker.com/legal/docker-terms-service/)

**Docker Security**
- Bake security right in from the word go
- We are going to use Snyk to scan our containers
- Snyk is free and you can set yourself up [here](https://snyk.io/)
- [Terms & Conditions for Snyk](https://snyk.io/policies/terms-of-service/)
- In `Docker Desktop` go to the ` Extensions Marketplace` and install the `Snyk Container Extension`
- On your command line you can now scan your Docker images with `docker scan your-docker-image`
- Disclaimer: Please follow any prompts `Snyk` requires you to fulfill to get up and running

#### .docker/config.json
```
{
	"auths": {
		"<account number>.dkr.ecr.eu-central-1.amazonaws.com": {},
		"https://index.docker.io/v1/": {}
	},
	"credsStore": "desktop",
	"currentContext": "desktop-linux"
}
```
### Helpful commands
#### List images
```
docker image list | grep <account number>
```
#### Copy
```
docker cp ~/.docker/config.json ortelius-in-a-box-control-plane:/var/lib/kubelet/config.json
```
#### Exec
```
docker exec -it ortelius-in-a-box-worker bash
```
#### Delete images
```
docker image rm <account number>.dkr.ecr.eu-central-1.amazonaws.com/dex:v2.27.0
```

### AWS ECR
- Login in to AWS on the command line with your Allianz credentials to refresh your session token
#### Auth with ECR
```
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin <account number>.dkr.ecr.eu-central-1.amazonaws.com
```
- Pull the current images to the local machine at the time of writing
```
docker pull <account number>.dkr.ecr.eu-central-1.amazonaws.com/argocd:2.0.5.803-165841
```
```
docker pull <account number>.dkr.ecr.eu-central-1.amazonaws.com/dex:v2.27.0
```
```
docker pull <account number>.dkr.ecr.eu-central-1.amazonaws.com/redis:6.2.4-alpine
```

### Container Registries
#### [AWS Public registry](https://gallery.ecr.aws/)
- [Terms & Conditions](https://aws.amazon.com/service-terms/)
### AWS ortelius registry
- `<account number>.dkr.ecr.eu-central-1.amazonaws.com`

#### [Kind.sigs.k8s.io](https://kind.sigs.k8s.io/)
- Install [here](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- Kind allows you to use Docker to run K8s nodes as containers
- Get familiar with the basic commands
- Checkout the Kind documentation [here](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [Terms & Conditions](https://www.apache.org/licenses/LICENSE-2.0)

#### Why kind?
- kind supports multi-node (including HA) clusters
- kind supports building Kubernetes release builds from source
- support for make / bash or docker, in addition to pre-published builds
- kind supports Linux, macOS and Windows
- kind is a `CNCF certified conformant Kubernetes installer`

### Helpful tool
#### Container Runtime Interface (CRI) CLI
- crictl is available [here](https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md)
#### using `wget`
```
VERSION="v1.24.1"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz
```
#### using `curl`
```
VERSION="v1.24.1"
curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-${VERSION}-linux-amd64.tar.gz --output crictl-${VERSION}-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz
```

### Helpful commands
#### Get the list of nodes
```
kind get nodes -n ortelius-in-a-box
```
#### Cluster info
```
kubectl cluster-info --context ortelius-in-a-box
```
#### Logs
```
kind export logs -n ortelius-in-a-box
```
#### Load images onto the container nodes
```
kind load docker-image --name ortelius-in-a-box --nodes ortelius-in-a-box-control-plane,ortelius-in-a-box-worker,ortelius-in-a-box-worker2 <account number>.dkr.ecr.eu-central-1.amazonaws.com/redis:6.2.4-alpine
```

#### [Kubernetes.io](https://kubernetes.io/)
- K8s is a production grade container orchestrater
- [Terms & Conditions](https://www.linuxfoundation.org/legal/terms#:~:text=Users%20are%20solely%20responsible%20for,arising%20out%20of%20User%20Content.)
- [Creative Commons](https://creativecommons.org/licenses/by/3.0/)

#### Kubectl
- Install `kubectl` the command line tool [here](https://kubernetes.io/docs/tasks/tools/)
- Use the `kubectl` cheat sheet [here](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- Use [Devdocs](https://devdocs.io/) and the official documentation [here](https://kubernetes.io/docs/home/)
- Add the `aliases` & `auto complete` which are in the `cheat sheet`

#### Helpful tools
#### Kubectx for switching context
```
kubectx kind-ortelius-in-a-box
```
#### Kubens for switching namespaces
```
kubens argocd
```
- Download [here](https://github.com/ahmetb/kubectx)
#### imagpullsecret-patcher

A simple Kubernetes client-go application that creates and patches imagePullSecrets to service accounts in all Kubernetes namespaces to allow cluster-wide authenticated access to private container registry.
- Download [here](https://github.com/titansoft-pte-ltd/imagepullsecret-patcher)

### Helm
- Install Helm [here](https://helm.sh/)
- Also known as the package manager for Kubernetes
#### Please make sure you add the following Helm packages
```
helm repo add argo https://argoproj.github.io/argo-helm
```
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```
#### Use `helm repo list` to make sure they are there
```
helm repo list
```
### Helpful tips
#### Update Helm repos
```
helm repo update
```
#### Lint
```
helm lint ./helm-appsofapps
```
#### Debug
```
helm template ./helm-appsofapps --debug
```
#### Dry-run
```
helm install argocd ./helm-appsofapps --dry-run
```
#### Dry-run with Debug
```
helm install argocd ./helm-appsofapps --dry-run --debug
```

### [Terraform](https://www.terraform.io/intro)
- Install Terraform [here](https://www.terraform.io/downloads)
- Documentation is [here](https://www.terraform.io/docs)
- [Terms & Conditions](https://registry.terraform.io/terms)
#### Steps to get going
- Clone `helm-argocd` [here](https://github.developer.allianz.io/azt-grl/helm-argocd)
- Navigate to `helm-argocd/terraform`
- Make sure you are on the `acm-in-a-box` branch
- Run the following
```
terraform init
```
```
terraform plan
```
```
terraform apply
```
- You should see something like in the image in Docker Desktop
 ![ortelius Docker nodes!](images/docker/ortelius-nodes-docker.jpg "ortelius Docker nodes")

### Helpful tips
#### Logs
In total, there 5 log levels which can be used for debugging purposes:

- `TRACE` one of the most descriptive log levels, if you set the log level to *TRACE,* Terraform will write every action and step into the log file.
- `DEBUG` a little bit more sophisticated logging which is used by developers at critical or more complex pieces of code to reduce debugging time.
- `INFO` the info log level is useful when needing to log some informative instructions or readme type instructions.
- `WARN` used when something is not critical but would be nice to include in the form of a log so that the developer can make adjustments later.
- `ERROR` as the name suggests, this is used if something is terribly wrong and is a blocker.
```
export TF_LOG="DEBUG"
```
```
export TF_LOG_PATH="/beavis/terraform-debug.log"
```