{{/*
Name of the postgresql clusterIP service
*/}}
{{- define "xnat.postgresql.svc" -}}
{{- printf "%s-%s-rw" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
