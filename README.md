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

### Create a secret containing Postgres credentials

Create a manifest for the secret:

```bash
cat <<EOF > secret.yaml
apiVersion: v1
stringData:
  username: xnat
  password: xnat
kind: Secret
metadata:
  name: pg-user-secret
  namespace: xnat-core
type: kubernetes.io/basic-auth
EOF
```

Create the secret:

```bash
kubectl apply -f secret.yaml --namespace xnat-core
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
--set image.name=xnat-core \
--set image.tag=0.0.1 \
--set imageCredentials.enabled=true \
--set imageCredentials.registry=ghcr.io \
--set imageCredentials.username=<GH_USERNAME> \
--set imageCredentials.password=<GH_PAT> \
--set postgresql.auth.password=xnat \
--set web.config.adminPassword=<ADMIN_USER_PASSWORD> \
--set web.config.serviceAdminPassword=<SERVICE_USER_PASSWORD> \
--namespace xnat-core \
xnat-core xnat-0.0.9.tgz
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
helm template xnat-core ./xnat-0.0.9.tgz > build/chart.yaml
```

## Parameters

### Common parameters

| Name                         | Description                                             | Value                                         |
| ---------------------------- | ------------------------------------------------------- | --------------------------------------------- |
| `replicaCount`               | Number of replicas                                      | `1`                                           |
| `image.pullPolicy`           | image pull policy                                       | `IfNotPresent`                                |
| `image.pullSecret`           | Name of secret used to pull image                       | `""`                                          |
| `image.registry`             | Image registry                                          | `ghcr.io`                                     |
| `image.namespace`            | Image registry namespace                                | `ucl-mirsg`                                   |
| `image.name`                 | Name of the image in the registry                       | `""`                                          |
| `image.tag`                  | Image tag                                               | `latest`                                      |
| `imageCredentials.enabled`   | Enable or disable image pull secret                     | `false`                                       |
| `imageCredentials.registry`  | Image registry                                          | `""`                                          |
| `imageCredentials.username`  | Image registry username                                 | `""`                                          |
| `imageCredentials.password`  | Image registry password                                 | `""`                                          |
| `imageCredentials.email`     | Image registry email                                    | `""`                                          |
| `nameOverride`               | Override name                                           | `""`                                          |
| `fullnameOverride`           | Override fullname                                       | `""`                                          |
| `serviceAccount.create`      | Specifies whether a service account should be created   | `true`                                        |
| `serviceAccount.automount`   | Automatically mount a ServiceAccount's API credentials? | `true`                                        |
| `serviceAccount.annotations` | Annotations to add to the service account               | `{}`                                          |
| `serviceAccount.name`        | The name of the service account to use.                 | `""`                                          |
| `service.port`               | Service port                                            | `80`                                          |
| `service.type`               | Service type                                            | `ClusterIP`                                   |
| `service.targetPort`         | Service target port                                     | `8080`                                        |
| `persistence.storageClass`   | Persistent volume storage class                         | `nil`                                         |
| `persistence.annotations`    | Persistent volume annotations                           | `{}`                                          |
| `volumes[0].name`            | XNAT node configuration Volume name                     | `node-conf`                                   |
| `volumes[1].name`            | XNAT archive Volume name                                | `xnat-archive`                                |
| `volumes[1].accessModes`     | XNAT archive Volume access modes                        | `["ReadWriteOnce"]`                           |
| `volumes[1].annotations`     | XNAT archive Volume annotations                         | `{}`                                          |
| `volumes[1].existingClaim`   | XNAT archive Volume existingClaim                       | `nil`                                         |
| `volumes[1].persistent`      | XNAT archive Volume persistent                          | `true`                                        |
| `volumes[1].size`            | XNAT archive Volume size                                | `8Gi`                                         |
| `volumes[1].storageClass`    | XNAT archive Volume storageClass                        | `nil`                                         |
| `volumes[2].name`            | XNAT instance configuration Volume name                 | `xnat-config`                                 |
| `volumes[3].name`            | XNAT prearchive Volume name                             | `xnat-prearchive`                             |
| `volumes[3].accessModes`     | XNAT prearchive Volume access modes                     | `["ReadWriteOnce"]`                           |
| `volumes[3].annotations`     | XNAT prearchive Volume annotations                      | `{}`                                          |
| `volumes[3].existingClaim`   | XNAT prearchive Volume existingClaim                    | `nil`                                         |
| `volumes[3].persistent`      | XNAT prearchive Volume persistent                       | `true`                                        |
| `volumes[3].size`            | XNAT prearchive Volume size                             | `8Gi`                                         |
| `volumes[3].storageClass`    | XNAT prearchive Volume storageClass                     | `nil`                                         |
| `volumeMounts[0].name`       | XNAT node configuration Volume name                     | `node-conf`                                   |
| `volumeMounts[0].mountPath`  | XNAT node configuration Volume mount path               | `/data/xnat/home/config/node-conf.properties` |
| `volumeMounts[0].subPath`    | XNAT node configuration Volume sub path                 | `node-conf.properties`                        |
| `volumeMounts[1].name`       | XNAT archive Volume name                                | `xnat-archive`                                |
| `volumeMounts[1].mountPath`  | XNAT archive Volume mount path                          | `/data/xnat/archive`                          |
| `volumeMounts[1].subPath`    | XNAT archive Volume sub path                            | `nil`                                         |
| `volumeMounts[2].name`       | XNAT instance configuration Volume name                 | `xnat-config`                                 |
| `volumeMounts[2].mountPath`  | XNAT instance configuration Volume mount path           | `/data/xnat/home/config/xnat-conf.properties` |
| `volumeMounts[2].subPath`    | XNAT instance configuration Volume sub path             | `xnat-conf.properties`                        |
| `volumeMounts[3].name`       | XNAT prearchive Volume name                             | `xnat-prearchive`                             |
| `volumeMounts[3].mountPath`  | XNAT prearchive Volume mount path                       | `/data/xnat/prearchive`                       |
| `volumeMounts[3].subPath`    | XNAT prearchive Volume sub path                         | `nil`                                         |

