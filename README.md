BHS2024
==============

Описание
-----------

Тестовое задание для проекта **Маркетплейс ассетов Hive** 

Построение стенда:
-----------------------
1. Создание виртуальной машины:
    * Создание ВМ будем производить в облаке К2 Cloud, K2 Cloud является AWS-подобным облаком, создавать ВМ будем с использованием Terraform, для этого на управляющем хосте, необходимо выполнить следующую последовательность действий. Мой управляющий хост развернут на ОС Ubuntu 20.04.6 LTS (Focal Fossa), ВМ будем создавать на ОС Debian 11 (bullseye). 
    * В зависимости от используемого дистрибутива Debian-based or RHEL-based:
        ```bash
        sudo apt install unzip -y
        sudo yum install unzip -y
        ```
    * Выкачать архив с бинарником terraform, распаковать, выдать права на исполнение, закинуть в /bin:
        ```bash
        sudo wget https://hashicorp-releases.yandexcloud.net/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip
        sudo unzip terraform_1.7.5_linux_amd64.zip
        sudo cp terraform /bin
        # Проверить версию Terraform
        terraform --version
        ```
    * В директории /opt создать вложенные директории для хранения даннных о провайдерах Terraform, данный способ позволит поднять своё зеркало Terraform на управляющем хосте, позволит использовать Terraform без VPN. Внизу приведен пример для конкретных целевых провайдеров K2 Cloud, если версия/необходимый провайдер отличаются, необходимо создать директории с соответсвующим наименованием после директории local.
        ```bash
        sudo mkdir -p /opt/terraform_mirror/.terraform.d/plugins/registry.terraform.io/local/croc/24.0.0/linux_amd64
        sudo mkdir -p /opt/terraform_mirror/.terraform.d/plugins/registry.terraform.io/local/template/2.0.0/linux_amd64/
        ```
    * Выкачать провайдеры K2 Cloud, Templates, распаковать архивы, положить провайдеры в целевые директории:
        ```bash
        sudo wget https://github.com/C2Devel/terraform-provider-croccloud/releases/download/v24.0.0/terraform-provider-croccloud_24.0.0_linux_amd64.zip 
        sudo unzip terraform-provider-croccloud_24.0.0_linux_amd64.zip 
        sudo mv terraform-provider-croccloud_24.0.0 terraform-provider-croc_v24.0.0
        # Выкачать провайдер с целевого хранилища/через VPN
        sudo wget https://nextcloud.croc.ru/s/2T7s7nnCKTZdHX3/download/terraform-provider-template_v2.2.0_x4
        sudo mv terraform-provider-template_v2.2.0_x4 /opt/terraform_mirror/.terraform.d/plugins/registry.terraform.io/local/template/2.0.0/linux_amd64/
        ```
    * Переместить файл .terraformrc в /home директорию пользователя, от имени которого планируется производить запуск Terraform манифестов по созданию ВМ.
        ```bash
        sudo mv .terraformrc ~
        ```
    * Получить учётные данные для доступа в K2 Cloud: AWS_ACCESS_KEY, AWS_SECRET_KEY
    * Внести необходимые данные по ВМ и разворачиваемой инфраструктуре в файл terraform.tfvars, чувствительные данные в файл не вносить. Переменные, их дефолтные значения, описаны в файле variables.tf.
    * Сгенерировать RSA ключ для доступа к серверам по OpenSSH, скопировать публичную часть ключа
        ```bash
                ssh-keygen
                Generating public/private rsa key pair.
                Enter file in which to save the key (/home/ec2-user/.ssh/id_rsa):
                /home/ec2-user/.ssh/id_rsa already exists.
                Overwrite (y/n)? y
                Enter passphrase (empty for no passphrase):
                Enter same passphrase again:
                Your identification has been saved in /home/ec2-user/.ssh/id_rsa
                Your public key has been saved in /home/ec2-user/.ssh/id_rsa.pub
                The key fingerprint is:
                SHA256:b4VJyUryGJgOinmhYJbLrNj4l3R7qY4OpvdgByMBl9w ec2-user@AEREMIN
                The key's randomart image is:
                +---[RSA 3072]----+
                |...o             |
                |..+ Eo   . .     |
                |o+o o o . +      |
                |B=.+   * o o     |
                |*++ . . S o .    |
                |o= o. .  . .     |
                |+ *..o . .o      |
                | =.+o.. o.       |
                |...++.oo         |
                +----[SHA256]-----+
        ```
    * Запустить установку целевой инфраструктуры, передать чувствительные данные как переменную Terraform, в идеале - интегрироваться с Vault/положить секреты в Enviroment Gitlab. Дождаться выполнения команды.
    ```bash
    sudo terraform apply -var="secret_key=" -var="access_key=" -var="public_key=" -auto-approve
    ```
    * После деплоя, проверить доступность ВМ по сети, командой ping, подключиться по SSH, используя приватную часть ключа, созданного выше, подключение по-умолчанию идёт через пользователя ec2-user, созданного Packer, при использовании сторонних облаков/образов необходимо изменить имя пользователя на целевое/добавить в файл init/cloud-init.yaml секцию создания пользователя, добавления ключа, IP адрес целевого хоста доя подключения можно узнать выполнив команду ниже.
        ```bash
        cat terraform.tfstate.backup | grep private_ip
            "private_ip": "10.10.10.20",
        ssh ec2-user@10.10.10.20 -i /home/ec2-user/id_rsa
        ```
