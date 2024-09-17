# xnat

Helm Chart for XNAT

## Parameters

### Common parameters for both XNAT web and shadow deployments

| Name                           | Description                                             | Value                                         |
| ------------------------------ | ------------------------------------------------------- | --------------------------------------------- |
| `replicaCount`                 | Number of replicas                                      | `1`                                           |
| `image.digest`                 | Image digest in the way sha256:aa...                    | `""`                                          |
| `image.pullPolicy`             | MariaDB image pull policy                               | `IfNotPresent`                                |
| `image.pullSecrets`            | Image pull secrets                                      | `["ghcr-secret"]`                             |
| `image.registry`               | Image registry                                          | `ghcr.io`                                     |
| `image.repository`             | Image repository                                        | `ghcr.io/ucl-mirsg/xnat-core`                 |
| `image.tag`                    | Image tag                                               | `latest`                                      |
| `imageCredentials.registry`    | Image registry                                          | `ghcr.io`                                     |
| `imageCredentials.username`    | Image registry username                                 | `username`                                    |
| `imageCredentials.password`    | Image registry password                                 | `password`                                    |
| `imageCredentials.email`       | Image registry email                                    | `""`                                          |
| `nameOverride`                 | Override name                                           | `""`                                          |
| `fullnameOverride`             | Override fullname                                       | `""`                                          |
| `serviceAccount.create`        | Specifies whether a service account should be created   | `true`                                        |
| `serviceAccount.automount`     | Automatically mount a ServiceAccount's API credentials? | `true`                                        |
| `serviceAccount.annotations`   | Annotations to add to the service account               | `{}`                                          |
| `serviceAccount.name`          | The name of the service account to use.                 | `""`                                          |
| `service.port`                 | Service port                                            | `80`                                          |
| `service.type`                 | Service type                                            | `ClusterIP`                                   |
| `volumes[0].name`              | XNAT node configuration Volume name                     | `node-conf`                                   |
| `volumes[1].name`              | XNAT node configuration Volume name                     | `xnat-config`                                 |
| `volumes[1].secret.secretName` | XNAT instance configuration Volume secret               | `xnat-conf`                                   |
| `volumeMounts[0].name`         | XNAT node configuration Volume name                     | `node-conf`                                   |
| `volumeMounts[0].mountPath`    | XNAT node configuration Volume mount path               | `/data/xnat/home/config`                      |
| `volumeMounts[1].name`         | XNAT instance configuration Volume name                 | `xnat-config`                                 |
| `volumeMounts[1].mountPath`    | XNAT instance configuration Volume mount path           | `/data/xnat/home/config/xnat-conf.properties` |
| `volumeMounts[1].readOnly`     | XNAT instance configuration Volume read only            | `true`                                        |
| `volumeMounts[1].subPath`      | XNAT instance configuration Volume sub path             | `xnat-conf.properties`                        |

### XNAT Database parameters

| Name                               | Description                                      | Value      |
| ---------------------------------- | ------------------------------------------------ | ---------- |
| `postgresql.enabled`               | Enable or disable the PostgreSQL deployment      | `true`     |
| `postgresql.auth.database`         | PostgreSQL database name                         | `xnat`     |
| `postgresql.auth.username`         | PostgreSQL username                              | `xnat`     |
| `postgresql.auth.password`         | PostgreSQL password. Make sure to override this. | `xnat`     |
| `postgresql.auth.postgresPassword` | PostgreSQL password. Make sure to override this. | `postgres` |

### XNAT Web parameters

| Name                                             | Description                              | Value                      |
| ------------------------------------------------ | ---------------------------------------- | -------------------------- |
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
| `web.resources`                                  | Resources to set for the web pod         | `{}`                       |
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

### XNAT shadow parameters

| Name                                                | Description                              | Value      |
| --------------------------------------------------- | ---------------------------------------- | ---------- |
| `shadow.dicom_scp.serviceType`                      | Service type                             | `NodePort` |
| `shadow.dicom_scp.annotations`                      | Annotations                              | `{}`       |
| `shadow.dicom_scp.receivers[0].ae_title`            | SCP AE title                             | `XNAT`     |
| `shadow.dicom_scp.receivers[0].port`                | SCP port                                 | `8104`     |
| `shadow.podAnnotations`                             | Pod annotations to add to the shadow pod | `{}`       |
| `shadow.podLabels`                                  | Labels to add to the shadow pod          | `{}`       |
| `shadow.podSecurityContext`                         | Pod security context                     | `{}`       |
| `shadow.securityContext`                            | shadow Deployment security context       | `{}`       |
| `shadow.resources`                                  | Resources to set for the shadow pod      | `{}`       |
| `shadow.readinessProbe.tcpSocket.port`              | Readiness probe TCP socket               | `8080`     |
| `shadow.readinessProbe.initialDelaySeconds`         | Readiness probe initial delay seconds    | `15`       |
| `shadow.readinessProbe.periodSeconds`               | Readiness probe period seconds           | `10`       |
| `shadow.livenessProbe.tcpSocket.port`               | Liveness probe TCP socket                | `8080`     |
| `shadow.livenessProbe.initialDelaySeconds`          | Liveness probe initial delay seconds     | `15`       |
| `shadow.livenessProbe.periodSeconds`                | Liveness probe period seconds            | `10`       |
| `shadow.autoscaling.enabled`                        | Enable or disable the autoscaling        | `false`    |
| `shadow.autoscaling.minReplicas`                    | Minimum number of replicas               | `1`        |
| `shadow.autoscaling.maxReplicas`                    | Maximum number of replicas               | `100`      |
| `shadow.autoscaling.targetCPUUtilizationPercentage` | Target CPU utilisation percentage        | `80`       |
| `shadow.nodeSelector`                               | Node selector to add to the shadow pod   | `{}`       |
| `shadow.tolerations`                                | Tolerations to add to the shadow pod     | `[]`       |
| `shadow.affinity`                                   | Affinity to add to the shadow pod        | `{}`       |
