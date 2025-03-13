# xnat

Helm Chart for XNAT

## Local Installation

### Create a local cluster

Create a cluster into which the chart will be installed using your preferred
method. For example, using [kind](https://kind.sigs.k8s.io/):

```shell
kind create cluster --name xnat
```

### Install the CNPG Operator

We use the [CNPG Operator](https://github.com/cloudnative-pg/cloudnative-pg) to
deploy Postgres. The operator can be installed using Helm:

```bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg
```

### Create a namespace to install the chart

Create a manifest for the namespace:

```bash
cat <<EOF > namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: xnat-core
EOF
```

Create the namespace:

```bash
kubectl apply -f namespace.yaml
```

### Create a secret containing Postgres and XNAT credentials

Create a manifest for the secret:

```bash
cat <<EOF > secrets.yaml
apiVersion: v1
stringData:
  username: xnat
  password: xnat
kind: Secret
metadata:
  name: pg-user-secret
  namespace: xnat-core
type: kubernetes.io/basic-auth
---
apiVersion: v1
stringData:
  adminPassword: strongPassword
  serviceAdminPassword: anotherStrongPassword
kind: Secret
metadata:
  name: localdb-secret
  namespace: xnat-core
type: kubernetes.io/basic-auth
EOF
```

Create the secret:

```bash
kubectl apply -f secrets.yaml
```

### Package and install `xnat-chart`

To install a local copy of the chart, first create a package:

```shell
helm package --dependency-update chart
```

Then install the packaged chart in the cluster with the following command:

```shell
helm install \
--set image.name=xnat-core \
--set image.tag=0.0.2 \
--set imageCredentials.enabled=true \
--set imageCredentials.registry=ghcr.io \
--set imageCredentials.username=<GH_USERNAME> \
--set imageCredentials.password=<GH_PAT> \
--namespace xnat-core \
xnat-core xnat-0.0.13.tgz
```

Set `image.tag` to the version of the
[XNAT image](https://github.com/UCL-MIRSG/xnat-image/pkgs/container/xnat-core)
you would like to use.

[Create a PAT](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic)
with `read:packages` scope. Use the PAT to set `imageCredentials.password`.

Set `imageCredential.username` to be your GitHub username.

### Uninstall the chart

Uninstall the chart using the following command:

```shell
helm uninstall xnat-core -n xnat-core
```

### Render the chart

The chart can be rendered using the default values with the following command:

```shell
helm template xnat-core ./xnat-0.0.13.tgz > build/chart.yaml
```

### Storage

The default values set for `volumes` will use emptyDir volumes. This means that
the volume shares the pod's lifetime and will be deleted when the pod is
deleted. To persist data set `volumes.persistent` to `true` and optionally set a
storage class with `volumes.storageClass`. For example if deploying on a local
Kubernetes cluster with [k3d](https://k3d.io/) you can make use of the default
storage class `local-path` to persist data to the host. Setting
`volumes.persistent` to `true` and `volumes.storageClass` to `local-path` would
create persistent volume claims from the `VolumeClaimTemplate` defined by the
statefulset and dynamically provision the volumes. If you set
`volumes.persistent` to `true` and set `volumes.existingClaim` you will need to
manually create the persistent volume claims before deploying the chart.

## Parameters

### Common parameters

| Name                                          | Description                                             | Value                   |
| --------------------------------------------- | ------------------------------------------------------- | ----------------------- |
| `replicaCount`                                | Number of replicas                                      | `2`                     |
| `image.pullPolicy`                            | image pull policy                                       | `IfNotPresent`          |
| `image.pullSecret`                            | Name of secret used to pull image                       | `""`                    |
| `image.registry`                              | Image registry                                          | `ghcr.io`               |
| `image.namespace`                             | Image registry namespace                                | `ucl-mirsg`             |
| `image.name`                                  | Name of the image in the registry                       | `""`                    |
| `image.tag`                                   | Image tag                                               | `latest`                |
| `imageCredentials.enabled`                    | Enable or disable image pull secret                     | `false`                 |
| `imageCredentials.registry`                   | Image registry                                          | `""`                    |
| `imageCredentials.username`                   | Image registry username                                 | `""`                    |
| `imageCredentials.password`                   | Image registry password                                 | `""`                    |
| `imageCredentials.email`                      | Image registry email                                    | `""`                    |
| `nameOverride`                                | Override name                                           | `""`                    |
| `fullnameOverride`                            | Override fullname                                       | `""`                    |
| `serviceAccount.create`                       | Specifies whether a service account should be created   | `true`                  |
| `serviceAccount.automount`                    | Automatically mount a ServiceAccount's API credentials? | `true`                  |
| `serviceAccount.annotations`                  | Annotations to add to the service account               | `{}`                    |
| `serviceAccount.name`                         | The name of the service account to use.                 | `""`                    |
| `service.port`                                | Service port                                            | `80`                    |
| `service.type`                                | Service type                                            | `ClusterIP`             |
| `service.targetPort`                          | Service target port                                     | `8080`                  |
| `volumes.xnat-build.accessMode`               | XNAT build volume access modes                          | `ReadWriteOnce`         |
| `volumes.xnat-build.annotations`              | XNAT build volume annotations                           | `{}`                    |
| `volumes.xnat-build.existingClaim`            | XNAT build volume existingClaim                         | `false`                 |
| `volumes.xnat-build.persistent`               | XNAT build volume persistent                            | `true`                  |
| `volumes.xnat-build.size`                     | XNAT build volume size                                  | `1Gi`                   |
| `volumes.xnat-build.storageClass`             | XNAT build volume storageClass                          | `nil`                   |
| `volumes.xnat-cache.accessMode`               | XNAT cache volume access modes                          | `ReadWriteOnce`         |
| `volumes.xnat-cache.annotations`              | XNAT cache volume annotations                           | `{}`                    |
| `volumes.xnat-cache.existingClaim`            | XNAT cache volume existingClaim                         | `false`                 |
| `volumes.xnat-cache.persistent`               | XNAT cache volume persistent                            | `true`                  |
| `volumes.xnat-cache.size`                     | XNAT cache volume size                                  | `10Gi`                  |
| `volumes.xnat-cache.storageClass`             | XNAT cache volume storageClass                          | `nil`                   |
| `volumes.xnat-home.accessMode`                | XNAT home volume access modes                           | `ReadWriteOnce`         |
| `volumes.xnat-home.annotations`               | XNAT home volume annotations                            | `{}`                    |
| `volumes.xnat-home.existingClaim`             | XNAT home volume existingClaim                          | `false`                 |
| `volumes.xnat-home.persistent`                | XNAT home volume persistent                             | `true`                  |
| `volumes.xnat-home.size`                      | XNAT home volume size                                   | `10Gi`                  |
| `volumes.xnat-home.storageClass`              | XNAT home volume storageClass                           | `nil`                   |
| `volumeMounts.xnat-build.mountPath`           | XNAT build volume mount path                            | `/data/xnat/build`      |
| `volumeMounts.xnat-build.subPath`             | XNAT build volume sub path                              | `nil`                   |
| `volumeMounts.xnat-cache.mountPath`           | XNAT cache volume mount path                            | `/data/xnat/cache`      |
| `volumeMounts.xnat-cache.subPath`             | XNAT cache volume sub path                              | `nil`                   |
| `volumeMounts.xnat-home.mountPath`            | XNAT home volume mount path                             | `/data/xnat/home`       |
| `volumeMounts.xnat-home.subPath`              | XNAT home volume sub path                               | `nil`                   |
| `extraVolumes.xnat-archive.accessMode`        | XNAT archive volume access modes                        | `ReadWriteOnce`         |
| `extraVolumes.xnat-archive.annotations`       | XNAT archive volume annotations                         | `{}`                    |
| `extraVolumes.xnat-archive.existingClaim`     | XNAT archive volume existingClaim                       | `false`                 |
| `extraVolumes.xnat-archive.persistent`        | XNAT archive volume persistent                          | `true`                  |
| `extraVolumes.xnat-archive.size`              | XNAT archive volume size                                | `10Gi`                  |
| `extraVolumes.xnat-archive.storageClass`      | XNAT archive volume storageClass                        | `nil`                   |
| `extraVolumes.xnat-prearchive.accessMode`     | XNAT prearchive volume access modes                     | `ReadWriteOnce`         |
| `extraVolumes.xnat-prearchive.annotations`    | XNAT prearchive volume annotations                      | `{}`                    |
| `extraVolumes.xnat-prearchive.existingClaim`  | XNAT prearchive volume existingClaim                    | `false`                 |
| `extraVolumes.xnat-prearchive.persistent`     | XNAT prearchive volume persistent                       | `true`                  |
| `extraVolumes.xnat-prearchive.size`           | XNAT prearchive volume size                             | `10Gi`                  |
| `extraVolumes.xnat-prearchive.storageClass`   | XNAT prearchive volume storageClass                     | `nil`                   |
| `extraVolumeMounts.xnat-archive.mountPath`    | XNAT archive volume mount path                          | `/data/xnat/archive`    |
| `extraVolumeMounts.xnat-archive.subPath`      | XNAT archive volume sub path                            | `nil`                   |
| `extraVolumeMounts.xnat-prearchive.mountPath` | XNAT prearchive volume mount path                       | `/data/xnat/prearchive` |
| `extraVolumeMounts.xnat-prearchive.subPath`   | XNAT prearchive volume sub path                         | `nil`                   |

### XNAT Web parameters

| Name                                                      | Description                                                | Value                                                       |
| --------------------------------------------------------- | ---------------------------------------------------------- | ----------------------------------------------------------- |
| `web.siteUrl`                                             | Site URL                                                   | `""`                                                        |
| `web.auth.openid.provider`                                | OpenID provider name                                       | `openid1`                                                   |
| `web.auth.openid.enabled`                                 | Enable or disable the config                               | `false`                                                     |
| `web.auth.openid.secretName`                              | Name of secret with clientID and clientSecret              | `openid-secret`                                             |
| `web.auth.openid.accessTokenUri`                          | OpenID access token URI                                    | `""`                                                        |
| `web.auth.openid.userAuthUri`                             | OpenID user authentication URI                             | `""`                                                        |
| `web.auth.openid.link`                                    | OpenID link                                                | `""`                                                        |
| `web.auth.localdb.secretName`                             | Name of secret with adminPassword and serviceAdminPassword | `localdb-secret`                                            |
| `web.podAnnotations`                                      | Annotations to add to the web pod                          | `{}`                                                        |
| `web.podLabels`                                           | Labels to add to the web pod                               | `{}`                                                        |
| `web.podSecurityContext.runAsUser`                        | Pod security context runAsUser                             | `1000`                                                      |
| `web.securityContext`                                     | Pod security context                                       | `{}`                                                        |
| `web.ingress.enabled`                                     | Enable or disable the ingress deployment                   | `false`                                                     |
| `web.ingress.className`                                   | Ingress class name                                         | `""`                                                        |
| `web.ingress.annotations`                                 | Ingress annotations                                        | `{}`                                                        |
| `web.ingress.hosts[0].host`                               | Ingress host                                               | `chart-example.local`                                       |
| `web.ingress.hosts[0].paths[0].path`                      | Ingress path                                               | `/`                                                         |
| `web.ingress.hosts[0].paths[0].pathType`                  | Ingress path type                                          | `ImplementationSpecific`                                    |
| `web.ingress.tls`                                         | Ingress TLS                                                | `[]`                                                        |
| `web.resources.limits.cpu`                                | CPU and memory limits                                      | `2`                                                         |
| `web.resources.limits.memory`                             | Memory limits                                              | `6000Mi`                                                    |
| `web.resources.requests.cpu`                              | CPU and memory requests                                    | `1`                                                         |
| `web.resources.requests.memory`                           | Memory requests                                            | `6000Mi`                                                    |
| `web.livenessProbe.failureThreshold`                      | Liveness probe failure threshold                           | `1`                                                         |
| `web.livenessProbe.httpGet.path`                          | Liveness probe httpGet path                                | `/app/template/Login.vm#!`                                  |
| `web.livenessProbe.httpGet.port`                          | Liveness probe httpGet port                                | `http`                                                      |
| `web.livenessProbe.periodSeconds`                         | Liveness probe period seconds                              | `10`                                                        |
| `web.livenessProbe.timeoutSeconds`                        | Liveness probe timeout seconds                             | `5`                                                         |
| `web.readinessProbe.failureThreshold`                     | Readiness probe failure threshold                          | `1`                                                         |
| `web.readinessProbe.httpGet.path`                         | Readiness probe httpGet path                               | `/app/template/Login.vm#!`                                  |
| `web.readinessProbe.httpGet.port`                         | Readiness probe httpGet port                               | `http`                                                      |
| `web.readinessProbe.periodSeconds`                        | Readiness probe period seconds                             | `10`                                                        |
| `web.readinessProbe.timeoutSeconds`                       | Readiness probe timeout seconds                            | `3`                                                         |
| `web.startupProbe.failureThreshold`                       | Startup probe failure threshold                            | `15`                                                        |
| `web.startupProbe.httpGet.path`                           | Startup probe httpGet path                                 | `/app/template/Login.vm#!`                                  |
| `web.startupProbe.httpGet.port`                           | Startup probe httpGet port                                 | `http`                                                      |
| `web.startupProbe.periodSeconds`                          | Startup probe period seconds                               | `10`                                                        |
| `web.startupProbe.initialDelaySeconds`                    | Startup probe initial delay seconds                        | `20`                                                        |
| `web.autoscaling.enabled`                                 | Enable or disable the autoscaling                          | `false`                                                     |
| `web.autoscaling.minReplicas`                             | Minimum number of replicas                                 | `1`                                                         |
| `web.autoscaling.maxReplicas`                             | Maximum number of replicas                                 | `100`                                                       |
| `web.autoscaling.targetCPUUtilizationPercentage`          | Target CPU utilisation percentage                          | `80`                                                        |
| `web.nodeSelector`                                        | Node selector                                              | `{}`                                                        |
| `web.tolerations`                                         | Tolerations to add to the web pod                          | `[]`                                                        |
| `web.affinity`                                            | Affinity to add to the web pod                             | `{}`                                                        |
| `web.tomcat.catalinaOpts`                                 | Override default CATALINA_OPTS                             | `""`                                                        |
| `web.config.enabled`                                      | Enable or disable the config                               | `true`                                                      |
| `web.config.image.pullPolicy`                             | Image pull policy                                          | `""`                                                        |
| `web.config.image.name`                                   | Image name                                                 | `xnat-config`                                               |
| `web.config.image.namespace`                              | Image namespace                                            | `ucl-mirsg`                                                 |
| `web.config.image.registry`                               | Image registry                                             | `ghcr.io`                                                   |
| `web.config.image.tag`                                    | Image tag                                                  | `latest`                                                    |
| `postgresql.enabled`                                      | Whether to deploy a PostgreSQL cluster                     | `true`                                                      |
| `postgresql.backups.enabled`                              | Whether to enable database backups                         | `false`                                                     |
| `postgresql.cluster.imageName`                            | Name of the PostgreSQL container image                     | `ghcr.io/cloudnative-pg/postgresql:14.17-standard-bookworm` |
| `postgresql.cluster.instances`                            | Number of PostgreSQL instances                             | `1`                                                         |
| `postgresql.cluster.postgresql.parameters.shared_buffers` | Amount of memory used for shared buffers                   | `512MB`                                                     |
| `postgresql.cluster.resources.requests.cpu`               | CPU request                                                | `1`                                                         |
| `postgresql.cluster.resources.requests.memory`            | Memory request                                             | `2Gi`                                                       |
| `postgresql.cluster.resources.limits.cpu`                 | CPU limit                                                  | `2`                                                         |
| `postgresql.cluster.resources.limits.memory`              | Memory limit                                               | `4Gi`                                                       |
| `postgresql.cluster.storage.size`                         | Size of the storage                                        | `8Gi`                                                       |
| `postgresql.cluster.initdb.database`                      | PostgreSQL database name                                   | `xnat`                                                      |
| `postgresql.cluster.initdb.owner`                         | PostgreSQL owner                                           | `xnat`                                                      |
| `postgresql.cluster.initdb.secret.name`                   | Name of the secret containing credentials for the database | `pg-user-secret`                                            |
| `postgresql.cluster.version.postgresql`                   | PostgreSQL major version to use                            | `14`                                                        |
