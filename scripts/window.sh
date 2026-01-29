XTIME="_NET_WM_USER_TIME" #a shorter name for xprop query that shoul return timestamps
export TMPDIR=/dev/shm    #save tmp files to memory to make it faster
LST=`mktemp`              #tmp file to store our listing 
wmctrl -lx |  awk -F' ' '{printf("%s\t%s    \t",$1,$3); for(i=5;i<=NF;i++) printf("%s",$i); printf("\n")  }'  > $LST #pretty-print our listing of windows into the tmp file
 #To each line of listing, prepend a timestamp acquired via an xprop call
 #Use awk to find a line whose 3rd column (winclass) matches the window class "mate-terminal.Mate-terminal" and among those that do, find the one whose timestamp is the largest
while read LINE; do ID=`echo "$LINE"|cut -f 1`; TIME=`xprop -id $ID $XTIME`;  TIME="${TIME/* = /}"; echo -e "$TIME\t$LINE" ; done <$LST ) | awk -v s="mate-terminal.Mate-terminal" '$3 == s {if($1>max){max=$1;line=$0};};END{print line}'
rm $LST  #delete tmp file
