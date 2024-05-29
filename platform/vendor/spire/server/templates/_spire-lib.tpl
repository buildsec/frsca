{{- define "spire-lib.cluster-name" }}
{{- if ne (len (dig "spire" "clusterName" "" .Values.global)) 0 }}
{{- .Values.global.spire.clusterName }}
{{- else }}
{{- .Values.clusterName }}
{{- end }}
{{- end }}

{{- define "spire-lib.trust-domain" }}
{{- if ne (len (dig "spire" "trustDomain" "" .Values.global)) 0 }}
{{- .Values.global.spire.trustDomain }}
{{- else }}
{{- .Values.trustDomain }}
{{- end }}
{{- end }}

{{- define "spire-lib.jwt-issuer" }}
{{- if ne (len (dig "spire" "jwtIssuer" "" .Values.global)) 0 }}
{{- .Values.global.spire.jwtIssuer }}
{{- else if ne (len .Values.jwtIssuer) 0 }}
{{- .Values.jwtIssuer }}
{{- else }}
{{- printf "https://oidc-discovery.%s" (include "spire-lib.trust-domain" .) }}
{{- end }}
{{- end }}

{{- define "spire-lib.bundle-configmap" }}
{{- if ne (len (dig "spire" "bundleConfigMap" "" .Values.global)) 0 }}
{{- .Values.global.spire.bundleConfigMap }}
{{- else }}
{{- .Values.bundleConfigMap }}
{{- end }}
{{- end }}

{{- define "spire-lib.cluster-domain" -}}
{{- if ne (len (dig "k8s" "clusterDomain" "" .Values.global)) 0 }}
{{- .Values.global.k8s.clusterDomain }}
{{- else }}
{{- .Values.clusterDomain }}
{{- end }}
{{- end }}

{{- define "spire-lib.registry" }}
{{- if ne (len (dig "spire" "image" "registry" "" .global)) 0 }}
{{- print .global.spire.image.registry "/"}}
{{- else if ne (len (.image.registry)) 0 }}
{{- print .image.registry "/"}}
{{- end }}
{{- end }}

{{- define "spire-lib.image" -}}
{{- $registry := include "spire-lib.registry" . }}
{{- $repo := .image.repository }}
{{- $tag := .image.tag | toString }}
{{- if eq (substr 0 7 $tag) "sha256:" }}
{{- printf "%s/%s@%s" $registry $repo $tag }}
{{- else if .appVersion }}
{{- $appVersion := .appVersion }}
{{- if and (hasKey . "ubi") (dig "openshift" false .global) }}
{{- $appVersion = printf "ubi-%s" $appVersion }}
{{- end }}
{{- printf "%s%s:%s" $registry $repo (default $appVersion $tag) }}
{{- else if $tag }}
{{- printf "%s%s:%s" $registry $repo $tag }}
{{- else }}
{{- printf "%s%s" $registry $repo }}
{{- end }}
{{- end }}

{{/* Takes in a dictionary with keys:
 * global - the standard global object
 * ingress - a standard format ingress config object
*/}}
{{- define "spire-lib.ingress-controller-type" }}
{{-   $type := "" }}
{{-   if ne (len (dig "spire" "ingressControllerType" "" .global)) 0 }}
{{-     $type = .global.spire.ingressControllerType }}
{{-   else if ne .ingress.controllerType "" }}
{{-     $type = .ingress.controllerType }}
{{-   else if (dig "openshift" false .global) }}
{{-     $type = "openshift" }}
{{-   else }}
{{-     $type = "other" }}
{{-   end }}
{{-   if not (has $type (list "ingress-nginx" "openshift" "other")) }}
{{-     fail "Unsupported ingress controller type specified. Must be one of [ingress-nginx, openshift, other]" }}
{{-   end }}
{{-   $type }}
{{- end }}

{{/* Takes in a dictionary with keys:
 * ingress - the standardized ingress object
 * Values - Chart values
*/}}
{{ define "spire-lib.ingress-calculated-name" }}
{{- $host := .ingress.host }}
{{- if not (contains $host ".") }}
{{-   $host = printf "%s.%s" $host (include "spire-lib.trust-domain" .) }}
{{- end }}
{{- $host }}
{{- end }}

