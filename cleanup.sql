delete from imsu where name like 'loadtest%';
DELETE FROM impi WHERE id_imsu not in (select id from imsu);
DELETE FROM impi_impu WHERE id_impi not in (select id from impi);
DELETE FROM impi_impu WHERE id_impu not in (select id from impu);
DELETE FROM impu WHERE id not in (select id_impu from impi_impu);
DELETE FROM impu_visited_network WHERE id_impu not in (select id from impu);
