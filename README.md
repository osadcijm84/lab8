# Lab 8 — Kubernetes Migration for ML Services

Миграция: модель (PySpark), витрина (Spark/Scala), источник данных (Redis) в кластер Kubernetes. С Helm Chart и базовыми ресурсными политиками.

## 🎯 Цель
Получить навыки оркестрации контейнеров в Kubernetes, подготовки инфраструктуры для Spark и деплоя трёх сервисов.

## 🏗️ Архитектура
```
┌─────────────┐     ┌─────────────┐     ┌───────────────┐     ┌──────────────┐
│  Model svc  │◄──► │  Data Mart  │ ◄── │   Redis svc    │     │  Spark on K8s │
│  (PySpark)  │     │ (Spark/Scala)│    │ (storage bus) │     │ (Driver/Execs)│
└─────────────┘     └─────────────┘     └───────────────┘     └──────────────┘
```

## 🚀 Быстрый старт

### Требования
- kubectl, Kubernetes cluster (minikube/kind/eks/aks/gke)
- Helm 3+
- Docker

### Установка
```bash
helm upgrade --install lab8 ./charts/lab8 \
  --set model.image=ghcr.io/osadcijm84/lab5-model:latest \
  --set source.image=ghcr.io/osadcijm84/lab6-source:latest \
  --set mart.image=ghcr.io/osadcijm84/lab7-mart:latest
```

Проверка:
```bash
kubectl get pods,svc
```

Артефакт модели:

- Helm чарт встраивает `dist/model-lab5-1.0.0.zip` как `ConfigMap` и через `initContainer` распаковывает его в `/opt/model`.
- Приложение модели получает путь к артефактам через переменную `MODEL_DIR=/opt/model`.

## 🔧 Настройка
- `charts/lab8/values.yaml` — образы, ресурсы, Redis
- секреты можно разместить в `Secret`/`ConfigMap`, шаблоны можно добавить в `templates/`

## 🔄 Обновления
- Роллинг-обновления через `Deployment` при смене тега образа
- Последовательность: источник → витрина → модель (или наоборот по требованиям)

## 📚 Ссылки
- Spark on K8s: https://spark.apache.org/docs/latest/running-on-kubernetes.html
- Гайд: https://habr.com/ru/companies/neoflex/articles/511734/

## 🧪 Тестирование
```bash
a. Отправьте тестовые данные в Redis
b. Проверьте логи подов модели и витрины
```

## 📝 Отчёт
См. `docs/REPORT.md`.
