{{/*
Expand the name of the chart.
*/}}
{{- define "tornjak-frontend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tornjak-frontend.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "tornjak-frontend.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else if and (dig "spire" "recommendations" "enabled" false .Values.global) (dig "spire" "recommendations" "namespaceLayout" true .Values.global) }}
    {{- if ne (len (dig "spire" "namespaces" "server" "name" "" .Values.global)) 0 }}
      {{- .Values.global.spire.namespaces.server.name }}
    {{- else }}
      {{- printf "spire-server" }}
    {{- end }}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tornjak-frontend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tornjak-frontend.labels" -}}
helm.sh/chart: {{ include "tornjak-frontend.chart" . }}
{{ include "tornjak-frontend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tornjak-frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tornjak-frontend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tornjak-frontend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "tornjak-frontend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create URL for accessing Tornjak APIs
*/}}
{{- define "tornjak-frontend.apiURL" -}}
{{- if .Values.apiServerURL -}}
{{- .Values.apiServerURL -}}
{{- else if .Values.ingress.enabled }}
{{- printf "https://tornjak-backend.%s" (include "spire-lib.trust-domain" .) }}
{{- else }}
{{- print "http://localhost:" .Values.service.port }}
{{- end }}
{{- end }}

{{- define "tornjak-frontend.workingDir" }}
{{- if .Values.workingDir }}
{{- .Values.workingDir }}
{{- else if (dig "openshift" false .Values.global) }}
{{- printf "/opt/app-root/src" }}
{{- else }}
{{- printf "/usr/src/app" }}
{{- end }}
{{- end }}
