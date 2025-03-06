#!/bin/bash

#Mostrar interfaces de red
mostrar_interfaces() {
    echo "-- Interfaces de red disponibles: --"
    ip link show
}

#Activar/Desactivar una interfaz
estado_interfaz() {
    read -p "Ingrese el nombre de la interfaz: " interfaz
    read -p "¿Desea 'up' (activar) o 'down' (desactivar) la interfaz? (up/down): " estado
    sudo ip link set "$interfaz" "$estado"
    echo "$interfaz $estado."
}

#Alambrica&Inalambrica
configurar_conexion() {
    read -p "Ingrese el nombre de la interfaz a usar: " interfaz
    echo "Escoja una opción (1 o 2): "
    echo "1. Inalambrica"
    echo "2. Alambrica"
    read conexion

    if [[ $conexion == 1 ]]; then
        echo "Redes Wi-Fi disponibles:"
        sudo iwlist "$interfaz" scan | grep "ESSID"
        read -p "Ingrese el nombre de la red (SSID): " ssid
        read -s -p "Ingrese la contraseña: " passwd
        sudo nmcli dev wifi connect "$ssid" password "$passwd"
	sudo nmcli connection modify "$ssid" connection.autoconnect yes
    else
	sudo nmcli device connect "$interfaz"
    fi
}

#Estática/Dinámica
configurar_red() {
    read -p "Ingrese el nombre de la interfaz a configurar: " interfaz
    read -p "Dinamica (1) ó Estatica(2): " tipo

    if [[ $tipo == 1 ]]; then
        sudo nmcli con modify "$interfaz" ipv4.method auto
	sudo nmcli con down "$interfaz" && sudo nmcli con up "$interfaz"
        echo "Configuración dinámica aplicada a $interfaz"
    else
        read -p "Ingrese la dirección IP: " ip
        read -p "Ingrese la máscara de red (ejemplo: 24 para /24): " mascara
        read -p "Ingrese la puerta de enlace: " gateway
        read -p "Ingrese el servidor DNS: " dns

        sudo nmcli con mod "$interfaz" ipv4.addresses "$ip/$mascara"
	sudo nmcli con mod "$interfaz" ipv4.gateway "$gateway"
	sudo nmcli con mod "$interfaz" ipv4.dns "$dns"
	sudo nmcli con mod "$interfaz" ipv4.method manual
	sudo nmcli con down "$interfaz" && sudo nmcli con up "$interfaz"
	echo "Configuración estatica aplicada a $interfaz"
    fi
}

while true; do
    echo "===== Menú de Configuración de Red ====="
    echo "1. Mostrar interfaces de red"
    echo "2. Activar/Desactivar interfaz"
    echo "3. Conectar a una red"
    echo "4. Configurar IP (estática o dinámica)"
    echo "5. Salir"
    read -p "Seleccione una opción: " opcion

    case $opcion in
        1) mostrar_interfaces ;;
        2) estado_interfaz ;;
        3) configurar_conexion ;;
        4) configurar_red ;;
    esac
done

