Recommended structure for your setup

Since you're running K3s + Helm + ArgoCD, a clean structure is:

├── applications
│   ├── frontend.yaml
│   ├── backend.yaml│   
│   └── istio-gateway.yaml
│
├── helm
│   ├── frontend
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   └── backend
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│
└── infrastructure
    ├── istio-gateway        # Gateway + VirtualService for routing 

Each application.yaml defines one ArgoCD Application. Set repoURL in each to your git repo.

Even better (most scalable pattern)

Use App of Apps pattern.

Example:

argocd-gitops
│
├── apps
│   ├── frontend.yaml
│   ├── backend.yaml
│   
│
└── root-app.yaml


You install only one app manually:

root-app


ArgoCD then creates all other applications automatically.