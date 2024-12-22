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
    /usr/bin/yq -i \".redis.pass = \\\"$REDIS_PASS\\\"\" /misskey/.config/default.yml && \
    /usr/bin/yq -i \".bskSystemWebhookSecret = \\\"$BSK_SECRET\\\"\" /misskey/.config/default.yml && \
    /usr/bin/yq -i \".proxy = \\\"$PROXY_SECRET\\\"\" /misskey/.config/default.yml && \
    /usr/bin/yq -i \".meilisearch.host = \\\"$MEILISEARCH_HOST\\\"\" /misskey/.config/default.yml && \
    /usr/bin/yq -i \".meilisearch.port = $MEILISEARCH_PORT\" /misskey/.config/default.yml && \
    /usr/bin/yq -i \".meilisearch.apiKey = \\\"$MEILISEARCH_API_KEY\\\"\" /misskey/.config/default.yml && \
    /usr/bin/yq -i \".meilisearch.ssl = $MEILISEARCH_SSL\" /misskey/.config/default.yml && \
    /usr/bin/yq -i \".meilisearch.index = \\\"$MEILISEARCH_INDEX\\\"\" /misskey/.config/default.yml && \
    /usr/bin/yq -i \".hanamisearch.host = \\\"$HANAMISEARCH_HOST\\\"\" /misskey/.config/default.yml && \
    /usr/bin/yq -i \".hanamisearch.port = $HANAMISEARCH_PORT\" /misskey/.config/default.yml && \
    /usr/bin/yq -i \".hanamisearch.apiKey = \\\"$HANAMISEARCH_API_KEY\\\"\" /misskey/.config/default.yml && \
    /usr/bin/yq -i \".hanamisearch.ssl = $HANAMISEARCH_SSL\" /misskey/.config/default.yml && \
    /usr/bin/yq -i \".hanamisearch.index = \\\"$HANAMISEARCH_INDEX\\\"\" /misskey/.config/default.yml"
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
    - name: PROXY_SECRET
      valueFrom:
        secretKeyRef:
          name: proxy-secret
          key: secret
    - name: MEILISEARCH_HOST
      valueFrom:
        secretKeyRef:
          name: meilisearch-secret
          key: host
    - name: MEILISEARCH_PORT
      valueFrom:
        secretKeyRef:
          name: meilisearch-secret
          key: port
    - name: MEILISEARCH_API_KEY
      valueFrom:
        secretKeyRef:
          name: meilisearch-secret
          key: apiKey
    - name: MEILISEARCH_SSL
      valueFrom:
        secretKeyRef:
          name: meilisearch-secret
          key: ssl
    - name: MEILISEARCH_INDEX
      valueFrom:
        secretKeyRef:
          name: meilisearch-secret
          key: index
    - name: HANAMISEARCH_HOST
      valueFrom:
        secretKeyRef:
          name: hanamisearch-secret
          key: host
    - name: HANAMISEARCH_PORT
      valueFrom:
        secretKeyRef:
          name: hanamisearch-secret
          key: port
    - name: HANAMISEARCH_API_KEY
      valueFrom:
        secretKeyRef:
          name: hanamisearch-secret
          key: apiKey
    - name: HANAMISEARCH_SSL
      valueFrom:
        secretKeyRef:
          name: hanamisearch-secret
          key: ssl
    - name: HANAMISEARCH_INDEX
      valueFrom:
        secretKeyRef:
          name: hanamisearch-secret
          key: index
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
