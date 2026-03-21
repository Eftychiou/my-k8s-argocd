# Kubernetes & ArgoCD Commands Reference

Quick reference for common operations in this cluster.

---

## Port forwarding

Forward local ports to cluster services for local access.

### Istio ingress gateway

```bash
k port-forward -n istio-system svc/istio-ingressgateway 8080:80
```

Maps local port **8080** to the Istio ingress gateway (port 80). Use `http://localhost:8080` to hit services routed through Istio.

### ArgoCD server

```bash
k port-forward -n argocd svc/argocd-server 8081:443
```

Maps local port **8081** to the ArgoCD server (HTTPS). ArgoCD UI: **george.com:8081** (when that host resolves to your machine).

---

## ArgoCD URL and access

- **ArgoCD URL:** `george.com:8081` (with port-forward running on 8081)
- **Default user:** `admin`

---

## ArgoCD admin password

### Reset admin password (use initial secret again)

```bash
k -n argocd patch secret argocd-secret -p '{"data": {"admin.password": null, "admin.passwordMtime": null}}'
```

Clears the stored admin password so ArgoCD falls back to the initial admin secret.

### Restart ArgoCD server after password change

```bash
k -n argocd rollout restart deploy/argocd-server
```

(Note: original had a typo `k-n`; use `k -n`.)

### Get initial admin password from secret

```bash
k -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

Decodes and prints the initial admin password.

- **Credentials:** `admin` / `xLl9a5q0YwB4vtT8` (replace with your actual value from the command above)

---


## General kubectl commands

### List pods in all namespaces

```bash
k get pods --all-namespaces
```

### Set default namespace for current context

```bash
k config set-context --current --namespace=george-app
```

Subsequent `k` commands use `george-app` unless `-n` is specified.

### Shell into a pod

```bash
k exec -it frontend-768f7b79fc-svvnt -- /bin/sh
```

Replace pod name as needed. Use `k get pods -n <namespace>` to find names.

### Restart all deployments in a namespace

```bash
k rollout restart deployment -n istio-system
```

### Restart ArgoCD deployments

```bash
kubectl rollout restart deployment -n argocd
```

---

## ArgoCD applications

### List ArgoCD applications in all namespaces

```bash
k get applications -A
```
### Delete ArgoCD application
```bash
kubectl delete application my-k8s-argocd-root
```

### Get all Resources

```bash
k get all
```


Shows Application custom resources managed by ArgoCD.

---

## Istio gateway and virtual service

### List Gateway and VirtualService in `istio-system`

```bash
k get gateway,virtualservice -n istio-system
```

Example output:

```
NAME                                                       GATEWAYS             HOSTS            AGE
virtualservice.networking.istio.io/george-virtualservice   ["george-gateway"]   ["george.com"]   2m
```

Confirms that `george.com` is routed via `george-gateway` and `george-virtualservice`.

# Helm

### Not monorepo
```bash
helm upgrade --install backend ./helm/backend --namespace george-app --create-namespace
helm upgrade --install frontend ./helm/frontend --namespace george-app --create-namespace
```

From repo root.

### Install or upgrade `george-app` (with namespace creation)

```bash
helm upgrade --install george-app ./helm -n george-app --create-namespace -f helm/values.yaml
```

### Install or upgrade `george-app` (namespace must exist)

```bash
helm upgrade --install george-app ./helm -n george-app -f helm/values.yaml
```

### Install/upgrade shared Helm chart as `istio-system` in `george-app` namespace

```bash
helm upgrade --install istio-system ./_helm --namespace george-app --create-namespace
```

### Install/upgrade shared Helm chart as `george-app` in `istio-system` namespace

```bash
helm upgrade --install george-app ./_helm --namespace istio-system
```



### List relesases
```bash
helm list -A
```

### List repos
```bash
helm repo list
```

### Delete Release
```bash
helm uninstall traefik-crd -n kube-system
```

## Delete finalizers
```bash
for app in $(kubectl get applications -n argocd -o jsonpath='{.items[*].metadata.name}'); do
  kubectl patch application $app -n argocd -p '{"metadata":{"finalizers":[]}}' --type=merge
done
```



## Install argo-cd

Bootstrap once with Helm, then let the root `Application` sync everything under `applications/`, including self-management of Argo CD via `applications/argocd.yaml`. That manifest pins the **argo-helm chart version** (e.g. `9.4.11` — run `helm list -n argocd` and set `targetRevision` to match) and uses `skipCrds: true` to mirror `--skip-crds`. Customize Argo CD by editing that file (add a `helm.values` block) instead of ad-hoc `helm upgrade`.

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace --skip-crds
k apply -f bootstrap/root-app.yaml
k port-forward service/argocd-server -n argocd 8081:443
k port-forward -n istio-system svc/istio-ingressgateway 8080:80
k port-forward -n traefik svc/traefik 8080:80
k -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
example  admin DwbYXQjTZ0c41wqu
```

## Being on a worker/master node you can get inside the cluster in a debug mode
```bash
kubectl run debug --rm -it --image=nicolaka/netshoot -- bash
curl http://frontend.george-app.svc.cluster.local
```

