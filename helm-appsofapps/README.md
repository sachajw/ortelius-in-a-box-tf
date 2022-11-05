# Helm Chart for ArgoCD Apps of Apps

This helm chart allows us to manage ArgoCD Applications by grouping them into other Applications in
the [App of Apps Pattern](https://argoproj.github.io/argo-cd/operator-manual/cluster-bootstrapping/#app-of-apps-pattern).

## Usage

- Ensure the App of Apps repository is managed in [helm/values-common.yaml](../helm/values-common.yaml).
- Add the App of Apps name to [values.yaml](values.yaml).

For each app, the template will create an Application with the name `apps-{{ $app }}`, based in the repository `azt-grl/argocdapps-{{ $app }}.git`.

### Importing an existing App of Apps

If you are adding an existing Application, you may get this error when following the steps above:

```
Error: rendered manifests contain a resource that already exists. Unable to continue with update: Application "apps-playground" in namespace "argocd" exists and cannot be imported into the current release: invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "argocdappsofapps"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "argocd"
```

The solution requires the following metadata to be applied manually before applying the change in the code:

|Type|Key|Value|
---|---|---
|Label|app.kubernetes.io/managed-by|Helm|
|Annotation|meta.helm.sh/release-name|argocdappsofapps|
|Annotation|meta.helm.sh/release-namespace|argocd|
