{{- define "lab8.name" -}}
lab8
{{- end -}}
{{- define "lab8.fullname" -}}
{{ include "lab8.name" . }}
{{- end -}}

{{- define "lab8.modelZipConfigMapName" -}}
{{ include "lab8.fullname" . }}-model-zip
{{- end -}}
