{{/*
Name of the postgresql clusterIP service
*/}}
{{- define "xnat.postgresql.svc" -}}
{{- if .Values.postgresql.fullnameOverride -}}
{{- printf "%s-rw" .Values.postgresql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-rw" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
