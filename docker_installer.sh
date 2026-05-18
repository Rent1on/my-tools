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
			docker volume create portainer_date
			echo "Запускаю Portainer.."
			docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_date:/data portainer/portainer:latest
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
			echo -e "\nВ разработке..."
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
