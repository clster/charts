# restics3bucketbackup

A Helm chart to deploy a CronJob which mounts a S3 bucket using `s3fs` and then runs `restic` to back it up.

## Prerequisites

* Kubernetes 1.16+

## Installing the Chart

To install the chart with the release name `my-release`, run:

```console
$ helm install my-release clster/restics3bucketbackup
```

## Uninstalling the Chart

To uninstall the chart with the release name `my-release`, run:

```console
$ helm install my-release clster/restics3bucketbackup
```

## Configuration

The following table lists the configurable parameters of the restics3bucketbackup chart and their default values.

| Parameter | Description | Default |
| --------- | ----------- | ------- |

TODO

## TODOs

- [ ] Add configuration table
- [ ] Add option to create PodSecurityPolicy + necessary RBAC
