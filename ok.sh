ar=()
while read n; do
	c=$(echo $n | cut -d ',' -f 1)
	ar+=($c "Add / Edit Items in $c")
done < data/category.csv
dialog --menu "users" 15 0 0 "${ar[@]}"
