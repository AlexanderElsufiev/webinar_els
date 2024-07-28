


--    DROP PROCEDURE svod.prig_obog_poln(text)


------------------------------------------------




CREATE OR REPLACE /*FUNCTION*/ PROCEDURE svod.prig_obog_poln(load_ text --,load_date date,work_schema text
)
  --  RETURNS text 
    LANGUAGE 'plpgsql'
  --  COST 100
  --  VOLATILE 
    
AS $BODY$
--Программа - сборник блоков по обогащению пригорода.
declare
	integer_var integer;
	date_zap	date;
	part_zap integer;
	shema text;
	calc_time char(20);
	load_ text;
	
	
begin  --1
load_=$1;
part_zap=1;

--call svod.prig_read(load_); --чтение - есть ли новые данные

-- начало цикла
 WHILE  (part_zap is not null) LOOP  --3

RAISE INFO ' рабочая схема записи=(%)',  load_;	  

call svod.prig_obog_0(load_);

execute 'select date_zap,part_zap,shema,cast(current_time as char(50)) from  '||load_||'.prig_times where dann=''prig'' and oper=''dannie'' '
		into date_zap,part_zap,shema,calc_time;


RAISE INFO ' Обрабатываемая дата % порция % схема % .     Время начала =%', date_zap,part_zap,shema,calc_time;	

if part_zap is not null then begin --2
call svod.prig_obog_1(load_);
commit;
--if substr(shema,5,4)='pass' then begin --3
call svod.prig_obog_1p(load_) ;
commit;
--end; --3
call svod.prig_obog_21(load_);
commit;
call svod.prig_obog_22(load_);
commit;
call svod.prig_obog_3(load_);
commit;

--  integer_var=100/(10-part_zap); RAISE INFO '  ДРОБЬ=%', integer_var;	--программируемая ошибка

call svod.prig_obog_4(load_) ;
commit;
--call svod.prig_agreg_1(load_);  --агрегация постанционная

call svod.prig_agr_analit(load_); --непосредственно запуск процедуры загрузки аналитической таблицы

end; --2
end if; --2

execute 'select cast(current_time as char(50)) from (select count(*) from '||load_||'.prig_times ) as a '
into calc_time;
RAISE INFO '  Время окончания=%', calc_time;	

END loop;--END LOOP; --3

end; --1
$BODY$;



ALTER /*FUNCTION*/ PROCEDURE svod.prig_obog_poln(text) OWNER TO asul; --компилляция!

 











------------------------------------------------

--  call svod.prig_obog_poln('l3_prig'); --непосредственно запуск процедуры ТЕСТОВЫЕ ДАННЫЕ  все сутки подряд




--  call svod.prig_obog_poln('l3_mes'); --непосредственно запуск процедуры МЕСЯЧНЫЕ ДАННЫЕ  все сутки подряд




 ------------------------------------------
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 --------------
 
 


/**/
