{{- define "misskey.name" -}}
misskey-{{- default .Values.host | replace "." "-" -}}
{{- end -}}

{{- define "misskey.initContainers" -}}
- name: "{{ .Release.Name }}-init"
  image: mikefarah/yq:4
  imagePullPolicy: Always
  command: ["/bin/sh"]
  args: [
    "-c",
    "cp /mnt/misskey-configuration/default.yml /misskey/.config && \
    /usr/bin/yq -i \".db.user = \\\"$POSTGRESQL_USER\\\"\" /misskey/.config/default.yml && \
    /usr/bin/yq -i \".db.pass = \\\"$POSTGRESQL_PASS\\\"\" /misskey/.config/default.yml && \
    /usr/bin/yq -i \".redis.pass = \\\"$REDIS_PASS\\\"\" /misskey/.config/default.yml" && \
    /usr/bin/yq -i \".bskSystemWebhookSecret = \\\"$BSK_SECRET\\\"\" /misskey/.config/default.yml"
  ]
  env:
    - name: POSTGRESQL_USER
      valueFrom:
        secretKeyRef:
          name: postgres-production-user-secret
          key: username
    - name: POSTGRESQL_PASS
      valueFrom:
        secretKeyRef:
          name: postgres-production-user-secret
          key: password
    - name: REDIS_PASS
      valueFrom:
        secretKeyRef:
          name: dragonfly-auth
          key: password
    - name: BSK_SECRET
      valueFrom:
        secretKeyRef:
          name: bsk-webhook
          key: secret
  volumeMounts:
    - name: {{ include "misskey.name" . }}-configuration-destination
      mountPath: /misskey/.config
    - name: {{ include "misskey.name" . }}-configuration
      mountPath: /mnt/misskey-configuration
      readOnly: true
{{- end }}

{{- define "misskey.volumes" -}}
- name: {{ include "misskey.name" . }}-configuration-destination
  emptyDir: {}
- name: {{ include "misskey.name" . }}-configuration
  configMap:
    name: {{ include "misskey.name" . }}-configuration
{{- end}}