### XNAT Web parameters

| Name                                                      | Description                                                | Value                                                       |
| --------------------------------------------------------- | ---------------------------------------------------------- | ----------------------------------------------------------- |
| `web.siteUrl`                                             | Site URL                                                   | `""`                                                        |
| `web.auth.openid.provider`                                | OpenID provider name                                       | `openid1`                                                   |
| `web.auth.openid.enabled`                                 | Enable or disable the config                               | `false`                                                     |
| `web.auth.openid.clientId`                                | OpenID client ID                                           | `""`                                                        |
| `web.auth.openid.clientSecret`                            | OpenID client secret                                       | `""`                                                        |
| `web.auth.openid.accessTokenUri`                          | OpenID access token URI                                    | `""`                                                        |
| `web.auth.openid.userAuthUri`                             | OpenID user authentication URI                             | `""`                                                        |
| `web.auth.openid.link`                                    | OpenID link                                                | `""`                                                        |
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
| `web.resources.limits.memory`                             | Memory limits                                              | `4000Mi`                                                    |
| `web.resources.requests.cpu`                              | CPU and memory requests                                    | `1`                                                         |
| `web.resources.requests.memory`                           | Memory requests                                            | `4000Mi`                                                    |
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
| `web.config.enabled`                                      | Enable or disable the config                               | `true`                                                      |
| `web.config.existingSecret`                               | Existing secret name                                       | `""`                                                        |
| `web.config.image.pullPolicy`                             | Image pull policy                                          | `""`                                                        |
| `web.config.image.name`                                   | Image name                                                 | `xnat-config`                                               |
| `web.config.image.namespace`                              | Image namespace                                            | `ucl-mirsg`                                                 |
| `web.config.image.registry`                               | Image registry                                             | `ghcr.io`                                                   |
| `web.config.image.tag`                                    | Image tag                                                  | `latest`                                                    |
| `web.config.adminPassword`                                | Admin password                                             | `""`                                                        |
| `web.config.serviceAdminPassword`                         | Service admin password                                     | `""`                                                        |
| `postgresql.enabled`                                      | Whether to deploy a PostgreSQL cluster                     | `true`                                                      |
| `postgresql.backups.enabled`                              | Whether to enable database backups                         | `false`                                                     |
| `postgresql.cluster.imageName`                            | Name of the PostgreSQL container image                     | `ghcr.io/cloudnative-pg/postgresql:14.17-standard-bookworm` |
| `postgresql.cluster.instances`                            | Number of PostgreSQL instances                             | `3`                                                         |
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
