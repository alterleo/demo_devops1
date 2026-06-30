# Привет!
# Это демонстрационный учебный проект по теме DevOps

На данный момент это:
1 приложение на python, которое проходит следующие этапы github actions:

## CI/CD
1) lint-and-test. Проверки посредством flake8 и pytest
2) build-and-push зависимая от 1) Сборка докер образа и загрузка в ghcr.io
3) deploy. 

## Runner
Локальный на собственном сервере.
Добавлено ограничение для испольвания self-hosted runner.

Для шага deploy добавил настройки Deployment protection rules - Required reviewers