{{/* Takes in a dictionary with keys:
 * ingress - the standardized ingress object
 * svcName - The service to route to
 * port - which port on the service to use
 * path - optional path to set on the rules
 * pathType - typical ingress path type
 * tlsSection - bool specifying to add by default the tls section to the ingress. Ingress-nginx needs true, openshift needs false.
 * Values - Chart values
*/}}
{{ define "spire-lib.ingress-spec" }}
{{- $host := include "spire-lib.ingress-calculated-name" . }}
{{- $svcName := .svcName }}
{{- $port := .port }}
{{- with .ingress.className }}
ingressClassName: {{ . | quote }}
{{- end }}
{{- if eq (add (len .ingress.tls) (len .ingress.hosts)) 0 }}
{{ if or .tlsSection .ingress.tlsSecret }}
tls:
  - hosts:
      - {{ $host | quote }}
{{- with .ingress.tlsSecret }}
    secretName: {{ . | quote }}
{{- end }}
{{- end }}
rules:
  - host: {{ $host | quote }}
    http:
      paths:
        - pathType: {{ .pathType }}
          {{- with .path }}
          path: {{ . }}
          {{- end }}
          backend:
            service:
              name: {{ $svcName | quote }}
              port:
                number: {{ $port }}
{{- else }}
{{- if .ingress.tls }}
tls:
  {{- range .ingress.tls }}
  - hosts:
      {{- range .hosts }}
      - {{ . | quote }}
      {{- end }}
    secretName: {{ .secretName | quote }}
  {{- end }}
{{- end }}
rules:
  {{- range .ingress.hosts }}
  - host: {{ .host | quote }}
    http:
      paths:
        {{- range .paths }}
        - path: {{ .path }}
          pathType: {{ .pathType }}
          backend:
            service:
              name: {{ $svcName | quote }}
              port:
                number: {{ $port }}
        {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "spire-lib.kubectl-image" }}
{{-   $root := deepCopy . }}
{{-   $tag := $root.image.tag | toString }}
{{-   if eq (len $tag) 0 }}
{{-      if dig "spire" "tools" "kubectl" "tag" "" $root.global }}
{{-        $_ := set $root.image "tag" $root.global.spire.tools.kubectl.tag }}
{{-      else }}
{{-        $_ := set $root.image "tag" (regexReplaceAll "^(v?\\d+\\.\\d+\\.\\d+).*" $root.KubeVersion "${1}") }}
{{-     end }}
{{-   end }}
{{-   include "spire-lib.image" $root }}
{{- end }}

{{/*
Take in an array of, '.', a failure string to display, and boolean to to display it,
if strictMode is enabled and the boolean is true
*/}}
{{- define "spire-lib.check-strict-mode" }}
{{ $root := index . 0 }}
{{ $message := index . 1 }}
{{ $condition := index . 2 }}
{{- if or (dig "spire" "strictMode" false $root.Values.global) (and (dig "spire" "recommendations" "enabled" false $root.Values.global) (dig "spire" "recommendations" "strictMode" true $root.Values.global)) }}
{{- if $condition }}
{{- fail $message }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Take a copy of the config and merge in .Values.customPlugins and .Values.unsupportedBuiltInPlugins passed through as root.
*/}}
{{- define "spire-lib.config_merge" }}
{{- $pluginsToMerge := dict "plugins" dict }}
{{- range $type, $val := .root.Values.customPlugins }}
{{-   if . }}
{{-     if eq $type "svidstore" }}
{{-       $_ := set $pluginsToMerge.plugins "SVIDStore" (deepCopy $val) }}
{{-     else }}
{{-       $nt := printf "%s%s" (substr 0 1 $type | upper) (substr 1 -1 $type) }}
{{-       $_ := set $pluginsToMerge.plugins $nt (deepCopy $val) }}
{{-     end }}
{{-   end }}
{{- end }}
{{- range $type, $val := .root.Values.unsupportedBuiltInPlugins }}
{{-   if . }}
{{-     if eq $type "svidstore" }}
{{-       $_ := set $pluginsToMerge.plugins "SVIDStore" (deepCopy $val) }}
{{-     else }}
{{-       $nt := printf "%s%s" (substr 0 1 $type | upper) (substr 1 -1 $type) }}
{{-       $_ := set $pluginsToMerge.plugins $nt (deepCopy $val) }}
{{-     end }}
{{-   end }}
{{- end }}
{{- $newConfig := .config | fromYaml | mustMerge $pluginsToMerge }}
{{- $newConfig | toYaml }}
{{- end }}

{{/*
Take a copy of the plugin section and return a yaml string based version
reformatted from a dict of dicts to a dict of lists of dicts
*/}}
{{- define "spire-lib.plugins_reformat" }}
{{- range $type, $v := . }}
{{ $type }}:
{{-   range $name, $v2 := $v }}
    - {{ $name }}: {{ $v2 | toYaml | nindent 8 }}
{{-   end }}
{{- end }}
{{- end }}

