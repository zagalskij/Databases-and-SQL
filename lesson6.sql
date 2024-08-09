/*
1. Создание таблицы users_old
Для создания таблицы users_old, которая будет аналогична таблице users, используйте следующий запрос:
*/

CREATE TABLE users_old LIKE users;

/*
2. Создание процедуры для перемещения пользователя из users в users_old
Для перемещения пользователя из таблицы users в таблицу users_old, включая использование транзакции, можно создать следующую хранимую процедуру:
*/

DELIMITER //

CREATE PROCEDURE move_user_to_old(IN user_id BIGINT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; -- откатить изменения, если возникла ошибка
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ошибка при перемещении пользователя';
    END;

    START TRANSACTION;
    
    -- Копирование пользователя в users_old
    INSERT INTO users_old (id, firstname, lastname, email)
    SELECT id, firstname, lastname, email
    FROM users
    WHERE id = user_id;

    -- Удаление пользователя из users
    DELETE FROM users
    WHERE id = user_id;
    
    COMMIT; -- завершение транзакции
END //

DELIMITER ;

/*
3. Создание хранимой функции hello()
Хранимая функция для возвращения приветствия в зависимости от времени суток:
*/

DELIMITER //

CREATE FUNCTION hello() RETURNS VARCHAR(20)
BEGIN
    DECLARE greeting VARCHAR(20);
    DECLARE current_time TIME;
    
    SET current_time = CURTIME();
    
    IF current_time >= '06:00:00' AND current_time < '12:00:00' THEN
        SET greeting = 'Доброе утро';
    ELSEIF current_time >= '12:00:00' AND current_time < '18:00:00' THEN
        SET greeting = 'Добрый день';
    ELSEIF current_time >= '18:00:00' AND current_time < '00:00:00' THEN
        SET greeting = 'Добрый вечер';
    ELSE
        SET greeting = 'Доброй ночи';
    END IF;
    
    RETURN greeting;
END //

DELIMITER ;


/*
4. (Дополнительно) Создание таблицы logs и триггеров для логирования
Для логирования действий в таблицах users, communities и messages можно создать таблицу logs и соответствующие триггеры:
*/

-- Создание таблицы logs
CREATE TABLE logs (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(50),
    action_time DATETIME DEFAULT NOW(),
    primary_key_value BIGINT
) ENGINE=ARCHIVE;

-- Триггер для таблицы users
CREATE TRIGGER log_users_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO logs (table_name, primary_key_value) VALUES ('users', NEW.id);
END;

-- Триггер для таблицы communities
CREATE TRIGGER log_communities_insert
AFTER INSERT ON communities
FOR EACH ROW
BEGIN
    INSERT INTO logs (table_name, primary_key_value) VALUES ('communities', NEW.id);
END;

-- Триггер для таблицы messages
CREATE TRIGGER log_messages_insert
AFTER INSERT ON messages
FOR EACH ROW
BEGIN
    INSERT INTO logs (table_name, primary_key_value) VALUES ('messages', NEW.id);
END;
/*
Эти запросы создадут таблицу logs и настроят автоматическое логирование действий при вставке данных в таблицы users, communities и messages.
*/