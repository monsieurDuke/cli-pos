#!/bin/bash
## ------------------
trap '' 2 
stty susp undef
## ------------------
cat data/category.csv | sort > /tmp/sort && cp /tmp/sort data/category.csv 
arr_opt=()
while read x; do
	lst_cats=$(echo $x | cut -d ',' -f 1)
	arr_opt+=($lst_cats "Add / Edit Items in $lst_cats")
done < data/category.csv
## ------------------
dialog --title " Menu " \
--ok-label "Edit" \
--cancel-label "<--" \
--menu "$1 ($2)\nChoose Available Options" 8 0 0 \
"** Category" "Create New Groups" \
"${arr_opt[@]}" > tmp/opt-menu.lock 2>&1 >/dev/tty
case "$?" in
	0)
		if [[ $(cat tmp/opt-menu.lock) == "** Category" ]]; then
			dialog --title " Menu - Category [new] " \
			--ok-label "  Done " \
			--cancel-label "<--" \
			--form "Add Category Name" 8 40 0 \
			"Category" 1 2 "$emp" 1 12 25 20 > tmp/cat-creation.lock \
			2>&1 >/dev/tty	
			case "$?" in	
				0)
					new_category=`sed -n 1p tmp/cat-creation.lock`
					if [[ "$new_category" ]]; then
						echo "$new_category" >> data/category.csv
						bash src/opt-menu.sh $1 $2
					else dialog --title " Info " --msgbox "Category creation failed. Please fill all the mandatory fields!" 8 35; bash src/opt-menu.sh $1 $2; fi
					;;
				1) bash src/opt-menu.sh $1 $2 ;;
			esac	
		else
			rm tmp/item.lock
			cat data/item.csv | sort | grep -w $(cat tmp/opt-menu.lock) > /tmp/sort && cp /tmp/sort tmp/item.lock
			arr_opt2=()
			while read x y; do
				lst_id=$(echo $x | cut -d ',' -f 2)
				lst_name="$(echo $x | cut -d ',' -f 3) $(echo $y | cut -d ',' -f 1)"
				arr_opt2+=($lst_id "$lst_name")
			done < tmp/item.lock
			dialog --title " Menu $(cat tmp/opt-menu.lock) " \
			--ok-label "Edit" \
			--cancel-label "<--" \
			--menu "$1 ($2)\nChoose Available Options" 8 0 0 \
			"** Item" "Create New Item" \
			"** $(cat tmp/opt-menu.lock)" "Edit / Delete the Category" \
			"${arr_opt2[@]}" > tmp/opt-menu2.lock 2>&1 >/dev/tty
			case "$?" in
				0)
					if [[ $(cat tmp/opt-menu2.lock) == "** Item" ]]; then
						dialog --title " Menu $(cat tmp/opt-menu.lock) - Item [new] " \
						--ok-label "  Done " \
						--cancel-label "<--" \
						--form "Add Item Details" 12 60 0 \
						"ID" 1 2 "$emp" 1 17 25 5 \
						"Name" 2 2 "$emp" 2 17 30 29 \
						"Price Dine-In" 3 2 "$emp" 3 17 25 6 \
						"Price Takeout" 4 2 "$emp" 4 17 25 6 \
						"Stock" 5 2 "$emp" 5 17 25 3 \
						> tmp/item-creation.lock \
						2>&1 >/dev/tty
						case "$?" in
							0)
								new_id=`sed -n 1p tmp/item-creation.lock`
								new_name=`sed -n 2p tmp/item-creation.lock`
								new_price_d=`sed -n 3p tmp/item-creation.lock`								
								new_price_t=`sed -n 4p tmp/item-creation.lock`
								new_stock=`sed -n 5p tmp/item-creation.lock`
								if [[ "$new_id" && "$new_name" && "$new_price_d" && "$new_price_t" && "$new_stock" ]]; then
									echo "[$(cat tmp/opt-menu.lock)],$new_id,$new_name,$new_price_d,$new_price_t,$new_stock" >> data/item.csv
									bash src/opt-menu.sh $1 $2
								else dialog --title " Info " --msgbox "Item creation failed. Please fill all the mandatory fields!" 8 35; bash src/opt-menu.sh $1 $2; fi
								;;
							1) bash src/opt-menu.sh $1 $2 ;;							
						esac
					elif [[ $(cat tmp/opt-menu2.lock) == "** $(cat tmp/opt-menu.lock)" ]]; then
						old_category=`sed -n 1p tmp/opt-menu.lock`
						dialog --title " Menu - $(cat tmp/opt-menu.lock) [modified] " \
						--ok-label "  Done " \
						--cancel-label "<--" \
						--extra-button \
						--extra-label " Del " \
						--form "Edit Category Name" 8 40 0 \
						"Category" 1 2 "$old_category" 1 12 25 15 \
						> tmp/menu-modification.lock \
						2>&1 >/dev/tty	
						case "$?" in
							0)
								new_category=`sed -n 1p tmp/menu-modification.lock`
								if [[ $new_category ]]; then
									sed -i "s/$old_category/$new_category/g" data/category.csv
									sed -i "s/$old_category/$new_category/g" data/item.csv									
									bash src/opt-menu.sh $1 $2									
								fi
								;;
							1) bash src/opt-menu.sh $1 $2 ;;
							3) 
								del_category=$(cat data/category.csv | grep -w $(cat tmp/menu-modification.lock))
								if [[ $(cat data/item.csv | grep -w $(cat tmp/menu-modification.lock) | wc -l) -eq 0 ]]; then
									sed -i "/$del_category/d" data/category.csv
									dialog --title " Info " --msgbox "Category $(cat tmp/menu-modification.lock) have been deleted!" 8 35
									bash src/opt-menu.sh $1 $2
								else
									dialog --title " Info " --msgbox "Category $(cat tmp/menu-modification.lock) deletion failed. Please check $(cat tmp/menu-modification.lock) if it still items within!" 8 35
									bash src/opt-menu.sh $1 $2									
								fi
							 	;;
						esac
					else
						## item-modification.lock + save + delete + back
						cat data/item.csv | grep -w $(cat tmp/opt-menu2.lock) | tr -s ',' '\n' > tmp/item-modification.lock
						old_id=`sed -n 2p tmp/item-modification.lock`	
						old_name=`sed -n 3p tmp/item-modification.lock`	
						old_price_d=`sed -n 4p tmp/item-modification.lock`	
						old_price_t=`sed -n 5p tmp/item-modification.lock`	
						old_stock=`sed -n 6p tmp/item-modification.lock`												
						dialog --title " Menu $(cat tmp/opt-menu.lock) - Item [modified] " \
						--ok-label "  Done " \
						--cancel-label "<--" \
						--extra-button \
						--extra-label " Del " \
						--form "Edit Item Details" 12 60 0 \
						"ID" 1 2 "$old_id" 1 17 25 5 \
						"Name" 2 2 "$old_name" 2 17 30 29 \
						"Price Dine-In" 3 2 "$old_price_d" 3 17 25 6 \
						"Price Takeout" 4 2 "$old_price_t" 4 17 25 6 \
						"Stock" 5 2 "$old_stock" 5 17 25 3 \
						> tmp/item-modification.lock \
						2>&1 >/dev/tty						
						case "$?" in
							0)
								new_id=`sed -n 1p tmp/item-modification.lock`	
								new_name=`sed -n 2p tmp/item-modification.lock`	
								new_price_d=`sed -n 3p tmp/item-modification.lock`	
								new_price_t=`sed -n 4p tmp/item-modification.lock`	
								new_stock=`sed -n 5p tmp/item-modification.lock`												
								if [[ "$new_id" && "$new_name" && "$new_price_d" && "$new_price_t" && "$new_stock" ]]; then
									old_entry=$(cat data/item.csv | grep -w "\[$(cat tmp/opt-menu.lock)\]" | grep -w "$old_id" | cut -d ',' -f 2-)
									sed -i "s/$old_entry/$new_id,$new_name,$new_price_d,$new_price_t,$new_stock/g" data/item.csv
									bash src/opt-menu.sh $1 $2
								fi
								;;
							1) bash src/opt-menu.sh $1 $2 ;;
							3)
								del_item=$(cat data/item.csv | grep -w $(cat tmp/opt-menu2.lock) | cut -d ',' -f 2-)
								sed -i "/$del_item/d" data/item.csv
								dialog --title " Info " --msgbox "Item $(cat tmp/opt-menu2.lock) - $old_name have been deleted!" 8 35
								bash src/opt-menu.sh $1 $2								
								;;
						esac	
					fi
					;;
				1) bash src/opt-menu.sh $1 $2 ;;				
			esac
		fi
		;;
	1) bash src/dashboard.sh $1 $2 ;;
esac