#!/bin/sh

Mysql="mysql -hlocalhost -uswm -pswm --default-character-set=utf8 Blog --auto-rehash=1 -N"

$Mysql -e"select c_bid,c_type,c_date,c_content from t_blog where c_state = 0  and c_content <> '';" > extra.txt

cat extra.txt | sed "s/\\\n//g" | sed "s/\\\t//g" > temp
mv temp extra.txt

cat extra.txt | while read bid type date content
do
	Dir=`$Mysql -e"select c_name from t_type_def where c_id = $type;"`
	echo $Dir
	title=`$Mysql -e"select c_title from t_blog where c_bid = '$bid';"`
	cat template/head.html | sed "s/#title#/$title/g" | sed "s/#date#/$date/g" > head.html
	echo ${content} > c.html
	cat template/foot.html | sed "s/#bid#/$bid/g" > foot.html

	cat head.html c.html foot.html > ${bid}.html
	mv ${bid}.html $Dir

	$Mysql -e"update t_blog set c_state = 4 where c_bid = '$bid';"

#rm c.html head.html
done

echo "done."
