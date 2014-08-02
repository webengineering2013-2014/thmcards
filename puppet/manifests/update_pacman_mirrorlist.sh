
# Author: Roman Domnich ( workaddr [ at ] yahoo.de )

NEWMIRRORLIST=/root/mirrorlist

for i in {1..5}
do
   curl https://www.archlinux.org/mirrorlist/all/http/ | cut -c 2- > $NEWMIRRORLIST
   
   if [[ -s $NEWMIRRORLIST ]]
   then
        mv $NEWMIRRORLIST /etc/pacman.d/mirrorlist
   
        break
   fi
done
