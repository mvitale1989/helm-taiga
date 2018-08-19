{{/* vim: set filetype=mustache: */}}

{{/* Expand the name of the chart. */}}
{{- define "taiga.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Create a default fully qualified app name. We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec). If release name contains chart name it will be used as a full name. */}}
{{- define "taiga.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "taiga.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Define the docker image name */}}
{{- define "taiga.image" -}}
{{- if regexMatch "^@" .Values.image.tag -}}
{{ .Values.image.repository }}{{ .Values.image.tag }}
{{- else -}}
{{ .Values.image.repository }}:{{ .Values.image.tag }}
{{- end -}}
{{- end -}}

{{/* Labels to attach to every auth-proxy object. */}}
{{- define "taiga.labels" -}}
app: {{ template "taiga.name" . }}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
chart: {{ include "taiga.chart" . }}
{{ if .Values.extraLabels -}}
{{ .Values.extraLabels | toYaml }}
{{- end -}}
{{- end -}}

{{/* Environment variables for configuring the containers */}}
{{- define "taiga.env" -}}
- name: TAIGA_HOSTNAME
  value: {{ required "taiga.apiserver must be set" .Values.taiga.apiserver }}
- name: TAIGA_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "taiga.fullname" . }}
      key: secretKey
- name: TAIGA_SLEEP
  value: "0"
- name: TAIGA_SSL
  value: "false"
- name: TAIGA_SSL_BY_REVERSE_PROXY
  value: {{ .Values.taiga.behindTlsProxy | ternary "True" "False" | quote }} #NB: case sensitive
- name: TAIGA_DB_HOST
  value: {{ required "taiga.dbHost must be set" .Values.taiga.dbHost }}
- name: TAIGA_DB_NAME
  value: {{ required "taiga.dbName must be set" .Values.taiga.dbName }}
- name: TAIGA_DB_USER
  value: {{ required "taiga.dbUser must be set" .Values.taiga.dbUser }}
- name: TAIGA_DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "taiga.fullname" . }}
      key: dbPassword
- name: TAIGA_ENABLE_EMAIL
  value: {{ .Values.taiga.emailEnabled | ternary "True" "False" | quote }}
{{- if .Values.taiga.emailEnabled }}
- name: TAIGA_EMAIL_FROM
  value: {{ .Values.taiga.emailFrom | default "taiga@example.com" |  quote }}
- name: TAIGA_EMAIL_USE_TLS
  value: {{ .Values.taiga.emailUseTls | default true | ternary "True" "False" | quote }}
- name: TAIGA_EMAIL_HOST
  value: {{ required "taiga.emailSmtpHost must be set" .Values.taiga.emailSmtpHost | quote }}
- name: TAIGA_EMAIL_PORT
  value: {{ default 587 .Values.taiga.emailSmtpPort | quote }}
- name: TAIGA_EMAIL_USER
  value: {{ required "taiga.emailSmtpUser must be set" .Values.taiga.emailSmtpUser | quote }}
- name: TAIGA_EMAIL_PASS
  valueFrom:
    secretKeyRef:
      name: {{ include "taiga.fullname" . }}
      key: emailSmtpPassword
{{- end }}
{{- end -}}
