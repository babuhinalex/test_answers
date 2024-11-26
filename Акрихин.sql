-- Создаем таблицу test_order
-- В таблице test_order хранится информация по заказам
create table test_order (
  id serial4 not null,
  user_id int4 null, -- id пользователя
  status varchar null, -- Статус заказа
  date timestamp null -- дата и время создания заказа 
);

-- Заполняем таблицу test_order данными
insert into test_order (user_id, status, date)
values (1, 'delivered', '2020-11-06 11:41:02'), -- id = 1
  (1, 'delivered', '2020-11-07 12:45:02'), -- id = 2
  (1, 'delivered', '2020-11-08 16:41:02'), -- id = 3
  (2, 'new', '2020-11-09 15:41:02'), -- id = 4
  (2, 'delivered', '2020-11-08 16:41:02'), -- id = 5
  (2, 'canceled', '2020-11-08 12:41:02'), -- id = 6
  (2, 'new', '2020-11-08 17:41:02'), -- id = 7
  (2, 'delivered', '2020-12-08 16:41:02'), -- id = 8
  (2, 'canceled', '2020-12-08 12:41:02'), -- id = 9
  (2, 'new', '2021-01-08 17:41:02'), -- id = 10
  (1, 'delivered', '2021-01-08 16:41:02'), -- id = 11
  (3, 'canceled', '2021-01-08 12:41:02'), -- id = 12
  (3, 'new', '2021-01-08 17:41:02'); -- id = 13


-- Создаем таблицу test_order_item
-- В таблице test_order_item хранится информация по позициям заказа
create table test_order_item (
  id serial4 not null,
  product_id int4 null, -- id продукта
  quantity int4 null, -- количество продукта
  price float null, -- стоимость одной единицы продукта в заказе
  order_id int4 null,-- id заказа
  deleted timestamp null -- дата удаления позиции
);

-- Заполняем таблицу test_order_item данными
insert into test_order_item (product_id, quantity, price, order_id, deleted)
values (1, 10, 100.25, 1, '2020-11-06 11:41:02'),
  (1, 10, 105.25, 1, Null),
  (1, 10, 110.25, 1, Null),
  (2, 13, 150.25, 1, Null),
  (2, 13, 150.25, 2, Null),
  (9, 15, 140.25, 3, Null),
  (9, 15, 141.25, 3, Null),
  (7, 32, 50.25, 4, Null),
  (7, 32, 50.25, 4, '2020-11-09 17:41:02'),
  (7, 32, 50.25, 5, Null),
  (9, 15, 141.25, 5, Null),
  (2, 13, 150.25, 6, Null),
  (9, 15, 140.25, 6, Null),
  (1, 10, 100.25, 7, '2020-11-08 18:41:02'),
  (1, 10, 105.25, 7, Null),
  (1, 10, 110.25, 7, Null),
  (2, 13, 150.25, 8, Null),
  (2, 13, 150.25, 9, Null),
  (9, 15, 140.25, 9, Null),
  (9, 15, 141.25, 9, Null),
  (7, 32, 50.25, 10, Null),
  (7, 32, 50.25, 10, '2021-01-08 18:41:02'),
  (7, 32, 50.25, 11, Null),
  (9, 15, 141.25, 12, Null),
  (2, 13, 150.25, 12, Null),
  (9, 15, 140.25, 13, Null);


-- Создаем представление (НЕ Материализованное) чтобы в будущем можно было обращаться к подзапросу
-- В нем выводим сумму отмененных или удаленных заказов с разбивкой по месяцам
CREATE VIEW sum_of_cancel_and_del  as (
SELECT to_char(date, 'YYYY-mm') as date, sum(quantity*price) as cancel_and_del_sum FROM test_order 
JOIN test_order_item ON test_order.id = test_order_item.order_id
WHERE status = 'canceled' or deleted is not NULL
GROUP BY to_char(date, 'YYYY-mm')
ORDER BY date)

-- Создаем представление (НЕ Материализованное) чтобы в будущем можно было обращаться к подзапросу
-- В нем выводим сумму всех заказов с разбивкой по месяцам
CREATE VIEW sum_of_all as (SELECT to_char(date, 'YYYY-mm') as date, sum(quantity*price) as all_sum
FROM test_order 
JOIN test_order_item ON test_order.id = test_order_item.order_id
GROUP BY to_char(date, 'YYYY-mm')
ORDER BY date)

-- Объеденяем два подзапроса и считаем долю заказов, которые были отменены за все время с разбивкой по месяцам
SELECT date, all_sum, cancel_and_del_sum, round(CAST(cancel_and_del_sum AS numeric)/CAST(all_sum AS numeric), 3) as cancel_and_del_fraction
FROM sum_of_all 
JOIN sum_of_cancel_and_del USING(date)
