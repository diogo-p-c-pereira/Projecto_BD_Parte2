-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 18, 2023 at 08:46 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `musisys`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `P1` (IN `EdicaoClonar` INT, IN `dataNova` DATE)   BEGIN
	declare new_edicao_numero numeric;
	declare new_data_fim date;
	set new_data_fim = (SELECT DATE_ADD(dataNova, INTERVAL (SELECT DATEDIFF((SELECT data_fim FROM edicao WHERE (numero = EdicaoClonar)),(SELECT data_inicio FROM edicao WHERE (numero = EdicaoClonar)))) DAY));

	INSERT INTO Edicao
    		(`nome`, `localidade`, `local`, `data_inicio`, `data_fim`, `lotacao`)
	SELECT 
    		nome, localidade, local, dataNova, new_data_fim, lotacao
	FROM 
    		edicao
	WHERE 
    		numero = EdicaoClonar;

	
	set new_edicao_numero = (SELECT MAX(numero) FROM edicao);



	INSERT INTO palco
    		(`Edicao_numero`, `codigo`, `nome`)
	SELECT 
    		new_edicao_numero, codigo, nome
	FROM 
    		palco
	WHERE 
    		Edicao_numero = EdicaoClonar;
	
	

	INSERT INTO dia_festival
    		(`Edicao_numero`, `data`)
	SELECT 
    		new_edicao_numero, (SELECT DATE_ADD(dataNova, INTERVAL (SELECT DATEDIFF( data,(SELECT data_inicio FROM edicao WHERE (numero = EdicaoClonar)))) DAY))
	FROM 
    		dia_festival
	WHERE 
    		Edicao_numero = EdicaoClonar;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `P2` (IN `nome` VARCHAR(60), IN `localidade` VARCHAR(60), IN `local` VARCHAR(60), IN `data_inicio` DATE, IN `data_fim` DATE, IN `lotacao` INT, IN `num_palcos` INT)   BEGIN
DECLARE nEdicao numeric;
  DECLARE i INT;
  SET i = 1;

  INSERT INTO edicao(nome,localidade,local,data_inicio,data_fim,lotacao)
  VALUES(nome,localidade,local,data_inicio,data_fim,lotacao);

set nEdicao = (SELECT MAX(numero) FROM edicao);

  WHILE i <= num_palcos DO
    INSERT INTO palco(codigo,edicao_numero,nome)
    VALUES(i,nEdicao, (SELECT CONCAT('Palco ', i)) );
    SET i = i + 1;
  END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Q1_Cartaz` (IN `nEdicao` INT)   BEGIN
	SELECT nome, dia_festival_data
	FROM participante,contrata
	WHERE participante.codigo=contrata.Participante_codigo AND contrata.Edicao_numero = nEdicao
	ORDER BY dia_festival_data ASC, cachet DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Q3_Qtd_espetadores_no_dia` (IN `dia` DATE)   SELECT qtd_espetadores 
FROM dia_festival
WHERE data=dia$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Q6_Entrevistado_por` (IN `nEdicao` INT, IN `nomeJornalista` VARCHAR(100))   BEGIN
	SELECT DISTINCT(participante.nome)
	FROM participante
	WHERE participante.codigo IN (SELECT Participante_codigo FROM entrevista WHERE Jornalista_num_carteira_profissional = (SELECT num_carteira_profissional FROM jornalista WHERE nome = nomeJornalista)
	AND data IN (SELECT data FROM dia_festival WHERE Edicao_numero = nEdicao));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Q7_Ainda_nao_entrevistados_por` (IN `nomeJornalista` VARCHAR(100))   SELECT DISTINCT(participante.nome)
	FROM participante
	WHERE participante.codigo NOT IN (SELECT Participante_codigo FROM entrevista WHERE Jornalista_num_carteira_profissional = (SELECT num_carteira_profissional FROM jornalista WHERE nome = nomeJornalista)
	AND data IN (SELECT data FROM dia_festival WHERE Edicao_numero = (SELECT numero FROM edicao WHERE (data_inicio = (SELECT MAX(data_inicio) 
			FROM edicao)))))$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `F1` () RETURNS INT(11)  begin
	declare totalEdicoes numeric;
	declare lucroTotal numeric;
	declare media double;
	set totalEdicoes = (SELECT COUNT(*) FROM edicao);
	set lucroTotal =  (SELECT SUM(preco) FROM tipo_de_bilhete, bilhete WHERE bilhete.tipo_de_bilhete_id=tipo_de_bilhete.id AND bilhete.devolvido=0) - (SELECT SUM(cachet) FROM contrata);
	set media = lucroTotal / totalEdicoes;
	return(media);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `F2` () RETURNS INT(11)  begin
	declare n_participantes numeric;
	declare edicao_n numeric;
	set edicao_n = (SELECT numero FROM edicao WHERE (data_inicio = (SELECT MAX(data_inicio) 
			FROM edicao)) );
