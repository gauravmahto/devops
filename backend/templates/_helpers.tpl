{{- define "my-backend.name" -}}
my-backend
{{- end -}}

{{- define "my-backend.fullname" -}}
{{ .Release.Name }}
{{- end -}}