2. Установка Docker, приложение, вывод приложения для доступа из локальной сети
    * Приложение и его структура:
       * Приложение - CRUD Web сервер на Go, который обрабатывает запросы к URL /users, позволяя выводить список пользователей приложения, создавать новых пользоватей, удалять пользоватей из БД. В качестве СУБД выбрано PostgreSQL. 
       * Структура приложения:
            ```
            ** app
                * app.go - основной скрипт, читает env переменные контейнера, запускает веб-сервис, подключается к СУБД
                ** db
                    * db.go - логика подключения к СУБД, инициализации таблиц БД
                ** models
                    * models.go - сущности для инициализации GORM
                ** web
                    * web.go - логика обработки запросов, приходящих на URL
            ``` 
    * Установка Docker и деплой приложения руками:
        * Для установки Docker и необходимых зависимостей, необходимо в зависимости от используемого дистрибутива Debian-based or RHEL-based:
            ```bash
            # Debian-based
            # Add Docker's official GPG key:
            sudo apt-get update
            sudo apt-get install ca-certificates curl
            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc

            # Add the repository to Apt sources:
            echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose

            # RHEL-based
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
            sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

            # Запустить демон docker
            sudo systemctl enable --now docker
            ```
        * Внести изменения в файл docker-compose.yaml, основные параметры файла представлены ниже, чувствительные данные для docker-compose хранятся в секретах docker, и должны доставляться на целевой хост средствами CI/CD, после поднятий контейнеров необходимо удалить файлы с секретами на целемов хосте.
            Variable | Type | Description | Required
            -------- | ----- | -------- | -----------
            `db.image` | string | Имя образа для СУБД PostgreSQL, используеся образ основанный на Alpine, для снижения размера образа| yes
            `db.volumes` | string | Путь для монтирования директории с файлами из контейнера на локальнйы хост, для сохранения данных БД после уничтожения контейнера | yes
            `db.ports` | string | Строка проброса портов на локальный хост, для подключения из локальной сети | yes
            `db.image` | string | Имя образа для СУБД PostgreSQL, используеся образ основанный на Alpine, для снижения размера образа| yes
            `db.environment.POSTGRES_USER_FILE` | string | ENV переменная контейнера, контейнер читает данные из файла для инициализации пользователя PostgreSQL | yes
            `db.environment.POSTGRES_PASSWORD_FILE` | string | ENV переменная контейнера, контейнер читает данные из файла для инициализации пароля пользователя PostgreSQL | yes
            `db.environment.POSTGRES_DATABASE_FILE` | string | ENV переменная контейнера, контейнер читает данные из файла для инициализации БД PostgreSQL | yes
            `db.secrets` | list | Список секретов, используемых контейнером с PostgreSQL | yes
            `db.shm_size` | string | Размер параметра shared buffers, влияет на размер буфера, используемого для временного хранения данных | yes
            `web_app.depends_on` | list | Имена контейнеров, от которых зависит запуск инстанса приложения | yes
            `web_app.build.dockerfile` | string | Путь до файла сборки контейнера с Go приложением | yes
            `web_app.build.context` | string | Путь до собираемой директории | yes
            `web_app.environment.POSTGRES_USER_FILE` | string | ENV переменная контейнера, контейнер читает данные из файла для инициализации подключения к PostgreSQL | yes
            `web_app.environment.POSTGRES_PASSWORD_FILE` | string | ENV переменная контейнера, контейнер читает данные из файла для инициализации подключения к PostgreSQ | yes
            `web_app.environment.POSTGRES_DATABASE_FILE` | string | ENV переменная контейнера, контейнер читает данные из файла для инициализации подключения к PostgreSQ | yes
            `web_app.environment.POSTGRES_HOST` | string | ENV переменная контейнера, контейнер читает данные из файла для инициализации подключения к PostgreSQ | yes
            `web_app.environment.POSTGRES_PORT` | string | ENV переменная контейнера, указывает на порт для PostgreSQL| yes
            `web_app.environment.APP_PORT` | string | ENV переменная контейнера, указывает порт, на котором будет поднимать приложение | yes
            `web_app.secrets` | list | Список секретов, используемых контейнером с приложением | yes
            `secrets.psql_db_password.file` | string | Путь до файла с секретом для создания пользователя PostgreSQL | yes
            `secrets.psql_db_username.file` | string | Путь до файла с секретом для создания пользователя PostgreSQL | yes
            `secrets.psql_db_database.file` | string | Путь до файла с секретом для создания БД PostgreSQL | yes
            `volumes.db_data.driver` | string | Тип volume - local, локальный volume | yes
        * Создать файлы в директории db с секретами для приложения, PostgreSQL:
            ```bash
            # For example
            echo "bhs" >> db_database.txt
            # Or
            nano db_database.txt
            ```
        * Настроить FW на целевом хосте в зависимости от дистрибутива:
            ```bash
            # Debian-based
            sudo ufw allow 8080/tcp
            sudo ufw allow from 10.55.10.0/24
            sudo ufw enable
            # RHEL
            sudo setenforce 0
            sudo systemctl enable --now firewalld 
            sudo firewall-cmd --permanent --add-port=8080/tcp
            sudo firewall-cmd --permanent --add-source=10.55.10.0/24
            sudo firewall-cmd --reload
            ```
        * Запустить процесс создания инфарструктуры, выполнив команду, контейнер с приложением собирается в два этапа, один конт под сборку с зависимостями для Golang на alpine, второй на голом scratch для оптимизации объема конта:
            ```bash
            docker-compose up -d
            ```
        * При необходимости запустить процесс создания исключительно контейнера с СУБД:
            ```bash
            docker-compose up -d db
        * Для просмотра логов по всей инсталляции, необходимо выполнить команду:
            ```bash
            docker-compose logs --tail=100 -f	
            ```
        * Посмотреть список текущих работающих контейнеров:
            ```bash
            docker ps
            ```
        * Для просмотра логов контейнера с СУБД, необходимо выполнить команду:
            ```bash
            docker-compose logs --tail=100  -f db
            ```
        * Для просмотра логов контейнера с приложением, необходимо выполнить команду:
            ```bash
            docker-compose logs --tail=100  -f web_app
            ```
        * Проверка работоспособности приложения:
            * С управляющего хоста, ввести в браузере следующий URL: http://localhost:8080/users, выполнить команду для добавления пользователя в БД:
                ```bash
                curl -X POST http://localhost:8080/users -H "Content-Type: application/json" -d '{"Name" : "Artem", "Email" : "aeremin@gmail.com" }'
                ```
            * Выполнить GET запрос к URL http://localhost:8080/users, выведется список пользователей:
                ```bash
                curl -X GET http://localhost:8080/users
                ```
            * Для удаления пользователя, выполнить DELETE запрос к URL http://localhost:8080/users, пользователь удалится
                ```bash
                curl -X DELETE http://localhost:8080/users -H "Content-Type: application/json" -d '{"Name" : "Artem"", "Email" : "aeremin@gmail.com" }' 
                ```

    * Установка Docker, подготовка хоста и деплой приложения через Ansible:
        * Для автоматической установки приложения и инфраструктуры необходимо установить Ansible, при деплое используются определенные коллекции, которые поддерживаются с версии Ansible выше определенной, в гайде используется версия Ansible 2.17 как самая стабильная и актуальная на данный момент:
            ```bash
            python3 -m pip install --user ansible-core==*version*
            ```
        * Установить все завимости для запуска плейбука:
            ```bash
            ansible-galaxy install -g -f -r requirements.yaml
            ```
        * Заполнить файл ansible.cfg согласно необходимым данным:
            ```cfg
            [defaults]
            inventory = inventory.yaml # путь до inventory файла
            remote_user = ec2-user # пользователь для работы ansible, имеет права sudo без ввода пароля
            ask_pass = false # не запрашивать пароль, т.к. используем ключи
            roles_path = roles # путь до каталога с ролями

            [privilege_escalation]
            become = true # необходимо ли повышать привелегии 
            become_user = root # до какого пользователя необходимо повысить привилегии
 
            [ssh_connection]
            ssh_args = -o ServerAliveInterval=5
            forks = 15
            ```
        * Заполнить файл inventory.yaml данными для подключения, указать FQDN созданной ВМ:
            ```yaml
            ---
            bhs_databases:
            hosts:
                bhs2024.test.local:

            bhs_webservers:
                bhs2024.test.local:

            bhs-dev:
            children:
                bhs_databases:
                bhs_webservers:
            ```
        * Заполнить файл group_vars/all.yaml, переопределить необходимые переменные ролей из defaults, ниже привел пример параметров для текущей инсталляции:
            ```yaml
                # Путья для дириректории с исходниками на управляющей машине
                source_code_path: "/home/croc/vuz/project/bhs2024/bhs2024-git/application"
                # Путь до директории с docker-compose.yaml
                docker_compose_path: "/opt/bhs-2024"
                # Docker daemon options as a dict
                docker_daemon_options: {
                storage-driver: "overlay2",
                dns: ["8.8.8.8"],
                log-driver: "json-file",
                log-opts: {
                        "max-size": "25m",
                        "max-file": "5",
                        "compress": "true"
                    }
                }
            ```
        * Запустить плейбук, используя команду, выделить необходимые для инсталляции теги, доступные теги описаны в таблице ниже:
            ```bash
            ansible-playbook playbook.yml --tags "tag"
            ```
            Tag name | Description |
            -------- | ----- |
            `web` | Установка контейнера с приложением |
            `db` | Установка контейнера с СУБД |
            `prod` | Установка инфраструктуры в Prod конфигурации |
            `infra` | Установка инфраструктуры - контейнера СУБД |
            `dev` | Установка инфраструктуры в Dev конфигурации |


3. Makefile для Docker:
    * Установить make в зависимости от используемого дистрибутива Debian-based or RHEL-based:
        ```bash
        sudo apt install make -y
        sudo dnf install make -y
        ```
    * Список команд Makefile указан ниже, для вызова мана по Makefile необходимо выполнить команду:
        ```bash
        make help
        clear            Удалить все контейнеры инсталляции и все volume
        dev-down         Удалить dev контейнер с СУБД
        dev-up           Поднять контейнер с СУБД через docker-compose
        down             Удалить все контейнеры инстанса
        help             Подсказка по доступным командам
        logs-db          Вывести логи контейнера с СУБД
        logs-web         Вывести логи веб-приложения
        logs             Получить логи инсталляции
        ps               Получить список всех работающих контейнеров
        restart-dev      Перезапустить контейнер с СУБД
        restart          Перезапустить все контейнеры инстанса
        up               Поднять все контейнеры через docker-compose
        ```