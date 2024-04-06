{{/*
Expand the name of the chart.
*/}}
{{- define "spire-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Spire Server deployment/statefulset
*/}}
{{- define "spire-server.kind" -}}
{{- if not (has .Values.kind (list "statefulset" "deployment")) -}}
  {{- fail "Unsupported deployment type" -}}
{{- else -}}
  {{- .Values.kind -}}
{{- end -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "spire-server.fullname" -}}
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
{{- define "spire-server.namespace" -}}
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

{{- define "spire-server.agent-namespace" -}}
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

{{- define "spire-server.bundle-namespace" -}}
  {{- if .Values.notifier.k8sbundle.namespace }}
    {{- .Values.notifier.k8sbundle.namespace }}
  {{- else if .Values.namespaceOverride -}}
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

{{- define "spire-server.podMonitor.namespace" -}}
  {{- if ne (len .Values.telemetry.prometheus.podMonitor.namespace) 0 }}
    {{- .Values.telemetry.prometheus.podMonitor.namespace }}
  {{- else if ne (len (dig "telemetry" "prometheus" "podMonitor" "namespace" "" .Values.global)) 0 }}
    {{- .Values.global.telemetry.prometheus.podMonitor.namespace }}
  {{- else }}
    {{- include "spire-server.namespace" . }}
  {{- end }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "spire-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "spire-server.labels" -}}
helm.sh/chart: {{ include "spire-server.chart" . }}
{{ include "spire-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "spire-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spire-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "spire-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "spire-server.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "spire-server.upstream-ca-secret" -}}
{{- $root := . }}
{{- with .Values.upstreamAuthority.disk -}}
{{- if eq (.secret.create | toString) "true" -}}
{{ include "spire-server.fullname" $root }}-upstream-ca
{{- else -}}
{{ default (include "spire-server.fullname" $root) .secret.name }}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "spire-controller-manager.fullname" -}}
{{ include "spire-server.fullname" . | trimSuffix "-server" }}-controller-manager
{{- end }}

{{- define "spire-server.serviceAccountAllowedList" }}
{{- $releaseNamespace := include "spire-server.agent-namespace" . }}
{{- if ne (len .Values.nodeAttestor.k8sPsat.serviceAccountAllowList) 0 }}
{{-   $list := list }}
{{-   range .Values.nodeAttestor.k8sPsat.serviceAccountAllowList }}
{{-     if contains ":" . }}
{{-       $list = append $list . }}
{{-     else }}
{{-       $list = append $list ( printf "%s:%s" $releaseNamespace . ) | }}
{{-     end }}
{{-   end }}
{{-   $list | toJson }}
{{- else }}
[{{ printf "%s:%s-agent" $releaseNamespace .Release.Name | quote }}]
{{- end }}
{{- end }}

{{- define "spire-server.config-mysql-query" }}
{{- $lst := list }}
{{- range . }}
{{- range $key, $value := . }}
{{- $eValue := toString $value }}
{{- $entry := printf "%s=%s" (urlquery $key) (urlquery $eValue) }}
{{- $lst = append $lst $entry }}
{{- end }}
{{- end }}
{{- $lst = append $lst "parseTime=true" }}
{{- printf "?%s" (join "&" (uniq $lst)) }}
{{- end }}

{{- define "spire-server.config-postgresql-options" }}
{{- $lst := list }}
{{- range . }}
{{- range $key, $value := . }}
{{- $eValue := toString $value }}
{{- $entry := printf "%s=%s" $key $eValue }}
{{- $lst = append $lst $entry }}
{{- end }}
{{- end }}
{{- if gt (len $lst) 0 }}
{{- printf " %s" (join " " $lst) }}
{{- end }}
{{- end }}

{{- define "spire-server.datastore-config" }}
{{- $config := deepCopy .Values.dataStore.sql.plugin_data }}
{{- if eq .Values.dataStore.sql.databaseType "sqlite3" }}
  {{- $_ := set $config "database_type" "sqlite3" }}
  {{- $_ := set $config "connection_string" "/run/spire/data/datastore.sqlite3" }}
{{- else if eq .Values.dataStore.sql.databaseType "mysql" }}
  {{- $_ := set $config "database_type" "mysql" }}
  {{- $port := int .Values.dataStore.sql.port | default 3306 }}
  {{- $query := include "spire-server.config-mysql-query" .Values.dataStore.sql.options }}
  {{- $_ := set $config "connection_string" (printf "%s:${DBPW}@tcp(%s:%d)/%s%s" .Values.dataStore.sql.username .Values.dataStore.sql.host $port .Values.dataStore.sql.databaseName $query) }}
{{- else if eq .Values.dataStore.sql.databaseType "postgres" }}
  {{- $_ := set $config "database_type" "postgres" }}
  {{- $port := int .Values.dataStore.sql.port | default 5432 }}
  {{- $options:= include "spire-server.config-postgresql-options" .Values.dataStore.sql.options }}
  {{- $_ := set $config "connection_string" (printf "dbname=%s user=%s password=${DBPW} host=%s port=%d%s" .Values.dataStore.sql.databaseName .Values.dataStore.sql.username .Values.dataStore.sql.host $port $options) }}
{{- else }}
  {{- fail "Unsupported database type" }}
{{- end }}
{{- $config | toYaml }}
{{- end }}

