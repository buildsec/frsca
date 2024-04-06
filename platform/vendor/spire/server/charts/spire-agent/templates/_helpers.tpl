{{/*
Expand the name of the chart.
*/}}
{{- define "spire-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "spire-agent.fullname" -}}
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
{{- define "spire-agent.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else if and (dig "spire" "recommendations" "enabled" false .Values.global) (dig "spire" "recommendations" "namespaceLayout" true .Values.global) }}
    {{- if ne (len (dig "spire" "namespaces" "system" "name" "" .Values.global)) 0 }}
      {{- .Values.global.spire.namespaces.system.name }}
    {{- else }}
      {{- printf "spire-system" }}
    {{- end }}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{- define "spire-agent.server.namespace" -}}
  {{- if .Values.server.namespaceOverride -}}
    {{- .Values.server.namespaceOverride -}}
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

{{- define "spire-agent.podMonitor.namespace" -}}
  {{- if ne (len .Values.telemetry.prometheus.podMonitor.namespace) 0 }}
    {{- .Values.telemetry.prometheus.podMonitor.namespace }}
  {{- else if ne (len (dig "telemetry" "prometheus" "podMonitor" "namespace" "" .Values.global)) 0 }}
    {{- .Values.global.telemetry.prometheus.podMonitor.namespace }}
  {{- else }}
    {{- include "spire-agent.namespace" . }}
  {{- end }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "spire-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "spire-agent.labels" -}}
helm.sh/chart: {{ include "spire-agent.chart" . }}
{{ include "spire-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "spire-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spire-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "spire-agent.serviceAccountName" -}}
{{- default (printf "%s-agent" .Release.Name) .Values.serviceAccount.name }}
{{- end }}

{{- define "spire-agent.server-address" }}
{{- if and (ne (len (dig "spire" "upstreamSpireAddress" "" .Values.global)) 0) .Values.upstream }}
{{- print .Values.global.spire.upstreamSpireAddress }}
{{- else if .Values.server.address }}
{{- .Values.server.address }}
{{- else if .Values.server.nameOverride }}
{{ .Release.Name }}-{{ .Values.server.nameOverride }}.{{ include "spire-agent.server.namespace" . }}
{{- else }}
{{ .Release.Name }}-server.{{ include "spire-agent.server.namespace" . }}
{{- end }}
{{- end }}

{{- define "spire-agent.socket-path" -}}
{{- print .Values.socketPath }}
{{- end }}

{{- define "spire-agent.connect-by-hostname" -}}
{{-   if ne .Values.kubeletConnectByHostname "" }}
{{-     if eq (.Values.kubeletConnectByHostname | toString) "true" }}
{{-       printf "true" }}
{{-     else }}
{{-       printf "false" }}
{{-     end }}
{{-   else if (dig "openshift" false .Values.global) }}
{{-     printf "true" }}
{{-   else }}
{{-     printf "false" }}
{{-   end }}
{{- end }}

{{- define "spire-agent.socket-alternate-names" -}}
{{-   $sockName := .Values.socketPath | base }}
{{-   $l := deepCopy .Values.socketAlternate.names }}
{{-   $l = without $l $sockName }}
names:
{{ $l | toYaml }}
{{- end }}
