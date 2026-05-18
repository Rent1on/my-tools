#!/bin/bash

chmod +x "$0" &> /dev/null

while true; do
	echo -e "\n=-- Меню исталятора Docker --="
	echo "1. - Установить софт (Docker, Portainer, Git)"
	echo "2. - Установка и контейнеризация проекта"
	echo "3. - Удаления(Проект, софт)"
	echo "4. - Диагностика сервера"
	echo "5. - Выход"
	read -p "Выберите операцию: " choise

	case "$choise" in
		1)
			echo -e "\nУстанавливаю Docker..."
			apt update && apt install docker.io -y

			echo -e "\nЗапускаю службы Docker..."
			systemctl enable --now docker

			echo -e "\nУстанавливаю Git..."
			apt update && apt install git -y

			echo -e "\nУстанавливаю Portainer..."
			docker volume create portainer_data
			
			echo -e "\nЗапускаю Portainer..."
			docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

			echo -e "\nНастраиваю права для Docker-сокета..."
			chmod 666 /var/run/docker.sock

			echo -e "\e[1;32 Готово! Софт установлен! \e[0m"
			;;

		2)
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
				read -p "Выберите действие: " sub_choice

				case "$sub_choice" in
					1)	
						if [[ "$D_STATUS" == "ok" ]]; then
							echo "Запускаю установку проекта.."

							read -p "Введите ссылку на репазиторий Github(БЕЗ .git): " GIT_LINK
							git clone $GIT_LINK.git

							read -p "Введите папку проекта: " PROJECT_NAME
							cd $PROJECT_NAME

							echo "Создаю .env файл..."
							read -p "Введите токен бота: " BOT_TOKEN
							cat <<EOF > ".env"
BOT_TOKEN=$BOT_TOKEN
EOF
							read -p "Введите имя контейнера и проекта: " CONTAINER_NAME
							echo "Начинаю сборку контейнера..."
							docker build -t $CONTAINER_NAME .
							
							echo "Запускаю контейнер..."
							docker run -d --name $CONTAINER_NAME --env-file .env $CONTAINER_NAME

							echo -e "\e[1;32m Проект $CONTAINER_NAME запущен!\e[0m"

						else
							echo -e "\e[1;31m Docker не установлен! Установите в главном меню пункт 1.\e[0m"
						fi
						;;
					
					2)
						break
						;;

					*)
						echo "Не верный выбор действия! Выбирите 1-2!"
						;;
				esac
			done
			;;

		3)
			while true; do
				echo -e "\n--- [ Меню удаления ] ---"
				echo "1. - Удалить проект и контейнеры"
				echo "2. - Удалить софт"
				echo "3. - Выход"
				read -p "Выберите операцию: " del_choise
				case "$del_choise" in
					1)
						read -p "Введите имя вашего контейнера: " CONTAINER_NAME
						echo "Останавливаю и удаляю контейнеры..."
						docker stop portainer $CONTAINER_NAME &> /dev/null
						docker rm portainer $CONTAINER_NAME &> /dev/null

						read -p "Введите названия папки проекта: " PROJECT_NAME
						echo "Удаляю папку проекта..."
						rm -rf $PROJECT_NAME

						echo -e "\e[1;32m Готово! Контейнеры и папка проекта удалена!\e[0m"
						;;

					2)
						echo -e "\nУдаляю софт..."
						apt purge docker.io git -y &> /dev/null
						apt autoremove -y &> /dev/null

						echo -e "\e[1;32 Готово! Софт удалён!\e[0m"
						;;
					
					3)
						break
						;;
					
					*)
						echo -e "\nНе верный выбор действия! Выбирите 1-2!"
						;;
				esac
			done
			;;
		
		4)
			echo -e "\nЗапускаю ping 8.8.8.8 "
			ping 8.8.8.8 -c 100 > diagnostic.txt
			echo "Запускаю mtr google.com"
			if ! command -v mtr &> /dev/null; then apt install mtr -y -qq &> /dev/null; fi
			echo " " >> diagnostic.txt
			mtr -n --report --report-cycles 200 google.com >> diagnostic.txt
			;;

		
		5)
			echo -e "\nВыхожу с скрипта"
			break
			;;

		*)
			echo -e "\nДанной операции нет, выбирите от 1 до 5!"
			;;

	esac
done
