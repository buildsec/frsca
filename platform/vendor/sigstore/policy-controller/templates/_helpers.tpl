{{/*
Expand the name of the chart.
*/}}
{{- define "policy-controller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "policy-controller.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "policy-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "policy-controller.labels" -}}
helm.sh/chart: {{ include "policy-controller.chart" . }}
{{ include "policy-controller.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "policy-controller.selectorLabels" -}}
app.kubernetes.io/name: {{ include "policy-controller.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "policy-controller.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "policy-controller.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Self-signed certificate authority issuer name
*/}}
{{- define "policy-controller.CAIssuerName" -}}
{{- if .Values.certificates.ca.issuer.name -}}
{{ .Values.certificates.ca.issuer.name }}
{{- else -}}
{{ template "policy-controller.fullname" . }}-ca-issuer
{{- end -}}
{{- end -}}

{{/*
CA Certificate issuer name
*/}}
{{- define "policy-controller.CAissuerName" -}}
{{- if .Values.certificates.selfSigned -}}
{{ template "policy-controller.CAIssuerName" . }}
{{- else -}}
{{ required "A valid .Values.certificates.ca.issuer.name is required!" .Values.certificates.issuer.name }}
{{- end -}}
{{- end -}}

{{/*
CA signed certificate issuer name
*/}}
{{- define "policy-controller.IssuerName" -}}
{{- if .Values.certificates.issuer.name -}}
{{ .Values.certificates.issuer.name }}
{{- else -}}
{{ template "policy-controller.fullname" . }}-issuer
{{- end -}}
{{- end -}}

{{/*
Certificate issuer name
*/}}
{{- define "policy-controller.issuerName" -}}
{{- if .Values.certificates.selfSigned -}}
{{ template "policy-controller.IssuerName" . }}
{{- else -}}
{{ required "A valid .Values.certificates.issuer.name is required!" .Values.certificates.issuer.name }}
{{- end -}}
{{- end -}}

{{/*
Create the image path for the passed in image field
*/}}
{{- define "policy-controller.image" -}}
{{- if eq (substr 0 7 .version) "sha256:" -}}
{{- printf "%s@%s" .repository .version -}}
{{- else -}}
{{- printf "%s:%s" .repository .version -}}
{{- end -}}
{{- end -}}

{{/*
Create the image path for the passed in policy-webhook image field
*/}}
{{- define "policywebhook.image" -}}
{{- if eq (substr 0 7 .version) "sha256:" -}}
{{- printf "%s@%s" .repository .version -}}
{{- else -}}
{{- printf "%s:%s" .repository .version -}}
{{- end -}}
{{- end -}}

{{/*
*/}}
{{- define "policy-controller.webhook.namespaceSelector" -}}
{{- if .Values.webhook.namespaceSelector }}
{{ toYaml .Values.webhook.namespaceSelector }}
{{- else }}
matchExpressions:
  - key: policy.sigstore.dev/include
    operator: In
    values: ["true"]
{{- end }}
{{- end -}}
