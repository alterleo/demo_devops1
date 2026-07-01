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

# Infrastructure
## Terraform
Добавлены файлы terraform.
Одна виртуальная ОС ubuntu. Необходимые секретные переменные передаются через переменные окружения.
Это ручной режим для создания сервера. Получаем external_ip сервера для этапа deploy. 

Пример:
`
export TF_VAR_project_id=5d4eff6c-842a-4a81-af3f-33e90fc050bf
export TF_VAR_auth_key_id=fa06762f2b712db834f7d18c1b5420ef
export TF_VAR_auth_secret=f77b17f58ee2cd2ff0d5c12195950c72
export TF_VAR_vpc_id=fd48280c-3030-4d30-a8a8-e472311adbef
export TF_VAR_user_passwd=$(mkpasswd -m sha-512 "YourPassword123!")
`

## Ansible
На шаге deploy runner выполняет playbook:
- установка в runner ansible;
- выполнение playbook;
- установка/запуск докера;
- создание необходимой папки, копирование файлов;
- авторизация в GitHub Container Registry и вытягивание ранее подготовленного образа;
- выполнение compose файла;
- проверка состояния приложения.

### Nginx
SSL сертификата и домена нет, поэтому проверка через 80 порт