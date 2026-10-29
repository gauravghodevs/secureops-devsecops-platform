# Centralized Logging Verification (2026-10-28)

## 1. Logging Stack Pod & Service Status

```text
NAME                        READY   STATUS    RESTARTS   AGE    IP            NODE                   NOMINATED NODE   READINESS GATES
pod/elasticsearch-0         1/1     Running   0          7h6m   10.244.0.28   devops-control-plane   <none>           <none>
pod/fluent-bit-527cp        1/1     Running   0          7h5m   10.244.0.29   devops-control-plane   <none>           <none>
pod/kibana-fd649788-gd4bn   1/1     Running   0          7h6m   10.244.0.27   devops-control-plane   <none>           <none>

NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE     SELECTOR
service/elasticsearch   ClusterIP   10.96.158.29    <none>        9200/TCP   7h39m   app=elasticsearch
service/kibana          ClusterIP   10.96.194.201   <none>        5601/TCP   7h39m   app=kibana
```

## 2. Elasticsearch Indices

```text
health status index                uuid                   pri rep docs.count docs.deleted store.size pri.store.size dataset.size
yellow open   secureops-2026.10.28 mfBL9i4gR8mhREtxB3LNTg   1   1      26288            0      9.4mb          9.4mb        9.4mb
```

## 3. Sample Ingested payment-api Log Document

```json
{
  "took" : 230,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 10000,
      "relation" : "gte"
    },
    "max_score" : 13.174894,
    "hits" : [
      {
        "_index" : "secureops-2026.10.28",
        "_id" : "0e0rgaEB_Csjy7ykZher",
        "_score" : 13.174894,
        "_source" : {
          "@timestamp" : "2026-10-28T06:18:58.312Z",
          "time" : "2026-10-28T06:18:58.312434574Z",
          "stream" : "stderr",
          "_p" : "F",
          "log" : "[2026/10/28 06:18:58] [ info] [input:tail:tail.0] inotify_fs_add(): inode=372118 watch_fd=41 name=/var/log/containers/payment-api-7df874b85d-fs7n2_default_payment-api-35cac4399a4faac28b48c9aaeb0d24f53c3d7ebd23176e1e3b7cb6a1b564e7a8.log",
          "kubernetes" : {
            "pod_name" : "fluent-bit-527cp",
            "namespace_name" : "logging",
            "pod_id" : "c21e4a5e-36ff-4405-bc30-cf23c85a522f",
            "labels" : {
              "app" : "fluent-bit",
              "controller-revision-hash" : "5447f586ff",
              "pod-template-generation" : "1"
            },
            "host" : "devops-control-plane",
            "container_name" : "fluent-bit",
            "docker_id" : "0fa8dab9d9cc79b30bd050992b0ca26b940f749ec54b838c44c669dcaf46e0ab",
            "container_hash" : "docker.io/fluent/fluent-bit@sha256:981b37a0faf56182e2e880cfdb87226dc71ed29a8a9eb4bbaba83ccfe0e00cbf",
            "container_image" : "docker.io/fluent/fluent-bit:3.1.4"
          }
        }
      }
    ]
  }
}
```

## 4. Direct payment-api Container Log Hit

```json
{
  "took" : 153,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 10000,
      "relation" : "gte"
    },
    "max_score" : 1.5970464,
    "hits" : [
      {
        "_index" : "secureops-2026.10.28",
        "_id" : "o-0rgaEB_Csjy7yk2xhf",
        "_score" : 1.5970464,
        "_source" : {
          "@timestamp" : "2026-10-28T06:19:04.398Z",
          "time" : "2026-10-28T06:19:04.398729458Z",
          "stream" : "stdout",
          "_p" : "F",
          "log" : "INFO:     10.244.0.1:42700 - \"GET /health HTTP/1.1\" 200 OK",
          "kubernetes" : {
            "pod_name" : "payment-api-7df874b85d-j6r9t",
            "namespace_name" : "default",
            "pod_id" : "ffba9a8e-a4ad-473b-bb46-5265d7916cde",
            "labels" : {
              "app" : "payment-api",
              "pod-template-hash" : "7df874b85d"
            },
            "host" : "devops-control-plane",
            "container_name" : "payment-api",
            "docker_id" : "a40f4c215f0f0d8abeb4c62497721427a4578feb74fa1f225a031eb14187a3b6",
            "container_hash" : "ghcr.io/gauravghodevs/secureops-payment-api@sha256:065db211c68952992417040abcf4ccdf2e97d0a198d87c05773a4e30ddd88eb4",
            "container_image" : "ghcr.io/gauravghodevs/secureops-payment-api:8a9965cfabef1ce7ed49787141a806179be44b1b"
          }
        }
      }
    ]
  }
}
```