{{- define "spire-server.upstream-spire-address" }}
{{- if ne (len (dig "spire" "upstreamSpireAddress" "" .Values.global)) 0 }}
{{- print .Values.global.spire.upstreamSpireAddress }}
{{- else if .Values.upstreamAuthority.spire.server.nameOverride }}
{{- printf "%s-%s" .Release.Name .Values.upstreamAuthority.spire.server.nameOverride }}
{{- else }}
{{- print .Values.upstreamAuthority.spire.server.address }}
{{- end }}
{{- end }}

{{/*
Tornjak specific section
*/}}

{{- define "spire-tornjak.fullname" -}}
{{ include "spire-server.fullname" . | trimSuffix "-server" }}-tornjak
{{- end }}

{{- define "spire-tornjak.config" -}}
{{ include "spire-tornjak.fullname" . }}-config
{{- end }}

{{- define "spire-tornjak.backend" -}}
{{ include "spire-tornjak.fullname" . }}-backend
{{- end }}

{{/*
Tornjak automatically determines the connection type based on provided configuration.
When TLS Secret is provided, it enables TLS connection.
When TLS Secret and User CA Secret (or ConfigMap) are provided, it enables mTLS connection.
Otherwise it starts HTTP Connection
The code below determines what connection type should be used.
*/}}
{{- define "spire-tornjak.connectionType" -}}

{{- if (lookup "v1" "Secret" (include "spire-server.namespace" .) .Values.tornjak.config.tlsSecret) -}}

{{- $caType := default "INVALID" .Values.tornjak.config.clientCA.type }}
{{- if (lookup "v1" $caType (include "spire-server.namespace" .) .Values.tornjak.config.clientCA.name) -}}
{{- printf "mtls" -}}
{{- else }}
{{- printf "tls" -}}
{{- end -}}
{{- else -}}
{{- printf "http" -}}
{{- end -}}
{{- end -}}

{{- define "spire-tornjak.servicename" -}}
{{- include "spire-tornjak.backend" . -}}
{{- end -}}

{{- define "spire-server.test.federation-ingress-args" }}
{{-   $args := list }}
{{-   $host := include "spire-lib.ingress-calculated-name" (dict "Values" .Values "ingress" .Values.federation.ingress) }}
{{-   if gt (len .Values.federation.ingress.tls) 0 }}
{{-     $host = index (index (index .Values.federation.ingress.tls 0) "hosts") 0 }}
{{-   end }}
{{-   if dig "tests" "tls" "enabled" false .Values }}
{{-     if ne (len (dig "tests" "tls" "customCA" "" .Values)) 0 }}
{{-       $args = append $args "--cacert" }}
{{-       $args = append $args "/ca/ca.crt" }}
{{-     end }}
{{-     $args = append $args (printf "https://%s/" $host) }}
{{-   else }}
{{-     $args = append $args (printf "http://%s/" $host) }}
{{-   end }}
{{ $args | toYaml }}
{{- end -}}

{{- define "spire-server.controller-manager-class-name" -}}
{{-   if .Values.controllerManager.className }}
{{-     .Values.controllerManager.className }}
{{-   else }}
{{-     .Release.Namespace }}-{{ default .Release.Name .Values.crNameOverride }}
{{-   end -}}
{{- end -}}

{{- define "spire-server.ca-subject-country" }}
{{-   $g := dig "spire" "caSubject" "country" "" .Values.global }}
{{-   default .Values.ca_subject.country $g }}
{{- end }}

{{- define "spire-server.ca-subject-organization" }}
{{-   $g := dig "spire" "caSubject" "organization" "" .Values.global }}
{{-   default .Values.ca_subject.organization $g }}
{{- end }}

{{- define "spire-server.ca-subject-common-name" }}
{{-   $g := dig "spire" "caSubject" "commonName" "" .Values.global }}
{{-   default .Values.ca_subject.common_name $g }}
{{- end }}
