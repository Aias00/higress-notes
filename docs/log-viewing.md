# 如何查看 Higress 的运行日志

## K8s 部署

直接使用 `kubectl logs` 命令即可。例如：

```bash
kubectl logs -n higress-system higress-gateway-5cb7f44768-snfbd
```

注意，`higress-controller` pod 里有两个容器，`higress-core` 和 `discovery`，分别对应 `controller` 和 `pilot` 两个组件。查看日志的时候可以使用 `-c` 参数来执行要查看日志的容器名称。例如：

```bash
kubectl logs -n higress-system higress-controller-5c768d64d9-m5gtp -c discovery
```

## Docker Compose 部署

在安装目录下执行 `./bin/logs.sh 组件名称` 即可查看对应组件的日志。

常用的组件名称如下：

- apiserver
- controller
- pilot
- gateway
- console

## all-in-one 镜像部署

all-in-one 模式下，Higress 所有的日志文件均保存在容器内的 `/var/log/higress` 目录下。使用 `docker exec` 命令进入到容器内直接查看文件内容即可。 

```bash
docker exec -it higress-ai-gateway bash

cd /var/log/higress
ls -l
cat gateway.log
```
