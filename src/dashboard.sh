#!/bin/bash
## ------------------
trap '' 2 
stty susp undef
## ------------------
case $2 in
	"admin")
		dialog --title " Dashboard " \
		--ok-label "Select" \
		--no-cancel \
		--menu "$1 ($2)\nChoose Available Options" 4 0 0 \
		"Menu"     "Edit Kitchen's Menu Items & Categories" \
		"Order"    "Create Dine-In & Delivery Order" \
		"Account"  "Manage User Account's Details" \
		"Reciept"  "Review All Past Transactions" \
		"History"  "Review All Past Event Logs" \
		"Storage"  "Manage and Track Stock Levels" \
		"Settings" "Configure Store Preferences" \
		"Logout"   "Switch User Account" \
		"Exit"     "Exit Application" > tmp/opt.lock 2>&1 >/dev/tty
		;;
	"staff")
		dialog --title " Dashboard " \
		--ok-label "Select" \
		--no-cancel \
		--menu "$1 ($2)\nChoose Available Options" 8 0 0 \
		"Menu"    "Edit Kitchen's Menu Items & Categories" \
		"Order"   "Create Dine-In & Delivery Order" \
		"Reciept" "Review Past Transactions" \
		"Logout"  "Switch User Account" > tmp/opt.lock 2>&1 >/dev/tty
		;;
esac
## ------------------
opt=`cat tmp/opt.lock`
case $opt in
	"Logout") bash pos.sh ;; "Exit") exit 0 ;; "Account") bash src/opt-account.sh $1 $2 ;;
	"Menu") bash src/opt-menu.sh $1 $2 ;;
esac