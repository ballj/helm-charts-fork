{{/* Templates for certificates injection */}}

{{- define "certificates.initContainer" -}}
{{- if .Values.certificates.customCAs }}
- name: certificates
  image: alpine:latest
  imagePullPolicy: Always
  command:
  - sh
  - -c
  - apk add --no-cache ca-certificates && update-ca-certificates
  {{- if .Values.certificates.image.extraEnvVars }}
  env:
  {{- tpl (toYaml .Values.certificates.image.extraEnvVars) $ | nindent 2 }}
  {{- end }}
  volumeMounts:
    - name: etc-ssl-certs
      mountPath: /etc/ssl/certs
      readOnly: false
    - name: custom-ca-certificates
      mountPath: /usr/local/share/ca-certificates
      readOnly: true
{{- end }}
{{- end }}

{{- define "certificates.volumes" -}}
{{- if .Values.certificates.customCAs }}
- name: etc-ssl-certs
  emptyDir:
    medium: "Memory"
- name: custom-ca-certificates
  projected:
    defaultMode: 0400
    sources:
    {{- range $index, $customCA := .Values.certificates.customCAs }}
    - secret:
        name: {{ $customCA.secret }}
        # items not specified, will mount all keys
    {{- end }}
{{- end -}}
{{- end -}}

{{- define "certificates.volumeMount" -}}
{{- if .Values.certificates.customCAs }}
- name: etc-ssl-certs
  mountPath: /etc/ssl/certs/
  readOnly: true
{{- end -}}
{{- end -}}