set n_participantes = (Select 	count(participante_codigo)
		FROM contrata
		where Edicao_numero = edicao_n);
	return (n_participantes);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `acesso`
--

CREATE TABLE `acesso` (
  `Dia_festival_data` date NOT NULL,
  `Tipo_de_bilhete_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `acesso`
--

INSERT INTO `acesso` (`Dia_festival_data`, `Tipo_de_bilhete_id`) VALUES
('2023-12-01', 1),
('2023-12-01', 2),
('2023-12-01', 4),
('2023-12-03', 1),
('2023-12-03', 3),
('2023-12-03', 4);

-- --------------------------------------------------------

--
-- Table structure for table `bilhete`
--

CREATE TABLE `bilhete` (
  `num_serie` int(11) NOT NULL,
  `Tipo_de_bilhete_id` int(11) NOT NULL,
  `Espetador_com_bilhete_Espetador_identificador` int(11) DEFAULT NULL,
  `designacao` varchar(60) DEFAULT NULL,
  `devolvido` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bilhete`
--

INSERT INTO `bilhete` (`num_serie`, `Tipo_de_bilhete_id`, `Espetador_com_bilhete_Espetador_identificador`, `designacao`, `devolvido`) VALUES
(1, 1, 2, NULL, 1),
(2, 2, 3, NULL, 0),
(3, 4, 1, NULL, 0);

--
-- Triggers `bilhete`
--
DELIMITER $$
CREATE TRIGGER `T2_a_insert_after_bilhete` AFTER INSERT ON `bilhete` FOR EACH ROW BEGIN
	UPDATE dia_festival SET qtd_espetadores = (qtd_espetadores + 1) WHERE data IN (SELECT Dia_festival_data FROM acesso WHERE Tipo_de_bilhete_id = new.Tipo_de_bilhete_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `T2_a_update_after_bilhete` AFTER UPDATE ON `bilhete` FOR EACH ROW BEGIN
	IF (old.devolvido=0 AND new.devolvido=1) THEN
		UPDATE dia_festival SET qtd_espetadores = (qtd_espetadores - 1) WHERE data IN (SELECT Dia_festival_data FROM acesso WHERE Tipo_de_bilhete_id = 				old.Tipo_de_bilhete_id);
	ELSEIF (old.devolvido=1 AND new.devolvido=0) THEN
		UPDATE dia_festival SET qtd_espetadores = (qtd_espetadores + 1) WHERE data IN (SELECT Dia_festival_data FROM acesso WHERE Tipo_de_bilhete_id = 						new.Tipo_de_bilhete_id);
	ELSEIF (old.Tipo_de_bilhete_id <> new.Tipo_de_bilhete_id AND new.devolvido<>1) THEN
		UPDATE dia_festival SET qtd_espetadores = (qtd_espetadores - 1) WHERE data IN (SELECT Dia_festival_data FROM acesso WHERE Tipo_de_bilhete_id = 						old.Tipo_de_bilhete_id);
		UPDATE dia_festival SET qtd_espetadores = (qtd_espetadores + 1) WHERE data IN (SELECT Dia_festival_data FROM acesso WHERE Tipo_de_bilhete_id = 						new.Tipo_de_bilhete_id);
	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `T2_b_insert_before_bilhete` BEFORE INSERT ON `bilhete` FOR EACH ROW BEGIN
	IF (new.devolvido<>1) THEN
		IF (SELECT COUNT(*) FROM dia_festival WHERE ((data IN (SELECT Dia_festival_data FROM acesso WHERE (Tipo_de_bilhete_id = new.Tipo_de_bilhete_id))) AND 
       (qtd_espetadores=(SELECT lotacao FROM edicao WHERE(numero = Edicao_numero)))))<>0 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lotacao Esgotada!';
		END IF;
	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `T2_b_update_before_bilhete` BEFORE UPDATE ON `bilhete` FOR EACH ROW BEGIN
	IF (new.devolvido<>1) THEN
		IF (SELECT COUNT(*) FROM dia_festival WHERE ((data IN (SELECT Dia_festival_data FROM acesso WHERE (Tipo_de_bilhete_id = new.Tipo_de_bilhete_id))) AND 
       (qtd_espetadores=(SELECT lotacao FROM edicao WHERE(numero = Edicao_numero)))))<>0 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lotacao Esgotada!';
		END IF;
	END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `contrata`
--

CREATE TABLE `contrata` (
  `Edicao_numero` tinyint(4) NOT NULL,
  `Participante_codigo` smallint(6) NOT NULL,
  `cachet` int(11) DEFAULT NULL,
  `Palco_Edicao_numero` tinyint(4) NOT NULL,
  `Palco_codigo` tinyint(4) NOT NULL,
  `Dia_festival_data` date NOT NULL,
  `hora_inicio` time DEFAULT NULL,
  `hora_fim` time DEFAULT NULL,
  `Convidado_Edicao_numero` tinyint(4) DEFAULT NULL,
  `Convidado_Participante_codigo` smallint(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `contrata`
--

INSERT INTO `contrata` (`Edicao_numero`, `Participante_codigo`, `cachet`, `Palco_Edicao_numero`, `Palco_codigo`, `Dia_festival_data`, `hora_inicio`, `hora_fim`, `Convidado_Edicao_numero`, `Convidado_Participante_codigo`) VALUES
(1, 1, NULL, 2, 2, '2023-12-01', '11:50:14', '11:56:10', NULL, NULL),
(1, 2, NULL, 1, 2, '2023-12-01', NULL, NULL, NULL, NULL),
(3, 1, NULL, 1, 2, '2024-11-02', '16:21:26', '17:21:20', NULL, NULL);

--
-- Triggers `contrata`
--
DELIMITER $$
CREATE TRIGGER `CKpalco_no_contrata_before_insert` BEFORE INSERT ON `contrata` FOR EACH ROW BEGIN
	IF(new.Palco_codigo NOT IN (SELECT codigo FROM palco WHERE Edicao_numero=new.Edicao_numero)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Palco não pertence à Edição';
	END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `dia_festival`
--

CREATE TABLE `dia_festival` (
  `Edicao_numero` tinyint(4) NOT NULL,
  `data` date NOT NULL,
  `qtd_espetadores` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dia_festival`
--

INSERT INTO `dia_festival` (`Edicao_numero`, `data`, `qtd_espetadores`) VALUES
(1, '2023-12-01', 2),
(1, '2023-12-02', 0),
(1, '2023-12-03', 1),
(1, '2023-12-05', 0),
(3, '2024-11-02', 0);

--
-- Triggers `dia_festival`
--
DELIMITER $$
CREATE TRIGGER `dia_festival_before_insert` BEFORE INSERT ON `dia_festival` FOR EACH ROW BEGIN
	IF(new.data not between (SELECT data_inicio FROM edicao WHERE numero = new.Edicao_numero) AND ((SELECT data_fim FROM edicao WHERE numero = new.Edicao_numero))) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dia não pertence ao festival!';
	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `dia_festival_before_update` BEFORE UPDATE ON `dia_festival` FOR EACH ROW BEGIN
	IF(new.data not between (SELECT data_inicio FROM edicao WHERE numero = new.Edicao_numero) AND ((SELECT data_fim FROM edicao WHERE numero = new.Edicao_numero))) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dia não pertence ao festival!';
	END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `edicao`
--

CREATE TABLE `edicao` (
  `numero` tinyint(4) NOT NULL,
  `nome` varchar(60) DEFAULT NULL,
  `localidade` varchar(60) DEFAULT NULL,
  `local` varchar(60) DEFAULT NULL,
  `data_inicio` date DEFAULT NULL,
  `data_fim` date DEFAULT NULL,
  `lotacao` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `edicao`
--

INSERT INTO `edicao` (`numero`, `nome`, `localidade`, `local`, `data_inicio`, `data_fim`, `lotacao`) VALUES
(1, 'NOS Alive', 'Algés', 'Passeio Maritimo', '2023-12-01', '2023-12-05', 4),
(2, 'Sol da Caparica', 'Costa da Caparica', 'Parque S.António', '2024-02-01', '2024-02-10', 10),
(3, 'Sumol Summerfest', 'Zambujeira', 'Herdade XPTO', '2024-11-01', '2024-11-06', 1000);

-- --------------------------------------------------------

--
-- Table structure for table `elemento_grupo`
--

CREATE TABLE `elemento_grupo` (
  `Individual_Participante_codigo` smallint(6) NOT NULL,
  `Grupo_Participante_codigo` smallint(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `elemento_grupo`
--
DELIMITER $$
CREATE TRIGGER `trigger_verificao_elementos_grupo_before_insert` BEFORE INSERT ON `elemento_grupo` FOR EACH ROW BEGIN
 if (SELECT tipo FROM `participante` WHERE codigo = 			new.Individual_Participante_codigo) <> 'Individual' THEN
 	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Participante não individual!';
 END IF;
 if (SELECT tipo FROM `participante` WHERE codigo = 			new.Grupo_Participante_codigo) <> 'Grupo' THEN
 	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Participante não é um grupo!';
 END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trigger_verificao_elementos_grupo_before_update` BEFORE UPDATE ON `elemento_grupo` FOR EACH ROW BEGIN
 if (SELECT tipo FROM `participante` WHERE codigo = 			new.Individual_Participante_codigo) <> 'Individual' THEN
 	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Participante não individual!';
 END IF;
 if (SELECT tipo FROM `participante` WHERE codigo = 			new.Grupo_Participante_codigo) <> 'Grupo' THEN
 	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Participante não é um grupo!';
 END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `entrevista`
--

CREATE TABLE `entrevista` (
  `Participante_codigo` smallint(6) NOT NULL,
  `Jornalista_num_carteira_profissional` int(11) NOT NULL,
  `data` date DEFAULT NULL,
  `hora` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `espetador_com_bilhete`
--

CREATE TABLE `espetador_com_bilhete` (
  `Espetador_identificador` int(11) NOT NULL,
  `nome` varchar(100) DEFAULT NULL,
  `genero` enum('M','F') DEFAULT NULL,
  `subtipo` enum('Pagante','Convidado') NOT NULL,
  `idade` tinyint(4) DEFAULT NULL,
  `profissao` varchar(60) DEFAULT NULL
) ;

--
-- Dumping data for table `espetador_com_bilhete`
--

INSERT INTO `espetador_com_bilhete` (`Espetador_identificador`, `nome`, `genero`, `subtipo`, `idade`, `profissao`) VALUES
(1, 'Bruno', NULL, 'Pagante', 25, NULL),
(2, 'Diogo', 'M', 'Convidado', NULL, 'Engenheiro'),
(3, 'André', NULL, 'Convidado', NULL, 'Ativista');

-- --------------------------------------------------------

--
-- Table structure for table `estilo`
--

CREATE TABLE `estilo` (
  `codigo` char(2) NOT NULL,
  `Nome` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `estilo_de_artista`
--

CREATE TABLE `estilo_de_artista` (
  `Participante_codigo` smallint(6) NOT NULL,
  `Estilo_codigo` char(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jornalista`
--

CREATE TABLE `jornalista` (
  `nome` varchar(100) DEFAULT NULL,
  `genero` enum('M','F') DEFAULT NULL,
  `Media_codigo` char(2) NOT NULL,
  `num_carteira_profissional` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `livre_transito`
--

CREATE TABLE `livre_transito` (
  `Edicao_numero` tinyint(4) NOT NULL,
  `Jornalista_num_carteira_profissional` int(11) NOT NULL,
  `numero` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `media`
--

CREATE TABLE `media` (
  `codigo` char(2) NOT NULL,
  `nome` varchar(30) NOT NULL,
  `tipo` enum('Rádio','TV','Jornal','Revista') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `montado`
--

CREATE TABLE `montado` (
  `Palco_Edicao_numero` tinyint(4) NOT NULL,
  `Palco_codigo` tinyint(4) NOT NULL,
  `Tecnico_numero` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `montado`
--
DELIMITER $$
CREATE TRIGGER `T1_montado_before_insert` BEFORE INSERT ON `montado` FOR EACH ROW BEGIN
	IF (((SELECT Participante_codigo FROM `tecnico` WHERE numero = new.Tecnico_numero) <> (SELECT Participante_codigo FROM `contrata` WHERE Palco_Edicao_numero = new.Palco_Edicao_numero AND Palco_codigo = new.Palco_codigo)) AND ((SELECT tipo FROM `tecnico` WHERE numero = new.Tecnico_numero) <> 'Organizacao')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Participante não corresponde ao Roadie';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `T1_montado_before_update` BEFORE INSERT ON `montado` FOR EACH ROW BEGIN
	IF (((SELECT Participante_codigo FROM `tecnico` WHERE numero = new.Tecnico_numero) <> (SELECT Participante_codigo FROM `contrata` WHERE Palco_Edicao_numero = new.Palco_Edicao_numero AND Palco_codigo = new.Palco_codigo)) AND ((SELECT tipo FROM `tecnico` WHERE numero = new.Tecnico_numero) <> 'Organizacao')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Participante não corresponde ao Roadie';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pais`
--

CREATE TABLE `pais` (
  `codigo` char(2) NOT NULL,
  `nome` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `palco`
--

CREATE TABLE `palco` (
  `codigo` tinyint(4) NOT NULL,
  `Edicao_numero` tinyint(4) NOT NULL,
  `nome` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `palco`
--

INSERT INTO `palco` (`codigo`, `Edicao_numero`, `nome`) VALUES
(1, 1, 'Palco 1'),
(2, 1, 'Palco 2'),
(3, 1, 'Palco 3'),
(4, 1, 'Principal'),
(1, 2, 'Palco 1'),
(2, 2, 'Palco 2'),
(1, 3, 'Palco 1'),
(2, 3, 'Palco 2');

-- --------------------------------------------------------

--
-- Table structure for table `papel`
--

CREATE TABLE `papel` (
  `codigo` char(2) NOT NULL,
  `Nome` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `papel_no_grupo`
--

CREATE TABLE `papel_no_grupo` (
  `Elemento_grupo_Individual_Participante_codigo` smallint(6) NOT NULL,
  `Elemento_grupo_Grupo_Participante_codigo` smallint(6) NOT NULL,
  `Papel_codigo` char(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `participante`
--

CREATE TABLE `participante` (
  `codigo` smallint(6) NOT NULL,
  `nome` varchar(80) DEFAULT NULL,
  `tipo` enum('Individual','Grupo') NOT NULL,
  `Pais_codigo` char(2) DEFAULT NULL,
  `qtd_elementos` tinyint(4) DEFAULT NULL
) ;

--
-- Dumping data for table `participante`
--

INSERT INTO `participante` (`codigo`, `nome`, `tipo`, `Pais_codigo`, `qtd_elementos`) VALUES
(1, 'Testers', 'Grupo', NULL, 5),
(2, 'Banda X', 'Grupo', NULL, 3);

-- --------------------------------------------------------

--
-- Stand-in structure for view `q2_resultados_diarios`
-- (See below for the actual view)
--
CREATE TABLE `q2_resultados_diarios` (
`data` date
,`qtd_espetadores` int(11)
,`Faturacao` decimal(32,6)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `q4_estilos_musicais_por_edicao`
-- (See below for the actual view)
--
CREATE TABLE `q4_estilos_musicais_por_edicao` (
`Edição` tinyint(4)
,`Estilo` varchar(30)
,`Qtd_artistas` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `q5_todos_os_participantes`
-- (See below for the actual view)
--
CREATE TABLE `q5_todos_os_participantes` (
`nome` varchar(80)
,`Anos` varchar(5)
,`cachet` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `reportagem`
--

CREATE TABLE `reportagem` (
  `Dia_festival_data` date NOT NULL,
  `Jornalista_num_carteira_profissional` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tecnico`
--

CREATE TABLE `tecnico` (
  `numero` int(11) NOT NULL,
  `nome` varchar(120) NOT NULL,
  `tipo` enum('Roadie','Organizacao') NOT NULL,
  `Participante_codigo` smallint(6) DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `tema`
--

CREATE TABLE `tema` (
  `Edicao_numero` tinyint(4) NOT NULL,
  `Participante_codigo` smallint(6) NOT NULL,
  `nr_ordem` tinyint(4) NOT NULL,
  `titulo` varchar(60) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tipo_de_bilhete`
--

CREATE TABLE `tipo_de_bilhete` (
  `id` int(11) NOT NULL,
  `Nome` varchar(30) NOT NULL,
  `preco` decimal(6,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tipo_de_bilhete`
--

INSERT INTO `tipo_de_bilhete` (`id`, `Nome`, `preco`) VALUES
(1, '2 dias', 16.00),
(2, '1 dez', 10.00),
(3, '2 dez', 10.00),
(4, 'Barato', 5.00);

-- --------------------------------------------------------

--
-- Structure for view `q2_resultados_diarios`
--
DROP TABLE IF EXISTS `q2_resultados_diarios`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `q2_resultados_diarios`  AS SELECT `df`.`data` AS `data`, `df`.`qtd_espetadores` AS `qtd_espetadores`, sum(case when `b`.`devolvido` = 0 then `tb`.`preco` / (select count(`acesso`.`Tipo_de_bilhete_id`) from `acesso` where `acesso`.`Tipo_de_bilhete_id` = `tb`.`id`) else 0 end) AS `Faturacao` FROM (((`dia_festival` `df` join `acesso` `a`) join `tipo_de_bilhete` `tb`) join `bilhete` `b`) WHERE `df`.`data` = `a`.`Dia_festival_data` AND `a`.`Tipo_de_bilhete_id` = `tb`.`id` AND `tb`.`id` = `b`.`Tipo_de_bilhete_id` GROUP BY `df`.`data` ;

-- --------------------------------------------------------

--
-- Structure for view `q4_estilos_musicais_por_edicao`
--
DROP TABLE IF EXISTS `q4_estilos_musicais_por_edicao`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `q4_estilos_musicais_por_edicao`  AS SELECT `contrata`.`Edicao_numero` AS `Edição`, `estilo`.`Nome` AS `Estilo`, count(`estilo`.`codigo`) AS `Qtd_artistas` FROM (((`estilo_de_artista` join `participante`) join `estilo`) join `contrata`) WHERE `contrata`.`Participante_codigo` = `participante`.`codigo` AND `estilo_de_artista`.`Participante_codigo` = `participante`.`codigo` AND `estilo_de_artista`.`Estilo_codigo` = `estilo`.`codigo` GROUP BY `contrata`.`Edicao_numero`, `estilo`.`codigo` ;

-- --------------------------------------------------------

--
-- Structure for view `q5_todos_os_participantes`
--
DROP TABLE IF EXISTS `q5_todos_os_participantes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `q5_todos_os_participantes`  AS SELECT `participante`.`nome` AS `nome`, year(curdate()) - year(`contrata`.`Dia_festival_data`) AS `Anos`, `contrata`.`cachet` AS `cachet` FROM (`participante` join `contrata`) WHERE `participante`.`codigo` = `contrata`.`Participante_codigo` AND (`participante`.`nome`,`contrata`.`Dia_festival_data`) in (select `participante`.`nome`,max(`contrata`.`Dia_festival_data`) from (`participante` join `contrata`) where `participante`.`codigo` = `contrata`.`Participante_codigo` AND (select to_days(curdate()) - to_days(`contrata`.`Dia_festival_data`) > 0) group by `participante`.`nome`)union select `participante`.`nome` AS `nome`,'Nunca' AS `Anos`,NULL AS `cachet` from `participante` where !exists(select `participante`.`nome` from `contrata` where `participante`.`codigo` = `contrata`.`Participante_codigo` limit 1)  ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `acesso`
--
ALTER TABLE `acesso`
  ADD PRIMARY KEY (`Dia_festival_data`,`Tipo_de_bilhete_id`),
  ADD KEY `FK_Tipo_de_bilhete_acesso_Dia_festival` (`Tipo_de_bilhete_id`);

--
-- Indexes for table `bilhete`
--
ALTER TABLE `bilhete`
  ADD PRIMARY KEY (`num_serie`),
  ADD KEY `FK_Bilhete_noname_Tipo_de_bilhete` (`Tipo_de_bilhete_id`),
  ADD KEY `FK_Bilhete_tem_Espetador_com_bilhete` (`Espetador_com_bilhete_Espetador_identificador`);

--
-- Indexes for table `contrata`
--
ALTER TABLE `contrata`
  ADD PRIMARY KEY (`Edicao_numero`,`Participante_codigo`),
  ADD KEY `FK_Participante_Contrata_Edicao` (`Participante_codigo`),
  ADD KEY `FK_Contrata_apresenta_Palco` (`Palco_Edicao_numero`,`Palco_codigo`),
  ADD KEY `FK_Contrata_Atuacao_Dia_festival` (`Dia_festival_data`),
  ADD KEY `FK_Participante_Convida_Participante` (`Convidado_Edicao_numero`,`Convidado_Participante_codigo`);

--
-- Indexes for table `dia_festival`
--
ALTER TABLE `dia_festival`
  ADD PRIMARY KEY (`data`),
  ADD KEY `FK_Dia_festival_noname_Edicao` (`Edicao_numero`);

--
-- Indexes for table `edicao`
--
ALTER TABLE `edicao`
  ADD PRIMARY KEY (`numero`);

--
-- Indexes for table `elemento_grupo`
--
ALTER TABLE `elemento_grupo`
  ADD PRIMARY KEY (`Individual_Participante_codigo`,`Grupo_Participante_codigo`),
  ADD KEY `FK_Grupo_Elemento_grupo_Individual` (`Grupo_Participante_codigo`);

--
-- Indexes for table `entrevista`
--
ALTER TABLE `entrevista`
  ADD PRIMARY KEY (`Participante_codigo`,`Jornalista_num_carteira_profissional`),
  ADD KEY `FK_Jornalista_Entrevista_Participante` (`Jornalista_num_carteira_profissional`);

--
-- Indexes for table `espetador_com_bilhete`
--
ALTER TABLE `espetador_com_bilhete`
  ADD PRIMARY KEY (`Espetador_identificador`);

--
-- Indexes for table `estilo`
--
ALTER TABLE `estilo`
  ADD PRIMARY KEY (`codigo`);

--
-- Indexes for table `estilo_de_artista`
--
ALTER TABLE `estilo_de_artista`
  ADD PRIMARY KEY (`Participante_codigo`,`Estilo_codigo`),
  ADD KEY `FK_Estilo_estilo_de_artista_Participante` (`Estilo_codigo`);

--
-- Indexes for table `jornalista`
--
ALTER TABLE `jornalista`
  ADD PRIMARY KEY (`num_carteira_profissional`),
  ADD KEY `FK_Jornalista_representa_Media` (`Media_codigo`);

--
-- Indexes for table `livre_transito`
--
ALTER TABLE `livre_transito`
  ADD PRIMARY KEY (`Edicao_numero`,`Jornalista_num_carteira_profissional`),
  ADD KEY `FK_Jornalista_Livre_transito_Edicao` (`Jornalista_num_carteira_profissional`);

--
-- Indexes for table `media`
--
ALTER TABLE `media`
  ADD PRIMARY KEY (`codigo`);

--
-- Indexes for table `montado`
--
ALTER TABLE `montado`
  ADD PRIMARY KEY (`Palco_Edicao_numero`,`Palco_codigo`,`Tecnico_numero`),
  ADD KEY `FK_Tecnico_montado_Palco` (`Tecnico_numero`);

--
-- Indexes for table `pais`
--
ALTER TABLE `pais`
  ADD PRIMARY KEY (`codigo`);

--
-- Indexes for table `palco`
--
ALTER TABLE `palco`
  ADD PRIMARY KEY (`Edicao_numero`,`codigo`);

--
-- Indexes for table `papel`
--
ALTER TABLE `papel`
  ADD PRIMARY KEY (`codigo`);

--
-- Indexes for table `papel_no_grupo`
--
ALTER TABLE `papel_no_grupo`
  ADD PRIMARY KEY (`Elemento_grupo_Individual_Participante_codigo`,`Elemento_grupo_Grupo_Participante_codigo`,`Papel_codigo`),
  ADD KEY `FK_Papel_papel_no_grupo_Elemento_grupo` (`Papel_codigo`);

--
-- Indexes for table `participante`
--
ALTER TABLE `participante`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `FK_Individual_origem_Pais` (`Pais_codigo`);

--
-- Indexes for table `reportagem`
--
ALTER TABLE `reportagem`
  ADD PRIMARY KEY (`Dia_festival_data`,`Jornalista_num_carteira_profissional`),
  ADD KEY `FK_Jornalista_Reportagem_Dia_festival` (`Jornalista_num_carteira_profissional`);

--
-- Indexes for table `tecnico`
--
ALTER TABLE `tecnico`
  ADD PRIMARY KEY (`numero`),
  ADD KEY `FK_Roadie_ligado_Participante` (`Participante_codigo`);

--
-- Indexes for table `tema`
--
ALTER TABLE `tema`
  ADD PRIMARY KEY (`Edicao_numero`,`Participante_codigo`,`nr_ordem`);

--
-- Indexes for table `tipo_de_bilhete`
--
ALTER TABLE `tipo_de_bilhete`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bilhete`
--
ALTER TABLE `bilhete`
  MODIFY `num_serie` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `edicao`
--
ALTER TABLE `edicao`
  MODIFY `numero` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `espetador_com_bilhete`
--
ALTER TABLE `espetador_com_bilhete`
  MODIFY `Espetador_identificador` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `participante`
--
ALTER TABLE `participante`
  MODIFY `codigo` smallint(6) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tecnico`
--
ALTER TABLE `tecnico`
  MODIFY `numero` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tipo_de_bilhete`
--
ALTER TABLE `tipo_de_bilhete`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `acesso`
--
ALTER TABLE `acesso`
  ADD CONSTRAINT `FK_Dia_festival_acesso_Tipo_de_bilhete` FOREIGN KEY (`Dia_festival_data`) REFERENCES `dia_festival` (`data`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Tipo_de_bilhete_acesso_Dia_festival` FOREIGN KEY (`Tipo_de_bilhete_id`) REFERENCES `tipo_de_bilhete` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `bilhete`
--
ALTER TABLE `bilhete`
  ADD CONSTRAINT `FK_Bilhete_noname_Tipo_de_bilhete` FOREIGN KEY (`Tipo_de_bilhete_id`) REFERENCES `tipo_de_bilhete` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Bilhete_tem_Espetador_com_bilhete` FOREIGN KEY (`Espetador_com_bilhete_Espetador_identificador`) REFERENCES `espetador_com_bilhete` (`Espetador_identificador`) ON UPDATE CASCADE;

--
-- Constraints for table `contrata`
--
ALTER TABLE `contrata`
  ADD CONSTRAINT `FK_Contrata_Atuacao_Dia_festival` FOREIGN KEY (`Dia_festival_data`) REFERENCES `dia_festival` (`data`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Contrata_apresenta_Palco` FOREIGN KEY (`Palco_Edicao_numero`,`Palco_codigo`) REFERENCES `palco` (`Edicao_numero`, `codigo`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Edicao_Contrata_Participante` FOREIGN KEY (`Edicao_numero`) REFERENCES `edicao` (`numero`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Participante_Contrata_Edicao` FOREIGN KEY (`Participante_codigo`) REFERENCES `participante` (`codigo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Participante_Convida_Participante` FOREIGN KEY (`Convidado_Edicao_numero`,`Convidado_Participante_codigo`) REFERENCES `contrata` (`Edicao_numero`, `Participante_codigo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `dia_festival`
--
ALTER TABLE `dia_festival`
  ADD CONSTRAINT `FK_Dia_festival_noname_Edicao` FOREIGN KEY (`Edicao_numero`) REFERENCES `edicao` (`numero`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `elemento_grupo`
--
ALTER TABLE `elemento_grupo`
  ADD CONSTRAINT `FK_Grupo_Elemento_grupo_Individual` FOREIGN KEY (`Grupo_Participante_codigo`) REFERENCES `participante` (`codigo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Individual_Elemento_grupo_Grupo` FOREIGN KEY (`Individual_Participante_codigo`) REFERENCES `participante` (`codigo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `entrevista`
--
ALTER TABLE `entrevista`
  ADD CONSTRAINT `FK_Jornalista_Entrevista_Participante` FOREIGN KEY (`Jornalista_num_carteira_profissional`) REFERENCES `jornalista` (`num_carteira_profissional`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Participante_Entrevista_Jornalista` FOREIGN KEY (`Participante_codigo`) REFERENCES `participante` (`codigo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `estilo_de_artista`
--
ALTER TABLE `estilo_de_artista`
  ADD CONSTRAINT `FK_Estilo_estilo_de_artista_Participante` FOREIGN KEY (`Estilo_codigo`) REFERENCES `estilo` (`codigo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Participante_estilo_de_artista_Estilo` FOREIGN KEY (`Participante_codigo`) REFERENCES `participante` (`codigo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `jornalista`
--
ALTER TABLE `jornalista`
  ADD CONSTRAINT `FK_Jornalista_representa_Media` FOREIGN KEY (`Media_codigo`) REFERENCES `media` (`codigo`) ON UPDATE CASCADE;

--
-- Constraints for table `livre_transito`
--
ALTER TABLE `livre_transito`
  ADD CONSTRAINT `FK_Edicao_Livre_transito_Jornalista` FOREIGN KEY (`Edicao_numero`) REFERENCES `edicao` (`numero`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Jornalista_Livre_transito_Edicao` FOREIGN KEY (`Jornalista_num_carteira_profissional`) REFERENCES `jornalista` (`num_carteira_profissional`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `montado`
--
ALTER TABLE `montado`
  ADD CONSTRAINT `FK_Palco_montado_Tecnico` FOREIGN KEY (`Palco_Edicao_numero`,`Palco_codigo`) REFERENCES `palco` (`Edicao_numero`, `codigo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Tecnico_montado_Palco` FOREIGN KEY (`Tecnico_numero`) REFERENCES `tecnico` (`numero`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `palco`
--
ALTER TABLE `palco`
  ADD CONSTRAINT `FK_Palco_tem_Edicao` FOREIGN KEY (`Edicao_numero`) REFERENCES `edicao` (`numero`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `papel_no_grupo`
--
ALTER TABLE `papel_no_grupo`
  ADD CONSTRAINT `FK_Elemento_grupo_papel_no_grupo_Papel` FOREIGN KEY (`Elemento_grupo_Individual_Participante_codigo`,`Elemento_grupo_Grupo_Participante_codigo`) REFERENCES `elemento_grupo` (`Individual_Participante_codigo`, `Grupo_Participante_codigo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Papel_papel_no_grupo_Elemento_grupo` FOREIGN KEY (`Papel_codigo`) REFERENCES `papel` (`codigo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `participante`
--
ALTER TABLE `participante`
  ADD CONSTRAINT `FK_Individual_origem_Pais` FOREIGN KEY (`Pais_codigo`) REFERENCES `pais` (`codigo`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `reportagem`
--
ALTER TABLE `reportagem`
  ADD CONSTRAINT `FK_Dia_festival_Reportagem_Jornalista` FOREIGN KEY (`Dia_festival_data`) REFERENCES `dia_festival` (`data`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Jornalista_Reportagem_Dia_festival` FOREIGN KEY (`Jornalista_num_carteira_profissional`) REFERENCES `jornalista` (`num_carteira_profissional`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tecnico`
--
ALTER TABLE `tecnico`
  ADD CONSTRAINT `FK_Roadie_ligado_Participante` FOREIGN KEY (`Participante_codigo`) REFERENCES `participante` (`codigo`) ON UPDATE CASCADE;

--
-- Constraints for table `tema`
--
ALTER TABLE `tema`
  ADD CONSTRAINT `FK_Tema_enterpretado_Contrata` FOREIGN KEY (`Edicao_numero`,`Participante_codigo`) REFERENCES `contrata` (`Edicao_numero`, `Participante_codigo`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
