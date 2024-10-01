{{/*
Name of postgresql deployment
*/}}
{{- define "xnat.postgresql.fullname" -}}
{{ include "postgresql.v1.primary.fullname" .Subcharts.postgresql }}
{{- end -}}

{{/*
Name of the postgresql clusterIP service
*/}}
{{- define "xnat.postgresql.svc" -}}
{{ include "postgresql.v1.primary.fullname" .Subcharts.postgresql }}
{{- end -}}
