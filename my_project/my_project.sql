
/**/
drop table if exists dannie,dannie2;

create table dannie(
	id serial primary key,
	x1 float,x2 float,ogr float,
	tip int,
	--d1 float,d2 float,d3 float,
	y float, spros float);

create table dannie2(
	id serial primary key,
	metod char(15),
	x1 float,x2 float,ogr float,
	tip int,vid int,
	--d1 float,d2 float,d3 float,
	y float, spros float,
	yy float, spros_ float,time float
	);
/**/



/**/	
-- создание или замена процедуры
--drop if exists PROCEDURE pop_dann;commit;

CREATE OR REPLACE PROCEDURE pop_dann()
-- язык, на котором написана процедура
LANGUAGE plpgsql
AS $$
	Declare x1 float;
x2 float;
ogr float;
y float;
r float;
yy float;
k2 float;
kr float;
k_ogr float;
max_y float;
tip int;
-- начало транзакции
BEGIN
	FOR tip IN 1..50 LOOP
	k2=random();kr=random()*3;
	k_ogr=1+random();max_y=1.5;
	if tip=1 then k2=0;kr=1;end if;

	FOR i IN 1..1100 LOOP
	x1=random();x2=random();
	y=x1+x2*k2+random()*kr;yy=y;
	
	if max_y<yy then max_y=yy;end if;
	if k_ogr<max_y then k_ogr=max_y;end if;
		
	--x1=x1+random();
	--x2=x2+random();
	--ogr=((random()*random()*(1+k_ogr)+0.002)*10)/10;--ограничитель
	--ogr=round((random()*random()*(1+k_ogr)+0.002)*10)/10;--ограничитель
	ogr=round((random()*k_ogr+0.2)*10)/10;--ограничитель
	
	if ogr=0 then ogr=0.1;end if;
	r=(random()-0.5)/5;
	if y>ogr then y=ogr+r;end if;
	if y>yy then y=yy;end if;

if i>100 then
 	INSERT INTO dannie(x1,x2,ogr,y,spros,tip)
	VALUES (x1,x2,ogr,y,yy,tip);
end if;
	
	END LOOP;
	END LOOP;

-- завершение процедуры и транзакции
END
$$;
commit;
/**/





--drop  PROCEDURE populate;commit;

-- вызов процедуры
CALL pop_dann();



-- отображение результатов
SELECT * FROM dannie  LIMIT 20;

SELECT * FROM dannie2  LIMIT 20;
--select * from tab;
