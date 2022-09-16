### As of CrepeOS v0.7b4, this file has no purpose. You can delete this.

### linenums=($(grep "^........................................os" source/system.lst -n | awk '{print $1}' | grep -o '[0-9]\+'))
### linelabels=($(grep "^........................................os" source/system.lst -n | awk '{print $NF}'))

### for i in $(seq 0 `expr ${#linenums[@]} - 2`); do
###	next=`expr $i + 1`
###	echo "`expr ${linenums[$next]} - ${linenums[$i]}` ${linelabels[$i]}"
### done
