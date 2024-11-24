-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: 127.0.0.1
-- Létrehozás ideje: 2024. Nov 24. 12:29
-- Kiszolgáló verziója: 10.4.28-MariaDB
-- PHP verzió: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Adatbázis: `database`
--
CREATE DATABASE IF NOT EXISTS `database` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `database`;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `access_control`
--

DROP TABLE IF EXISTS `access_control`;
CREATE TABLE `access_control` (
  `user_id` int(11) NOT NULL,
  `num_of_runs` int(11) DEFAULT 0,
  `deadline_dt` datetime DEFAULT NULL,
  `last_updated_dt` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `request`
--

DROP TABLE IF EXISTS `request`;
CREATE TABLE `request` (
  `uuid` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `direction` int(11) DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `creation_datetime` double DEFAULT NULL,
  `is_setup_completed` tinyint(1) DEFAULT 0,
  `num_of_components` int(11) DEFAULT NULL,
  `is_calculation_completed` tinyint(1) DEFAULT 0,
  `server_path` varchar(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Eseményindítók `request`
--
DROP TRIGGER IF EXISTS `before_insert_request_uuid`;
DELIMITER $$
CREATE TRIGGER `before_insert_request_uuid` BEFORE INSERT ON `request` FOR EACH ROW BEGIN
    DECLARE is_unique BOOLEAN DEFAULT FALSE;
    DECLARE generated_uuid INT;

    WHILE is_unique = FALSE DO
        -- Generate a random UUID between 1,000,000 and 9,999,999
        SET generated_uuid = FLOOR(1000000 + (RAND() * 9000000));

        -- Check if this UUID already exists in the table
        IF (SELECT COUNT(*) FROM request WHERE uuid = generated_uuid) = 0 THEN
            SET is_unique = TRUE;
        END IF;
    END WHILE;

    -- Assign the unique UUID to the new row
    SET NEW.uuid = generated_uuid;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `result`
--

DROP TABLE IF EXISTS `result`;
CREATE TABLE `result` (
  `uuid` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `direction` int(11) DEFAULT NULL,
  `summary_path` varchar(255) DEFAULT NULL,
  `details_path` varchar(255) DEFAULT NULL,
  `creation_datetime` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Eseményindítók `result`
--
DROP TRIGGER IF EXISTS `before_insert_result_uuid`;
DELIMITER $$
CREATE TRIGGER `before_insert_result_uuid` BEFORE INSERT ON `result` FOR EACH ROW BEGIN
    DECLARE is_unique BOOLEAN DEFAULT FALSE;
    DECLARE generated_uuid INT;

    WHILE is_unique = FALSE DO
        -- Generate a random UUID between 1,000,000 and 9,999,999
        SET generated_uuid = FLOOR(1000000 + (RAND() * 9000000));

        -- Check if this UUID already exists in the table
        IF (SELECT COUNT(*) FROM result WHERE uuid = generated_uuid) = 0 THEN
            SET is_unique = TRUE;
        END IF;
    END WHILE;

    -- Assign the unique UUID to the new row
    SET NEW.uuid = generated_uuid;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `uuid` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password_hashed` varchar(100) DEFAULT NULL,
  `creation_dt` timestamp NOT NULL DEFAULT current_timestamp(),
  `modified_dt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Eseményindítók `user`
--
DROP TRIGGER IF EXISTS `after_user_insert`;
DELIMITER $$
CREATE TRIGGER `after_user_insert` AFTER INSERT ON `user` FOR EACH ROW BEGIN
    INSERT INTO access_control (user_id, num_of_runs, deadline_dt, last_updated_dt)
    VALUES (NEW.uuid, 0, UNIX_TIMESTAMP(DATE_ADD(NOW(), INTERVAL 1 YEAR)), UNIX_TIMESTAMP(NOW()));
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `before_insert_user_uuid`;
DELIMITER $$
CREATE TRIGGER `before_insert_user_uuid` BEFORE INSERT ON `user` FOR EACH ROW BEGIN
    DECLARE is_unique BOOLEAN DEFAULT FALSE;
    DECLARE generated_uuid INT;

    WHILE is_unique = FALSE DO
        -- Generate a random UUID between 1,000,000 and 9,999,999
        SET generated_uuid = FLOOR(1000000 + (RAND() * 9000000));

        -- Check if this UUID already exists in the table
        IF (SELECT COUNT(*) FROM user WHERE uuid = generated_uuid) = 0 THEN
            SET is_unique = TRUE;
        END IF;
    END WHILE;

    -- Assign the unique UUID to the new row
    SET NEW.uuid = generated_uuid;
END
$$
DELIMITER ;

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `access_control`
--
ALTER TABLE `access_control`
  ADD PRIMARY KEY (`user_id`);

--
-- A tábla indexei `request`
--
ALTER TABLE `request`
  ADD PRIMARY KEY (`uuid`),
  ADD KEY `fk_user_id` (`user_id`);

--
-- A tábla indexei `result`
--
ALTER TABLE `result`
  ADD PRIMARY KEY (`uuid`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `request_id` (`request_id`);

--
-- A tábla indexei `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`uuid`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `request`
--
ALTER TABLE `request`
  MODIFY `uuid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9838905;

--
-- Megkötések a kiírt táblákhoz
--

--
-- Megkötések a táblához `access_control`
--
ALTER TABLE `access_control`
  ADD CONSTRAINT `access_control_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`uuid`);

--
-- Megkötések a táblához `request`
--
ALTER TABLE `request`
  ADD CONSTRAINT `fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`uuid`);

--
-- Megkötések a táblához `result`
--
ALTER TABLE `result`
  ADD CONSTRAINT `result_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`uuid`),
  ADD CONSTRAINT `result_ibfk_2` FOREIGN KEY (`request_id`) REFERENCES `request` (`uuid`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
