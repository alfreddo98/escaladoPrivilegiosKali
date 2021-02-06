# escaladoPrivilegiosKali
Se trata básicamente de una herramienta para aprovechar vulnerabilidad de los Sistemas Operativos Kali Linux, Centos, Parrot o RedHat y ejecutar una consola en la que se tienen prilegios de usuario normal como usuario root.

La herramienta básicamente, explota que este tipo de sistemas, por defecto tiene el archivo ptrace_escope, que se encuentra en la ruta: proc/sys/kernel/yama/ptrace_scope con un 0, lo que indica que al hacer sudo en cualquier consola se guardará la contraseña con un token, de forma que ya no se tenga que volver a poner.

La herramienta lo que hace es buscar los procesos en los que bash se está corriendo y busca una en el que se este actuando como roor, captura el token y se abre un nuevo proceso bash con ese mismo token en el que se actuará como root, de esta forma (la consola en la que se corre el programa no se convierte en root, sino otra consola nueva que se abre en esa misma).

La herramienta automatiza automatiza el encontrar los requisitos que se necesiten y avisará indicando porque cuando no se pueda realizar el ataque. Se necesita como requisito que la máquina tenga gdb (no es una herramienta intrusiva y es bastante normal que los equipos la tengan, kali y parrot la tienen por defecto), que haya otra consola en la que se haya hecho sudo (ya se quedará guardado y en entorno empresarial es bastante común) y que el archivo ptrace_scope tenga un 0.

Para remediar esta vulnerabilidad es bastante sencilla, bastaría con poner un 1 en el archivo ptrace_escope mencionado anteriormente.
