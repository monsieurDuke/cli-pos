#!/bin/bash
## ------------------
trap '' 2 
stty susp undef
## ------------------
cat data/user.csv | sort > /tmp/sort && cp /tmp/sort data/user.csv 
arr_opt=()
while read x y; do
	lst_name="$(echo $x | cut -d ',' -f 3) $(echo $y | cut -d ',' -f 1)"
	lst_user=$(echo $x | cut -d ',' -f 1)
	arr_opt+=($lst_user "$lst_name")
done < data/user.csv
## ------------------
dialog --title " Account " \
--ok-label "Edit" \
--cancel-label "<--" \
--menu "$1 ($2)\nChoose Available Account" 8 0 0 \
"** Account"    "Create New User Account" \
"${arr_opt[@]}" > tmp/opt-acc.lock 2>&1 >/dev/tty
case "$?" in
	0)
		if [[ $(cat tmp/opt-acc.lock) == "** Account" ]]; then
			dialog --title " Account [new] " \
			--ok-label "  Done " \
			--cancel-label "<--" \
			--form "Add User Details\nAvailable Roles: admin & staff" 13 40 0 \
			"Username" 1 2 "$emp" 1 12 25 15 \
			"Fullname" 2 2 "$emp" 2 12 25 22 \
			"Password" 3 2 "$emp" 3 12 25 22 \
			"Role" 4 2 "$emp" 4 12 25 5 \
			"Phone" 5 2 "$emp" 5 12 25 13 > tmp/user-creation.lock \
			2>&1 >/dev/tty
			case "$?" in
				0)
					new_username=`sed -n 1p tmp/user-creation.lock`
					new_fullname=`sed -n 2p tmp/user-creation.lock`
					new_password=`sed -n 3p tmp/user-creation.lock`
					new_role=`sed -n 4p tmp/user-creation.lock`
					new_phone=`sed -n 5p tmp/user-creation.lock`				
					if [[ "$new_username" && "$new_fullname" && "$new_password" && "$new_role" && "$new_phone" ]]; then
						fullname_mod=$(echo "$new_fullname" | tr -s ',' ' ')
						password_mod=$(echo "$new_password" | md5sum | cut -d ' ' -f 1)
						[[ $(echo $new_role | tr [:upper:] [:lower:]) == "admin" ]] || new_role="staff"
						echo "$new_username,$password_mod,$fullname_mod,$new_role,$new_phone" >> data/user.csv
						bash src/opt-account.sh $1 $2
					else dialog --title " Info " --msgbox "User account creation failed. Please fill all the mandatory fields!" 8 35; bash src/opt-account.sh $1 $2; fi
					;;
				1)	bash src/opt-account.sh $1 $2 ;;
			esac
		else
			cat data/user.csv | grep -w $(cat tmp/opt-acc.lock) | tr -s ',' '\n' > tmp/user-modification.lock
			old_username=`sed -n 1p tmp/user-modification.lock`
			old_password=`sed -n 2p tmp/user-modification.lock`			
			old_fullname=`sed -n 3p tmp/user-modification.lock`
			old_fullname_mod=$old_fullname									
			old_role=`sed -n 4p tmp/user-modification.lock`
			old_phone=`sed -n 5p tmp/user-modification.lock`
			dialog --title " Account [modified] " \
			--ok-label "  Done " \
			--cancel-label "<--" \
			--extra-button \
			--extra-label " Del " \
			--form "Edit User Details\nAvailable Roles: admin & staff" 13 40 0 \
			"Username" 1 2 "$old_username" 1 12 25 15 \
			"Fullname" 2 2 "$old_fullname_mod" 2 12 25 22 \
			"Password" 3 2 "$emp" 3 12 25 22 \
			"Role" 4 2 "$old_role" 4 12 25 5 \
			"Phone" 5 2 "$old_phone" 5 12 25 13 > tmp/user-modification.lock \
			2>&1 >/dev/tty	
			case "$?" in
				0)
					new_username=`sed -n 1p tmp/user-modification.lock`
					new_fullname=`sed -n 2p tmp/user-modification.lock`
					new_password=`sed -n 3p tmp/user-modification.lock`
					new_role=`sed -n 4p tmp/user-modification.lock`
					new_phone=`sed -n 5p tmp/user-modification.lock`				
					if [[ "$new_username" && "$new_fullname" && "$new_role" && "$new_phone" ]]; then
						fullname_mod=$(echo "$new_fullname" | tr -s ',' ' ')
						if [[ "$new_password" ]]; then
							password_mod=$(echo "$new_password" | md5sum | cut -d ' ' -f 1)
						else
							password_mod="$old_password"
						fi
						[[ $(echo $new_role | tr [:upper:] [:lower:]) == "admin" ]] || new_role="staff"
						old_entry=$(cat data/user.csv | grep -w $old_username)
						sed -i "s/$old_entry/$new_username,$password_mod,$fullname_mod,$new_role,$new_phone/g" data/user.csv
						if [[ "$old_username" == $1 ]]; then
							[[ "$old_username" != "$new_username" ]] && set "$new_username" $2
						fi						
						bash src/opt-account.sh $1 $2
					else dialog --title " Info " --msgbox "User account modification failed. Please fill all the mandatory fields!" 8 35; bash src/opt-account.sh $1 $2; fi
					;;
				3)
					del_user=$(cat data/user.csv | grep -w $(cat tmp/opt-acc.lock))
					if [[ $(cat tmp/opt-acc.lock) == $1 ]]; then
						dialog --title " Info " --msgbox "User account $(cat tmp/opt-acc.lock) cannot be deleted while still in use!" 8 35
						bash src/opt-account.sh $1 $2			
					else
						sed -i "/$del_user/d" data/user.csv
						dialog --title " Info " --msgbox "User account $(cat tmp/opt-acc.lock) have been deleted!" 8 35
						bash src/opt-account.sh $1 $2
					fi
					;;
				1) bash src/opt-account.sh $1 $2 ;;
			esac
		fi
		;;
	1) bash src/dashboard.sh $1 $2 ;;
esac