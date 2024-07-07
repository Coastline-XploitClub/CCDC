# kubectl Cheat Sheet

## Kubectl autocomplete

### BASH

```bash
source <(kubectl completion bash) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.
echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.
```

You can also use a shorthand alias for kubectl that also works with completion:

```bash
alias k=kubectl
complete -o default -F __start_kubectl k
```

### A note on --all-namespaces

Appending `--all-namespaces` happens frequently enough that you should be aware of the shorthand for `--all-namespaces` which is `kubectl -A`.

## Kubectl context and configuration

Set which Kubernetes cluster `kubectl` communicates with and modifies configuration information. See Authenticating Across Clusters with kubeconfig documentation for detailed config file information.

```bash
kubectl config view # Show Merged kubeconfig settings.

# use multiple kubeconfig files at the same time and view merged config
KUBECONFIG=~/.kube/config:~/.kube/kubconfig2

kubectl config view

# get the password for the e2e user
kubectl config view -o jsonpath='{.users[?(@.name == "e2e")].user.password}'

kubectl config view -o jsonpath='{.users[].name}'    # display the first user
kubectl config view -o jsonpath='{.users[*].name}'   # get a list of users
kubectl config get-contexts                          # display list of contexts
kubectl config current-context                       # display the current-context
kubectl config use-context my-cluster-name           # set the default context to my-cluster-name

kubectl config set-cluster my-cluster-name           # set a cluster entry in the kubeconfig

# configure the URL to a proxy server to use for requests made by this client in the kubeconfig
kubectl config set-cluster my-cluster-name --proxy-url=my-proxy-url

# add a new user to your kubeconf that supports basic auth
kubectl config set-credentials kubeuser/foo.kubernetes.com --username=kubeuser --password=kubepassword

# permanently save the namespace for all subsequent kubectl commands in that context.
kubectl config set-context --current --namespace=ggckad-s2

# set a context utilizing a specific username and namespace.
kubectl config set-context gce --user=cluster-admin --namespace=foo \
  && kubectl config use-context gce

kubectl config unset users.foo                       # delete user foo

# short alias to set/show context/namespace (only works for bash and bash-compatible shells, current context to be set before using kn to set namespace)
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'
```

## Kubectl output formatting

```bash
kubectl get pods -o yaml                          # output in YAML format, which includes the namespace
kubectl get pods -o yaml --export                 # export pod details in YAML format without cluster specific information
kubectl get pods -o json                          # output in JSON format, which includes the namespace
kubectl get pods -o jsonpath='{.items[*].spec.containers[*].image}' # Return a list of image names from the JSON output
kubectl get pods -o name                          # print only the resource name and nothing else
kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' # Return only the pod names
kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\t"}}{{.status.phase}}{{"\n"}}{{end}}' # Return a table of pod names and status
kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\t"}}{{.status.phase}}{{"\t"}}{{.spec.nodeName}}{{"\n"}}{{end}}' # Return a table of pod names, status and node name
kubectl get pods -o custom-columns=POD:.metadata.name,NODE:.spec.nodeName --sort-by=.spec.nodeName # Return a table using custom columns and sort by a column
kubectl get pods -o jsonpath='{.items[*].metadata.labels}' # Return labels of all pods
kubectl get pods -o jsonpath='{.items[*].spec.containers[*].image}' # Return a list of image names
kubectl get pods -o jsonpath='{.items[*].status.containerStatuses[*].restartCount}' # Return a list of restart counts for all containers
kubectl get pods -o jsonpath='{.items[*].metadata.labels.env}' # Return a list of label values (assumes all pods have the same label keys defined)
kubectl get pods -o jsonpath='{.items[*].metadata.labels.env}' --sort-by='.metadata.labels.env' # Return a list of label values, sorted by label key
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}' # Return a table using a Go template
kubectl get pods -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' # Return a list of pod names using tr

# get the version label of all pods with label app=cassandra
kubectl get pods --selector=app=cassandra rc -o \
  jsonpath='{.items[*].metadata.labels.version}'
```
