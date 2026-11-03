#!/bin/bash

# Перевірка Docker
if command -v docker
then
    echo "Docker вже встановлений"
else
    echo "Встановлюємо Docker..."
    sudo apt update
    sudo apt install -y docker.io
fi


# Перевірка Docker Compose
if docker compose version > /dev/null 2>&1
then
    echo "Docker Compose вже встановлений"
else
    echo "Встановлюємо Docker Compose..."
    sudo apt update
    sudo apt install -y docker-compose-v2
fi

# Перевірка Python
if command -v python3 > /dev/null 2>&1 && python3 -c 'import sys; sys.exit(sys.version_info < (3, 9))'
then
    echo "Python 3.9 або новіший вже встановлений"
else
    echo "Встановлюємо Python..."
    sudo apt update
    sudo apt install -y python3 python3-pip
fi

# Перевірка Django
if [ -f "$HOME/django-env/bin/python" ] && "$HOME/django-env/bin/python" -m django --version > /dev/null 2>&1
then
    echo "Django вже встановлений"
else
    echo "Встановлюємо Django..."
    sudo apt install -y python3-venv
    python3 -m venv "$HOME/django-env"
    "$HOME/django-env/bin/pip" install django
fi
