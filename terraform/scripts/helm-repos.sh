#!/bin/bash
set -euo pipefail

echo "Adding & installing Keptn Ortelius Service & Ortelius"

helm repo add keptn-ortelius-service https://ortelius.github.io/keptn-ortelius-service
helm repo add ortelius https://ortelius.github.io/ortelius-charts/
helm install my-ms-dep-pkg-cud ortelius/ms-dep-pkg-cud --version 10.0.0-build.66
helm install my-ms-compitem-crud ortelius/ms-compitem-crud --version 10.0.0-build.78
helm install my-ms-dep-pkg-r ortelius/ms-dep-pkg-r --version 10.0.0-build.53
helm install my-ms-validate-user ortelius/ms-validate-user --version 10.0.0-build.48
helm install my-keptn-ortelius-service keptn-ortelius-service/keptn-ortelius-service --version 0.0.1

echo "Done"