{{/*
Take a copy of the config as a yaml config and root var.
Merge in .root.Values.customPlugins and .Values.unsupportedBuiltInPlugins into config,
Reformat the plugin section from a dict of dicts to a dict of lists of dicts,
and export it back as as json string.
This makes it much easier for users to merge in plugin configs, as dicts are easier
to merge in values, but spire needs arrays.
*/}}
{{- define "spire-lib.reformat-and-yaml2json" -}}
{{- $config := include "spire-lib.config_merge" . | fromYaml }}
{{- $plugins := include "spire-lib.plugins_reformat" $config.plugins | fromYaml }}
{{- $_ := set $config "plugins" $plugins }}
{{- $config | toPrettyJson }}
{{- end }}

{{- define "spire-lib.default_securitycontext_values" }}
allowPrivilegeEscalation: false
runAsNonRoot: true
readOnlyRootFilesystem: true
capabilities:
  drop: [ALL]
seccompProfile:
  type: RuntimeDefault
{{- end }}

{{- define "spire-lib.default_k8s_podsecuritycontext_values" }}
fsGroupChangePolicy: OnRootMismatch
runAsUser: 1000
runAsGroup: 1000
fsGroup: 1000
{{- end }}

{{/*
Note: runAsUser, runAsGroup, fsGroup, are not needed due to it autoassigning restricted users feature of openshift
*/}}
{{- define "spire-lib.default_openshift_podsecuritycontext_values" }}
fsGroupChangePolicy: OnRootMismatch
{{- end }}

{{- define "spire-lib.securitycontext" }}
{{- include "spire-lib.securitycontext-extended" (dict "root" . "securityContext" .Values.securityContext) }}
{{- end }}

{{/* Same as securitycontext but takes in:
root - global . context for the chart
securityContext - the subbranch of values that contains the securityContext to merge
*/}}
{{- define "spire-lib.securitycontext-extended" }}
{{- if and (dig "spire" "recommendations" "enabled" false .root.Values.global) (dig "spire" "recommendations" "securityContexts" true .root.Values.global) }}
{{- $vals := deepCopy (include "spire-lib.default_securitycontext_values" .root | fromYaml) }}
{{- $vals = mergeOverwrite $vals .securityContext }}
{{- toYaml $vals }}
{{- else }}
{{- toYaml .securityContext }}
{{- end }}
{{- end }}

{{- define "spire-lib.podsecuritycontext" }}
{{-   $vals := dict }}
{{-   if and (dig "spire" "recommendations" "enabled" false .Values.global) (dig "spire" "recommendations" "securityContexts" true .Values.global) }}
{{-     if (dig "openshift" false .Values.global) }}
{{-       $vals = mergeOverwrite $vals (include "spire-lib.default_openshift_podsecuritycontext_values" . | fromYaml) }}
{{-     else }}
{{-       $vals = mergeOverwrite $vals (include "spire-lib.default_k8s_podsecuritycontext_values" . | fromYaml) }}
{{-     end }}
{{-   end }}
{{-   $vals = mergeOverwrite $vals .Values.podSecurityContext }}
{{-   toYaml $vals }}
{{- end }}

{{- define "spire-lib.default_node_priority_class_name" }}
{{- if .Values.priorityClassName }}
priorityClassName: {{ .Values.priorityClassName }}
{{- else if and (dig "spire" "recommendations" "enabled" false .Values.global) (dig "spire" "recommendations" "priorityClassName" true .Values.global) }}
priorityClassName: system-node-critical
{{- end }}
{{- end }}

{{- define "spire-lib.default_cluster_priority_class_name" }}
{{- if .Values.priorityClassName }}
priorityClassName: {{ .Values.priorityClassName }}
{{- else if and (dig "spire" "recommendations" "enabled" false .Values.global) (dig "spire" "recommendations" "priorityClassName" true .Values.global) }}
priorityClassName: system-cluster-critical
{{- end }}
{{- end }}

{{/*
Use autoscaling/v2 (Kubernetes 1.23 and newer) or autoscaling/v2beta2 (Kubernetes 1.12-1.25) based on cluster capabilities.
Anything lower has an incompatible API.
*/}}
{{- define "spire-lib.autoscalingVersion" -}}
{{- if (.Capabilities.APIVersions.Has "autoscaling/v2") }}
{{- print "autoscaling/v2" }}
{{- else if (.Capabilities.APIVersions.Has "autoscaling/v2beta2") }}
{{- print "autoscaling/v2beta2" }}
{{- else }}
{{- fail "Unsupported autoscaling API version" }}
{{- end }}
{{- end }}
