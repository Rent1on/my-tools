#!/bin/bash

chmod +x "$0" &> /dev/null

while true; do
	echo -e "\n=-- Меню исталятора Docker --="
	echo "1. - Установить Docker"
	echo "2. - Установить Portainer"
	echo "3. - Установить Git"
	echo "4. - Диагностика сервера"
	echo "5. - Установить собвственный проект"
	echo "6. - Выход"
	read -p "(1-6)Выбирите операцию: " choise

	case "$choise" in
		1)
			echo -e "\nУстанавливаю Docker..."
			apt update && apt install docker.io -y
			echo "Запускаю службы Docker..."
			systemctl enable --now docker
			;;

		2)
			echo -e "\nУстанавливаю Porainer.."
			docker volume create portainer_data
			echo "Запускаю Portainer.."
			docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
			echo "Настройка прав для Docker-сокета..."
			chmod 666 /var/run/docker.sock
			echo "Portainer доступен на порту 9443(https)"
			;;

		3)
			echo -e "\nУстанавливаю Git"
			apt update && apt install git -y
			;;

		4)
			echo -e "\nЗапускаю ping 8.8.8.8 "
			ping 8.8.8.8 -c 100 > ping.txt
			echo "Запускаю mtr google.com"
			if ! command -v mtr &> /dev/null; then apt insrall mtr -y -qq &> /dev/null; fi
			mtr -n --report --report-cycles 200 google.com > mtr_google.txt
			;;

		5)
			while true; do
				echo -e "\n--- [Проверерка компонентов] ---"
				if command -v docker &> /dev/null; then
					echo "Docker: [ Установлен ]"
					D_STATUS="ok"
				else
					echo "Docker: [ Не установлен ]"
					D_STATUS="miss"
				fi

				if docker ps -a --format '{{.Names}}' | grep -q "portainer"; then
					echo "Portainer: [ Запущен ]"
				else
					echo "Portainer: [ Отсутвует ]"
				fi

				if command -v git &> /dev/null; then
					echo "Git: [ Установлен ]"
				else
					echo "Git: [ Не установлен ]"
				fi

				echo -e "\n--- [ Меню установки проекта ] ---"
				echo "1. - Установить проект (требует Git, Docker)"
				echo "2. - Назад в главное меню"
				read -p "Выбирите действие: " sub_choice

				case "$sub_choice" in
					1)	
						if [[ "$D_STASTUS" == "ok" ]]; then
							echo "Запускаю установку проекта.."

							read -p "Введите ссылку на репазиторий Github: " GIT_LINK
							git clone $GIT_LINK.git

							read -p "Введите папку проекта: " PROJECT_NAME
							cd $PROJECT_NAME

							echo "Создаю .env файл..."
							read -p "Введите токен бота: " BOT_TOKEN
							cat <<EOF > ".env"
BOT_TOKEN=$BOT_TOKEN
EOF
							read -p "Введите имя контейнера: " CONTAINER_NAME
							echo "Начинаю сборку контейнера..."
							docker buil -t $CONTAINER_NAME .
							
							read -p "Введите имя проекта для Portainer: " NAME_PROJECT
							echo "Запускаю контейнер..."
							docker run -d --name $CONTAINER_NAME --env-file .env $NAME_PROJECT

						else
							echo "Докер не установлен! Установите в главном меню пункт 1."
						fi
						;;
					
					2)
						break
						;;

					*)
						echo "Не верный выбор действия!"
						;;
				esac
			done
			;;

		
		6)
			echo " "
			echo "Выхожу с скрипта"
			break
			;;

		*)
			echo " "
			echo "Данной операции нет, выбирите от 1 до 6!"
			;;

	esac
done
