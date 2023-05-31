#!/bin/bash
function Print
{
    if [ $(wc -l <<< "$1") -lt 30 ]; then
        echo "$1"
    else
        less <<< "$1"
    fi
}

function PrintProcs
{
    while true
    do
        echo "Введите имя службы или его часть"
        read -p "> " path
        Print "$(ps xaww -o'pid,unit,args' | grep -P '^\s+\d+\s+(\w|[@-])*\.service ')"
        echo "Повторить? (y/n)"
		read -p "> " answer
		if [[ "$answer" == n ]]
		then
			break
		fi
    done
}

function Search
{
    while true
    do
        echo "Введите имя службы или его часть"
        read -p "> " path
        Print "$(systemctl list-units --type=service | tail -n +2 | head -n -7 | grep "$path")"
        echo "Повторить? (y/n)"
		read -p "> " answer
		if [[ "$answer" == n ]]
		then
			break
		fi
    done
}

function ManageServicesMenu()
{
    while true
    do
	echo -e "\n1. Включить службу\n`
	`2. Отключить службу\n`
    `3. Запустить/перезапустить службу`
    `4. Остановить службу\n`
    `5. Вывести содержимое юнита службы\n`
    `6. Отредактировать юнит службы\n`
	`7. Справка\n`
	`8. Выход\n"
	read -p "> " option
	case "$option" in
		1)
			systemctl enable "$1"
		;;
		2)
			systemctl disable "$1"
		;;
		3)
			systemctl restart "$1"
		;;
		4)
			systemctl stop "$1"
		;;
        5)
            cat "$(getunit $1)"
        ;;
        6)
            nano "$(getunit $1)"
        ;;
        7)
			echo Выберете номер действия из списка
		;;
		8)
			break
		;;
		*)
			echo -e "Введите число из списка!\n" >&2
	esac
done
}

function ManageServices
{
    echo -e "\nВведите число, соответствующее выбранной службе\n"
    readarray -t services < <(systemctl list-units --type=service | tail -n +2 | head -n -7 | cut -c 3- | cut -d ' ' -f 1)
    services+=(Справка Назад)
    select service in "${services[@]}"; do
        case $service in
            Назад) break;;
            Справка) echo "Введите число, соответствующее выбранной службе";;
            *)
                if [[ -z $service ]]; then
                    echo "Ошибка: введите число из списка" >&2
                else
                    ManageServicesMenu "$service"
                fi
                ;;
        esac
    done
}

function EventLogSearcher
{
    echo "Введите имя службы или его часть"
    read -p "> " name
    echo "Введите степень важности"
    read -p "> " priority
    echo "Введите строку поиска"
    read -p "> " bar
    journalctl -p "$priority" -u "$name" -g "$line"
}

if [[ "$1" == "--help" ]];
then
	echo "Этот сценарий позволяет управлять системными службами и журналами"
	exit
fi

if [ "$EUID" -ne 0 ]; then
	echo "Запустите программу с правами администратора" >&2
	exit
fi

if [[ "$1" != "" ]];
then
	echo "usage: sudo ./lab7.sh [--help]" >&2
	exit
fi

while true
do
	echo -e "\nГлавное меню\n\n`
	`1. Поиск системных служб\n`
    `2. Вывести список процессов и связанных с ними systemd служб\n`
    `3. Управление службами\n`
    `4. Поиск событий в журнале\n`
	`5. Справка\n`
	`6. Выход\n"
	read -p "> " option
	case "$option" in
		1)
			Search
		;;
		2)
			PrintProcs
		;;
		3)
			ManageServices
		;;
		4)
			EventLogSearcher
		;;
        5)
			echo Выберете номер действия из списка
		;;
		6)
			break
		;;
		*)
			echo -e "Введите число из списка!\n" >&2
	esac
done
