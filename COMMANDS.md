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

## Helm: install/upgrade application
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

### Delete release in namespace with helm

```bash
helm uninstall frontend -n george-app
helm uninstall backend -n george-app
```

---

## ArgoCD applications

### List ArgoCD applications in all namespaces

```bash
k get applications -A
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
