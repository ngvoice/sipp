#!/bin/sh
rm clients.csv create.sql
PASSWORD=`date | md5sum | tr -d -c '[A-Za-z0-9]'`
echo $PASSWORD
# echo "SEQUENTIAL" >> ./clients.csv
echo "RANDOM" >> ./clients.csv
echo "use hss_db;" >> ./create.sql
echo "delete from imsu where name like 'loadtest%';" >> ./create.sql
echo "DELETE FROM impi WHERE id_imsu not in (select id from imsu);" >> ./create.sql
echo "DELETE FROM impi_impu WHERE id_impi not in (select id from impi);" >> ./create.sql
echo "DELETE FROM impi_impu WHERE id_impu not in (select id from impu);" >> ./create.sql
echo "DELETE FROM impu WHERE id not in (select id_impu from impi_impu);" >> ./create.sql
echo "DELETE FROM impu_visited_network WHERE id_impu not in (select id from impu);" >> ./create.sql
echo "SET autocommit=0;" >> ./create.sql
i=100000
if [ $# -ne 0 ]
then
        MAX=`expr $i + $1`
else
	MAX=600000	
fi
DOMAIN=$2
PREFIX="494012345"
echo "Creating $i/$MAX accounts"
while [ $i -le $MAX ]
do
	echo $i
	echo "$PREFIX$i;$DOMAIN;[authentication username=contract$i password=$i-$PASSWORD-$i];contract$i" >> ./clients.csv
	echo "START TRANSACTION;" >> ./create.sql
	echo "insert into imsu (name, id_capabilities_set, id_preferred_scscf_set) values ('loadtest-$i', 1, 1);" >> ./create.sql
	echo "set @imsu_id=last_insert_id();" >> ./create.sql
	echo "INSERT INTO impi (id_imsu, identity, k, auth_scheme, default_auth_scheme, amf, op, sqn, ip, line_identifier, zh_uicc_type, zh_key_life_time, zh_default_auth_scheme) VALUES (@imsu_id, 'contract$i', '$i-$PASSWORD-$i', 255, 4, '', '', '000000000000', '', '', 0, 3600, 1);" >> ./create.sql
	echo "set @impi1_id=last_insert_id();" >> ./create.sql
	echo "INSERT INTO impi (id_imsu, identity, k, auth_scheme, default_auth_scheme, amf, op, sqn, ip, line_identifier, zh_uicc_type, zh_key_life_time, zh_default_auth_scheme) VALUES (@imsu_id, '$PREFIX$i@$DOMAIN', '$i-password-$i', 255, 4, '', '', '000000000000', '', '', 0, 3600, 1);" >> ./create.sql
	echo "set @impi2_id=last_insert_id();" >> ./create.sql
	echo "INSERT INTO impu (identity, type, barring, user_state, id_sp, id_implicit_set, id_charging_info, wildcard_psi, display_name, psi_activation, can_register) VALUES('sip:$PREFIX$i@$DOMAIN', 0, 0, 1, 1, 0, 1, '', '', 0, 1);" >> ./create.sql
	echo "set @impu1_id=last_insert_id();" >> ./create.sql
	echo "INSERT INTO impu_visited_network (id_impu, id_visited_network) VALUES(@impu1_id, 6);" >> ./create.sql
	echo "update impu set id_implicit_set=@impu1_id where id=@impu1_id;" >> ./create.sql
	echo "INSERT INTO impu (identity, type, barring, user_state, id_sp, id_implicit_set, id_charging_info, wildcard_psi, display_name, psi_activation, can_register) VALUES('tel:$PREFIX$i', 0, 0, 1, 1, @impu1_id, 1, '', '', 0, 1);" >> ./create.sql
	echo "set @impu2_id=last_insert_id();" >> ./create.sql
	echo "INSERT INTO impu_visited_network (id_impu, id_visited_network) VALUES(@impu2_id, 6);" >> ./create.sql
	echo "INSERT INTO impi_impu (id_impi, id_impu) VALUES(@impi1_id, @impu1_id);" >> ./create.sql
	echo "INSERT INTO impi_impu (id_impi, id_impu) VALUES(@impi1_id, @impu2_id);" >> ./create.sql
	echo "INSERT INTO impi_impu (id_impi, id_impu) VALUES(@impi2_id, @impu1_id);" >> ./create.sql
	echo "INSERT INTO impi_impu (id_impi, id_impu) VALUES(@impi2_id, @impu2_id);" >> ./create.sql
	echo "COMMIT;" >> ./create.sql
	i=`expr $i + 1`
done

