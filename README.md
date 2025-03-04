# xnat

Helm Chart for XNAT

## Local Installation

### Create a local cluster

Create a cluster into which the chart will be installed using your preferred
method. For example, using [kind](https://kind.sigs.k8s.io/):

```shell
kind create cluster --name xnat
```

### Package the chart

To install a local copy of the chart, first create a package:

```shell
helm package --dependency-update chart
```

### Install the chart

Install the packaged chart in the cluster with the following command:

```shell
helm install \
--set image.tag=0.0.1 \
--set imageCredentials.enabled=true \
--set imageCredentials.registry=ghcr.io \
--set imageCredentials.username=<GH_USERNAME> \
--set imageCredentials.password=<GH_PAT> \
--set postgresql.auth.password=xnat \
--namespace xnat-core \
--create-namespace \
xnat-core xnat-0.0.6.tgz
```

Note that omitting the `namespace` option and `create-namespace` flag will
result in the resources being created in the `default` namespace.

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
helm template xnat-core ./xnat-0.0.6.tgz > build/chart.yaml
```

## Parameters

### Common parameters

| Name                               | Description                                             | Value                                                |
| ---------------------------------- | ------------------------------------------------------- | ---------------------------------------------------- |
| `replicaCount`                     | Number of replicas                                      | `1`                                                  |
| `image.pullPolicy`                 | image pull policy                                       | `IfNotPresent`                                       |
| `image.pullSecret`                 | Name of secret used to pull image                       | `""`                                                 |
| `image.registry`                   | Image registry                                          | `ghcr.io`                                            |
| `image.namespace`                  | Image registry namespace                                | `ucl-mirsg`                                          |
| `image.name`                       | Name of the image in the registry                       | `xnat-core`                                          |
| `image.tag`                        | Image tag                                               | `latest`                                             |
| `imageCredentials.enabled`         | Enable or disable image pull secret                     | `false`                                              |
| `imageCredentials.registry`        | Image registry                                          | `""`                                                 |
| `imageCredentials.username`        | Image registry username                                 | `""`                                                 |
| `imageCredentials.password`        | Image registry password                                 | `""`                                                 |
| `imageCredentials.email`           | Image registry email                                    | `""`                                                 |
| `nameOverride`                     | Override name                                           | `""`                                                 |
| `fullnameOverride`                 | Override fullname                                       | `""`                                                 |
| `serviceAccount.create`            | Specifies whether a service account should be created   | `true`                                               |
| `serviceAccount.automount`         | Automatically mount a ServiceAccount's API credentials? | `true`                                               |
| `serviceAccount.annotations`       | Annotations to add to the service account               | `{}`                                                 |
| `serviceAccount.name`              | The name of the service account to use.                 | `""`                                                 |
| `service.port`                     | Service port                                            | `80`                                                 |
| `service.type`                     | Service type                                            | `ClusterIP`                                          |
| `service.targetPort`               | Service target port                                     | `8080`                                               |
| `persistence.storageClass`         | Persistent volume storage class                         | `nil`                                                |
| `persistence.annotations`          | Persistent volume annotations                           | `{}`                                                 |
| `volumes[0].name`                  | XNAT node configuration Volume name                     | `node-conf`                                          |
| `volumes[1].name`                  | Wait for PostgreSQL Volume name                         | `wait-for-postgres`                                  |
| `volumes[1].configMap.name`        | Wait for PostgreSQL Volume name                         | `wait-for-postgres`                                  |
| `volumes[1].configMap.defaultMode` | Wait for PostgreSQL Volume permissions                  | `777`                                                |
| `volumes[2].name`                  | XNAT archive Volume name                                | `xnat-archive`                                       |
| `volumes[2].accessModes`           | XNAT archive Volume access modes                        | `["ReadWriteOnce"]`                                  |
| `volumes[2].annotations`           | XNAT archive Volume annotations                         | `{}`                                                 |
| `volumes[2].existingClaim`         | XNAT archive Volume existingClaim                       | `nil`                                                |
| `volumes[2].persistent`            | XNAT archive Volume persistent                          | `true`                                               |
| `volumes[2].size`                  | XNAT archive Volume size                                | `8Gi`                                                |
| `volumes[2].storageClass`          | XNAT archive Volume storageClass                        | `nil`                                                |
| `volumes[3].name`                  | XNAT instance configuration Volume name                 | `xnat-config`                                        |
| `volumes[3].secret.secretName`     | XNAT instance configuration Volume secret name          | `xnat-conf`                                          |
| `volumes[4].name`                  | XNAT OpenID configuration Volume name                   | `xnat-openid-config`                                 |
| `volumes[4].secret.secretName`     | XNAT OpenID configuration Volume secret name            | `openid-conf`                                        |
| `volumes[5].name`                  | XNAT prearchive Volume name                             | `xnat-prearchive`                                    |
| `volumes[5].accessModes`           | XNAT prearchive Volume access modes                     | `["ReadWriteOnce"]`                                  |
| `volumes[5].annotations`           | XNAT prearchive Volume annotations                      | `{}`                                                 |
| `volumes[5].existingClaim`         | XNAT prearchive Volume existingClaim                    | `nil`                                                |
| `volumes[5].persistent`            | XNAT prearchive Volume persistent                       | `true`                                               |
| `volumes[5].size`                  | XNAT prearchive Volume size                             | `8Gi`                                                |
| `volumes[5].storageClass`          | XNAT prearchive Volume storageClass                     | `nil`                                                |
| `volumeMounts[0].name`             | XNAT node configuration Volume name                     | `node-conf`                                          |
| `volumeMounts[0].mountPath`        | XNAT node configuration Volume mount path               | `/data/xnat/home/config`                             |
| `volumeMounts[1].name`             | Wait for PostgreSQL Volume name                         | `wait-for-postgres`                                  |
| `volumeMounts[1].mountPath`        | Wait for PostgreSQL Volume mount path                   | `/usr/local/bin/wait-for-postgres.sh`                |
| `volumeMounts[1].subPath`          | Wait for PostgreSQL Volume sub path                     | `wait-for-postgres.sh`                               |
| `volumeMounts[1].readOnly`         | Wait for PostgreSQL Volume read only                    | `true`                                               |
| `volumeMounts[2].name`             | XNAT archive Volume name                                | `xnat-archive`                                       |
| `volumeMounts[2].mountPath`        | XNAT archive Volume mount path                          | `/data/xnat/archive`                                 |
| `volumeMounts[2].subPath`          | XNAT archive Volume sub path                            | `nil`                                                |
| `volumeMounts[3].name`             | XNAT instance configuration Volume name                 | `xnat-config`                                        |
| `volumeMounts[3].mountPath`        | XNAT instance configuration Volume mount path           | `/data/xnat/home/config/xnat-conf.properties`        |
| `volumeMounts[3].readOnly`         | XNAT instance configuration Volume read only            | `true`                                               |
| `volumeMounts[3].subPath`          | XNAT instance configuration Volume sub path             | `xnat-conf.properties`                               |
| `volumeMounts[4].name`             | XNAT OpenID configuration Volume name                   | `xnat-openid-config`                                 |
| `volumeMounts[4].mountPath`        | XNAT OpenID configuration Volume mount path             | `/data/xnat/home/config/auth/openid-conf.properties` |
| `volumeMounts[4].readOnly`         | XNAT OpenID configuration Volume read only              | `true`                                               |
| `volumeMounts[4].subPath`          | XNAT OpenID configuration Volume sub path               | `openid-conf.properties`                             |
| `volumeMounts[5].name`             | XNAT prearchive Volume name                             | `xnat-prearchive`                                    |
| `volumeMounts[5].mountPath`        | XNAT prearchive Volume mount path                       | `/data/xnat/prearchive`                              |
| `volumeMounts[5].subPath`          | XNAT prearchive Volume sub path                         | `nil`                                                |

### XNAT Database parameters

| Name                               | Description                                      | Value                  |
| ---------------------------------- | ------------------------------------------------ | ---------------------- |
| `postgresql.enabled`               | Enable or disable the PostgreSQL deployment      | `true`                 |
| `postgresql.auth.database`         | PostgreSQL database name                         | `xnat`                 |
| `postgresql.auth.username`         | PostgreSQL username                              | `xnat`                 |
| `postgresql.auth.password`         | PostgreSQL password. Make sure to override this. | `xnat`                 |
| `postgresql.auth.postgresPassword` | PostgreSQL password. Make sure to override this. | `postgres`             |
| `postgresql.image.tag`             | PostgreSQL image tag                             | `14.17.0-debian-12-r2` |

### XNAT Web parameters

| Name                                             | Description                              | Value                      |
| ------------------------------------------------ | ---------------------------------------- | -------------------------- |
| `web.siteUrl`                                    | Site URL                                 | `""`                       |
| `web.auth.openid.clientId`                       | OpenID client ID                         | `""`                       |
| `web.auth.openid.clientSecret`                   | OpenID client secret                     | `""`                       |
| `web.auth.openid.accessTokenUri`                 | OpenID access token URI                  | `""`                       |
| `web.auth.openid.userAuthUri`                    | OpenID user authentication URI           | `""`                       |
| `web.auth.openid.link`                           | OpenID link                              | `""`                       |
| `web.podAnnotations`                             | Annotations to add to the web pod        | `{}`                       |
| `web.podLabels`                                  | Labels to add to the web pod             | `{}`                       |
| `web.podSecurityContext`                         | Pod security context                     | `{}`                       |
| `web.securityContext`                            | Pod security context                     | `{}`                       |
| `web.ingress.enabled`                            | Enable or disable the ingress deployment | `false`                    |
| `web.ingress.className`                          | Ingress class name                       | `""`                       |
| `web.ingress.annotations`                        | Ingress annotations                      | `{}`                       |
| `web.ingress.hosts[0].host`                      | Ingress host                             | `chart-example.local`      |
| `web.ingress.hosts[0].paths[0].path`             | Ingress path                             | `/`                        |
| `web.ingress.hosts[0].paths[0].pathType`         | Ingress path type                        | `ImplementationSpecific`   |
| `web.ingress.tls`                                | Ingress TLS                              | `[]`                       |
| `web.resources.limits.cpu`                       | CPU and memory limits                    | `2`                        |
| `web.resources.limits.memory`                    | Memory limits                            | `4000Mi`                   |
| `web.resources.requests.cpu`                     | CPU and memory requests                  | `1`                        |
| `web.resources.requests.memory`                  | Memory requests                          | `4000Mi`                   |
| `web.livenessProbe.failureThreshold`             | Liveness probe failure threshold         | `1`                        |
| `web.livenessProbe.httpGet.path`                 | Liveness probe httpGet path              | `/app/template/Login.vm#!` |
| `web.livenessProbe.httpGet.port`                 | Liveness probe httpGet port              | `http`                     |
| `web.livenessProbe.periodSeconds`                | Liveness probe period seconds            | `10`                       |
| `web.livenessProbe.timeoutSeconds`               | Liveness probe timeout seconds           | `5`                        |
| `web.readinessProbe.failureThreshold`            | Readiness probe failure threshold        | `1`                        |
| `web.readinessProbe.httpGet.path`                | Readiness probe httpGet path             | `/app/template/Login.vm#!` |
| `web.readinessProbe.httpGet.port`                | Readiness probe httpGet port             | `http`                     |
| `web.readinessProbe.periodSeconds`               | Readiness probe period seconds           | `10`                       |
| `web.readinessProbe.timeoutSeconds`              | Readiness probe timeout seconds          | `3`                        |
| `web.startupProbe.failureThreshold`              | Startup probe failure threshold          | `15`                       |
| `web.startupProbe.httpGet.path`                  | Startup probe httpGet path               | `/app/template/Login.vm#!` |
| `web.startupProbe.httpGet.port`                  | Startup probe httpGet port               | `http`                     |
| `web.startupProbe.periodSeconds`                 | Startup probe period seconds             | `10`                       |
| `web.autoscaling.enabled`                        | Enable or disable the autoscaling        | `false`                    |
| `web.autoscaling.minReplicas`                    | Minimum number of replicas               | `1`                        |
| `web.autoscaling.maxReplicas`                    | Maximum number of replicas               | `100`                      |
| `web.autoscaling.targetCPUUtilizationPercentage` | Target CPU utilisation percentage        | `80`                       |
| `web.nodeSelector`                               | Node selector                            | `{}`                       |
| `web.tolerations`                                | Tolerations to add to the web pod        | `[]`                       |
| `web.affinity`                                   | Affinity to add to the web pod           | `{}`                       |
