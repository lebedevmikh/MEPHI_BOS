#!/bin/bash
function SelectChangeMode()
{
	while true
	do
		echo -e '\n1. Перевести файловую систему в режим "только чтение"\n`
				`2. Перевести файловую систему в режим "только запись"\n
				`3. Назад\n'
		read -p "> " answer
		case "$answer" in
			1)
				mount -o remount,ro $(df --output=target $1 | tail -n +2)
				break
			;;
			2)
				mount -o remount,rw $(df --output=target $1 | tail -n +2)
				break
			;;
			3)
				break
			;;
			*)
				echo -e "Введите число из списка!" >&2
			;;
		esac
	done
}

function ChangeParameters
{
	echo -e "\nВведите номер системы из списка\n"
	readarray -t systems < <(df -x proc -x sys -x tmpfs -x devtmpfs --output=target | tail -n +2)
	systems+=(Справка Назад)
	select system in "${systems[@]}"; do
		case $system in
			Назад) break;;
			Справка) echo "Введите номер системы из списка";;
			*)
				if [[ -z $system ]]; then
					echo "Введите номер из списка!" >&2
				else
					SelectChangeMode $system
				fi
			;;
		esac
	done
}

function ShowParameters
{
	echo -e "\nВведите номер системы из списка\n"
	readarray -t systems < <(df -x proc -x sys -x tmpfs -x devtmpfs --output=target | tail -n +2)
	systems+=(Справка Назад)
	select system in "${systems[@]}"; do
		case $system in
			Назад) break;;
			Справка) echo "Введите номер системы из списка";;
			*)
				if [[ -z $system ]]; then
					echo "Введите номер из списка!" >&2
				else
					mount | grep $(df --output=target $system | tail -n +2)
				fi
			;;
		esac
	done
}

function ShowInfo
{
	echo -e "\nВведите номер системы из списка\n"
	readarray -t systems < <(df -t ext2 -t ext3 -t ext4 -t extcow --output=source,target | tail -n +2 | sed "s/ \+/ on /g")
	systems+=(Справка Назад)
	select system in "${systems[@]}"; do
		case $system in
			Назад) break;;
			Справка) echo "Введите номер системы из списка";;
			*)
				if [[ -z $system ]]; then
					echo "Введите номер из списка!" >&2
				else
					tune2fs -l $(echo "$system" | cut -d ' ' -f 1)
				fi
			;;
		esac
	done
}

function MountSystem
{
	while true
	do
		echo Введите каталог монтирования
		read -p "> " dir
		if [[ -d $dir ]] && find $dir -maxdepth 1 | wc
		then
			echo "Каталог должен быть пустым!" >&2
			continue
		else
			mkdir dir
			echo Создан каталог
		fi
		echo Введите путь до устройства или файла
		read -p "> " path
		if [[ -f $path ]]
			then
			mount -o loop $path $dir
		else
			mount $path $dir
		fi
		echo "Повторить? (y/n)"
		read -p "> " answer
		if [[ "$answer" == n ]]
		then
			break
		fi
	done
}

function UnmountSystem
{
	while true
	do
		echo -e "\n1. Выбрать систему из списка\n2. Ввести путь\n3. Справка\n4. Назад\n"
		read -p "> " answer
		case "$answer" in
			1)
				readarray -t systems < <(df -x proc -x sys -x tmpfs -x devtmpfs --output=target | tail -n +2)
				systems+=(Справка Назад)
				select system in "${systems[@]}"; do
					case $system in
						Назад) break;;
						Справка) echo "Введите номер системы из списка";;
						*)
							if [[ -z $system ]]; then
								echo "Введите номер из списка!" >&2
							else
								unmount $system
								break
							fi
						;;
					esac
				done
			;;
			2)
				read -p "> " path
				unmount $path
			;;
			3)
				echo Введите номер системы из списка или путь к ней
			;;
			4)
				break
			;;
		esac
	done
}

if [[ "$1" == "--help" ]];
then
	echo "Этот сценарий позволяет работать с файловыми системами"
	exit
fi

if [ "$EUID" -ne 0 ]; then
	echo "Запустите программу с правами администратора" >&2
	exit
fi

if [[ "$1" != "" ]];
then
	echo "usage: sudo ./FileSystemsManagement.sh [--help]" >&2
	exit
fi

while true
do
	echo -e "\nГлавное меню\n\n`
	`1. Вывести таблицу файловых систем\n`
	`2. Монтировать файловую систему\n`
	`3. Отмонтировать файловую систему\n`
	`4. Изменить параметры монтирования примонтированной файловой системы\n`
	`5. Вывести параметры монтирования примонтированной файловой системы\n`
	`6. Вывести детальную информацию о файловой системе ext*\n`
	`7. Справка\n`
	`8. Выход\n"
	read -p "> " option
	case "$option" in
		1)
			df -x proc -x sys -x tmpfs -x devtmpfs --output=source,fstype,target
		;;
		2)
			MountSystem
		;;
		3)
			UnmountSystem
		;;
		4)
			ChangeParameters
		;;
		5)
			ShowParameters
		;;
		6)
			ShowInfo
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