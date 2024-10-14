{{/*
Name of postgresql deployment
*/}}
{{- define "xnat.postgresql.fullname" -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Name of the postgresql clusterIP service
*/}}
{{- define "xnat.postgresql.svc" -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
