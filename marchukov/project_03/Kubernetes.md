Можно было развернуть полностью через Ansible, но я решил пока использовать его только как средство централизованного управления.

## Устанавливаем Kubernetes руками

https://habr.com/company/southbridge/blog/334846/

В основном ставим по этой статье, за исключением некоторых пунктов


Инициализация:

```
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.132.0.2 --kubernetes-version stable
```

Подключение Flannel:

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

Вот это можно выполнить для текущего пользователя, чтобы не заходить каждый раз под `packet`:

```
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf

echo "export KUBECONFIG=$HOME/admin.conf" | tee -a ~/.bashrc
```

### Создаем пользователя и биндинг, чтобы входить в дашборд

https://github.com/kubernetes/dashboard/wiki/Creating-sample-user


### Ставим дашборд

https://github.com/kubernetes/dashboard

Пробрасываем порт через NodePort:

https://habr.com/post/358264/#dashboard

Заходим на дашборд по адресу https://35.187.111.78:30000

Получить токен:

```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')|grep token
```

### Подключаем другие ноды

Устанавливаем пакеты:

```
wget https://gist.githubusercontent.com/alexellis/7315e75635623667c32199368aa11e95/raw/b025dfb91b43ea9309ce6ed67e24790ba65d7b67/kube.sh

ansible all -m script -a kube.sh -b

# Добавляем ноды в кластер

ansible all -m command -a "kubeadm join 10.132.0.2:6443 --token ytpkoc.xatl4xheikm2watd --discovery-token-ca-cert-hash sha256:0d649ea2775c0d716708b8d5762ff51bac00dfbafddfcd9950b3f5bd64eb404e" -b

# Проверяем ноды

kubectl get nodes
```

### Материалы

По использованию kubectl: https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands


### Tips'n'Tricks

Запуск контейнера

kubectl run -it --image=alpine --command sh

Для тех, кто привык к докеру: https://kubernetes.io/docs/reference/kubectl/docker-cli-to-kubectl/

## Устанавливаем Kubernetes через Ansible

https://github.com/kubernetes-incubator/kubespray

http://linux-notes.org/ustanovka-kubernetes-v-unix-linux/





eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLWx4cDk4Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI4MGI2Y2ZmYy1lNWI4LTExZTgtYTY1OS00MjAxMGE4NDAwMDIiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06YWRtaW4tdXNlciJ9.S5S6lNrSk6coE5PElnxqBKxJGWXwBtndjNggmvplJlNS7zw08BBMIBsndl5eD-1vLErH1VEqt1d8vVTiD_GCDGN78OyTs89KhVfey0yCIX86F3-z35oFZmAQAHMBcnb9WXpHJ55Y3_QaUSZIDjCWLcmbMLZZjxuC8ID3PtqRz_KnM-zzsle23j9XBEAu__C-hGZs2Yk37CSXU3u0nSZvI2bTmhaYWODB6nuUBtthcrE83kJZ_-o5yjO64O8sgRPJW7clRmXErG4NcU9-Ihom-7x-i0lRYYtOU9dghO7tik4-hTzV_4DIQbmBy0rfiuZoGWElkPT7N9-7SfRhRaWJiA