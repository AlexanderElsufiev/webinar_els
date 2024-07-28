
/*
Что бы увидеть свои запросы запускаете
select * from pg_stat_activity
order by usename, backend_start;
Находите pid который нужно остановить, и подставляете его сюда:
SELECT pg_terminate_backend(pid);
С уважением,
Ширман Елена Павловна
*/






select query,pid,* from pg_stat_activity where query like '%l3_mes%' and not(query like '%query%')


7470
10401


SELECT pg_terminate_backend( 24101 );  --УДАЛЕНИЕ ЗАДАНИЯ



"call svod.all_read('l3_mes','2023-02-26','prig');"	27343

----------------------------------------------------



----------------------------------------------------

--------------------------------



select part_zap,count(*) from l3_mes.prig_bil group by 1 order by 1


select * from l3_mes.prig_times where oper='read' order by -part_zap

select * from l3_mes.prig_times where part_zap in(1,2)

select * from l3_mes.prig_times where oper='dann'

select * from l3_mes.prig_times where substr(dann,1,4)='svod'

--delete from l3_mes.prig_times where substr(dann,1,4)='svod'

select * from l3_mes.prig_times where itog is not null


delete from l3_mes.prig_times where itog='table'












