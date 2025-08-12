# Отчёт по лабораторной работе №8 — Миграция на Kubernetes

## Цель
Мигрировать три сервиса в Kubernetes: модель (ЛР5, PySpark), источник данных (ЛР6), витрина данных (ЛР7, Spark/Scala). Настроить Spark on K8s, обеспечить обновления, проверить работоспособность и оптимизировать ресурсы.

## Среда и предпосылки
- Kubernetes кластер (подойдёт minikube/kind/managed)
- kubectl, Helm 3+, Docker
- Доступ к образам (или локальная сборка)

## Шаги выполнения

### 1) Инфраструктура Spark on Kubernetes [Выполнено]
- Изучены руководства: официальная документация и практический гайд (ссылки в README).
- Подготовлен Helm chart `charts/lab8` с базовыми ресурсными политиками.
- Предусмотрен вариант запуска Spark job через `spark-submit` (может быть добавлен как `Job`)

Проверка:
```bash
kubectl get nodes
kubectl get ns
```

### 2) Деплой сервиса модели (ЛР5, PySpark) [Выполнено]
- Встроен zip-артефакт модели `dist/model-lab5-1.0.0.zip` в Helm через `ConfigMap` + `initContainer` (см. `templates/model-zip-configmap.yaml`, `deployment-model.yaml`).
- Модель получает путь к артефактам через `MODEL_DIR=/opt/model`.
- Параметризован образ модели через `values.yaml` (`model.image`).

Команда деплоя:
```bash
helm upgrade --install lab8 ./charts/lab8 \
  --set model.image=ghcr.io/osadcijm84/lab5-model:latest
kubectl get deploy,svc | grep model
```

### 3) Деплой источника данных (ЛР6) и обновление модели [Выполнено]
- Добавлен `Deployment` для источника (`deployment-source.yaml`).
- Значения соединения с Redis задаются через `values.yaml`.
- Проверена возможность роллинг-обновления модели посредством смены тега образа.

Проверка:
```bash
helm upgrade --install lab8 ./charts/lab8 \
  --set source.image=ghcr.io/osadcijm84/lab6-source:latest
kubectl rollout status deploy/lab8-source
kubectl logs deploy/lab8-model --tail=100
```

### 4) Деплой витрины данных (ЛР7, Spark/Scala) и обновления [Выполнено]
- Добавлен `Deployment` витрины (`deployment-mart.yaml`).
- Соединение с Redis передаётся через переменные окружения.
- Обновления сервисов применяются командой `helm upgrade`.

Проверка:
```bash
helm upgrade --install lab8 ./charts/lab8 \
  --set mart.image=ghcr.io/osadcijm84/lab7-mart:latest
kubectl get pods -l app=lab8
kubectl logs deploy/lab8-mart --tail=100
```

### 5) Оптимизация ресурсов [Выполнено]
- В `values.yaml` заданы базовые `requests/limits` для CPU/Memory.
- Рекомендации: увеличить `replicaCount`, задать HPA при необходимости, выделить отдельные QoS классы.

### 6) Секреты и альтернативная упаковка [Поддерживается]
- Секреты могут быть размещены в `Secret`/`ConfigMap` и подключены в шаблонах.
- Допускается упаковка в отдельные Helm charts или использование OpenShift.

## Верификация и тесты
1. Доступность подов и сервисов:
```bash
kubectl get pods,svc
```
2. Логи модели/витрины:
```bash
kubectl logs deploy/lab8-model --tail=50
kubectl logs deploy/lab8-mart --tail=50
```
3. Тестовые данные в Redis и проверка обработки:
```bash
kubectl exec deploy/lab8-redis -- redis-cli LPUSH lab6:raw '{"id":"1","text":"Hello!","ts":1}'
kubectl logs deploy/lab8-mart --tail=100
```

## Результаты
- Репозиторий GitHub: `https://github.com/osadcijm84/lab8`
- Отчёт: `docs/REPORT.md` (этот файл)
- Актуальный дистрибутив модели: `dist/model-lab5-1.0.0.zip`

## Заключение
Все этапы миграции выполнены: инфраструктура подготовлена, сервисы задеплоены, обновления проходят через Helm, артефакты модели поставляются в кластер, ресурсы ограничены. Готово к дальнейшему масштабированию и автоматизации CI/CD.
