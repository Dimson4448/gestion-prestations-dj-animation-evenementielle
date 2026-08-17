/*M!999999\- enable the sandbox mode */
-- MariaDB dump 10.19-11.8.3-MariaDB, for Win64 (AMD64)
--
-- Host: 127.0.0.1    Database: ultimate_dj_django
-- ------------------------------------------------------
-- Server version	11.8.3-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `account_deletion_requests`
--

DROP TABLE IF EXISTS `account_deletion_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_deletion_requests` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `reason` longtext NOT NULL,
  `status` varchar(20) NOT NULL,
  `review_message` longtext NOT NULL,
  `requested_at` datetime(6) NOT NULL,
  `reviewed_at` datetime(6) DEFAULT NULL,
  `client_id` bigint(20) NOT NULL,
  `reviewed_by_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `account_deletion_req_client_id_e528c2c1_fk_client_pr` (`client_id`),
  KEY `account_deletion_req_reviewed_by_id_a5573f4b_fk_auth_user` (`reviewed_by_id`),
  CONSTRAINT `account_deletion_req_client_id_e528c2c1_fk_client_pr` FOREIGN KEY (`client_id`) REFERENCES `client_profiles` (`id`),
  CONSTRAINT `account_deletion_req_reviewed_by_id_a5573f4b_fk_auth_user` FOREIGN KEY (`reviewed_by_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_deletion_requests`
--

LOCK TABLES `account_deletion_requests` WRITE;
/*!40000 ALTER TABLE `account_deletion_requests` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `account_deletion_requests` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group_permissions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=129 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `auth_permission` VALUES
(1,'Can add log entry',1,'add_logentry'),
(2,'Can change log entry',1,'change_logentry'),
(3,'Can delete log entry',1,'delete_logentry'),
(4,'Can view log entry',1,'view_logentry'),
(5,'Can add permission',2,'add_permission'),
(6,'Can change permission',2,'change_permission'),
(7,'Can delete permission',2,'delete_permission'),
(8,'Can view permission',2,'view_permission'),
(9,'Can add group',3,'add_group'),
(10,'Can change group',3,'change_group'),
(11,'Can delete group',3,'delete_group'),
(12,'Can view group',3,'view_group'),
(13,'Can add user',4,'add_user'),
(14,'Can change user',4,'change_user'),
(15,'Can delete user',4,'delete_user'),
(16,'Can view user',4,'view_user'),
(17,'Can add content type',5,'add_contenttype'),
(18,'Can change content type',5,'change_contenttype'),
(19,'Can delete content type',5,'delete_contenttype'),
(20,'Can view content type',5,'view_contenttype'),
(21,'Can add session',6,'add_session'),
(22,'Can change session',6,'change_session'),
(23,'Can delete session',6,'delete_session'),
(24,'Can view session',6,'view_session'),
(25,'Can add profil client',7,'add_clientprofile'),
(26,'Can change profil client',7,'change_clientprofile'),
(27,'Can delete profil client',7,'delete_clientprofile'),
(28,'Can view profil client',7,'view_clientprofile'),
(29,'Can add profil DJ',8,'add_djprofile'),
(30,'Can change profil DJ',8,'change_djprofile'),
(31,'Can delete profil DJ',8,'delete_djprofile'),
(32,'Can view profil DJ',8,'view_djprofile'),
(33,'Can add type d\'événement',9,'add_eventtype'),
(34,'Can change type d\'événement',9,'change_eventtype'),
(35,'Can delete type d\'événement',9,'delete_eventtype'),
(36,'Can view type d\'événement',9,'view_eventtype'),
(37,'Can add style musical',10,'add_musicstyle'),
(38,'Can change style musical',10,'change_musicstyle'),
(39,'Can delete style musical',10,'delete_musicstyle'),
(40,'Can view style musical',10,'view_musicstyle'),
(41,'Can add package',11,'add_package'),
(42,'Can change package',11,'change_package'),
(43,'Can delete package',11,'delete_package'),
(44,'Can view package',11,'view_package'),
(45,'Can add option de service',12,'add_serviceoption'),
(46,'Can change option de service',12,'change_serviceoption'),
(47,'Can delete option de service',12,'delete_serviceoption'),
(48,'Can view option de service',12,'view_serviceoption'),
(49,'Can add matériel',13,'add_equipment'),
(50,'Can change matériel',13,'change_equipment'),
(51,'Can delete matériel',13,'delete_equipment'),
(52,'Can view matériel',13,'view_equipment'),
(53,'Can add créneau DJ',14,'add_djavailability'),
(54,'Can change créneau DJ',14,'change_djavailability'),
(55,'Can delete créneau DJ',14,'delete_djavailability'),
(56,'Can view créneau DJ',14,'view_djavailability'),
(57,'Can add réservation',15,'add_booking'),
(58,'Can change réservation',15,'change_booking'),
(59,'Can delete réservation',15,'delete_booking'),
(60,'Can view réservation',15,'view_booking'),
(61,'Can add playlist',16,'add_playlist'),
(62,'Can change playlist',16,'change_playlist'),
(63,'Can delete playlist',16,'delete_playlist'),
(64,'Can view playlist',16,'view_playlist'),
(65,'Can add chanson de playlist',17,'add_playlistsong'),
(66,'Can change chanson de playlist',17,'change_playlistsong'),
(67,'Can delete chanson de playlist',17,'delete_playlistsong'),
(68,'Can view chanson de playlist',17,'view_playlistsong'),
(69,'Can add devis',18,'add_quote'),
(70,'Can change devis',18,'change_quote'),
(71,'Can delete devis',18,'delete_quote'),
(72,'Can view devis',18,'view_quote'),
(73,'Can add lieu',19,'add_venue'),
(74,'Can change lieu',19,'change_venue'),
(75,'Can delete lieu',19,'delete_venue'),
(76,'Can view lieu',19,'view_venue'),
(77,'Can add matériel de réservation',20,'add_bookingequipment'),
(78,'Can change matériel de réservation',20,'change_bookingequipment'),
(79,'Can delete matériel de réservation',20,'delete_bookingequipment'),
(80,'Can view matériel de réservation',20,'view_bookingequipment'),
(81,'Can add contrat',21,'add_contract'),
(82,'Can change contrat',21,'change_contract'),
(83,'Can delete contrat',21,'delete_contract'),
(84,'Can view contrat',21,'view_contract'),
(85,'Can add rendez-vous préparatoire',22,'add_preparatoryappointment'),
(86,'Can change rendez-vous préparatoire',22,'change_preparatoryappointment'),
(87,'Can delete rendez-vous préparatoire',22,'delete_preparatoryappointment'),
(88,'Can view rendez-vous préparatoire',22,'view_preparatoryappointment'),
(89,'Can add option de devis',23,'add_quoteoption'),
(90,'Can change option de devis',23,'change_quoteoption'),
(91,'Can delete option de devis',23,'delete_quoteoption'),
(92,'Can view option de devis',23,'view_quoteoption'),
(93,'Can add avis client',24,'add_review'),
(94,'Can change avis client',24,'change_review'),
(95,'Can delete avis client',24,'delete_review'),
(96,'Can view avis client',24,'view_review'),
(97,'Can add facture',25,'add_invoice'),
(98,'Can change facture',25,'change_invoice'),
(99,'Can delete facture',25,'delete_invoice'),
(100,'Can view facture',25,'view_invoice'),
(101,'Can add paiement',26,'add_payment'),
(102,'Can change paiement',26,'change_payment'),
(103,'Can delete paiement',26,'delete_payment'),
(104,'Can view paiement',26,'view_payment'),
(105,'Can add remboursement',27,'add_refund'),
(106,'Can change remboursement',27,'change_refund'),
(107,'Can delete remboursement',27,'delete_refund'),
(108,'Can view remboursement',27,'view_refund'),
(109,'Can add demande d\'annulation',28,'add_cancellationrequest'),
(110,'Can change demande d\'annulation',28,'change_cancellationrequest'),
(111,'Can delete demande d\'annulation',28,'delete_cancellationrequest'),
(112,'Can view demande d\'annulation',28,'view_cancellationrequest'),
(113,'Can add Blacklisted Token',29,'add_blacklistedtoken'),
(114,'Can change Blacklisted Token',29,'change_blacklistedtoken'),
(115,'Can delete Blacklisted Token',29,'delete_blacklistedtoken'),
(116,'Can view Blacklisted Token',29,'view_blacklistedtoken'),
(117,'Can add Outstanding Token',30,'add_outstandingtoken'),
(118,'Can change Outstanding Token',30,'change_outstandingtoken'),
(119,'Can delete Outstanding Token',30,'delete_outstandingtoken'),
(120,'Can view Outstanding Token',30,'view_outstandingtoken'),
(121,'Can add demande de suppression de compte',31,'add_accountdeletionrequest'),
(122,'Can change demande de suppression de compte',31,'change_accountdeletionrequest'),
(123,'Can delete demande de suppression de compte',31,'delete_accountdeletionrequest'),
(124,'Can view demande de suppression de compte',31,'view_accountdeletionrequest'),
(125,'Can add candidature DJ',32,'add_djapplication'),
(126,'Can change candidature DJ',32,'change_djapplication'),
(127,'Can delete candidature DJ',32,'delete_djapplication'),
(128,'Can view candidature DJ',32,'view_djapplication');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `last_name` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=445 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `auth_user` VALUES
(223,'pbkdf2_sha256$1000000$dTE6A8uumr6ixt13XI4Q9y$+dgPwJgHeHsPOgfLJInIwauf0tYcO1fML/uBIncsaKc=',NULL,0,'client001@ultimate-dj.test','Vianney','Tchamako','client001@ultimate-dj.test',0,1,'2025-10-27 09:00:00.000000'),
(224,'pbkdf2_sha256$600000$client002$hashdemo',NULL,0,'client002@ultimate-dj.test','Sarah','Lambert','client002@ultimate-dj.test',0,1,'2025-10-28 09:00:00.000000'),
(225,'pbkdf2_sha256$600000$client003$hashdemo',NULL,0,'client003@ultimate-dj.test','Thomas','Benali','client003@ultimate-dj.test',0,1,'2025-10-29 09:00:00.000000'),
(226,'pbkdf2_sha256$600000$client004$hashdemo',NULL,0,'client004@ultimate-dj.test','Laura','Moreau','client004@ultimate-dj.test',0,1,'2025-10-30 09:00:00.000000'),
(227,'pbkdf2_sha256$600000$client005$hashdemo',NULL,0,'client005@ultimate-dj.test','Nicolas','Diallo','client005@ultimate-dj.test',0,1,'2025-10-31 09:00:00.000000'),
(228,'pbkdf2_sha256$600000$client006$hashdemo',NULL,0,'client006@ultimate-dj.test','Amina','Willems','client006@ultimate-dj.test',0,1,'2025-11-01 09:00:00.000000'),
(229,'pbkdf2_sha256$600000$client007$hashdemo',NULL,0,'client007@ultimate-dj.test','Julien','Mertens','client007@ultimate-dj.test',0,1,'2025-11-02 09:00:00.000000'),
(230,'pbkdf2_sha256$600000$client008$hashdemo',NULL,0,'client008@ultimate-dj.test','Camille','Dubois','client008@ultimate-dj.test',0,1,'2025-11-03 09:00:00.000000'),
(231,'pbkdf2_sha256$600000$client009$hashdemo',NULL,0,'client009@ultimate-dj.test','Youssef','Janssens','client009@ultimate-dj.test',0,1,'2025-11-04 09:00:00.000000'),
(232,'pbkdf2_sha256$600000$client010$hashdemo',NULL,0,'client010@ultimate-dj.test','Marie','Leroy','client010@ultimate-dj.test',0,1,'2025-11-05 09:00:00.000000'),
(233,'pbkdf2_sha256$600000$client011$hashdemo',NULL,0,'client011@ultimate-dj.test','Antoine','Leclercq','client011@ultimate-dj.test',0,1,'2025-11-06 09:00:00.000000'),
(234,'pbkdf2_sha256$600000$client012$hashdemo',NULL,0,'client012@ultimate-dj.test','Sophie','Simon','client012@ultimate-dj.test',0,1,'2025-11-07 09:00:00.000000'),
(235,'pbkdf2_sha256$600000$client013$hashdemo',NULL,0,'client013@ultimate-dj.test','Mehdi','Petit','client013@ultimate-dj.test',0,1,'2025-11-08 09:00:00.000000'),
(236,'pbkdf2_sha256$600000$client014$hashdemo',NULL,0,'client014@ultimate-dj.test','Nadia','Vermeulen','client014@ultimate-dj.test',0,1,'2025-11-09 09:00:00.000000'),
(237,'pbkdf2_sha256$600000$client015$hashdemo',NULL,0,'client015@ultimate-dj.test','Lucas','Peeters','client015@ultimate-dj.test',0,1,'2025-11-10 09:00:00.000000'),
(238,'pbkdf2_sha256$600000$client016$hashdemo',NULL,0,'client016@ultimate-dj.test','Emma','Martin','client016@ultimate-dj.test',0,1,'2025-11-11 09:00:00.000000'),
(239,'pbkdf2_sha256$600000$client017$hashdemo',NULL,0,'client017@ultimate-dj.test','Hugo','De Smet','client017@ultimate-dj.test',0,1,'2025-11-12 09:00:00.000000'),
(240,'pbkdf2_sha256$600000$client018$hashdemo',NULL,0,'client018@ultimate-dj.test','Ines','Nguyen','client018@ultimate-dj.test',0,1,'2025-11-13 09:00:00.000000'),
(241,'pbkdf2_sha256$600000$client019$hashdemo',NULL,0,'client019@ultimate-dj.test','Simon','Laurent','client019@ultimate-dj.test',0,1,'2025-11-14 09:00:00.000000'),
(242,'pbkdf2_sha256$600000$client020$hashdemo',NULL,0,'client020@ultimate-dj.test','Elise','Fontaine','client020@ultimate-dj.test',0,1,'2025-11-15 09:00:00.000000'),
(243,'pbkdf2_sha256$600000$client021$hashdemo',NULL,0,'client021@ultimate-dj.test','Maxime','Tchamako','client021@ultimate-dj.test',0,1,'2025-11-16 09:00:00.000000'),
(244,'pbkdf2_sha256$600000$client022$hashdemo',NULL,0,'client022@ultimate-dj.test','Chloe','Lambert','client022@ultimate-dj.test',0,1,'2025-11-17 09:00:00.000000'),
(245,'pbkdf2_sha256$600000$client023$hashdemo',NULL,0,'client023@ultimate-dj.test','Romain','Benali','client023@ultimate-dj.test',0,1,'2025-11-18 09:00:00.000000'),
(246,'pbkdf2_sha256$600000$client024$hashdemo',NULL,0,'client024@ultimate-dj.test','Lina','Moreau','client024@ultimate-dj.test',0,1,'2025-11-19 09:00:00.000000'),
(247,'pbkdf2_sha256$600000$client025$hashdemo',NULL,0,'client025@ultimate-dj.test','Adrien','Diallo','client025@ultimate-dj.test',0,1,'2025-11-20 09:00:00.000000'),
(248,'pbkdf2_sha256$600000$client026$hashdemo',NULL,0,'client026@ultimate-dj.test','Maya','Willems','client026@ultimate-dj.test',0,1,'2025-11-21 09:00:00.000000'),
(249,'pbkdf2_sha256$600000$client027$hashdemo',NULL,0,'client027@ultimate-dj.test','Karim','Mertens','client027@ultimate-dj.test',0,1,'2025-11-22 09:00:00.000000'),
(250,'pbkdf2_sha256$600000$client028$hashdemo',NULL,0,'client028@ultimate-dj.test','Julie','Dubois','client028@ultimate-dj.test',0,1,'2025-11-23 09:00:00.000000'),
(251,'pbkdf2_sha256$600000$client029$hashdemo',NULL,0,'client029@ultimate-dj.test','Kevin','Janssens','client029@ultimate-dj.test',0,1,'2025-11-24 09:00:00.000000'),
(252,'pbkdf2_sha256$600000$client030$hashdemo',NULL,0,'client030@ultimate-dj.test','Noemie','Leroy','client030@ultimate-dj.test',0,1,'2025-11-25 09:00:00.000000'),
(253,'pbkdf2_sha256$600000$client031$hashdemo',NULL,0,'client031@ultimate-dj.test','Vianney','Leclercq','client031@ultimate-dj.test',0,1,'2025-11-26 09:00:00.000000'),
(254,'pbkdf2_sha256$600000$client032$hashdemo',NULL,0,'client032@ultimate-dj.test','Sarah','Simon','client032@ultimate-dj.test',0,1,'2025-11-27 09:00:00.000000'),
(255,'pbkdf2_sha256$600000$client033$hashdemo',NULL,0,'client033@ultimate-dj.test','Thomas','Petit','client033@ultimate-dj.test',0,1,'2025-11-28 09:00:00.000000'),
(256,'pbkdf2_sha256$600000$client034$hashdemo',NULL,0,'client034@ultimate-dj.test','Laura','Vermeulen','client034@ultimate-dj.test',0,1,'2025-11-29 09:00:00.000000'),
(257,'pbkdf2_sha256$600000$client035$hashdemo',NULL,0,'client035@ultimate-dj.test','Nicolas','Peeters','client035@ultimate-dj.test',0,1,'2025-11-30 09:00:00.000000'),
(258,'pbkdf2_sha256$600000$client036$hashdemo',NULL,0,'client036@ultimate-dj.test','Amina','Martin','client036@ultimate-dj.test',0,1,'2025-12-01 09:00:00.000000'),
(259,'pbkdf2_sha256$600000$client037$hashdemo',NULL,0,'client037@ultimate-dj.test','Julien','De Smet','client037@ultimate-dj.test',0,1,'2025-12-02 09:00:00.000000'),
(260,'pbkdf2_sha256$600000$client038$hashdemo',NULL,0,'client038@ultimate-dj.test','Camille','Nguyen','client038@ultimate-dj.test',0,1,'2025-12-03 09:00:00.000000'),
(261,'pbkdf2_sha256$600000$client039$hashdemo',NULL,0,'client039@ultimate-dj.test','Youssef','Laurent','client039@ultimate-dj.test',0,1,'2025-12-04 09:00:00.000000'),
(262,'pbkdf2_sha256$600000$client040$hashdemo',NULL,0,'client040@ultimate-dj.test','Marie','Fontaine','client040@ultimate-dj.test',0,1,'2025-12-05 09:00:00.000000'),
(263,'pbkdf2_sha256$600000$client041$hashdemo',NULL,0,'client041@ultimate-dj.test','Antoine','Tchamako','client041@ultimate-dj.test',0,1,'2025-12-06 09:00:00.000000'),
(264,'pbkdf2_sha256$600000$client042$hashdemo',NULL,0,'client042@ultimate-dj.test','Sophie','Lambert','client042@ultimate-dj.test',0,1,'2025-12-07 09:00:00.000000'),
(265,'pbkdf2_sha256$600000$client043$hashdemo',NULL,0,'client043@ultimate-dj.test','Mehdi','Benali','client043@ultimate-dj.test',0,1,'2025-12-08 09:00:00.000000'),
(266,'pbkdf2_sha256$600000$client044$hashdemo',NULL,0,'client044@ultimate-dj.test','Nadia','Moreau','client044@ultimate-dj.test',0,1,'2025-12-09 09:00:00.000000'),
(267,'pbkdf2_sha256$600000$client045$hashdemo',NULL,0,'client045@ultimate-dj.test','Lucas','Diallo','client045@ultimate-dj.test',0,1,'2025-12-10 09:00:00.000000'),
(268,'pbkdf2_sha256$600000$client046$hashdemo',NULL,0,'client046@ultimate-dj.test','Emma','Willems','client046@ultimate-dj.test',0,1,'2025-12-11 09:00:00.000000'),
(269,'pbkdf2_sha256$600000$client047$hashdemo',NULL,0,'client047@ultimate-dj.test','Hugo','Mertens','client047@ultimate-dj.test',0,1,'2025-12-12 09:00:00.000000'),
(270,'pbkdf2_sha256$600000$client048$hashdemo',NULL,0,'client048@ultimate-dj.test','Ines','Dubois','client048@ultimate-dj.test',0,1,'2025-12-13 09:00:00.000000'),
(271,'pbkdf2_sha256$600000$client049$hashdemo',NULL,0,'client049@ultimate-dj.test','Simon','Janssens','client049@ultimate-dj.test',0,1,'2025-12-14 09:00:00.000000'),
(272,'pbkdf2_sha256$600000$client050$hashdemo',NULL,0,'client050@ultimate-dj.test','Elise','Leroy','client050@ultimate-dj.test',0,1,'2025-12-15 09:00:00.000000'),
(273,'pbkdf2_sha256$600000$client051$hashdemo',NULL,0,'client051@ultimate-dj.test','Maxime','Leclercq','client051@ultimate-dj.test',0,1,'2025-12-16 09:00:00.000000'),
(274,'pbkdf2_sha256$600000$client052$hashdemo',NULL,0,'client052@ultimate-dj.test','Chloe','Simon','client052@ultimate-dj.test',0,1,'2025-12-17 09:00:00.000000'),
(275,'pbkdf2_sha256$600000$client053$hashdemo',NULL,0,'client053@ultimate-dj.test','Romain','Petit','client053@ultimate-dj.test',0,1,'2025-12-18 09:00:00.000000'),
(276,'pbkdf2_sha256$600000$client054$hashdemo',NULL,0,'client054@ultimate-dj.test','Lina','Vermeulen','client054@ultimate-dj.test',0,1,'2025-12-19 09:00:00.000000'),
(277,'pbkdf2_sha256$600000$client055$hashdemo',NULL,0,'client055@ultimate-dj.test','Adrien','Peeters','client055@ultimate-dj.test',0,1,'2025-12-20 09:00:00.000000'),
(278,'pbkdf2_sha256$600000$client056$hashdemo',NULL,0,'client056@ultimate-dj.test','Maya','Martin','client056@ultimate-dj.test',0,1,'2025-12-21 09:00:00.000000'),
(279,'pbkdf2_sha256$600000$client057$hashdemo',NULL,0,'client057@ultimate-dj.test','Karim','De Smet','client057@ultimate-dj.test',0,1,'2025-12-22 09:00:00.000000'),
(280,'pbkdf2_sha256$600000$client058$hashdemo',NULL,0,'client058@ultimate-dj.test','Julie','Nguyen','client058@ultimate-dj.test',0,1,'2025-12-23 09:00:00.000000'),
(281,'pbkdf2_sha256$600000$client059$hashdemo',NULL,0,'client059@ultimate-dj.test','Kevin','Laurent','client059@ultimate-dj.test',0,1,'2025-12-24 09:00:00.000000'),
(282,'pbkdf2_sha256$600000$client060$hashdemo',NULL,0,'client060@ultimate-dj.test','Noemie','Fontaine','client060@ultimate-dj.test',0,1,'2025-12-25 09:00:00.000000'),
(283,'pbkdf2_sha256$600000$client061$hashdemo',NULL,0,'client061@ultimate-dj.test','Vianney','Tchamako','client061@ultimate-dj.test',0,1,'2025-12-26 09:00:00.000000'),
(284,'pbkdf2_sha256$600000$client062$hashdemo',NULL,0,'client062@ultimate-dj.test','Sarah','Lambert','client062@ultimate-dj.test',0,1,'2025-12-27 09:00:00.000000'),
(285,'pbkdf2_sha256$600000$client063$hashdemo',NULL,0,'client063@ultimate-dj.test','Thomas','Benali','client063@ultimate-dj.test',0,1,'2025-12-28 09:00:00.000000'),
(286,'pbkdf2_sha256$600000$client064$hashdemo',NULL,0,'client064@ultimate-dj.test','Laura','Moreau','client064@ultimate-dj.test',0,1,'2025-12-29 09:00:00.000000'),
(287,'pbkdf2_sha256$600000$client065$hashdemo',NULL,0,'client065@ultimate-dj.test','Nicolas','Diallo','client065@ultimate-dj.test',0,1,'2025-12-30 09:00:00.000000'),
(288,'pbkdf2_sha256$600000$client066$hashdemo',NULL,0,'client066@ultimate-dj.test','Amina','Willems','client066@ultimate-dj.test',0,1,'2025-12-31 09:00:00.000000'),
(289,'pbkdf2_sha256$600000$client067$hashdemo',NULL,0,'client067@ultimate-dj.test','Julien','Mertens','client067@ultimate-dj.test',0,1,'2026-01-01 09:00:00.000000'),
(290,'pbkdf2_sha256$600000$client068$hashdemo',NULL,0,'client068@ultimate-dj.test','Camille','Dubois','client068@ultimate-dj.test',0,1,'2026-01-02 09:00:00.000000'),
(291,'pbkdf2_sha256$600000$client069$hashdemo',NULL,0,'client069@ultimate-dj.test','Youssef','Janssens','client069@ultimate-dj.test',0,1,'2026-01-03 09:00:00.000000'),
(292,'pbkdf2_sha256$600000$client070$hashdemo',NULL,0,'client070@ultimate-dj.test','Marie','Leroy','client070@ultimate-dj.test',0,1,'2026-01-04 09:00:00.000000'),
(293,'pbkdf2_sha256$600000$client071$hashdemo',NULL,0,'client071@ultimate-dj.test','Antoine','Leclercq','client071@ultimate-dj.test',0,1,'2026-01-05 09:00:00.000000'),
(294,'pbkdf2_sha256$600000$client072$hashdemo',NULL,0,'client072@ultimate-dj.test','Sophie','Simon','client072@ultimate-dj.test',0,1,'2026-01-06 09:00:00.000000'),
(295,'pbkdf2_sha256$600000$client073$hashdemo',NULL,0,'client073@ultimate-dj.test','Mehdi','Petit','client073@ultimate-dj.test',0,1,'2026-01-07 09:00:00.000000'),
(296,'pbkdf2_sha256$600000$client074$hashdemo',NULL,0,'client074@ultimate-dj.test','Nadia','Vermeulen','client074@ultimate-dj.test',0,1,'2026-01-08 09:00:00.000000'),
(297,'pbkdf2_sha256$600000$client075$hashdemo',NULL,0,'client075@ultimate-dj.test','Lucas','Peeters','client075@ultimate-dj.test',0,1,'2026-01-09 09:00:00.000000'),
(298,'pbkdf2_sha256$600000$client076$hashdemo',NULL,0,'client076@ultimate-dj.test','Emma','Martin','client076@ultimate-dj.test',0,1,'2026-01-10 09:00:00.000000'),
(299,'pbkdf2_sha256$600000$client077$hashdemo',NULL,0,'client077@ultimate-dj.test','Hugo','De Smet','client077@ultimate-dj.test',0,1,'2026-01-11 09:00:00.000000'),
(300,'pbkdf2_sha256$600000$client078$hashdemo',NULL,0,'client078@ultimate-dj.test','Ines','Nguyen','client078@ultimate-dj.test',0,1,'2026-01-12 09:00:00.000000'),
(301,'pbkdf2_sha256$600000$client079$hashdemo',NULL,0,'client079@ultimate-dj.test','Simon','Laurent','client079@ultimate-dj.test',0,1,'2026-01-13 09:00:00.000000'),
(302,'pbkdf2_sha256$600000$client080$hashdemo',NULL,0,'client080@ultimate-dj.test','Elise','Fontaine','client080@ultimate-dj.test',0,1,'2026-01-14 09:00:00.000000'),
(303,'pbkdf2_sha256$600000$client081$hashdemo',NULL,0,'client081@ultimate-dj.test','Maxime','Tchamako','client081@ultimate-dj.test',0,1,'2026-01-15 09:00:00.000000'),
(304,'pbkdf2_sha256$600000$client082$hashdemo',NULL,0,'client082@ultimate-dj.test','Chloe','Lambert','client082@ultimate-dj.test',0,1,'2026-01-16 09:00:00.000000'),
(305,'pbkdf2_sha256$600000$client083$hashdemo',NULL,0,'client083@ultimate-dj.test','Romain','Benali','client083@ultimate-dj.test',0,1,'2026-01-17 09:00:00.000000'),
(306,'pbkdf2_sha256$600000$client084$hashdemo',NULL,0,'client084@ultimate-dj.test','Lina','Moreau','client084@ultimate-dj.test',0,1,'2026-01-18 09:00:00.000000'),
(307,'pbkdf2_sha256$600000$client085$hashdemo',NULL,0,'client085@ultimate-dj.test','Adrien','Diallo','client085@ultimate-dj.test',0,1,'2026-01-19 09:00:00.000000'),
(308,'pbkdf2_sha256$600000$client086$hashdemo',NULL,0,'client086@ultimate-dj.test','Maya','Willems','client086@ultimate-dj.test',0,1,'2026-01-20 09:00:00.000000'),
(309,'pbkdf2_sha256$600000$client087$hashdemo',NULL,0,'client087@ultimate-dj.test','Karim','Mertens','client087@ultimate-dj.test',0,1,'2026-01-21 09:00:00.000000'),
(310,'pbkdf2_sha256$600000$client088$hashdemo',NULL,0,'client088@ultimate-dj.test','Julie','Dubois','client088@ultimate-dj.test',0,1,'2026-01-22 09:00:00.000000'),
(311,'pbkdf2_sha256$600000$client089$hashdemo',NULL,0,'client089@ultimate-dj.test','Kevin','Janssens','client089@ultimate-dj.test',0,1,'2026-01-23 09:00:00.000000'),
(312,'pbkdf2_sha256$600000$client090$hashdemo',NULL,0,'client090@ultimate-dj.test','Noemie','Leroy','client090@ultimate-dj.test',0,1,'2026-01-24 09:00:00.000000'),
(313,'pbkdf2_sha256$600000$client091$hashdemo',NULL,0,'client091@ultimate-dj.test','Vianney','Leclercq','client091@ultimate-dj.test',0,1,'2026-01-25 09:00:00.000000'),
(314,'pbkdf2_sha256$600000$client092$hashdemo',NULL,0,'client092@ultimate-dj.test','Sarah','Simon','client092@ultimate-dj.test',0,1,'2026-01-26 09:00:00.000000'),
(315,'pbkdf2_sha256$600000$client093$hashdemo',NULL,0,'client093@ultimate-dj.test','Thomas','Petit','client093@ultimate-dj.test',0,1,'2026-01-27 09:00:00.000000'),
(316,'pbkdf2_sha256$600000$client094$hashdemo',NULL,0,'client094@ultimate-dj.test','Laura','Vermeulen','client094@ultimate-dj.test',0,1,'2026-01-28 09:00:00.000000'),
(317,'pbkdf2_sha256$600000$client095$hashdemo',NULL,0,'client095@ultimate-dj.test','Nicolas','Peeters','client095@ultimate-dj.test',0,1,'2026-01-29 09:00:00.000000'),
(318,'pbkdf2_sha256$600000$client096$hashdemo',NULL,0,'client096@ultimate-dj.test','Amina','Martin','client096@ultimate-dj.test',0,1,'2026-01-30 09:00:00.000000'),
(319,'pbkdf2_sha256$600000$client097$hashdemo',NULL,0,'client097@ultimate-dj.test','Julien','De Smet','client097@ultimate-dj.test',0,1,'2026-01-31 09:00:00.000000'),
(320,'pbkdf2_sha256$600000$client098$hashdemo',NULL,0,'client098@ultimate-dj.test','Camille','Nguyen','client098@ultimate-dj.test',0,1,'2026-02-01 09:00:00.000000'),
(321,'pbkdf2_sha256$600000$client099$hashdemo',NULL,0,'client099@ultimate-dj.test','Youssef','Laurent','client099@ultimate-dj.test',0,1,'2026-02-02 09:00:00.000000'),
(322,'pbkdf2_sha256$600000$client100$hashdemo',NULL,0,'client100@ultimate-dj.test','Marie','Fontaine','client100@ultimate-dj.test',0,1,'2026-02-03 09:00:00.000000'),
(323,'pbkdf2_sha256$600000$client101$hashdemo',NULL,0,'client101@ultimate-dj.test','Antoine','Tchamako','client101@ultimate-dj.test',0,1,'2026-02-04 09:00:00.000000'),
(324,'pbkdf2_sha256$600000$client102$hashdemo',NULL,0,'client102@ultimate-dj.test','Sophie','Lambert','client102@ultimate-dj.test',0,1,'2026-02-05 09:00:00.000000'),
(325,'pbkdf2_sha256$600000$client103$hashdemo',NULL,0,'client103@ultimate-dj.test','Mehdi','Benali','client103@ultimate-dj.test',0,1,'2026-02-06 09:00:00.000000'),
(326,'pbkdf2_sha256$600000$client104$hashdemo',NULL,0,'client104@ultimate-dj.test','Nadia','Moreau','client104@ultimate-dj.test',0,1,'2026-02-07 09:00:00.000000'),
(327,'pbkdf2_sha256$600000$client105$hashdemo',NULL,0,'client105@ultimate-dj.test','Lucas','Diallo','client105@ultimate-dj.test',0,1,'2026-02-08 09:00:00.000000'),
(328,'pbkdf2_sha256$600000$client106$hashdemo',NULL,0,'client106@ultimate-dj.test','Emma','Willems','client106@ultimate-dj.test',0,1,'2026-02-09 09:00:00.000000'),
(329,'pbkdf2_sha256$600000$client107$hashdemo',NULL,0,'client107@ultimate-dj.test','Hugo','Mertens','client107@ultimate-dj.test',0,1,'2026-02-10 09:00:00.000000'),
(330,'pbkdf2_sha256$600000$client108$hashdemo',NULL,0,'client108@ultimate-dj.test','Ines','Dubois','client108@ultimate-dj.test',0,1,'2026-02-11 09:00:00.000000'),
(331,'pbkdf2_sha256$600000$client109$hashdemo',NULL,0,'client109@ultimate-dj.test','Simon','Janssens','client109@ultimate-dj.test',0,1,'2026-02-12 09:00:00.000000'),
(332,'pbkdf2_sha256$600000$client110$hashdemo',NULL,0,'client110@ultimate-dj.test','Elise','Leroy','client110@ultimate-dj.test',0,1,'2026-02-13 09:00:00.000000'),
(333,'pbkdf2_sha256$600000$client111$hashdemo',NULL,0,'client111@ultimate-dj.test','Maxime','Leclercq','client111@ultimate-dj.test',0,1,'2026-02-14 09:00:00.000000'),
(334,'pbkdf2_sha256$600000$client112$hashdemo',NULL,0,'client112@ultimate-dj.test','Chloe','Simon','client112@ultimate-dj.test',0,1,'2026-02-15 09:00:00.000000'),
(335,'pbkdf2_sha256$600000$client113$hashdemo',NULL,0,'client113@ultimate-dj.test','Romain','Petit','client113@ultimate-dj.test',0,1,'2026-02-16 09:00:00.000000'),
(336,'pbkdf2_sha256$600000$client114$hashdemo',NULL,0,'client114@ultimate-dj.test','Lina','Vermeulen','client114@ultimate-dj.test',0,1,'2026-02-17 09:00:00.000000'),
(337,'pbkdf2_sha256$600000$client115$hashdemo',NULL,0,'client115@ultimate-dj.test','Adrien','Peeters','client115@ultimate-dj.test',0,1,'2026-02-18 09:00:00.000000'),
(338,'pbkdf2_sha256$600000$client116$hashdemo',NULL,0,'client116@ultimate-dj.test','Maya','Martin','client116@ultimate-dj.test',0,1,'2026-02-19 09:00:00.000000'),
(339,'pbkdf2_sha256$600000$client117$hashdemo',NULL,0,'client117@ultimate-dj.test','Karim','De Smet','client117@ultimate-dj.test',0,1,'2026-02-20 09:00:00.000000'),
(340,'pbkdf2_sha256$600000$client118$hashdemo',NULL,0,'client118@ultimate-dj.test','Julie','Nguyen','client118@ultimate-dj.test',0,1,'2026-02-21 09:00:00.000000'),
(341,'pbkdf2_sha256$600000$client119$hashdemo',NULL,0,'client119@ultimate-dj.test','Kevin','Laurent','client119@ultimate-dj.test',0,1,'2026-02-22 09:00:00.000000'),
(342,'pbkdf2_sha256$600000$client120$hashdemo',NULL,0,'client120@ultimate-dj.test','Noemie','Fontaine','client120@ultimate-dj.test',0,1,'2026-02-23 09:00:00.000000'),
(343,'pbkdf2_sha256$600000$dj121$hashdemo',NULL,0,'dj121@ultimate-dj.test','Camille','Peeters','dj121@ultimate-dj.test',0,1,'2026-01-05 09:00:00.000000'),
(344,'pbkdf2_sha256$600000$dj122$hashdemo',NULL,0,'dj122@ultimate-dj.test','Youssef','Leroy','dj122@ultimate-dj.test',0,1,'2026-01-06 09:00:00.000000'),
(345,'pbkdf2_sha256$600000$dj123$hashdemo',NULL,0,'dj123@ultimate-dj.test','Marie','Diallo','dj123@ultimate-dj.test',0,1,'2026-01-07 09:00:00.000000'),
(346,'pbkdf2_sha256$600000$dj124$hashdemo',NULL,0,'dj124@ultimate-dj.test','Antoine','Fontaine','dj124@ultimate-dj.test',0,1,'2026-01-08 09:00:00.000000'),
(347,'pbkdf2_sha256$600000$dj125$hashdemo',NULL,0,'dj125@ultimate-dj.test','Sophie','Peeters','dj125@ultimate-dj.test',0,1,'2026-01-09 09:00:00.000000'),
(348,'pbkdf2_sha256$600000$dj126$hashdemo',NULL,0,'dj126@ultimate-dj.test','Mehdi','Leroy','dj126@ultimate-dj.test',0,1,'2026-01-10 09:00:00.000000'),
(349,'pbkdf2_sha256$600000$dj127$hashdemo',NULL,0,'dj127@ultimate-dj.test','Nadia','Diallo','dj127@ultimate-dj.test',0,1,'2026-01-11 09:00:00.000000'),
(350,'pbkdf2_sha256$600000$dj128$hashdemo',NULL,0,'dj128@ultimate-dj.test','Lucas','Fontaine','dj128@ultimate-dj.test',0,1,'2026-01-12 09:00:00.000000'),
(351,'pbkdf2_sha256$600000$dj129$hashdemo',NULL,0,'dj129@ultimate-dj.test','Emma','Peeters','dj129@ultimate-dj.test',0,1,'2026-01-13 09:00:00.000000'),
(352,'pbkdf2_sha256$600000$dj130$hashdemo',NULL,0,'dj130@ultimate-dj.test','Hugo','Leroy','dj130@ultimate-dj.test',0,1,'2026-01-14 09:00:00.000000'),
(353,'pbkdf2_sha256$600000$dj131$hashdemo',NULL,0,'dj131@ultimate-dj.test','Ines','Diallo','dj131@ultimate-dj.test',0,1,'2026-01-15 09:00:00.000000'),
(354,'pbkdf2_sha256$600000$dj132$hashdemo',NULL,0,'dj132@ultimate-dj.test','Simon','Fontaine','dj132@ultimate-dj.test',0,1,'2026-01-16 09:00:00.000000'),
(355,'pbkdf2_sha256$600000$dj133$hashdemo',NULL,0,'dj133@ultimate-dj.test','Elise','Peeters','dj133@ultimate-dj.test',0,1,'2026-01-17 09:00:00.000000'),
(356,'pbkdf2_sha256$600000$dj134$hashdemo',NULL,0,'dj134@ultimate-dj.test','Maxime','Leroy','dj134@ultimate-dj.test',0,1,'2026-01-18 09:00:00.000000'),
(357,'pbkdf2_sha256$600000$dj135$hashdemo',NULL,0,'dj135@ultimate-dj.test','Chloe','Diallo','dj135@ultimate-dj.test',0,1,'2026-01-19 09:00:00.000000'),
(358,'pbkdf2_sha256$600000$dj136$hashdemo',NULL,0,'dj136@ultimate-dj.test','Romain','Fontaine','dj136@ultimate-dj.test',0,1,'2026-01-20 09:00:00.000000'),
(359,'pbkdf2_sha256$600000$dj137$hashdemo',NULL,0,'dj137@ultimate-dj.test','Lina','Peeters','dj137@ultimate-dj.test',0,1,'2026-01-21 09:00:00.000000'),
(360,'pbkdf2_sha256$600000$dj138$hashdemo',NULL,0,'dj138@ultimate-dj.test','Adrien','Leroy','dj138@ultimate-dj.test',0,1,'2026-01-22 09:00:00.000000'),
(361,'pbkdf2_sha256$600000$dj139$hashdemo',NULL,0,'dj139@ultimate-dj.test','Maya','Diallo','dj139@ultimate-dj.test',0,1,'2026-01-23 09:00:00.000000'),
(362,'pbkdf2_sha256$600000$dj140$hashdemo',NULL,0,'dj140@ultimate-dj.test','Karim','Fontaine','dj140@ultimate-dj.test',0,1,'2026-01-24 09:00:00.000000'),
(363,'pbkdf2_sha256$600000$dj141$hashdemo',NULL,0,'dj141@ultimate-dj.test','Julie','Peeters','dj141@ultimate-dj.test',0,1,'2026-01-25 09:00:00.000000'),
(364,'pbkdf2_sha256$600000$dj142$hashdemo',NULL,0,'dj142@ultimate-dj.test','Kevin','Leroy','dj142@ultimate-dj.test',0,1,'2026-01-26 09:00:00.000000'),
(365,'pbkdf2_sha256$600000$dj143$hashdemo',NULL,0,'dj143@ultimate-dj.test','Noemie','Diallo','dj143@ultimate-dj.test',0,1,'2026-01-27 09:00:00.000000'),
(366,'pbkdf2_sha256$600000$dj144$hashdemo',NULL,0,'dj144@ultimate-dj.test','Vianney','Fontaine','dj144@ultimate-dj.test',0,1,'2026-01-28 09:00:00.000000'),
(367,'pbkdf2_sha256$600000$dj145$hashdemo',NULL,0,'dj145@ultimate-dj.test','Sarah','Peeters','dj145@ultimate-dj.test',0,1,'2026-01-29 09:00:00.000000'),
(368,'pbkdf2_sha256$600000$dj146$hashdemo',NULL,0,'dj146@ultimate-dj.test','Thomas','Leroy','dj146@ultimate-dj.test',0,1,'2026-01-30 09:00:00.000000'),
(369,'pbkdf2_sha256$600000$dj147$hashdemo',NULL,0,'dj147@ultimate-dj.test','Laura','Diallo','dj147@ultimate-dj.test',0,1,'2026-01-31 09:00:00.000000'),
(370,'pbkdf2_sha256$600000$dj148$hashdemo',NULL,0,'dj148@ultimate-dj.test','Nicolas','Fontaine','dj148@ultimate-dj.test',0,1,'2026-02-01 09:00:00.000000'),
(371,'pbkdf2_sha256$600000$dj149$hashdemo',NULL,0,'dj149@ultimate-dj.test','Amina','Peeters','dj149@ultimate-dj.test',0,1,'2026-02-02 09:00:00.000000'),
(372,'pbkdf2_sha256$600000$dj150$hashdemo',NULL,0,'dj150@ultimate-dj.test','Julien','Leroy','dj150@ultimate-dj.test',0,1,'2026-02-03 09:00:00.000000'),
(373,'pbkdf2_sha256$600000$dj151$hashdemo',NULL,0,'dj151@ultimate-dj.test','Camille','Diallo','dj151@ultimate-dj.test',0,1,'2026-02-04 09:00:00.000000'),
(374,'pbkdf2_sha256$600000$dj152$hashdemo',NULL,0,'dj152@ultimate-dj.test','Youssef','Fontaine','dj152@ultimate-dj.test',0,1,'2026-02-05 09:00:00.000000'),
(375,'pbkdf2_sha256$600000$dj153$hashdemo',NULL,0,'dj153@ultimate-dj.test','Marie','Peeters','dj153@ultimate-dj.test',0,1,'2026-02-06 09:00:00.000000'),
(376,'pbkdf2_sha256$600000$dj154$hashdemo',NULL,0,'dj154@ultimate-dj.test','Antoine','Leroy','dj154@ultimate-dj.test',0,1,'2026-02-07 09:00:00.000000'),
(377,'pbkdf2_sha256$600000$dj155$hashdemo',NULL,0,'dj155@ultimate-dj.test','Sophie','Diallo','dj155@ultimate-dj.test',0,1,'2026-02-08 09:00:00.000000'),
(378,'pbkdf2_sha256$600000$dj156$hashdemo',NULL,0,'dj156@ultimate-dj.test','Mehdi','Fontaine','dj156@ultimate-dj.test',0,1,'2026-02-09 09:00:00.000000'),
(379,'pbkdf2_sha256$600000$dj157$hashdemo',NULL,0,'dj157@ultimate-dj.test','Nadia','Peeters','dj157@ultimate-dj.test',0,1,'2026-02-10 09:00:00.000000'),
(380,'pbkdf2_sha256$600000$dj158$hashdemo',NULL,0,'dj158@ultimate-dj.test','Lucas','Leroy','dj158@ultimate-dj.test',0,1,'2026-02-11 09:00:00.000000'),
(381,'pbkdf2_sha256$600000$dj159$hashdemo',NULL,0,'dj159@ultimate-dj.test','Emma','Diallo','dj159@ultimate-dj.test',0,1,'2026-02-12 09:00:00.000000'),
(382,'pbkdf2_sha256$600000$dj160$hashdemo',NULL,0,'dj160@ultimate-dj.test','Hugo','Fontaine','dj160@ultimate-dj.test',0,1,'2026-02-13 09:00:00.000000'),
(383,'pbkdf2_sha256$600000$dj161$hashdemo',NULL,0,'dj161@ultimate-dj.test','Ines','Peeters','dj161@ultimate-dj.test',0,1,'2026-02-14 09:00:00.000000'),
(384,'pbkdf2_sha256$600000$dj162$hashdemo',NULL,0,'dj162@ultimate-dj.test','Simon','Leroy','dj162@ultimate-dj.test',0,1,'2026-02-15 09:00:00.000000'),
(385,'pbkdf2_sha256$600000$dj163$hashdemo',NULL,0,'dj163@ultimate-dj.test','Elise','Diallo','dj163@ultimate-dj.test',0,1,'2026-02-16 09:00:00.000000'),
(386,'pbkdf2_sha256$600000$dj164$hashdemo',NULL,0,'dj164@ultimate-dj.test','Maxime','Fontaine','dj164@ultimate-dj.test',0,1,'2026-02-17 09:00:00.000000'),
(387,'pbkdf2_sha256$600000$dj165$hashdemo',NULL,0,'dj165@ultimate-dj.test','Chloe','Peeters','dj165@ultimate-dj.test',0,1,'2026-02-18 09:00:00.000000'),
(388,'pbkdf2_sha256$600000$dj166$hashdemo',NULL,0,'dj166@ultimate-dj.test','Romain','Leroy','dj166@ultimate-dj.test',0,1,'2026-02-19 09:00:00.000000'),
(389,'pbkdf2_sha256$600000$dj167$hashdemo',NULL,0,'dj167@ultimate-dj.test','Lina','Diallo','dj167@ultimate-dj.test',0,1,'2026-02-20 09:00:00.000000'),
(390,'pbkdf2_sha256$600000$dj168$hashdemo',NULL,0,'dj168@ultimate-dj.test','Adrien','Fontaine','dj168@ultimate-dj.test',0,1,'2026-02-21 09:00:00.000000'),
(391,'pbkdf2_sha256$600000$dj169$hashdemo',NULL,0,'dj169@ultimate-dj.test','Maya','Peeters','dj169@ultimate-dj.test',0,1,'2026-02-22 09:00:00.000000'),
(392,'pbkdf2_sha256$600000$dj170$hashdemo',NULL,0,'dj170@ultimate-dj.test','Karim','Leroy','dj170@ultimate-dj.test',0,1,'2026-02-23 09:00:00.000000'),
(393,'pbkdf2_sha256$600000$dj171$hashdemo',NULL,0,'dj171@ultimate-dj.test','Julie','Diallo','dj171@ultimate-dj.test',0,1,'2026-02-24 09:00:00.000000'),
(394,'pbkdf2_sha256$600000$dj172$hashdemo',NULL,0,'dj172@ultimate-dj.test','Kevin','Fontaine','dj172@ultimate-dj.test',0,1,'2026-02-25 09:00:00.000000'),
(395,'pbkdf2_sha256$600000$dj173$hashdemo',NULL,0,'dj173@ultimate-dj.test','Noemie','Peeters','dj173@ultimate-dj.test',0,1,'2026-02-26 09:00:00.000000'),
(396,'pbkdf2_sha256$600000$dj174$hashdemo',NULL,0,'dj174@ultimate-dj.test','Vianney','Leroy','dj174@ultimate-dj.test',0,1,'2026-02-27 09:00:00.000000'),
(397,'pbkdf2_sha256$600000$dj175$hashdemo',NULL,0,'dj175@ultimate-dj.test','Sarah','Diallo','dj175@ultimate-dj.test',0,1,'2026-02-28 09:00:00.000000'),
(398,'pbkdf2_sha256$600000$dj176$hashdemo',NULL,0,'dj176@ultimate-dj.test','Thomas','Fontaine','dj176@ultimate-dj.test',0,1,'2026-03-01 09:00:00.000000'),
(399,'pbkdf2_sha256$600000$dj177$hashdemo',NULL,0,'dj177@ultimate-dj.test','Laura','Peeters','dj177@ultimate-dj.test',0,1,'2026-03-02 09:00:00.000000'),
(400,'pbkdf2_sha256$600000$dj178$hashdemo',NULL,0,'dj178@ultimate-dj.test','Nicolas','Leroy','dj178@ultimate-dj.test',0,1,'2026-03-03 09:00:00.000000'),
(401,'pbkdf2_sha256$600000$dj179$hashdemo',NULL,0,'dj179@ultimate-dj.test','Amina','Diallo','dj179@ultimate-dj.test',0,1,'2026-03-04 09:00:00.000000'),
(402,'pbkdf2_sha256$600000$dj180$hashdemo',NULL,0,'dj180@ultimate-dj.test','Julien','Fontaine','dj180@ultimate-dj.test',0,1,'2026-03-05 09:00:00.000000'),
(403,'pbkdf2_sha256$600000$dj181$hashdemo',NULL,0,'dj181@ultimate-dj.test','Camille','Peeters','dj181@ultimate-dj.test',0,1,'2026-03-06 09:00:00.000000'),
(404,'pbkdf2_sha256$600000$dj182$hashdemo',NULL,0,'dj182@ultimate-dj.test','Youssef','Leroy','dj182@ultimate-dj.test',0,1,'2026-03-07 09:00:00.000000'),
(405,'pbkdf2_sha256$600000$dj183$hashdemo',NULL,0,'dj183@ultimate-dj.test','Marie','Diallo','dj183@ultimate-dj.test',0,1,'2026-03-08 09:00:00.000000'),
(406,'pbkdf2_sha256$600000$dj184$hashdemo',NULL,0,'dj184@ultimate-dj.test','Antoine','Fontaine','dj184@ultimate-dj.test',0,1,'2026-03-09 09:00:00.000000'),
(407,'pbkdf2_sha256$600000$dj185$hashdemo',NULL,0,'dj185@ultimate-dj.test','Sophie','Peeters','dj185@ultimate-dj.test',0,1,'2026-03-10 09:00:00.000000'),
(408,'pbkdf2_sha256$600000$dj186$hashdemo',NULL,0,'dj186@ultimate-dj.test','Mehdi','Leroy','dj186@ultimate-dj.test',0,1,'2026-03-11 09:00:00.000000'),
(409,'pbkdf2_sha256$600000$dj187$hashdemo',NULL,0,'dj187@ultimate-dj.test','Nadia','Diallo','dj187@ultimate-dj.test',0,1,'2026-03-12 09:00:00.000000'),
(410,'pbkdf2_sha256$600000$dj188$hashdemo',NULL,0,'dj188@ultimate-dj.test','Lucas','Fontaine','dj188@ultimate-dj.test',0,1,'2026-03-13 09:00:00.000000'),
(411,'pbkdf2_sha256$600000$dj189$hashdemo',NULL,0,'dj189@ultimate-dj.test','Emma','Peeters','dj189@ultimate-dj.test',0,1,'2026-03-14 09:00:00.000000'),
(412,'pbkdf2_sha256$600000$dj190$hashdemo',NULL,0,'dj190@ultimate-dj.test','Hugo','Leroy','dj190@ultimate-dj.test',0,1,'2026-03-15 09:00:00.000000'),
(413,'pbkdf2_sha256$600000$dj191$hashdemo',NULL,0,'dj191@ultimate-dj.test','Ines','Diallo','dj191@ultimate-dj.test',0,1,'2026-03-16 09:00:00.000000'),
(414,'pbkdf2_sha256$600000$dj192$hashdemo',NULL,0,'dj192@ultimate-dj.test','Simon','Fontaine','dj192@ultimate-dj.test',0,1,'2026-03-17 09:00:00.000000'),
(415,'pbkdf2_sha256$600000$dj193$hashdemo',NULL,0,'dj193@ultimate-dj.test','Elise','Peeters','dj193@ultimate-dj.test',0,1,'2026-03-18 09:00:00.000000'),
(416,'pbkdf2_sha256$600000$dj194$hashdemo',NULL,0,'dj194@ultimate-dj.test','Maxime','Leroy','dj194@ultimate-dj.test',0,1,'2026-03-19 09:00:00.000000'),
(417,'pbkdf2_sha256$600000$dj195$hashdemo',NULL,0,'dj195@ultimate-dj.test','Chloe','Diallo','dj195@ultimate-dj.test',0,1,'2026-03-20 09:00:00.000000'),
(418,'pbkdf2_sha256$600000$dj196$hashdemo',NULL,0,'dj196@ultimate-dj.test','Romain','Fontaine','dj196@ultimate-dj.test',0,1,'2026-03-21 09:00:00.000000'),
(419,'pbkdf2_sha256$600000$dj197$hashdemo',NULL,0,'dj197@ultimate-dj.test','Lina','Peeters','dj197@ultimate-dj.test',0,1,'2026-03-22 09:00:00.000000'),
(420,'pbkdf2_sha256$600000$dj198$hashdemo',NULL,0,'dj198@ultimate-dj.test','Adrien','Leroy','dj198@ultimate-dj.test',0,1,'2026-03-23 09:00:00.000000'),
(421,'pbkdf2_sha256$600000$dj199$hashdemo',NULL,0,'dj199@ultimate-dj.test','Maya','Diallo','dj199@ultimate-dj.test',0,1,'2026-03-24 09:00:00.000000'),
(422,'pbkdf2_sha256$600000$dj200$hashdemo',NULL,0,'dj200@ultimate-dj.test','Karim','Fontaine','dj200@ultimate-dj.test',0,1,'2026-03-25 09:00:00.000000'),
(423,'pbkdf2_sha256$600000$dj201$hashdemo',NULL,0,'dj201@ultimate-dj.test','Julie','Peeters','dj201@ultimate-dj.test',0,1,'2026-01-05 09:00:00.000000'),
(424,'pbkdf2_sha256$600000$dj202$hashdemo',NULL,0,'dj202@ultimate-dj.test','Kevin','Leroy','dj202@ultimate-dj.test',0,1,'2026-01-06 09:00:00.000000'),
(425,'pbkdf2_sha256$600000$dj203$hashdemo',NULL,0,'dj203@ultimate-dj.test','Noemie','Diallo','dj203@ultimate-dj.test',0,1,'2026-01-07 09:00:00.000000'),
(426,'pbkdf2_sha256$600000$dj204$hashdemo',NULL,0,'dj204@ultimate-dj.test','Vianney','Fontaine','dj204@ultimate-dj.test',0,1,'2026-01-08 09:00:00.000000'),
(427,'pbkdf2_sha256$600000$dj205$hashdemo',NULL,0,'dj205@ultimate-dj.test','Sarah','Peeters','dj205@ultimate-dj.test',0,1,'2026-01-09 09:00:00.000000'),
(428,'pbkdf2_sha256$600000$dj206$hashdemo',NULL,0,'dj206@ultimate-dj.test','Thomas','Leroy','dj206@ultimate-dj.test',0,1,'2026-01-10 09:00:00.000000'),
(429,'pbkdf2_sha256$600000$dj207$hashdemo',NULL,0,'dj207@ultimate-dj.test','Laura','Diallo','dj207@ultimate-dj.test',0,1,'2026-01-11 09:00:00.000000'),
(430,'pbkdf2_sha256$600000$dj208$hashdemo',NULL,0,'dj208@ultimate-dj.test','Nicolas','Fontaine','dj208@ultimate-dj.test',0,1,'2026-01-12 09:00:00.000000'),
(431,'pbkdf2_sha256$600000$dj209$hashdemo',NULL,0,'dj209@ultimate-dj.test','Amina','Peeters','dj209@ultimate-dj.test',0,1,'2026-01-13 09:00:00.000000'),
(432,'pbkdf2_sha256$600000$dj210$hashdemo',NULL,0,'dj210@ultimate-dj.test','Julien','Leroy','dj210@ultimate-dj.test',0,1,'2026-01-14 09:00:00.000000'),
(433,'pbkdf2_sha256$600000$dj211$hashdemo',NULL,0,'dj211@ultimate-dj.test','Camille','Diallo','dj211@ultimate-dj.test',0,1,'2026-01-15 09:00:00.000000'),
(434,'pbkdf2_sha256$600000$dj212$hashdemo',NULL,0,'dj212@ultimate-dj.test','Youssef','Fontaine','dj212@ultimate-dj.test',0,1,'2026-01-16 09:00:00.000000'),
(435,'pbkdf2_sha256$600000$dj213$hashdemo',NULL,0,'dj213@ultimate-dj.test','Marie','Peeters','dj213@ultimate-dj.test',0,1,'2026-01-17 09:00:00.000000'),
(436,'pbkdf2_sha256$600000$dj214$hashdemo',NULL,0,'dj214@ultimate-dj.test','Antoine','Leroy','dj214@ultimate-dj.test',0,1,'2026-01-18 09:00:00.000000'),
(437,'pbkdf2_sha256$600000$dj215$hashdemo',NULL,0,'dj215@ultimate-dj.test','Sophie','Diallo','dj215@ultimate-dj.test',0,1,'2026-01-19 09:00:00.000000'),
(438,'pbkdf2_sha256$600000$dj216$hashdemo',NULL,0,'dj216@ultimate-dj.test','Mehdi','Fontaine','dj216@ultimate-dj.test',0,1,'2026-01-20 09:00:00.000000'),
(439,'pbkdf2_sha256$600000$dj217$hashdemo',NULL,0,'dj217@ultimate-dj.test','Nadia','Peeters','dj217@ultimate-dj.test',0,1,'2026-01-21 09:00:00.000000'),
(440,'pbkdf2_sha256$600000$dj218$hashdemo',NULL,0,'dj218@ultimate-dj.test','Lucas','Leroy','dj218@ultimate-dj.test',0,1,'2026-01-22 09:00:00.000000'),
(441,'pbkdf2_sha256$600000$dj219$hashdemo',NULL,0,'dj219@ultimate-dj.test','Emma','Diallo','dj219@ultimate-dj.test',0,1,'2026-01-23 09:00:00.000000'),
(442,'pbkdf2_sha256$600000$dj220$hashdemo',NULL,0,'dj220@ultimate-dj.test','Hugo','Fontaine','dj220@ultimate-dj.test',0,1,'2026-01-24 09:00:00.000000'),
(443,'pbkdf2_sha256$1000000$srMJsejlXxBB0duSDWfXvM$DhwQFe+1BcmbkyUBT/MOfmOzhT/y6ZedpJgtg9BqRNU=','2026-08-13 21:51:47.491501',1,'admin@ultimate-dj.test','Vianney','Tchamako','admin@ultimate-dj.test',1,1,'2026-07-04 08:00:00.000000'),
(444,'pbkdf2_sha256$600000$staff$hashdemo',NULL,0,'staff@ultimate-dj.test','Dimitri','Moreau','staff@ultimate-dj.test',1,1,'2026-07-04 08:00:00.000000');
/*!40000 ALTER TABLE `auth_user` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_groups` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`),
  CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_groups`
--

LOCK TABLES `auth_user_groups` WRITE;
/*!40000 ALTER TABLE `auth_user_groups` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `auth_user_groups` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_user_permissions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_user_permissions`
--

LOCK TABLES `auth_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `auth_user_user_permissions` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `auth_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `booking_equipment`
--

DROP TABLE IF EXISTS `booking_equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_equipment` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `quantity` smallint(5) unsigned NOT NULL CHECK (`quantity` >= 0),
  `booking_id` bigint(20) NOT NULL,
  `equipment_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_booking_equipment` (`booking_id`,`equipment_id`),
  KEY `booking_equipment_equipment_id_2395799a_fk_equipment_id` (`equipment_id`),
  CONSTRAINT `booking_equipment_booking_id_1ae0f325_fk_bookings_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  CONSTRAINT `booking_equipment_equipment_id_2395799a_fk_equipment_id` FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`id`),
  CONSTRAINT `booking_equipment_quantity_positive` CHECK (`quantity` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=441 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booking_equipment`
--

LOCK TABLES `booking_equipment` WRITE;
/*!40000 ALTER TABLE `booking_equipment` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `booking_equipment` VALUES
(221,1,1,122),
(222,1,1,139),
(223,1,2,123),
(224,1,2,140),
(225,1,3,124),
(226,1,3,141),
(227,1,4,125),
(228,1,4,142),
(229,1,5,126),
(230,1,5,143),
(231,1,6,127),
(232,1,6,144),
(233,1,7,128),
(234,1,7,145),
(235,1,8,129),
(236,1,8,146),
(237,1,9,130),
(238,1,9,147),
(239,1,10,131),
(240,1,10,148),
(241,1,11,132),
(242,1,11,149),
(243,1,12,133),
(244,1,12,150),
(245,1,13,134),
(246,1,13,151),
(247,1,14,135),
(248,1,14,152),
(249,1,15,136),
(250,1,15,153),
(251,1,16,137),
(252,1,16,154),
(253,1,17,138),
(254,1,17,155),
(255,1,18,139),
(256,1,18,156),
(257,1,19,140),
(258,1,19,157),
(259,1,20,141),
(260,1,20,158),
(261,1,21,142),
(262,1,21,159),
(263,1,22,143),
(264,1,22,160),
(265,1,23,144),
(266,1,23,161),
(267,1,24,145),
(268,1,24,162),
(269,1,25,146),
(270,1,25,163),
(271,1,26,147),
(272,1,26,164),
(273,1,27,148),
(274,1,27,165),
(275,1,28,149),
(276,1,28,166),
(277,1,29,150),
(278,1,29,167),
(279,1,30,151),
(280,1,30,168),
(281,1,31,152),
(282,1,31,169),
(283,1,32,153),
(284,1,32,170),
(285,1,33,154),
(286,1,33,171),
(287,1,34,155),
(288,1,34,172),
(289,1,35,156),
(290,1,35,173),
(291,1,36,157),
(292,1,36,174),
(293,1,37,158),
(294,1,37,175),
(295,1,38,159),
(296,1,38,176),
(297,1,39,160),
(298,1,39,177),
(299,1,40,161),
(300,1,40,178),
(301,1,41,162),
(302,1,41,179),
(303,1,42,163),
(304,1,42,180),
(305,1,43,164),
(306,1,43,181),
(307,1,44,165),
(308,1,44,182),
(309,1,45,166),
(310,1,45,183),
(311,1,46,167),
(312,1,46,184),
(313,1,47,168),
(314,1,47,185),
(315,1,48,169),
(316,1,48,186),
(317,1,49,170),
(318,1,49,187),
(319,1,50,171),
(320,1,50,188),
(321,1,51,172),
(322,1,51,189),
(323,1,52,173),
(324,1,52,190),
(325,1,53,174),
(326,1,53,191),
(327,1,54,175),
(328,1,54,192),
(329,1,55,176),
(330,1,55,193),
(331,1,56,177),
(332,1,56,194),
(333,1,57,178),
(334,1,57,195),
(335,1,58,179),
(336,1,58,196),
(337,1,59,180),
(338,1,59,197),
(339,1,60,181),
(340,1,60,198),
(341,1,61,182),
(342,1,61,199),
(343,1,62,183),
(344,1,62,200),
(345,1,63,184),
(346,1,63,201),
(347,1,64,185),
(348,1,64,202),
(349,1,65,186),
(350,1,65,203),
(351,1,66,187),
(352,1,66,204),
(353,1,67,188),
(354,1,67,205),
(355,1,68,189),
(356,1,68,206),
(357,1,69,190),
(358,1,69,207),
(359,1,70,191),
(360,1,70,208),
(361,1,71,192),
(362,1,71,209),
(363,1,72,193),
(364,1,72,210),
(365,1,73,194),
(366,1,73,211),
(367,1,74,195),
(368,1,74,212),
(369,1,75,196),
(370,1,75,213),
(371,1,76,197),
(372,1,76,214),
(373,1,77,198),
(374,1,77,215),
(375,1,78,199),
(376,1,78,216),
(377,1,79,200),
(378,1,79,217),
(379,1,80,201),
(380,1,80,218),
(381,1,81,202),
(382,1,81,219),
(383,1,82,203),
(384,1,82,220),
(385,1,83,204),
(386,1,83,221),
(387,1,84,205),
(388,1,84,222),
(389,1,85,206),
(390,1,85,223),
(391,1,86,207),
(392,1,86,224),
(393,1,87,208),
(394,1,87,225),
(395,1,88,209),
(396,1,88,226),
(397,1,89,210),
(398,1,89,227),
(399,1,90,211),
(400,1,90,228),
(401,1,91,212),
(402,1,91,229),
(403,1,92,213),
(404,1,92,230),
(405,1,93,214),
(406,1,93,231),
(407,1,94,215),
(408,1,94,232),
(409,1,95,216),
(410,1,95,233),
(411,1,96,217),
(412,1,96,234),
(413,1,97,218),
(414,1,97,235),
(415,1,98,219),
(416,1,98,236),
(417,1,99,220),
(418,1,99,237),
(419,1,100,221),
(420,1,100,238),
(421,1,101,222),
(422,1,101,239),
(423,1,102,223),
(424,1,102,240),
(425,1,103,121),
(426,1,103,224),
(427,1,104,122),
(428,1,104,225),
(429,1,105,123),
(430,1,105,226),
(431,1,106,124),
(432,1,106,227),
(433,1,107,125),
(434,1,107,228),
(435,1,108,126),
(436,1,108,229),
(437,1,109,127),
(438,1,109,230),
(439,1,110,128),
(440,1,110,231);
/*!40000 ALTER TABLE `booking_equipment` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `event_date` date NOT NULL,
  `start_time` time(6) NOT NULL,
  `end_time` time(6) NOT NULL,
  `status` varchar(30) NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `deposit_required` decimal(10,2) NOT NULL,
  `deposit_paid` tinyint(1) NOT NULL,
  `cancellation_reason` varchar(255) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  `dj_id` bigint(20) NOT NULL,
  `event_type_id` bigint(20) NOT NULL,
  `package_id` bigint(20) NOT NULL,
  `quote_id` bigint(20) NOT NULL,
  `venue_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `quote_id` (`quote_id`),
  UNIQUE KEY `unique_confirmed_dj_slot` (`dj_id`,`event_date`,`start_time`),
  KEY `bookings_venue_id_e9924600_fk_venues_id` (`venue_id`),
  KEY `bookings_client_id_89ca745f_fk_client_profiles_id` (`client_id`),
  KEY `bookings_event_type_id_99518ae7_fk_event_types_id` (`event_type_id`),
  KEY `bookings_package_id_69443b86_fk_packages_id` (`package_id`),
  CONSTRAINT `bookings_client_id_89ca745f_fk_client_profiles_id` FOREIGN KEY (`client_id`) REFERENCES `client_profiles` (`id`),
  CONSTRAINT `bookings_dj_id_40aedf9d_fk_dj_profiles_id` FOREIGN KEY (`dj_id`) REFERENCES `dj_profiles` (`id`),
  CONSTRAINT `bookings_event_type_id_99518ae7_fk_event_types_id` FOREIGN KEY (`event_type_id`) REFERENCES `event_types` (`id`),
  CONSTRAINT `bookings_package_id_69443b86_fk_packages_id` FOREIGN KEY (`package_id`) REFERENCES `packages` (`id`),
  CONSTRAINT `bookings_quote_id_ba27b557_fk_quotes_id` FOREIGN KEY (`quote_id`) REFERENCES `quotes` (`id`),
  CONSTRAINT `bookings_venue_id_e9924600_fk_venues_id` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`),
  CONSTRAINT `booking_end_after_start` CHECK (`end_time` > `start_time`),
  CONSTRAINT `booking_total_positive` CHECK (`total_amount` >= 0),
  CONSTRAINT `booking_deposit_positive` CHECK (`deposit_required` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=111 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookings`
--

LOCK TABLES `bookings` WRITE;
/*!40000 ALTER TABLE `bookings` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `bookings` VALUES
(1,'2026-08-16','19:00:00.000000','23:00:00.000000','paid',755.62,226.69,1,'','2026-03-17 09:00:00.000000',121,101,10,11,1,241),
(2,'2026-08-17','20:00:00.000000','23:00:00.000000','performed',948.64,284.59,1,'','2026-03-18 09:00:00.000000',122,102,11,12,2,242),
(3,'2026-08-18','21:00:00.000000','23:00:00.000000','paid',1141.66,342.50,1,'','2026-03-19 09:00:00.000000',123,103,12,13,3,243),
(4,'2026-08-19','18:00:00.000000','23:00:00.000000','cancelled',1014.68,304.40,0,'Annulation demandée par le client','2026-03-20 09:00:00.000000',124,104,13,14,4,244),
(5,'2026-08-20','19:00:00.000000','23:00:00.000000','preparatory_meeting',1207.70,362.31,0,'','2026-03-21 09:00:00.000000',125,105,14,15,5,245),
(6,'2026-08-21','20:00:00.000000','23:00:00.000000','confirmed',1295.72,388.72,1,'','2026-03-22 09:00:00.000000',126,106,15,16,6,246),
(7,'2026-08-22','21:00:00.000000','23:00:00.000000','performed',1488.74,446.62,1,'','2026-03-23 09:00:00.000000',127,107,16,17,7,247),
(8,'2026-08-23','18:00:00.000000','23:00:00.000000','paid',1361.76,408.53,1,'','2026-03-24 09:00:00.000000',128,108,17,18,8,248),
(9,'2026-08-24','19:00:00.000000','23:00:00.000000','cancelled',1554.78,466.43,0,'Annulation demandée par le client','2026-03-25 09:00:00.000000',129,109,10,19,9,249),
(10,'2026-08-25','20:00:00.000000','23:00:00.000000','preparatory_meeting',1747.80,524.34,0,'','2026-03-26 09:00:00.000000',130,110,11,20,10,250),
(11,'2026-08-26','21:00:00.000000','23:00:00.000000','confirmed',990.82,297.25,1,'','2026-03-27 09:00:00.000000',131,111,12,11,11,251),
(12,'2026-08-27','18:00:00.000000','23:00:00.000000','performed',758.84,227.65,1,'','2026-03-28 09:00:00.000000',132,112,13,12,12,252),
(13,'2026-08-28','19:00:00.000000','23:00:00.000000','paid',951.86,285.56,1,'','2026-03-29 08:00:00.000000',133,113,14,13,13,253),
(14,'2026-08-29','20:00:00.000000','23:00:00.000000','cancelled',1144.88,343.46,0,'Annulation demandée par le client','2026-03-30 08:00:00.000000',134,114,15,14,14,254),
(15,'2026-08-30','21:00:00.000000','23:00:00.000000','preparatory_meeting',1337.90,401.37,0,'','2026-03-31 08:00:00.000000',135,115,16,15,15,255),
(16,'2026-08-31','18:00:00.000000','23:00:00.000000','confirmed',1210.92,363.28,1,'','2026-04-01 08:00:00.000000',136,116,17,16,16,256),
(17,'2026-09-01','19:00:00.000000','23:00:00.000000','performed',1403.94,421.18,1,'','2026-04-02 08:00:00.000000',137,117,10,17,17,257),
(18,'2026-09-02','20:00:00.000000','23:00:00.000000','paid',1491.96,447.59,1,'','2026-04-03 08:00:00.000000',138,118,11,18,18,258),
(19,'2026-09-03','21:00:00.000000','23:00:00.000000','cancelled',1684.98,505.49,0,'Annulation demandée par le client','2026-04-04 08:00:00.000000',139,119,12,19,19,259),
(20,'2026-09-04','18:00:00.000000','23:00:00.000000','preparatory_meeting',1558.00,467.40,0,'','2026-04-05 08:00:00.000000',140,120,13,20,20,260),
(21,'2026-09-05','19:00:00.000000','23:00:00.000000','confirmed',801.02,240.31,1,'','2026-04-06 08:00:00.000000',141,121,14,11,21,261),
(22,'2026-09-06','20:00:00.000000','23:00:00.000000','performed',994.04,298.21,1,'','2026-04-07 08:00:00.000000',142,122,15,12,22,262),
(23,'2026-09-07','21:00:00.000000','23:00:00.000000','paid',1187.06,356.12,1,'','2026-04-08 08:00:00.000000',143,123,16,13,23,263),
(24,'2026-09-08','18:00:00.000000','23:00:00.000000','cancelled',955.08,286.52,0,'Annulation demandée par le client','2026-04-09 08:00:00.000000',144,124,17,14,24,264),
(25,'2026-09-09','19:00:00.000000','23:00:00.000000','preparatory_meeting',1148.10,344.43,0,'','2026-04-10 08:00:00.000000',145,125,10,15,25,265),
(26,'2026-09-10','20:00:00.000000','23:00:00.000000','confirmed',1341.12,402.34,1,'','2026-04-11 08:00:00.000000',146,126,11,16,26,266),
(27,'2026-09-11','21:00:00.000000','23:00:00.000000','performed',1534.14,460.24,1,'','2026-04-12 08:00:00.000000',147,127,12,17,27,267),
(28,'2026-09-12','18:00:00.000000','23:00:00.000000','paid',1407.16,422.15,1,'','2026-04-13 08:00:00.000000',148,128,13,18,28,268),
(29,'2026-09-13','19:00:00.000000','23:00:00.000000','cancelled',1600.18,480.05,0,'Annulation demandée par le client','2026-04-14 08:00:00.000000',149,129,14,19,29,269),
(30,'2026-09-14','20:00:00.000000','23:00:00.000000','preparatory_meeting',1688.20,506.46,0,'','2026-04-15 08:00:00.000000',150,130,15,20,30,270),
(31,'2026-09-15','21:00:00.000000','23:00:00.000000','confirmed',931.22,279.37,1,'','2026-04-16 08:00:00.000000',151,131,16,11,31,271),
(32,'2026-09-16','18:00:00.000000','23:00:00.000000','performed',804.24,241.27,1,'','2026-04-17 08:00:00.000000',152,132,17,12,32,272),
(33,'2026-09-17','19:00:00.000000','23:00:00.000000','paid',997.26,299.18,1,'','2026-04-18 08:00:00.000000',153,133,10,13,33,273),
(34,'2026-09-18','20:00:00.000000','23:00:00.000000','cancelled',1190.28,357.08,0,'Annulation demandée par le client','2026-04-19 08:00:00.000000',154,134,11,14,34,274),
(35,'2026-09-19','21:00:00.000000','23:00:00.000000','preparatory_meeting',1383.30,414.99,0,'','2026-04-20 08:00:00.000000',155,135,12,15,35,275),
(36,'2026-09-20','18:00:00.000000','23:00:00.000000','confirmed',1151.32,345.40,1,'','2026-04-21 08:00:00.000000',156,136,13,16,36,276),
(37,'2026-09-21','19:00:00.000000','23:00:00.000000','performed',1344.34,403.30,1,'','2026-04-22 08:00:00.000000',157,137,14,17,37,277),
(38,'2026-09-22','20:00:00.000000','23:00:00.000000','paid',1537.36,461.21,1,'','2026-04-23 08:00:00.000000',158,138,15,18,38,278),
(39,'2026-09-23','21:00:00.000000','23:00:00.000000','cancelled',1730.38,519.11,0,'Annulation demandée par le client','2026-04-24 08:00:00.000000',159,139,16,19,39,279),
(40,'2026-09-24','18:00:00.000000','23:00:00.000000','preparatory_meeting',1603.40,481.02,0,'','2026-04-25 08:00:00.000000',160,140,17,20,40,280),
(41,'2026-09-25','19:00:00.000000','23:00:00.000000','confirmed',846.42,253.93,1,'','2026-04-26 08:00:00.000000',161,141,10,11,41,281),
(42,'2026-09-26','20:00:00.000000','23:00:00.000000','performed',934.44,280.33,1,'','2026-04-27 08:00:00.000000',162,142,11,12,42,282),
(43,'2026-09-27','21:00:00.000000','23:00:00.000000','paid',1127.46,338.24,1,'','2026-04-28 08:00:00.000000',163,143,12,13,43,283),
(44,'2026-09-28','18:00:00.000000','23:00:00.000000','cancelled',1000.48,300.14,0,'Annulation demandée par le client','2026-04-29 08:00:00.000000',164,144,13,14,44,284),
(45,'2026-09-29','19:00:00.000000','23:00:00.000000','preparatory_meeting',1193.50,358.05,0,'','2026-04-30 08:00:00.000000',165,145,14,15,45,285),
(46,'2026-09-30','20:00:00.000000','23:00:00.000000','confirmed',1386.52,415.96,1,'','2026-05-01 08:00:00.000000',166,146,15,16,46,286),
(47,'2026-10-01','21:00:00.000000','23:00:00.000000','performed',1579.54,473.86,1,'','2026-05-02 08:00:00.000000',167,147,16,17,47,287),
(48,'2026-10-02','18:00:00.000000','23:00:00.000000','paid',1347.56,404.27,1,'','2026-05-03 08:00:00.000000',168,148,17,18,48,288),
(49,'2026-10-03','19:00:00.000000','23:00:00.000000','cancelled',1540.58,462.17,0,'Annulation demandée par le client','2026-05-04 08:00:00.000000',169,149,10,19,49,289),
(50,'2026-10-04','20:00:00.000000','23:00:00.000000','preparatory_meeting',1733.60,520.08,0,'','2026-05-05 08:00:00.000000',170,150,11,20,50,290),
(51,'2026-10-05','21:00:00.000000','23:00:00.000000','confirmed',976.62,292.99,1,'','2026-05-06 08:00:00.000000',171,151,12,11,51,291),
(52,'2026-10-06','18:00:00.000000','23:00:00.000000','performed',849.64,254.89,1,'','2026-05-07 08:00:00.000000',172,152,13,12,52,292),
(53,'2026-10-07','19:00:00.000000','23:00:00.000000','paid',1042.66,312.80,1,'','2026-05-08 08:00:00.000000',173,153,14,13,53,293),
(54,'2026-10-08','20:00:00.000000','23:00:00.000000','cancelled',1130.68,339.20,0,'Annulation demandée par le client','2026-05-09 08:00:00.000000',174,154,15,14,54,294),
(55,'2026-10-09','21:00:00.000000','23:00:00.000000','preparatory_meeting',1323.70,397.11,0,'','2026-05-10 08:00:00.000000',175,155,16,15,55,295),
(56,'2026-10-10','18:00:00.000000','23:00:00.000000','confirmed',1196.72,359.02,1,'','2026-05-11 08:00:00.000000',176,156,17,16,56,296),
(57,'2026-10-11','19:00:00.000000','23:00:00.000000','performed',1389.74,416.92,1,'','2026-05-12 08:00:00.000000',177,157,10,17,57,297),
(58,'2026-10-12','20:00:00.000000','23:00:00.000000','paid',1582.76,474.83,1,'','2026-05-13 08:00:00.000000',178,158,11,18,58,298),
(59,'2026-10-13','21:00:00.000000','23:00:00.000000','cancelled',1775.78,532.73,0,'Annulation demandée par le client','2026-05-14 08:00:00.000000',179,159,12,19,59,299),
(60,'2026-10-14','18:00:00.000000','23:00:00.000000','preparatory_meeting',1543.80,463.14,0,'','2026-05-15 08:00:00.000000',180,160,13,20,60,300),
(61,'2026-10-15','19:00:00.000000','23:00:00.000000','confirmed',786.82,236.05,1,'','2026-05-16 08:00:00.000000',181,161,14,11,61,301),
(62,'2026-10-16','20:00:00.000000','23:00:00.000000','performed',979.84,293.95,1,'','2026-05-17 08:00:00.000000',182,162,15,12,62,302),
(63,'2026-10-17','21:00:00.000000','23:00:00.000000','paid',1172.86,351.86,1,'','2026-05-18 08:00:00.000000',183,163,16,13,63,303),
(64,'2026-10-18','18:00:00.000000','23:00:00.000000','cancelled',1045.88,313.76,0,'Annulation demandée par le client','2026-05-19 08:00:00.000000',184,164,17,14,64,304),
(65,'2026-10-19','19:00:00.000000','23:00:00.000000','preparatory_meeting',1238.90,371.67,0,'','2026-05-20 08:00:00.000000',185,165,10,15,65,305),
(66,'2026-10-20','20:00:00.000000','23:00:00.000000','confirmed',1326.92,398.08,1,'','2026-05-21 08:00:00.000000',186,166,11,16,66,306),
(67,'2026-10-21','21:00:00.000000','23:00:00.000000','performed',1519.94,455.98,1,'','2026-05-22 08:00:00.000000',187,167,12,17,67,307),
(68,'2026-10-22','18:00:00.000000','23:00:00.000000','paid',1392.96,417.89,1,'','2026-05-23 08:00:00.000000',188,168,13,18,68,308),
(69,'2026-10-23','19:00:00.000000','23:00:00.000000','cancelled',1585.98,475.79,0,'Annulation demandée par le client','2026-05-24 08:00:00.000000',189,169,14,19,69,309),
(70,'2026-10-24','20:00:00.000000','23:00:00.000000','preparatory_meeting',1779.00,533.70,0,'','2026-05-25 08:00:00.000000',190,170,15,20,70,310),
(71,'2026-10-25','21:00:00.000000','23:00:00.000000','confirmed',1022.02,306.61,1,'','2026-05-26 08:00:00.000000',191,171,16,11,71,311),
(72,'2026-10-26','18:00:00.000000','23:00:00.000000','performed',790.04,237.01,1,'','2026-05-27 08:00:00.000000',192,172,17,12,72,312),
(73,'2026-10-27','19:00:00.000000','23:00:00.000000','paid',983.06,294.92,1,'','2026-05-28 08:00:00.000000',193,173,10,13,73,313),
(74,'2026-10-28','20:00:00.000000','23:00:00.000000','cancelled',1176.08,352.82,0,'Annulation demandée par le client','2026-05-29 08:00:00.000000',194,174,11,14,74,314),
(75,'2026-10-29','21:00:00.000000','23:00:00.000000','preparatory_meeting',1369.10,410.73,0,'','2026-05-30 08:00:00.000000',195,175,12,15,75,315),
(76,'2026-10-30','18:00:00.000000','23:00:00.000000','confirmed',1242.12,372.64,1,'','2026-05-31 08:00:00.000000',196,176,13,16,76,316),
(77,'2026-10-31','19:00:00.000000','23:00:00.000000','performed',1435.14,430.54,1,'','2026-06-01 08:00:00.000000',197,177,14,17,77,317),
(78,'2026-11-01','20:00:00.000000','23:00:00.000000','paid',1523.16,456.95,1,'','2026-06-02 08:00:00.000000',198,178,15,18,78,318),
(79,'2026-11-02','21:00:00.000000','23:00:00.000000','cancelled',1716.18,514.85,0,'Annulation demandée par le client','2026-06-03 08:00:00.000000',199,179,16,19,79,319),
(80,'2026-11-03','18:00:00.000000','23:00:00.000000','preparatory_meeting',1589.20,476.76,0,'','2026-06-04 08:00:00.000000',200,180,17,20,80,320),
(81,'2026-11-04','19:00:00.000000','23:00:00.000000','confirmed',832.22,249.67,1,'','2026-06-05 08:00:00.000000',201,181,10,11,81,321),
(82,'2026-11-05','20:00:00.000000','23:00:00.000000','performed',1025.24,307.57,1,'','2026-06-06 08:00:00.000000',202,182,11,12,82,322),
(83,'2026-11-06','21:00:00.000000','23:00:00.000000','paid',1218.26,365.48,1,'','2026-06-07 08:00:00.000000',203,183,12,13,83,323),
(84,'2026-11-07','18:00:00.000000','23:00:00.000000','cancelled',986.28,295.88,0,'Annulation demandée par le client','2026-06-08 08:00:00.000000',204,184,13,14,84,324),
(85,'2026-11-08','19:00:00.000000','23:00:00.000000','preparatory_meeting',1179.30,353.79,0,'','2026-06-09 08:00:00.000000',205,185,14,15,85,325),
(86,'2026-11-09','20:00:00.000000','23:00:00.000000','confirmed',1372.32,411.70,1,'','2026-06-10 08:00:00.000000',206,186,15,16,86,326),
(87,'2026-11-10','21:00:00.000000','23:00:00.000000','performed',1565.34,469.60,1,'','2026-06-11 08:00:00.000000',207,187,16,17,87,327),
(88,'2026-11-11','18:00:00.000000','23:00:00.000000','paid',1438.36,431.51,1,'','2026-06-12 08:00:00.000000',208,188,17,18,88,328),
(89,'2026-11-12','19:00:00.000000','23:00:00.000000','cancelled',1631.38,489.41,0,'Annulation demandée par le client','2026-06-13 08:00:00.000000',209,189,10,19,89,329),
(90,'2026-11-13','20:00:00.000000','23:00:00.000000','preparatory_meeting',1719.40,515.82,0,'','2026-06-14 08:00:00.000000',210,190,11,20,90,330),
(91,'2026-11-14','21:00:00.000000','23:00:00.000000','confirmed',962.42,288.73,1,'','2026-06-15 08:00:00.000000',211,191,12,11,91,331),
(92,'2026-11-15','18:00:00.000000','23:00:00.000000','performed',835.44,250.63,1,'','2026-06-16 08:00:00.000000',212,192,13,12,92,332),
(93,'2026-11-16','19:00:00.000000','23:00:00.000000','paid',1028.46,308.54,1,'','2026-06-17 08:00:00.000000',213,193,14,13,93,333),
(94,'2026-11-17','20:00:00.000000','23:00:00.000000','cancelled',1221.48,366.44,0,'Annulation demandée par le client','2026-06-18 08:00:00.000000',214,194,15,14,94,334),
(95,'2026-11-18','21:00:00.000000','23:00:00.000000','preparatory_meeting',1365.10,409.53,0,'','2026-06-19 08:00:00.000000',215,195,16,15,95,335),
(96,'2026-11-19','18:00:00.000000','23:00:00.000000','confirmed',1133.12,339.94,1,'','2026-06-20 08:00:00.000000',216,196,17,16,96,336),
(97,'2026-11-20','19:00:00.000000','23:00:00.000000','performed',1326.14,397.84,1,'','2026-06-21 08:00:00.000000',217,197,10,17,97,337),
(98,'2026-11-21','20:00:00.000000','23:00:00.000000','paid',1519.16,455.75,1,'','2026-06-22 08:00:00.000000',218,198,11,18,98,338),
(99,'2026-11-22','21:00:00.000000','23:00:00.000000','cancelled',1712.18,513.65,0,'Annulation demandée par le client','2026-06-23 08:00:00.000000',219,199,12,19,99,339),
(100,'2026-11-23','18:00:00.000000','23:00:00.000000','preparatory_meeting',1585.20,475.56,0,'','2026-06-24 08:00:00.000000',220,200,13,20,100,340),
(101,'2026-11-24','19:00:00.000000','23:00:00.000000','confirmed',828.22,248.47,1,'','2026-06-25 08:00:00.000000',221,101,14,11,101,341),
(102,'2026-11-25','20:00:00.000000','23:00:00.000000','performed',916.24,274.87,1,'','2026-06-26 08:00:00.000000',222,102,15,12,102,342),
(103,'2026-11-26','21:00:00.000000','23:00:00.000000','paid',1109.26,332.78,1,'','2026-06-27 08:00:00.000000',223,103,16,13,103,343),
(104,'2026-11-27','18:00:00.000000','23:00:00.000000','cancelled',982.28,294.68,0,'Annulation demandée par le client','2026-06-28 08:00:00.000000',224,104,17,14,104,344),
(105,'2026-11-28','19:00:00.000000','23:00:00.000000','preparatory_meeting',1175.30,352.59,0,'','2026-06-29 08:00:00.000000',225,105,10,15,105,345),
(106,'2026-11-29','20:00:00.000000','23:00:00.000000','confirmed',1368.32,410.50,1,'','2026-06-30 08:00:00.000000',226,106,11,16,106,346),
(107,'2026-11-30','21:00:00.000000','23:00:00.000000','performed',1561.34,468.40,1,'','2026-07-01 08:00:00.000000',227,107,12,17,107,347),
(108,'2026-12-01','18:00:00.000000','23:00:00.000000','paid',1329.36,398.81,1,'','2026-07-02 08:00:00.000000',228,108,13,18,108,348),
(109,'2026-12-02','19:00:00.000000','23:00:00.000000','cancelled',1522.38,456.71,0,'Annulation demandée par le client','2026-07-03 08:00:00.000000',229,109,14,19,109,349),
(110,'2026-12-03','20:00:00.000000','23:00:00.000000','preparatory_meeting',1715.40,514.62,0,'','2026-07-04 08:00:00.000000',230,110,15,20,110,350);
/*!40000 ALTER TABLE `bookings` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `cancellation_requests`
--

DROP TABLE IF EXISTS `cancellation_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cancellation_requests` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `reason` varchar(255) NOT NULL,
  `status` varchar(20) NOT NULL,
  `requested_at` datetime(6) NOT NULL,
  `reviewed_at` datetime(6) DEFAULT NULL,
  `booking_id` bigint(20) NOT NULL,
  `reviewed_by_id` int(11) DEFAULT NULL,
  `review_message` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `cancellation_requests_booking_id_8edac695_fk_bookings_id` (`booking_id`),
  KEY `cancellation_requests_reviewed_by_id_d1c90040_fk_auth_user_id` (`reviewed_by_id`),
  KEY `idx_cancel_request_status` (`status`,`requested_at`),
  CONSTRAINT `cancellation_requests_booking_id_8edac695_fk_bookings_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  CONSTRAINT `cancellation_requests_reviewed_by_id_d1c90040_fk_auth_user_id` FOREIGN KEY (`reviewed_by_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cancellation_requests`
--

LOCK TABLES `cancellation_requests` WRITE;
/*!40000 ALTER TABLE `cancellation_requests` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `cancellation_requests` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `client_profiles`
--

DROP TABLE IF EXISTS `client_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_profiles` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `preferred_language` varchar(5) NOT NULL,
  `date_of_birth` date NOT NULL,
  `phone` varchar(30) NOT NULL,
  `billing_address` varchar(255) NOT NULL,
  `billing_city` varchar(80) NOT NULL,
  `billing_postal_code` varchar(20) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `idx_client_city` (`billing_city`),
  CONSTRAINT `client_profiles_user_id_2c51f42e_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=241 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_profiles`
--

LOCK TABLES `client_profiles` WRITE;
/*!40000 ALTER TABLE `client_profiles` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `client_profiles` VALUES
(121,'fr','1975-01-01','+32 470 100000','Rue des Mélodies 1','Bruxelles','1000','2025-11-27 09:00:00.000000',223),
(122,'en','1976-02-02','+32 471 100001','Rue des Mélodies 2','Ixelles','1050','2025-11-28 09:00:00.000000',224),
(123,'nl','1977-03-03','+32 472 100002','Rue des Mélodies 3','Schaerbeek','1030','2025-11-29 09:00:00.000000',225),
(124,'fr','1978-04-04','+32 473 100003','Rue des Mélodies 4','Anderlecht','1070','2025-11-30 09:00:00.000000',226),
(125,'en','1979-05-05','+32 474 100004','Rue des Mélodies 5','Molenbeek-Saint-Jean','1080','2025-12-01 09:00:00.000000',227),
(126,'nl','1980-06-06','+32 475 100005','Rue des Mélodies 6','Uccle','1180','2025-12-02 09:00:00.000000',228),
(127,'fr','1981-07-07','+32 476 100006','Rue des Mélodies 7','Liege','4000','2025-12-03 09:00:00.000000',229),
(128,'en','1982-08-08','+32 477 100007','Rue des Mélodies 8','Namur','5000','2025-12-04 09:00:00.000000',230),
(129,'nl','1983-09-09','+32 478 100008','Rue des Mélodies 9','Charleroi','6000','2025-12-05 09:00:00.000000',231),
(130,'fr','1984-10-10','+32 479 100009','Rue des Mélodies 10','Mons','7000','2025-12-06 09:00:00.000000',232),
(131,'en','1985-11-11','+32 480 100010','Rue des Mélodies 11','Anvers','2000','2025-12-07 09:00:00.000000',233),
(132,'nl','1986-12-12','+32 481 100011','Rue des Mélodies 12','Gand','9000','2025-12-08 09:00:00.000000',234),
(133,'fr','1987-01-13','+32 482 100012','Rue des Mélodies 13','Louvain','3000','2025-12-09 09:00:00.000000',235),
(134,'en','1988-02-14','+32 483 100013','Rue des Mélodies 14','Malines','2800','2025-12-10 09:00:00.000000',236),
(135,'nl','1989-03-15','+32 484 100014','Rue des Mélodies 15','Bruges','8000','2025-12-11 09:00:00.000000',237),
(136,'fr','1990-04-16','+32 485 100015','Rue des Mélodies 16','Tournai','7500','2025-12-12 09:00:00.000000',238),
(137,'en','1991-05-17','+32 486 100016','Rue des Mélodies 17','Bruxelles','1000','2025-12-13 09:00:00.000000',239),
(138,'nl','1992-06-18','+32 487 100017','Rue des Mélodies 18','Ixelles','1050','2025-12-14 09:00:00.000000',240),
(139,'fr','1993-07-19','+32 488 100018','Rue des Mélodies 19','Schaerbeek','1030','2025-12-15 09:00:00.000000',241),
(140,'en','1994-08-20','+32 489 100019','Rue des Mélodies 20','Anderlecht','1070','2025-12-16 09:00:00.000000',242),
(141,'nl','1995-09-21','+32 470 100020','Rue des Mélodies 21','Molenbeek-Saint-Jean','1080','2025-12-17 09:00:00.000000',243),
(142,'fr','1996-10-22','+32 471 100021','Rue des Mélodies 22','Uccle','1180','2025-12-18 09:00:00.000000',244),
(143,'en','1997-11-23','+32 472 100022','Rue des Mélodies 23','Liege','4000','2025-12-19 09:00:00.000000',245),
(144,'nl','1998-12-24','+32 473 100023','Rue des Mélodies 24','Namur','5000','2025-12-20 09:00:00.000000',246),
(145,'fr','1999-01-25','+32 474 100024','Rue des Mélodies 25','Charleroi','6000','2025-12-21 09:00:00.000000',247),
(146,'en','1975-02-26','+32 475 100025','Rue des Mélodies 26','Mons','7000','2025-12-22 09:00:00.000000',248),
(147,'nl','1976-03-01','+32 476 100026','Rue des Mélodies 27','Anvers','2000','2025-12-23 09:00:00.000000',249),
(148,'fr','1977-04-02','+32 477 100027','Rue des Mélodies 28','Gand','9000','2025-12-24 09:00:00.000000',250),
(149,'en','1978-05-03','+32 478 100028','Rue des Mélodies 29','Louvain','3000','2025-12-25 09:00:00.000000',251),
(150,'nl','1979-06-04','+32 479 100029','Rue des Mélodies 30','Malines','2800','2025-12-26 09:00:00.000000',252),
(151,'fr','1980-07-05','+32 480 100030','Rue des Mélodies 31','Bruges','8000','2025-12-27 09:00:00.000000',253),
(152,'en','1981-08-06','+32 481 100031','Rue des Mélodies 32','Tournai','7500','2025-12-28 09:00:00.000000',254),
(153,'nl','1982-09-07','+32 482 100032','Rue des Mélodies 33','Bruxelles','1000','2025-12-29 09:00:00.000000',255),
(154,'fr','1983-10-08','+32 483 100033','Rue des Mélodies 34','Ixelles','1050','2025-12-30 09:00:00.000000',256),
(155,'en','1984-11-09','+32 484 100034','Rue des Mélodies 35','Schaerbeek','1030','2025-12-31 09:00:00.000000',257),
(156,'nl','1985-12-10','+32 485 100035','Rue des Mélodies 36','Anderlecht','1070','2026-01-01 09:00:00.000000',258),
(157,'fr','1986-01-11','+32 486 100036','Rue des Mélodies 37','Molenbeek-Saint-Jean','1080','2026-01-02 09:00:00.000000',259),
(158,'en','1987-02-12','+32 487 100037','Rue des Mélodies 38','Uccle','1180','2026-01-03 09:00:00.000000',260),
(159,'nl','1988-03-13','+32 488 100038','Rue des Mélodies 39','Liege','4000','2026-01-04 09:00:00.000000',261),
(160,'fr','1989-04-14','+32 489 100039','Rue des Mélodies 40','Namur','5000','2026-01-05 09:00:00.000000',262),
(161,'en','1990-05-15','+32 470 100040','Rue des Mélodies 41','Charleroi','6000','2026-01-06 09:00:00.000000',263),
(162,'nl','1991-06-16','+32 471 100041','Rue des Mélodies 42','Mons','7000','2026-01-07 09:00:00.000000',264),
(163,'fr','1992-07-17','+32 472 100042','Rue des Mélodies 43','Anvers','2000','2026-01-08 09:00:00.000000',265),
(164,'en','1993-08-18','+32 473 100043','Rue des Mélodies 44','Gand','9000','2026-01-09 09:00:00.000000',266),
(165,'nl','1994-09-19','+32 474 100044','Rue des Mélodies 45','Louvain','3000','2026-01-10 09:00:00.000000',267),
(166,'fr','1995-10-20','+32 475 100045','Rue des Mélodies 46','Malines','2800','2026-01-11 09:00:00.000000',268),
(167,'en','1996-11-21','+32 476 100046','Rue des Mélodies 47','Bruges','8000','2026-01-12 09:00:00.000000',269),
(168,'nl','1997-12-22','+32 477 100047','Rue des Mélodies 48','Tournai','7500','2026-01-13 09:00:00.000000',270),
(169,'fr','1998-01-23','+32 478 100048','Rue des Mélodies 49','Bruxelles','1000','2026-01-14 09:00:00.000000',271),
(170,'en','1999-02-24','+32 479 100049','Rue des Mélodies 50','Ixelles','1050','2026-01-15 09:00:00.000000',272),
(171,'nl','1975-03-25','+32 480 100050','Rue des Mélodies 51','Schaerbeek','1030','2026-01-16 09:00:00.000000',273),
(172,'fr','1976-04-26','+32 481 100051','Rue des Mélodies 52','Anderlecht','1070','2026-01-17 09:00:00.000000',274),
(173,'en','1977-05-01','+32 482 100052','Rue des Mélodies 53','Molenbeek-Saint-Jean','1080','2026-01-18 09:00:00.000000',275),
(174,'nl','1978-06-02','+32 483 100053','Rue des Mélodies 54','Uccle','1180','2026-01-19 09:00:00.000000',276),
(175,'fr','1979-07-03','+32 484 100054','Rue des Mélodies 55','Liege','4000','2026-01-20 09:00:00.000000',277),
(176,'en','1980-08-04','+32 485 100055','Rue des Mélodies 56','Namur','5000','2026-01-21 09:00:00.000000',278),
(177,'nl','1981-09-05','+32 486 100056','Rue des Mélodies 57','Charleroi','6000','2026-01-22 09:00:00.000000',279),
(178,'fr','1982-10-06','+32 487 100057','Rue des Mélodies 58','Mons','7000','2026-01-23 09:00:00.000000',280),
(179,'en','1983-11-07','+32 488 100058','Rue des Mélodies 59','Anvers','2000','2026-01-24 09:00:00.000000',281),
(180,'nl','1984-12-08','+32 489 100059','Rue des Mélodies 60','Gand','9000','2026-01-25 09:00:00.000000',282),
(181,'fr','1985-01-09','+32 470 100060','Rue des Mélodies 61','Louvain','3000','2026-01-26 09:00:00.000000',283),
(182,'en','1986-02-10','+32 471 100061','Rue des Mélodies 62','Malines','2800','2026-01-27 09:00:00.000000',284),
(183,'nl','1987-03-11','+32 472 100062','Rue des Mélodies 63','Bruges','8000','2026-01-28 09:00:00.000000',285),
(184,'fr','1988-04-12','+32 473 100063','Rue des Mélodies 64','Tournai','7500','2026-01-29 09:00:00.000000',286),
(185,'en','1989-05-13','+32 474 100064','Rue des Mélodies 65','Bruxelles','1000','2026-01-30 09:00:00.000000',287),
(186,'nl','1990-06-14','+32 475 100065','Rue des Mélodies 66','Ixelles','1050','2026-01-31 09:00:00.000000',288),
(187,'fr','1991-07-15','+32 476 100066','Rue des Mélodies 67','Schaerbeek','1030','2026-02-01 09:00:00.000000',289),
(188,'en','1992-08-16','+32 477 100067','Rue des Mélodies 68','Anderlecht','1070','2026-02-02 09:00:00.000000',290),
(189,'nl','1993-09-17','+32 478 100068','Rue des Mélodies 69','Molenbeek-Saint-Jean','1080','2026-02-03 09:00:00.000000',291),
(190,'fr','1994-10-18','+32 479 100069','Rue des Mélodies 70','Uccle','1180','2026-02-04 09:00:00.000000',292),
(191,'en','1995-11-19','+32 480 100070','Rue des Mélodies 71','Liege','4000','2026-02-05 09:00:00.000000',293),
(192,'nl','1996-12-20','+32 481 100071','Rue des Mélodies 72','Namur','5000','2026-02-06 09:00:00.000000',294),
(193,'fr','1997-01-21','+32 482 100072','Rue des Mélodies 73','Charleroi','6000','2026-02-07 09:00:00.000000',295),
(194,'en','1998-02-22','+32 483 100073','Rue des Mélodies 74','Mons','7000','2026-02-08 09:00:00.000000',296),
(195,'nl','1999-03-23','+32 484 100074','Rue des Mélodies 75','Anvers','2000','2026-02-09 09:00:00.000000',297),
(196,'fr','1975-04-24','+32 485 100075','Rue des Mélodies 76','Gand','9000','2026-02-10 09:00:00.000000',298),
(197,'en','1976-05-25','+32 486 100076','Rue des Mélodies 77','Louvain','3000','2026-02-11 09:00:00.000000',299),
(198,'nl','1977-06-26','+32 487 100077','Rue des Mélodies 78','Malines','2800','2026-02-12 09:00:00.000000',300),
(199,'fr','1978-07-01','+32 488 100078','Rue des Mélodies 79','Bruges','8000','2026-02-13 09:00:00.000000',301),
(200,'en','1979-08-02','+32 489 100079','Rue des Mélodies 80','Tournai','7500','2026-02-14 09:00:00.000000',302),
(201,'nl','1980-09-03','+32 470 100080','Rue des Mélodies 81','Bruxelles','1000','2026-02-15 09:00:00.000000',303),
(202,'fr','1981-10-04','+32 471 100081','Rue des Mélodies 82','Ixelles','1050','2026-02-16 09:00:00.000000',304),
(203,'en','1982-11-05','+32 472 100082','Rue des Mélodies 83','Schaerbeek','1030','2026-02-17 09:00:00.000000',305),
(204,'nl','1983-12-06','+32 473 100083','Rue des Mélodies 84','Anderlecht','1070','2026-02-18 09:00:00.000000',306),
(205,'fr','1984-01-07','+32 474 100084','Rue des Mélodies 85','Molenbeek-Saint-Jean','1080','2026-02-19 09:00:00.000000',307),
(206,'en','1985-02-08','+32 475 100085','Rue des Mélodies 86','Uccle','1180','2026-02-20 09:00:00.000000',308),
(207,'nl','1986-03-09','+32 476 100086','Rue des Mélodies 87','Liege','4000','2026-02-21 09:00:00.000000',309),
(208,'fr','1987-04-10','+32 477 100087','Rue des Mélodies 88','Namur','5000','2026-02-22 09:00:00.000000',310),
(209,'en','1988-05-11','+32 478 100088','Rue des Mélodies 89','Charleroi','6000','2026-02-23 09:00:00.000000',311),
(210,'nl','1989-06-12','+32 479 100089','Rue des Mélodies 90','Mons','7000','2026-02-24 09:00:00.000000',312),
(211,'fr','1990-07-13','+32 480 100090','Rue des Mélodies 91','Anvers','2000','2026-02-25 09:00:00.000000',313),
(212,'en','1991-08-14','+32 481 100091','Rue des Mélodies 92','Gand','9000','2026-02-26 09:00:00.000000',314),
(213,'nl','1992-09-15','+32 482 100092','Rue des Mélodies 93','Louvain','3000','2026-02-27 09:00:00.000000',315),
(214,'fr','1993-10-16','+32 483 100093','Rue des Mélodies 94','Malines','2800','2026-02-28 09:00:00.000000',316),
(215,'en','1994-11-17','+32 484 100094','Rue des Mélodies 95','Bruges','8000','2026-03-01 09:00:00.000000',317),
(216,'nl','1995-12-18','+32 485 100095','Rue des Mélodies 96','Tournai','7500','2026-03-02 09:00:00.000000',318),
(217,'fr','1996-01-19','+32 486 100096','Rue des Mélodies 97','Bruxelles','1000','2026-03-03 09:00:00.000000',319),
(218,'en','1997-02-20','+32 487 100097','Rue des Mélodies 98','Ixelles','1050','2026-03-04 09:00:00.000000',320),
(219,'nl','1998-03-21','+32 488 100098','Rue des Mélodies 99','Schaerbeek','1030','2026-03-05 09:00:00.000000',321),
(220,'fr','1999-04-22','+32 489 100099','Rue des Mélodies 100','Anderlecht','1070','2026-03-06 09:00:00.000000',322),
(221,'en','1975-05-23','+32 470 100100','Rue des Mélodies 101','Molenbeek-Saint-Jean','1080','2026-03-07 09:00:00.000000',323),
(222,'nl','1976-06-24','+32 471 100101','Rue des Mélodies 102','Uccle','1180','2026-03-08 09:00:00.000000',324),
(223,'fr','1977-07-25','+32 472 100102','Rue des Mélodies 103','Liege','4000','2026-03-09 09:00:00.000000',325),
(224,'en','1978-08-26','+32 473 100103','Rue des Mélodies 104','Namur','5000','2026-03-10 09:00:00.000000',326),
(225,'nl','1979-09-01','+32 474 100104','Rue des Mélodies 105','Charleroi','6000','2026-03-11 09:00:00.000000',327),
(226,'fr','1980-10-02','+32 475 100105','Rue des Mélodies 106','Mons','7000','2026-03-12 09:00:00.000000',328),
(227,'en','1981-11-03','+32 476 100106','Rue des Mélodies 107','Anvers','2000','2026-03-13 09:00:00.000000',329),
(228,'nl','1982-12-04','+32 477 100107','Rue des Mélodies 108','Gand','9000','2026-03-14 09:00:00.000000',330),
(229,'fr','1983-01-05','+32 478 100108','Rue des Mélodies 109','Louvain','3000','2026-03-15 09:00:00.000000',331),
(230,'en','1984-02-06','+32 479 100109','Rue des Mélodies 110','Malines','2800','2026-03-16 09:00:00.000000',332),
(231,'nl','1985-03-07','+32 480 100110','Rue des Mélodies 111','Bruges','8000','2026-03-17 09:00:00.000000',333),
(232,'fr','1986-04-08','+32 481 100111','Rue des Mélodies 112','Tournai','7500','2026-03-18 09:00:00.000000',334),
(233,'en','1987-05-09','+32 482 100112','Rue des Mélodies 113','Bruxelles','1000','2026-03-19 09:00:00.000000',335),
(234,'nl','1988-06-10','+32 483 100113','Rue des Mélodies 114','Ixelles','1050','2026-03-20 09:00:00.000000',336),
(235,'fr','1989-07-11','+32 484 100114','Rue des Mélodies 115','Schaerbeek','1030','2026-03-21 09:00:00.000000',337),
(236,'en','1990-08-12','+32 485 100115','Rue des Mélodies 116','Anderlecht','1070','2026-03-22 09:00:00.000000',338),
(237,'nl','1991-09-13','+32 486 100116','Rue des Mélodies 117','Molenbeek-Saint-Jean','1080','2026-03-23 09:00:00.000000',339),
(238,'fr','1992-10-14','+32 487 100117','Rue des Mélodies 118','Uccle','1180','2026-03-24 09:00:00.000000',340),
(239,'en','1993-11-15','+32 488 100118','Rue des Mélodies 119','Liege','4000','2026-03-25 09:00:00.000000',341),
(240,'nl','1994-12-16','+32 489 100119','Rue des Mélodies 120','Namur','5000','2026-03-26 09:00:00.000000',342);
/*!40000 ALTER TABLE `client_profiles` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `contracts`
--

DROP TABLE IF EXISTS `contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `contracts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `contract_number` varchar(40) NOT NULL,
  `status` varchar(20) NOT NULL,
  `refund_policy` varchar(255) NOT NULL,
  `signed_by_client_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `booking_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `contract_number` (`contract_number`),
  UNIQUE KEY `booking_id` (`booking_id`),
  CONSTRAINT `contracts_booking_id_2ed28caf_fk_bookings_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contracts`
--

LOCK TABLES `contracts` WRITE;
/*!40000 ALTER TABLE `contracts` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `contracts` VALUES
(1,'UDJ-CT-2026-0001','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-04-26 08:00:00.000000','2026-04-06 08:00:00.000000',1),
(2,'UDJ-CT-2026-0002','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-04-27 08:00:00.000000','2026-04-07 08:00:00.000000',2),
(3,'UDJ-CT-2026-0003','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-04-28 08:00:00.000000','2026-04-08 08:00:00.000000',3),
(4,'UDJ-CT-2026-0004','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-04-29 08:00:00.000000','2026-04-09 08:00:00.000000',4),
(5,'UDJ-CT-2026-0005','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-04-10 08:00:00.000000',5),
(6,'UDJ-CT-2026-0006','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-01 08:00:00.000000','2026-04-11 08:00:00.000000',6),
(7,'UDJ-CT-2026-0007','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-02 08:00:00.000000','2026-04-12 08:00:00.000000',7),
(8,'UDJ-CT-2026-0008','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-03 08:00:00.000000','2026-04-13 08:00:00.000000',8),
(9,'UDJ-CT-2026-0009','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-04 08:00:00.000000','2026-04-14 08:00:00.000000',9),
(10,'UDJ-CT-2026-0010','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-04-15 08:00:00.000000',10),
(11,'UDJ-CT-2026-0011','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-06 08:00:00.000000','2026-04-16 08:00:00.000000',11),
(12,'UDJ-CT-2026-0012','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-07 08:00:00.000000','2026-04-17 08:00:00.000000',12),
(13,'UDJ-CT-2026-0013','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-08 08:00:00.000000','2026-04-18 08:00:00.000000',13),
(14,'UDJ-CT-2026-0014','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-09 08:00:00.000000','2026-04-19 08:00:00.000000',14),
(15,'UDJ-CT-2026-0015','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-04-20 08:00:00.000000',15),
(16,'UDJ-CT-2026-0016','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-11 08:00:00.000000','2026-04-21 08:00:00.000000',16),
(17,'UDJ-CT-2026-0017','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-12 08:00:00.000000','2026-04-22 08:00:00.000000',17),
(18,'UDJ-CT-2026-0018','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-13 08:00:00.000000','2026-04-23 08:00:00.000000',18),
(19,'UDJ-CT-2026-0019','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-14 08:00:00.000000','2026-04-24 08:00:00.000000',19),
(20,'UDJ-CT-2026-0020','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-04-25 08:00:00.000000',20),
(21,'UDJ-CT-2026-0021','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-16 08:00:00.000000','2026-04-26 08:00:00.000000',21),
(22,'UDJ-CT-2026-0022','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-17 08:00:00.000000','2026-04-27 08:00:00.000000',22),
(23,'UDJ-CT-2026-0023','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-18 08:00:00.000000','2026-04-28 08:00:00.000000',23),
(24,'UDJ-CT-2026-0024','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-19 08:00:00.000000','2026-04-29 08:00:00.000000',24),
(25,'UDJ-CT-2026-0025','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-04-30 08:00:00.000000',25),
(26,'UDJ-CT-2026-0026','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-21 08:00:00.000000','2026-05-01 08:00:00.000000',26),
(27,'UDJ-CT-2026-0027','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-22 08:00:00.000000','2026-05-02 08:00:00.000000',27),
(28,'UDJ-CT-2026-0028','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-23 08:00:00.000000','2026-05-03 08:00:00.000000',28),
(29,'UDJ-CT-2026-0029','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-24 08:00:00.000000','2026-05-04 08:00:00.000000',29),
(30,'UDJ-CT-2026-0030','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-05-05 08:00:00.000000',30),
(31,'UDJ-CT-2026-0031','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-26 08:00:00.000000','2026-05-06 08:00:00.000000',31),
(32,'UDJ-CT-2026-0032','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-27 08:00:00.000000','2026-05-07 08:00:00.000000',32),
(33,'UDJ-CT-2026-0033','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-28 08:00:00.000000','2026-05-08 08:00:00.000000',33),
(34,'UDJ-CT-2026-0034','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-29 08:00:00.000000','2026-05-09 08:00:00.000000',34),
(35,'UDJ-CT-2026-0035','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-05-10 08:00:00.000000',35),
(36,'UDJ-CT-2026-0036','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-05-31 08:00:00.000000','2026-05-11 08:00:00.000000',36),
(37,'UDJ-CT-2026-0037','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-01 08:00:00.000000','2026-05-12 08:00:00.000000',37),
(38,'UDJ-CT-2026-0038','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-02 08:00:00.000000','2026-05-13 08:00:00.000000',38),
(39,'UDJ-CT-2026-0039','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-03 08:00:00.000000','2026-05-14 08:00:00.000000',39),
(40,'UDJ-CT-2026-0040','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-05-15 08:00:00.000000',40),
(41,'UDJ-CT-2026-0041','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-05 08:00:00.000000','2026-05-16 08:00:00.000000',41),
(42,'UDJ-CT-2026-0042','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-06 08:00:00.000000','2026-05-17 08:00:00.000000',42),
(43,'UDJ-CT-2026-0043','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-07 08:00:00.000000','2026-05-18 08:00:00.000000',43),
(44,'UDJ-CT-2026-0044','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-08 08:00:00.000000','2026-05-19 08:00:00.000000',44),
(45,'UDJ-CT-2026-0045','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-05-20 08:00:00.000000',45),
(46,'UDJ-CT-2026-0046','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-10 08:00:00.000000','2026-05-21 08:00:00.000000',46),
(47,'UDJ-CT-2026-0047','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-11 08:00:00.000000','2026-05-22 08:00:00.000000',47),
(48,'UDJ-CT-2026-0048','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-12 08:00:00.000000','2026-05-23 08:00:00.000000',48),
(49,'UDJ-CT-2026-0049','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-13 08:00:00.000000','2026-05-24 08:00:00.000000',49),
(50,'UDJ-CT-2026-0050','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-05-25 08:00:00.000000',50),
(51,'UDJ-CT-2026-0051','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-15 08:00:00.000000','2026-05-26 08:00:00.000000',51),
(52,'UDJ-CT-2026-0052','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-16 08:00:00.000000','2026-05-27 08:00:00.000000',52),
(53,'UDJ-CT-2026-0053','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-17 08:00:00.000000','2026-05-28 08:00:00.000000',53),
(54,'UDJ-CT-2026-0054','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-18 08:00:00.000000','2026-05-29 08:00:00.000000',54),
(55,'UDJ-CT-2026-0055','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-05-30 08:00:00.000000',55),
(56,'UDJ-CT-2026-0056','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-20 08:00:00.000000','2026-05-31 08:00:00.000000',56),
(57,'UDJ-CT-2026-0057','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-21 08:00:00.000000','2026-06-01 08:00:00.000000',57),
(58,'UDJ-CT-2026-0058','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-22 08:00:00.000000','2026-06-02 08:00:00.000000',58),
(59,'UDJ-CT-2026-0059','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-23 08:00:00.000000','2026-06-03 08:00:00.000000',59),
(60,'UDJ-CT-2026-0060','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-06-04 08:00:00.000000',60),
(61,'UDJ-CT-2026-0061','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-25 08:00:00.000000','2026-06-05 08:00:00.000000',61),
(62,'UDJ-CT-2026-0062','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-26 08:00:00.000000','2026-06-06 08:00:00.000000',62),
(63,'UDJ-CT-2026-0063','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-27 08:00:00.000000','2026-06-07 08:00:00.000000',63),
(64,'UDJ-CT-2026-0064','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-28 08:00:00.000000','2026-06-08 08:00:00.000000',64),
(65,'UDJ-CT-2026-0065','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-06-09 08:00:00.000000',65),
(66,'UDJ-CT-2026-0066','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-06-30 08:00:00.000000','2026-06-10 08:00:00.000000',66),
(67,'UDJ-CT-2026-0067','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-01 08:00:00.000000','2026-06-11 08:00:00.000000',67),
(68,'UDJ-CT-2026-0068','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-02 08:00:00.000000','2026-06-12 08:00:00.000000',68),
(69,'UDJ-CT-2026-0069','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-03 08:00:00.000000','2026-06-13 08:00:00.000000',69),
(70,'UDJ-CT-2026-0070','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-06-14 08:00:00.000000',70),
(71,'UDJ-CT-2026-0071','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-05 08:00:00.000000','2026-06-15 08:00:00.000000',71),
(72,'UDJ-CT-2026-0072','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-06 08:00:00.000000','2026-06-16 08:00:00.000000',72),
(73,'UDJ-CT-2026-0073','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-07 08:00:00.000000','2026-06-17 08:00:00.000000',73),
(74,'UDJ-CT-2026-0074','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-08 08:00:00.000000','2026-06-18 08:00:00.000000',74),
(75,'UDJ-CT-2026-0075','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-06-19 08:00:00.000000',75),
(76,'UDJ-CT-2026-0076','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-10 08:00:00.000000','2026-06-20 08:00:00.000000',76),
(77,'UDJ-CT-2026-0077','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-11 08:00:00.000000','2026-06-21 08:00:00.000000',77),
(78,'UDJ-CT-2026-0078','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-12 08:00:00.000000','2026-06-22 08:00:00.000000',78),
(79,'UDJ-CT-2026-0079','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-13 08:00:00.000000','2026-06-23 08:00:00.000000',79),
(80,'UDJ-CT-2026-0080','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-06-24 08:00:00.000000',80),
(81,'UDJ-CT-2026-0081','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-15 08:00:00.000000','2026-06-25 08:00:00.000000',81),
(82,'UDJ-CT-2026-0082','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-16 08:00:00.000000','2026-06-26 08:00:00.000000',82),
(83,'UDJ-CT-2026-0083','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-17 08:00:00.000000','2026-06-27 08:00:00.000000',83),
(84,'UDJ-CT-2026-0084','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-18 08:00:00.000000','2026-06-28 08:00:00.000000',84),
(85,'UDJ-CT-2026-0085','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-06-29 08:00:00.000000',85),
(86,'UDJ-CT-2026-0086','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-20 08:00:00.000000','2026-06-30 08:00:00.000000',86),
(87,'UDJ-CT-2026-0087','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-21 08:00:00.000000','2026-07-01 08:00:00.000000',87),
(88,'UDJ-CT-2026-0088','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-22 08:00:00.000000','2026-07-02 08:00:00.000000',88),
(89,'UDJ-CT-2026-0089','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-23 08:00:00.000000','2026-07-03 08:00:00.000000',89),
(90,'UDJ-CT-2026-0090','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-07-04 08:00:00.000000',90),
(91,'UDJ-CT-2026-0091','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-25 08:00:00.000000','2026-07-05 08:00:00.000000',91),
(92,'UDJ-CT-2026-0092','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-26 08:00:00.000000','2026-07-06 08:00:00.000000',92),
(93,'UDJ-CT-2026-0093','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-27 08:00:00.000000','2026-07-07 08:00:00.000000',93),
(94,'UDJ-CT-2026-0094','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-28 08:00:00.000000','2026-07-08 08:00:00.000000',94),
(95,'UDJ-CT-2026-0095','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-07-09 08:00:00.000000',95),
(96,'UDJ-CT-2026-0096','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-30 08:00:00.000000','2026-07-10 08:00:00.000000',96),
(97,'UDJ-CT-2026-0097','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-07-31 08:00:00.000000','2026-07-11 08:00:00.000000',97),
(98,'UDJ-CT-2026-0098','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-08-01 08:00:00.000000','2026-07-12 08:00:00.000000',98),
(99,'UDJ-CT-2026-0099','signed','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.','2026-08-02 08:00:00.000000','2026-07-13 08:00:00.000000',99),
(100,'UDJ-CT-2026-0100','sent','Acompte remboursable à 50% jusqu\'à 30 jours avant l\'événement, non remboursable ensuite sauf cas de force majeure.',NULL,'2026-07-14 08:00:00.000000',100);
/*!40000 ALTER TABLE `contracts` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `dj_applications`
--

DROP TABLE IF EXISTS `dj_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dj_applications` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `stage_name` varchar(100) NOT NULL,
  `date_of_birth` date NOT NULL,
  `phone` varchar(30) NOT NULL,
  `city` varchar(80) NOT NULL,
  `preferred_language` varchar(5) NOT NULL,
  `bio` longtext NOT NULL,
  `music_styles` varchar(255) NOT NULL,
  `base_hourly_rate` decimal(10,2) NOT NULL,
  `years_experience` smallint(5) unsigned NOT NULL CHECK (`years_experience` >= 0),
  `identity_document` varchar(100) NOT NULL,
  `insurance_document` varchar(100) NOT NULL,
  `status` varchar(20) NOT NULL,
  `review_message` longtext NOT NULL,
  `submitted_at` datetime(6) NOT NULL,
  `reviewed_at` datetime(6) DEFAULT NULL,
  `reviewed_by_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stage_name` (`stage_name`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `dj_applications_reviewed_by_id_ac654a83_fk_auth_user_id` (`reviewed_by_id`),
  CONSTRAINT `dj_applications_reviewed_by_id_ac654a83_fk_auth_user_id` FOREIGN KEY (`reviewed_by_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `dj_applications_user_id_6833b653_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `dj_application_rate_positive` CHECK (`base_hourly_rate` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dj_applications`
--

LOCK TABLES `dj_applications` WRITE;
/*!40000 ALTER TABLE `dj_applications` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `dj_applications` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `dj_availabilities`
--

DROP TABLE IF EXISTS `dj_availabilities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dj_availabilities` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `available_date` date NOT NULL,
  `start_time` time(6) NOT NULL,
  `end_time` time(6) NOT NULL,
  `status` varchar(20) NOT NULL,
  `dj_id` bigint(20) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `reason` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_dj_availability_slot` (`dj_id`,`available_date`,`start_time`),
  KEY `idx_availability_search` (`available_date`,`status`),
  CONSTRAINT `dj_availabilities_dj_id_9082b635_fk_dj_profiles_id` FOREIGN KEY (`dj_id`) REFERENCES `dj_profiles` (`id`),
  CONSTRAINT `availability_end_after_start` CHECK (`end_time` > `start_time`)
) ENGINE=InnoDB AUTO_INCREMENT=481 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dj_availabilities`
--

LOCK TABLES `dj_availabilities` WRITE;
/*!40000 ALTER TABLE `dj_availabilities` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `dj_availabilities` VALUES
(241,'2026-08-01','18:00:00.000000','23:00:00.000000','reserved',101,'2026-07-27 16:22:53.042384',''),
(242,'2026-08-02','20:00:00.000000','23:59:00.000000','reserved',102,'2026-07-27 16:22:53.042384',''),
(243,'2026-08-02','18:00:00.000000','23:00:00.000000','reserved',103,'2026-07-27 16:22:53.042384',''),
(244,'2026-08-03','20:00:00.000000','23:59:00.000000','reserved',104,'2026-07-27 16:22:53.042384',''),
(245,'2026-08-03','18:00:00.000000','23:00:00.000000','reserved',105,'2026-07-27 16:22:53.042384',''),
(246,'2026-08-04','20:00:00.000000','23:59:00.000000','reserved',106,'2026-07-27 16:22:53.054711',''),
(247,'2026-08-04','18:00:00.000000','23:00:00.000000','reserved',107,'2026-07-27 16:22:53.058824',''),
(248,'2026-08-05','20:00:00.000000','23:59:00.000000','reserved',108,'2026-07-27 16:22:53.058824',''),
(249,'2026-08-05','18:00:00.000000','23:00:00.000000','reserved',109,'2026-07-27 16:22:53.058824',''),
(250,'2026-08-06','20:00:00.000000','23:59:00.000000','reserved',110,'2026-07-27 16:22:53.058824',''),
(251,'2026-08-06','18:00:00.000000','23:00:00.000000','reserved',111,'2026-07-27 16:22:53.058824',''),
(252,'2026-08-07','20:00:00.000000','23:59:00.000000','reserved',112,'2026-07-27 16:22:53.075891',''),
(253,'2026-08-07','18:00:00.000000','23:00:00.000000','reserved',113,'2026-07-27 16:22:53.075891',''),
(254,'2026-08-08','20:00:00.000000','23:59:00.000000','reserved',114,'2026-07-27 16:22:53.075891',''),
(255,'2026-08-08','18:00:00.000000','23:00:00.000000','reserved',115,'2026-07-27 16:22:53.075891',''),
(256,'2026-08-09','20:00:00.000000','23:59:00.000000','reserved',116,'2026-07-27 16:22:53.075891',''),
(257,'2026-08-09','18:00:00.000000','23:00:00.000000','reserved',117,'2026-07-27 16:22:53.075891',''),
(258,'2026-08-10','20:00:00.000000','23:59:00.000000','reserved',118,'2026-07-27 16:22:53.091768',''),
(259,'2026-08-10','18:00:00.000000','23:00:00.000000','reserved',119,'2026-07-27 16:22:53.093345',''),
(260,'2026-08-11','20:00:00.000000','23:59:00.000000','reserved',120,'2026-07-27 16:22:53.093345',''),
(261,'2026-08-11','18:00:00.000000','23:00:00.000000','reserved',121,'2026-07-27 16:22:53.093345',''),
(262,'2026-08-12','20:00:00.000000','23:59:00.000000','reserved',122,'2026-07-27 16:22:53.093345',''),
(263,'2026-08-12','18:00:00.000000','23:00:00.000000','reserved',123,'2026-07-27 16:22:53.093345',''),
(264,'2026-08-13','20:00:00.000000','23:59:00.000000','reserved',124,'2026-07-27 16:22:53.093345',''),
(265,'2026-08-13','18:00:00.000000','23:00:00.000000','reserved',125,'2026-07-27 16:22:53.110330',''),
(266,'2026-08-14','20:00:00.000000','23:59:00.000000','reserved',126,'2026-07-27 16:22:53.110330',''),
(267,'2026-08-14','18:00:00.000000','23:00:00.000000','reserved',127,'2026-07-27 16:22:53.110330',''),
(268,'2026-08-15','20:00:00.000000','23:59:00.000000','reserved',128,'2026-07-27 16:22:53.110330',''),
(269,'2026-08-15','18:00:00.000000','23:00:00.000000','reserved',129,'2026-07-27 16:22:53.110330',''),
(270,'2026-08-16','20:00:00.000000','23:59:00.000000','reserved',130,'2026-07-27 16:22:53.110330',''),
(271,'2026-08-16','18:00:00.000000','23:00:00.000000','reserved',131,'2026-07-27 16:22:53.127146',''),
(272,'2026-08-17','20:00:00.000000','23:59:00.000000','reserved',132,'2026-07-27 16:22:53.127146',''),
(273,'2026-08-17','18:00:00.000000','23:00:00.000000','reserved',133,'2026-07-27 16:22:53.127146',''),
(274,'2026-08-18','20:00:00.000000','23:59:00.000000','reserved',134,'2026-07-27 16:22:53.127146',''),
(275,'2026-08-18','18:00:00.000000','23:00:00.000000','reserved',135,'2026-07-27 16:22:53.127146',''),
(276,'2026-08-19','20:00:00.000000','23:59:00.000000','reserved',136,'2026-07-27 16:22:53.127146',''),
(277,'2026-08-19','18:00:00.000000','23:00:00.000000','reserved',137,'2026-07-27 16:22:53.146145',''),
(278,'2026-08-20','20:00:00.000000','23:59:00.000000','reserved',138,'2026-07-27 16:22:53.146145',''),
(279,'2026-08-20','18:00:00.000000','23:00:00.000000','reserved',139,'2026-07-27 16:22:53.146145',''),
(280,'2026-08-21','20:00:00.000000','23:59:00.000000','reserved',140,'2026-07-27 16:22:53.146145',''),
(281,'2026-08-21','18:00:00.000000','23:00:00.000000','reserved',141,'2026-07-27 16:22:53.154957',''),
(282,'2026-08-22','20:00:00.000000','23:59:00.000000','reserved',142,'2026-07-27 16:22:53.154957',''),
(283,'2026-08-22','18:00:00.000000','23:00:00.000000','reserved',143,'2026-07-27 16:22:53.159449',''),
(284,'2026-08-23','20:00:00.000000','23:59:00.000000','reserved',144,'2026-07-27 16:22:53.159449',''),
(285,'2026-08-23','18:00:00.000000','23:00:00.000000','reserved',145,'2026-07-27 16:22:53.159449',''),
(286,'2026-08-24','20:00:00.000000','23:59:00.000000','reserved',146,'2026-07-27 16:22:53.159449',''),
(287,'2026-08-24','18:00:00.000000','23:00:00.000000','reserved',147,'2026-07-27 16:22:53.159449',''),
(288,'2026-08-25','20:00:00.000000','23:59:00.000000','reserved',148,'2026-07-27 16:22:53.175639',''),
(289,'2026-08-25','18:00:00.000000','23:00:00.000000','reserved',149,'2026-07-27 16:22:53.175639',''),
(290,'2026-08-26','20:00:00.000000','23:59:00.000000','reserved',150,'2026-07-27 16:22:53.175639',''),
(291,'2026-08-26','18:00:00.000000','23:00:00.000000','reserved',151,'2026-07-27 16:22:53.175639',''),
(292,'2026-08-27','20:00:00.000000','23:59:00.000000','reserved',152,'2026-07-27 16:22:53.175639',''),
(293,'2026-08-27','18:00:00.000000','23:00:00.000000','reserved',153,'2026-07-27 16:22:53.175639',''),
(294,'2026-08-28','20:00:00.000000','23:59:00.000000','reserved',154,'2026-07-27 16:22:53.175639',''),
(295,'2026-08-28','18:00:00.000000','23:00:00.000000','reserved',155,'2026-07-27 16:22:53.192386',''),
(296,'2026-08-29','20:00:00.000000','23:59:00.000000','reserved',156,'2026-07-27 16:22:53.192386',''),
(297,'2026-08-29','18:00:00.000000','23:00:00.000000','reserved',157,'2026-07-27 16:22:53.192386',''),
(298,'2026-08-30','20:00:00.000000','23:59:00.000000','reserved',158,'2026-07-27 16:22:53.192386',''),
(299,'2026-08-30','18:00:00.000000','23:00:00.000000','reserved',159,'2026-07-27 16:22:53.192386',''),
(300,'2026-08-31','20:00:00.000000','23:59:00.000000','reserved',160,'2026-07-27 16:22:53.208971',''),
(301,'2026-08-31','18:00:00.000000','23:00:00.000000','reserved',161,'2026-07-27 16:22:53.208971',''),
(302,'2026-09-01','20:00:00.000000','23:59:00.000000','reserved',162,'2026-07-27 16:22:53.208971',''),
(303,'2026-09-01','18:00:00.000000','23:00:00.000000','reserved',163,'2026-07-27 16:22:53.208971',''),
(304,'2026-09-02','20:00:00.000000','23:59:00.000000','reserved',164,'2026-07-27 16:22:53.208971',''),
(305,'2026-09-02','18:00:00.000000','23:00:00.000000','reserved',165,'2026-07-27 16:22:53.208971',''),
(306,'2026-09-03','20:00:00.000000','23:59:00.000000','reserved',166,'2026-07-27 16:22:53.225516',''),
(307,'2026-09-03','18:00:00.000000','23:00:00.000000','reserved',167,'2026-07-27 16:22:53.225516',''),
(308,'2026-09-04','20:00:00.000000','23:59:00.000000','reserved',168,'2026-07-27 16:22:53.225516',''),
(309,'2026-09-04','18:00:00.000000','23:00:00.000000','reserved',169,'2026-07-27 16:22:53.225516',''),
(310,'2026-09-05','20:00:00.000000','23:59:00.000000','reserved',170,'2026-07-27 16:22:53.225516',''),
(311,'2026-09-05','18:00:00.000000','23:00:00.000000','reserved',171,'2026-07-27 16:22:53.225516',''),
(312,'2026-09-06','20:00:00.000000','23:59:00.000000','reserved',172,'2026-07-27 16:22:53.225516',''),
(313,'2026-09-06','18:00:00.000000','23:00:00.000000','reserved',173,'2026-07-27 16:22:53.242261',''),
(314,'2026-09-07','20:00:00.000000','23:59:00.000000','reserved',174,'2026-07-27 16:22:53.242261',''),
(315,'2026-09-07','18:00:00.000000','23:00:00.000000','reserved',175,'2026-07-27 16:22:53.242261',''),
(316,'2026-09-08','20:00:00.000000','23:59:00.000000','reserved',176,'2026-07-27 16:22:53.242261',''),
(317,'2026-09-08','18:00:00.000000','23:00:00.000000','reserved',177,'2026-07-27 16:22:53.242261',''),
(318,'2026-09-09','20:00:00.000000','23:59:00.000000','reserved',178,'2026-07-27 16:22:53.255470',''),
(319,'2026-09-09','18:00:00.000000','23:00:00.000000','reserved',179,'2026-07-27 16:22:53.258996',''),
(320,'2026-09-10','20:00:00.000000','23:59:00.000000','reserved',180,'2026-07-27 16:22:53.258996',''),
(321,'2026-09-10','18:00:00.000000','23:00:00.000000','reserved',181,'2026-07-27 16:22:53.258996',''),
(322,'2026-09-11','20:00:00.000000','23:59:00.000000','reserved',182,'2026-07-27 16:22:53.258996',''),
(323,'2026-09-11','18:00:00.000000','23:00:00.000000','reserved',183,'2026-07-27 16:22:53.258996',''),
(324,'2026-09-12','20:00:00.000000','23:59:00.000000','reserved',184,'2026-07-27 16:22:53.275898',''),
(325,'2026-09-12','18:00:00.000000','23:00:00.000000','reserved',185,'2026-07-27 16:22:53.275898',''),
(326,'2026-09-13','20:00:00.000000','23:59:00.000000','reserved',186,'2026-07-27 16:22:53.275898',''),
(327,'2026-09-13','18:00:00.000000','23:00:00.000000','reserved',187,'2026-07-27 16:22:53.275898',''),
(328,'2026-09-14','20:00:00.000000','23:59:00.000000','reserved',188,'2026-07-27 16:22:53.275898',''),
(329,'2026-09-14','18:00:00.000000','23:00:00.000000','reserved',189,'2026-07-27 16:22:53.275898',''),
(330,'2026-09-15','20:00:00.000000','23:59:00.000000','reserved',190,'2026-07-27 16:22:53.275898',''),
(331,'2026-09-15','18:00:00.000000','23:00:00.000000','reserved',191,'2026-07-27 16:22:53.293383',''),
(332,'2026-09-16','20:00:00.000000','23:59:00.000000','reserved',192,'2026-07-27 16:22:53.294712',''),
(333,'2026-09-16','18:00:00.000000','23:00:00.000000','reserved',193,'2026-07-27 16:22:53.294712',''),
(334,'2026-09-17','20:00:00.000000','23:59:00.000000','reserved',194,'2026-07-27 16:22:53.294712',''),
(335,'2026-09-17','18:00:00.000000','23:00:00.000000','reserved',195,'2026-07-27 16:22:53.294712',''),
(336,'2026-09-18','20:00:00.000000','23:59:00.000000','reserved',196,'2026-07-27 16:22:53.294712',''),
(337,'2026-09-18','18:00:00.000000','23:00:00.000000','reserved',197,'2026-07-27 16:22:53.309181',''),
(338,'2026-09-19','20:00:00.000000','23:59:00.000000','reserved',198,'2026-07-27 16:22:53.309181',''),
(339,'2026-09-19','18:00:00.000000','23:00:00.000000','reserved',199,'2026-07-27 16:22:53.309181',''),
(340,'2026-09-20','20:00:00.000000','23:59:00.000000','reserved',200,'2026-07-27 16:22:53.309181',''),
(341,'2026-09-20','18:00:00.000000','23:00:00.000000','reserved',101,'2026-07-27 16:22:53.309181',''),
(342,'2026-09-21','20:00:00.000000','23:59:00.000000','reserved',102,'2026-07-27 16:22:53.309181',''),
(343,'2026-09-21','18:00:00.000000','23:00:00.000000','reserved',103,'2026-07-27 16:22:53.324744',''),
(344,'2026-09-22','20:00:00.000000','23:59:00.000000','reserved',104,'2026-07-27 16:22:53.325874',''),
(345,'2026-09-22','18:00:00.000000','23:00:00.000000','reserved',105,'2026-07-27 16:22:53.325874',''),
(346,'2026-09-23','20:00:00.000000','23:59:00.000000','reserved',106,'2026-07-27 16:22:53.325874',''),
(347,'2026-09-23','18:00:00.000000','23:00:00.000000','reserved',107,'2026-07-27 16:22:53.325874',''),
(348,'2026-09-24','20:00:00.000000','23:59:00.000000','reserved',108,'2026-07-27 16:22:53.325874',''),
(349,'2026-09-24','18:00:00.000000','23:00:00.000000','reserved',109,'2026-07-27 16:22:53.342384',''),
(350,'2026-09-25','20:00:00.000000','23:59:00.000000','reserved',110,'2026-07-27 16:22:53.342384',''),
(351,'2026-09-25','18:00:00.000000','23:00:00.000000','available',111,'2026-07-27 16:22:53.342384',''),
(352,'2026-09-26','20:00:00.000000','23:59:00.000000','available',112,'2026-07-27 16:22:53.342384',''),
(353,'2026-09-26','18:00:00.000000','23:00:00.000000','available',113,'2026-07-27 16:22:53.342384',''),
(354,'2026-09-27','20:00:00.000000','23:59:00.000000','available',114,'2026-07-27 16:22:53.342384',''),
(355,'2026-09-27','18:00:00.000000','23:00:00.000000','available',115,'2026-07-27 16:22:53.358767',''),
(356,'2026-09-28','20:00:00.000000','23:59:00.000000','available',116,'2026-07-27 16:22:53.358767',''),
(357,'2026-09-28','18:00:00.000000','23:00:00.000000','available',117,'2026-07-27 16:22:53.358767',''),
(358,'2026-09-29','20:00:00.000000','23:59:00.000000','available',118,'2026-07-27 16:22:53.358767',''),
(359,'2026-09-29','18:00:00.000000','23:00:00.000000','available',119,'2026-07-27 16:22:53.358767',''),
(360,'2026-09-30','20:00:00.000000','23:59:00.000000','available',120,'2026-07-27 16:22:53.358767',''),
(361,'2026-09-30','18:00:00.000000','23:00:00.000000','available',121,'2026-07-27 16:22:53.358767',''),
(362,'2026-10-01','20:00:00.000000','23:59:00.000000','available',122,'2026-07-27 16:22:53.375655',''),
(363,'2026-10-01','18:00:00.000000','23:00:00.000000','available',123,'2026-07-27 16:22:53.375655',''),
(364,'2026-10-02','20:00:00.000000','23:59:00.000000','available',124,'2026-07-27 16:22:53.375655',''),
(365,'2026-10-02','18:00:00.000000','23:00:00.000000','available',125,'2026-07-27 16:22:53.375655',''),
(366,'2026-10-03','20:00:00.000000','23:59:00.000000','available',126,'2026-07-27 16:22:53.375655',''),
(367,'2026-10-03','18:00:00.000000','23:00:00.000000','available',127,'2026-07-27 16:22:53.375655',''),
(368,'2026-10-04','20:00:00.000000','23:59:00.000000','available',128,'2026-07-27 16:22:53.392463',''),
(369,'2026-10-04','18:00:00.000000','23:00:00.000000','available',129,'2026-07-27 16:22:53.392463',''),
(370,'2026-10-05','20:00:00.000000','23:59:00.000000','available',130,'2026-07-27 16:22:53.392463',''),
(371,'2026-10-05','18:00:00.000000','23:00:00.000000','available',131,'2026-07-27 16:22:53.392463',''),
(372,'2026-10-06','20:00:00.000000','23:59:00.000000','available',132,'2026-07-27 16:22:53.392463',''),
(373,'2026-10-06','18:00:00.000000','23:00:00.000000','available',133,'2026-07-27 16:22:53.392463',''),
(374,'2026-10-07','20:00:00.000000','23:59:00.000000','available',134,'2026-07-27 16:22:53.407914',''),
(375,'2026-10-07','18:00:00.000000','23:00:00.000000','available',135,'2026-07-27 16:22:53.412138',''),
(376,'2026-10-08','20:00:00.000000','23:59:00.000000','available',136,'2026-07-27 16:22:53.412138',''),
(377,'2026-10-08','18:00:00.000000','23:00:00.000000','available',137,'2026-07-27 16:22:53.412138',''),
(378,'2026-10-09','20:00:00.000000','23:59:00.000000','available',138,'2026-07-27 16:22:53.412138',''),
(379,'2026-10-09','18:00:00.000000','23:00:00.000000','available',139,'2026-07-27 16:22:53.412138',''),
(380,'2026-10-10','20:00:00.000000','23:59:00.000000','available',140,'2026-07-27 16:22:53.412138',''),
(381,'2026-10-10','18:00:00.000000','23:00:00.000000','available',141,'2026-07-27 16:22:53.426057',''),
(382,'2026-10-11','20:00:00.000000','23:59:00.000000','available',142,'2026-07-27 16:22:53.426057',''),
(383,'2026-10-11','18:00:00.000000','23:00:00.000000','available',143,'2026-07-27 16:22:53.426057',''),
(384,'2026-10-12','20:00:00.000000','23:59:00.000000','available',144,'2026-07-27 16:22:53.426057',''),
(385,'2026-10-12','18:00:00.000000','23:00:00.000000','available',145,'2026-07-27 16:22:53.426057',''),
(386,'2026-10-13','20:00:00.000000','23:59:00.000000','available',146,'2026-07-27 16:22:53.426057',''),
(387,'2026-10-13','18:00:00.000000','23:00:00.000000','available',147,'2026-07-27 16:22:53.442297',''),
(388,'2026-10-14','20:00:00.000000','23:59:00.000000','available',148,'2026-07-27 16:22:53.442297',''),
(389,'2026-10-14','18:00:00.000000','23:00:00.000000','available',149,'2026-07-27 16:22:53.442297',''),
(390,'2026-10-15','20:00:00.000000','23:59:00.000000','available',150,'2026-07-27 16:22:53.442297',''),
(391,'2026-10-15','18:00:00.000000','23:00:00.000000','available',151,'2026-07-27 16:22:53.442297',''),
(392,'2026-10-16','20:00:00.000000','23:59:00.000000','available',152,'2026-07-27 16:22:53.456312',''),
(393,'2026-10-16','18:00:00.000000','23:00:00.000000','available',153,'2026-07-27 16:22:53.459001',''),
(394,'2026-10-17','20:00:00.000000','23:59:00.000000','available',154,'2026-07-27 16:22:53.459001',''),
(395,'2026-10-17','18:00:00.000000','23:00:00.000000','available',155,'2026-07-27 16:22:53.459001',''),
(396,'2026-10-18','20:00:00.000000','23:59:00.000000','available',156,'2026-07-27 16:22:53.459001',''),
(397,'2026-10-18','18:00:00.000000','23:00:00.000000','available',157,'2026-07-27 16:22:53.459001',''),
(398,'2026-10-19','20:00:00.000000','23:59:00.000000','available',158,'2026-07-27 16:22:53.459001',''),
(399,'2026-10-19','18:00:00.000000','23:00:00.000000','available',159,'2026-07-27 16:22:53.459001',''),
(400,'2026-10-20','20:00:00.000000','23:59:00.000000','available',160,'2026-07-27 16:22:53.475659',''),
(401,'2026-10-20','18:00:00.000000','23:00:00.000000','available',161,'2026-07-27 16:22:53.475659',''),
(402,'2026-10-21','20:00:00.000000','23:59:00.000000','available',162,'2026-07-27 16:22:53.475659',''),
(403,'2026-10-21','18:00:00.000000','23:00:00.000000','available',163,'2026-07-27 16:22:53.475659',''),
(404,'2026-10-22','20:00:00.000000','23:59:00.000000','available',164,'2026-07-27 16:22:53.475659',''),
(405,'2026-10-22','18:00:00.000000','23:00:00.000000','available',165,'2026-07-27 16:22:53.490587',''),
(406,'2026-10-23','20:00:00.000000','23:59:00.000000','available',166,'2026-07-27 16:22:53.492217',''),
(407,'2026-10-23','18:00:00.000000','23:00:00.000000','available',167,'2026-07-27 16:22:53.492217',''),
(408,'2026-10-24','20:00:00.000000','23:59:00.000000','available',168,'2026-07-27 16:22:53.492217',''),
(409,'2026-10-24','18:00:00.000000','23:00:00.000000','available',169,'2026-07-27 16:22:53.492217',''),
(410,'2026-10-25','20:00:00.000000','23:59:00.000000','available',170,'2026-07-27 16:22:53.492217',''),
(411,'2026-10-25','18:00:00.000000','23:00:00.000000','available',171,'2026-07-27 16:22:53.492217',''),
(412,'2026-10-26','20:00:00.000000','23:59:00.000000','available',172,'2026-07-27 16:22:53.508908',''),
(413,'2026-10-26','18:00:00.000000','23:00:00.000000','available',173,'2026-07-27 16:22:53.508908',''),
(414,'2026-10-27','20:00:00.000000','23:59:00.000000','available',174,'2026-07-27 16:22:53.508908',''),
(415,'2026-10-27','18:00:00.000000','23:00:00.000000','available',175,'2026-07-27 16:22:53.508908',''),
(416,'2026-10-28','20:00:00.000000','23:59:00.000000','available',176,'2026-07-27 16:22:53.508908',''),
(417,'2026-10-28','18:00:00.000000','23:00:00.000000','available',177,'2026-07-27 16:22:53.508908',''),
(418,'2026-10-29','20:00:00.000000','23:59:00.000000','available',178,'2026-07-27 16:22:53.525561',''),
(419,'2026-10-29','18:00:00.000000','23:00:00.000000','available',179,'2026-07-27 16:22:53.525561',''),
(420,'2026-10-30','20:00:00.000000','23:59:00.000000','available',180,'2026-07-27 16:22:53.525561',''),
(421,'2026-10-30','18:00:00.000000','23:00:00.000000','available',181,'2026-07-27 16:22:53.525561',''),
(422,'2026-10-31','20:00:00.000000','23:59:00.000000','available',182,'2026-07-27 16:22:53.525561',''),
(423,'2026-10-31','18:00:00.000000','23:00:00.000000','available',183,'2026-07-27 16:22:53.525561',''),
(424,'2026-11-01','20:00:00.000000','23:59:00.000000','available',184,'2026-07-27 16:22:53.541039',''),
(425,'2026-11-01','18:00:00.000000','23:00:00.000000','available',185,'2026-07-27 16:22:53.542411',''),
(426,'2026-11-02','20:00:00.000000','23:59:00.000000','available',186,'2026-07-27 16:22:53.542411',''),
(427,'2026-11-02','18:00:00.000000','23:00:00.000000','available',187,'2026-07-27 16:22:53.542411',''),
(428,'2026-11-03','20:00:00.000000','23:59:00.000000','available',188,'2026-07-27 16:22:53.542411',''),
(429,'2026-11-03','18:00:00.000000','23:00:00.000000','available',189,'2026-07-27 16:22:53.542411',''),
(430,'2026-11-04','20:00:00.000000','23:59:00.000000','available',190,'2026-07-27 16:22:53.556517',''),
(431,'2026-11-04','18:00:00.000000','23:00:00.000000','available',191,'2026-07-27 16:22:53.558844',''),
(432,'2026-11-05','20:00:00.000000','23:59:00.000000','available',192,'2026-07-27 16:22:53.558844',''),
(433,'2026-11-05','18:00:00.000000','23:00:00.000000','available',193,'2026-07-27 16:22:53.558844',''),
(434,'2026-11-06','20:00:00.000000','23:59:00.000000','available',194,'2026-07-27 16:22:53.558844',''),
(435,'2026-11-06','18:00:00.000000','23:00:00.000000','available',195,'2026-07-27 16:22:53.558844',''),
(436,'2026-11-07','20:00:00.000000','23:59:00.000000','available',196,'2026-07-27 16:22:53.558844',''),
(437,'2026-11-07','18:00:00.000000','23:00:00.000000','available',197,'2026-07-27 16:22:53.575561',''),
(438,'2026-11-08','20:00:00.000000','23:59:00.000000','available',198,'2026-07-27 16:22:53.577838',''),
(439,'2026-11-08','18:00:00.000000','23:00:00.000000','available',199,'2026-07-27 16:22:53.581770',''),
(440,'2026-11-09','20:00:00.000000','23:59:00.000000','available',200,'2026-07-27 16:22:53.581770',''),
(441,'2026-11-09','18:00:00.000000','23:00:00.000000','available',101,'2026-07-27 16:22:53.581770',''),
(442,'2026-11-10','20:00:00.000000','23:59:00.000000','available',102,'2026-07-27 16:22:53.581770',''),
(443,'2026-11-10','18:00:00.000000','23:00:00.000000','available',103,'2026-07-27 16:22:53.592175',''),
(444,'2026-11-11','20:00:00.000000','23:59:00.000000','available',104,'2026-07-27 16:22:53.592175',''),
(445,'2026-11-11','18:00:00.000000','23:00:00.000000','available',105,'2026-07-27 16:22:53.592175',''),
(446,'2026-11-12','20:00:00.000000','23:59:00.000000','available',106,'2026-07-27 16:22:53.592175',''),
(447,'2026-11-12','18:00:00.000000','23:00:00.000000','available',107,'2026-07-27 16:22:53.592175',''),
(448,'2026-11-13','20:00:00.000000','23:59:00.000000','available',108,'2026-07-27 16:22:53.592175',''),
(449,'2026-11-13','18:00:00.000000','23:00:00.000000','available',109,'2026-07-27 16:22:53.607666',''),
(450,'2026-11-14','20:00:00.000000','23:59:00.000000','available',110,'2026-07-27 16:22:53.608908',''),
(451,'2026-11-14','18:00:00.000000','23:00:00.000000','available',111,'2026-07-27 16:22:53.608908',''),
(452,'2026-11-15','20:00:00.000000','23:59:00.000000','available',112,'2026-07-27 16:22:53.608908',''),
(453,'2026-11-15','18:00:00.000000','23:00:00.000000','available',113,'2026-07-27 16:22:53.608908',''),
(454,'2026-11-16','20:00:00.000000','23:59:00.000000','available',114,'2026-07-27 16:22:53.608908',''),
(455,'2026-11-16','18:00:00.000000','23:00:00.000000','available',115,'2026-07-27 16:22:53.608908',''),
(456,'2026-11-17','20:00:00.000000','23:59:00.000000','available',116,'2026-07-27 16:22:53.625580',''),
(457,'2026-11-17','18:00:00.000000','23:00:00.000000','available',117,'2026-07-27 16:22:53.625580',''),
(458,'2026-11-18','20:00:00.000000','23:59:00.000000','available',118,'2026-07-27 16:22:53.625580',''),
(459,'2026-11-18','18:00:00.000000','23:00:00.000000','available',119,'2026-07-27 16:22:53.625580',''),
(460,'2026-11-19','20:00:00.000000','23:59:00.000000','available',120,'2026-07-27 16:22:53.625580',''),
(461,'2026-11-19','18:00:00.000000','23:00:00.000000','available',121,'2026-07-27 16:22:53.625580',''),
(462,'2026-11-20','20:00:00.000000','23:59:00.000000','available',122,'2026-07-27 16:22:53.642289',''),
(463,'2026-11-20','18:00:00.000000','23:00:00.000000','available',123,'2026-07-27 16:22:53.644231',''),
(464,'2026-11-21','20:00:00.000000','23:59:00.000000','available',124,'2026-07-27 16:22:53.644231',''),
(465,'2026-11-21','18:00:00.000000','23:00:00.000000','available',125,'2026-07-27 16:22:53.644231',''),
(466,'2026-11-22','20:00:00.000000','23:59:00.000000','available',126,'2026-07-27 16:22:53.644231',''),
(467,'2026-11-22','18:00:00.000000','23:00:00.000000','available',127,'2026-07-27 16:22:53.644231',''),
(468,'2026-11-23','20:00:00.000000','23:59:00.000000','available',128,'2026-07-27 16:22:53.657032',''),
(469,'2026-11-23','18:00:00.000000','23:00:00.000000','available',129,'2026-07-27 16:22:53.658823',''),
(470,'2026-11-24','20:00:00.000000','23:59:00.000000','available',130,'2026-07-27 16:22:53.658823',''),
(471,'2026-11-24','18:00:00.000000','23:00:00.000000','available',131,'2026-07-27 16:22:53.658823',''),
(472,'2026-11-25','20:00:00.000000','23:59:00.000000','available',132,'2026-07-27 16:22:53.658823',''),
(473,'2026-11-25','18:00:00.000000','23:00:00.000000','available',133,'2026-07-27 16:22:53.658823',''),
(474,'2026-11-26','20:00:00.000000','23:59:00.000000','available',134,'2026-07-27 16:22:53.658823',''),
(475,'2026-11-26','18:00:00.000000','23:00:00.000000','available',135,'2026-07-27 16:22:53.658823',''),
(476,'2026-11-27','20:00:00.000000','23:59:00.000000','available',136,'2026-07-27 16:22:53.675646',''),
(477,'2026-11-27','18:00:00.000000','23:00:00.000000','available',137,'2026-07-27 16:22:53.675646',''),
(478,'2026-11-28','20:00:00.000000','23:59:00.000000','available',138,'2026-07-27 16:22:53.675646',''),
(479,'2026-11-28','18:00:00.000000','23:00:00.000000','available',139,'2026-07-27 16:22:53.675646',''),
(480,'2026-11-29','20:00:00.000000','23:59:00.000000','available',140,'2026-07-27 16:22:53.675646','');
/*!40000 ALTER TABLE `dj_availabilities` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `dj_profiles`
--

DROP TABLE IF EXISTS `dj_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dj_profiles` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `stage_name` varchar(100) NOT NULL,
  `bio` longtext NOT NULL,
  `base_hourly_rate` decimal(10,2) NOT NULL,
  `travel_rate_per_km` decimal(10,2) NOT NULL,
  `years_experience` smallint(5) unsigned NOT NULL CHECK (`years_experience` >= 0),
  `is_available` tinyint(1) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stage_name` (`stage_name`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `idx_dj_available` (`is_available`),
  CONSTRAINT `dj_profiles_user_id_77725f09_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `dj_base_hourly_rate_positive` CHECK (`base_hourly_rate` >= 0),
  CONSTRAINT `dj_travel_rate_positive` CHECK (`travel_rate_per_km` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dj_profiles`
--

LOCK TABLES `dj_profiles` WRITE;
/*!40000 ALTER TABLE `dj_profiles` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `dj_profiles` VALUES
(101,'DJ Horizon 001','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',92.00,0.60,3,1,343),
(102,'DJ Horizon 002','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',99.00,0.65,4,1,344),
(103,'DJ Horizon 003','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',106.00,0.70,5,1,345),
(104,'DJ Horizon 004','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',113.00,0.75,6,1,346),
(105,'DJ Horizon 005','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',120.00,0.55,7,1,347),
(106,'DJ Horizon 006','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',127.00,0.60,8,1,348),
(107,'DJ Horizon 007','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',134.00,0.65,9,1,349),
(108,'DJ Horizon 008','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',141.00,0.70,10,1,350),
(109,'DJ Horizon 009','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',148.00,0.75,11,1,351),
(110,'DJ Horizon 010','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',155.00,0.55,12,1,352),
(111,'DJ Horizon 011','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',162.00,0.60,13,1,353),
(112,'DJ Horizon 012','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',85.00,0.65,14,1,354),
(113,'DJ Horizon 013','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',92.00,0.70,15,1,355),
(114,'DJ Horizon 014','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',99.00,0.75,16,1,356),
(115,'DJ Horizon 015','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',106.00,0.55,17,1,357),
(116,'DJ Horizon 016','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',113.00,0.60,18,1,358),
(117,'DJ Horizon 017','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',120.00,0.65,19,1,359),
(118,'DJ Horizon 018','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',127.00,0.70,2,1,360),
(119,'DJ Horizon 019','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',134.00,0.75,3,1,361),
(120,'DJ Horizon 020','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',141.00,0.55,4,1,362),
(121,'DJ Horizon 021','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',148.00,0.60,5,1,363),
(122,'DJ Horizon 022','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',155.00,0.65,6,1,364),
(123,'DJ Horizon 023','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',162.00,0.70,7,1,365),
(124,'DJ Horizon 024','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',85.00,0.75,8,1,366),
(125,'DJ Horizon 025','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',92.00,0.55,9,1,367),
(126,'DJ Horizon 026','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',99.00,0.60,10,1,368),
(127,'DJ Horizon 027','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',106.00,0.65,11,1,369),
(128,'DJ Horizon 028','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',113.00,0.70,12,1,370),
(129,'DJ Horizon 029','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',120.00,0.75,13,1,371),
(130,'DJ Horizon 030','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',127.00,0.55,14,1,372),
(131,'DJ Horizon 031','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',134.00,0.60,15,1,373),
(132,'DJ Horizon 032','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',141.00,0.65,16,1,374),
(133,'DJ Horizon 033','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',148.00,0.70,17,1,375),
(134,'DJ Horizon 034','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',155.00,0.75,18,1,376),
(135,'DJ Horizon 035','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',162.00,0.55,19,1,377),
(136,'DJ Horizon 036','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',85.00,0.60,2,1,378),
(137,'DJ Horizon 037','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',92.00,0.65,3,1,379),
(138,'DJ Horizon 038','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',99.00,0.70,4,1,380),
(139,'DJ Horizon 039','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',106.00,0.75,5,1,381),
(140,'DJ Horizon 040','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',113.00,0.55,6,1,382),
(141,'DJ Horizon 041','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',120.00,0.60,7,1,383),
(142,'DJ Horizon 042','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',127.00,0.65,8,1,384),
(143,'DJ Horizon 043','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',134.00,0.70,9,1,385),
(144,'DJ Horizon 044','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',141.00,0.75,10,1,386),
(145,'DJ Horizon 045','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',148.00,0.55,11,1,387),
(146,'DJ Horizon 046','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',155.00,0.60,12,1,388),
(147,'DJ Horizon 047','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',162.00,0.65,13,1,389),
(148,'DJ Horizon 048','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',85.00,0.70,14,1,390),
(149,'DJ Horizon 049','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',92.00,0.75,15,1,391),
(150,'DJ Horizon 050','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',99.00,0.55,16,1,392),
(151,'DJ Horizon 051','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',106.00,0.60,17,1,393),
(152,'DJ Horizon 052','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',113.00,0.65,18,1,394),
(153,'DJ Horizon 053','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',120.00,0.70,19,1,395),
(154,'DJ Horizon 054','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',127.00,0.75,2,1,396),
(155,'DJ Horizon 055','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',134.00,0.55,3,1,397),
(156,'DJ Horizon 056','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',141.00,0.60,4,1,398),
(157,'DJ Horizon 057','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',148.00,0.65,5,1,399),
(158,'DJ Horizon 058','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',155.00,0.70,6,1,400),
(159,'DJ Horizon 059','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',162.00,0.75,7,1,401),
(160,'DJ Horizon 060','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',85.00,0.55,8,1,402),
(161,'DJ Horizon 061','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',92.00,0.60,9,1,403),
(162,'DJ Horizon 062','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',99.00,0.65,10,1,404),
(163,'DJ Horizon 063','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',106.00,0.70,11,1,405),
(164,'DJ Horizon 064','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',113.00,0.75,12,1,406),
(165,'DJ Horizon 065','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',120.00,0.55,13,1,407),
(166,'DJ Horizon 066','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',127.00,0.60,14,1,408),
(167,'DJ Horizon 067','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',134.00,0.65,15,1,409),
(168,'DJ Horizon 068','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',141.00,0.70,16,1,410),
(169,'DJ Horizon 069','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',148.00,0.75,17,1,411),
(170,'DJ Horizon 070','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',155.00,0.55,18,1,412),
(171,'DJ Horizon 071','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',162.00,0.60,19,1,413),
(172,'DJ Horizon 072','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',85.00,0.65,2,1,414),
(173,'DJ Horizon 073','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',92.00,0.70,3,1,415),
(174,'DJ Horizon 074','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',99.00,0.75,4,1,416),
(175,'DJ Horizon 075','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',106.00,0.55,5,1,417),
(176,'DJ Horizon 076','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',113.00,0.60,6,1,418),
(177,'DJ Horizon 077','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',120.00,0.65,7,1,419),
(178,'DJ Horizon 078','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',127.00,0.70,8,1,420),
(179,'DJ Horizon 079','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',134.00,0.75,9,1,421),
(180,'DJ Horizon 080','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',141.00,0.55,10,1,422),
(181,'DJ Horizon 081','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',148.00,0.60,11,1,423),
(182,'DJ Horizon 082','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',155.00,0.65,12,1,424),
(183,'DJ Horizon 083','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',162.00,0.70,13,1,425),
(184,'DJ Horizon 084','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',85.00,0.75,14,1,426),
(185,'DJ Horizon 085','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',92.00,0.55,15,1,427),
(186,'DJ Horizon 086','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',99.00,0.60,16,1,428),
(187,'DJ Horizon 087','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',106.00,0.65,17,1,429),
(188,'DJ Horizon 088','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',113.00,0.70,18,1,430),
(189,'DJ Horizon 089','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',120.00,0.75,19,1,431),
(190,'DJ Horizon 090','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',127.00,0.55,2,1,432),
(191,'DJ Horizon 091','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',134.00,0.60,3,1,433),
(192,'DJ Horizon 092','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',141.00,0.65,4,1,434),
(193,'DJ Horizon 093','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',148.00,0.70,5,1,435),
(194,'DJ Horizon 094','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',155.00,0.75,6,1,436),
(195,'DJ Horizon 095','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',162.00,0.55,7,1,437),
(196,'DJ Horizon 096','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',85.00,0.60,8,1,438),
(197,'DJ Horizon 097','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',92.00,0.65,9,1,439),
(198,'DJ Horizon 098','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',99.00,0.70,10,1,440),
(199,'DJ Horizon 099','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',106.00,0.75,11,1,441),
(200,'DJ Horizon 100','DJ professionnel spécialisé dans les événements privés et professionnels en Belgique. Expérience adaptée aux mariages, anniversaires et soirées d\'entreprise.',113.00,0.55,12,1,442);
/*!40000 ALTER TABLE `dj_profiles` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `dj_profiles_music_styles`
--

DROP TABLE IF EXISTS `dj_profiles_music_styles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `dj_profiles_music_styles` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `djprofile_id` bigint(20) NOT NULL,
  `musicstyle_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dj_profiles_music_styles_djprofile_id_musicstyle__eb786132_uniq` (`djprofile_id`,`musicstyle_id`),
  KEY `dj_profiles_music_st_musicstyle_id_b125fa6d_fk_music_sty` (`musicstyle_id`),
  CONSTRAINT `dj_profiles_music_st_musicstyle_id_b125fa6d_fk_music_sty` FOREIGN KEY (`musicstyle_id`) REFERENCES `music_styles` (`id`),
  CONSTRAINT `dj_profiles_music_styles_djprofile_id_39ccf4aa_fk_dj_profiles_id` FOREIGN KEY (`djprofile_id`) REFERENCES `dj_profiles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=601 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dj_profiles_music_styles`
--

LOCK TABLES `dj_profiles_music_styles` WRITE;
/*!40000 ALTER TABLE `dj_profiles_music_styles` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `dj_profiles_music_styles` VALUES
(302,101,14),
(301,101,18),
(303,101,22),
(306,102,15),
(304,102,19),
(305,102,23),
(307,103,16),
(309,103,20),
(308,103,24),
(312,104,13),
(310,104,17),
(311,104,21),
(314,105,14),
(313,105,18),
(315,105,22),
(318,106,15),
(316,106,19),
(317,106,23),
(319,107,16),
(321,107,20),
(320,107,24),
(324,108,13),
(322,108,17),
(323,108,21),
(326,109,14),
(325,109,18),
(327,109,22),
(330,110,15),
(328,110,19),
(329,110,23),
(331,111,16),
(333,111,20),
(332,111,24),
(336,112,13),
(334,112,17),
(335,112,21),
(338,113,14),
(337,113,18),
(339,113,22),
(342,114,15),
(340,114,19),
(341,114,23),
(343,115,16),
(345,115,20),
(344,115,24),
(348,116,13),
(346,116,17),
(347,116,21),
(350,117,14),
(349,117,18),
(351,117,22),
(354,118,15),
(352,118,19),
(353,118,23),
(355,119,16),
(357,119,20),
(356,119,24),
(360,120,13),
(358,120,17),
(359,120,21),
(362,121,14),
(361,121,18),
(363,121,22),
(366,122,15),
(364,122,19),
(365,122,23),
(367,123,16),
(369,123,20),
(368,123,24),
(372,124,13),
(370,124,17),
(371,124,21),
(374,125,14),
(373,125,18),
(375,125,22),
(378,126,15),
(376,126,19),
(377,126,23),
(379,127,16),
(381,127,20),
(380,127,24),
(384,128,13),
(382,128,17),
(383,128,21),
(386,129,14),
(385,129,18),
(387,129,22),
(390,130,15),
(388,130,19),
(389,130,23),
(391,131,16),
(393,131,20),
(392,131,24),
(396,132,13),
(394,132,17),
(395,132,21),
(398,133,14),
(397,133,18),
(399,133,22),
(402,134,15),
(400,134,19),
(401,134,23),
(403,135,16),
(405,135,20),
(404,135,24),
(408,136,13),
(406,136,17),
(407,136,21),
(410,137,14),
(409,137,18),
(411,137,22),
(414,138,15),
(412,138,19),
(413,138,23),
(415,139,16),
(417,139,20),
(416,139,24),
(420,140,13),
(418,140,17),
(419,140,21),
(422,141,14),
(421,141,18),
(423,141,22),
(426,142,15),
(424,142,19),
(425,142,23),
(427,143,16),
(429,143,20),
(428,143,24),
(432,144,13),
(430,144,17),
(431,144,21),
(434,145,14),
(433,145,18),
(435,145,22),
(438,146,15),
(436,146,19),
(437,146,23),
(439,147,16),
(441,147,20),
(440,147,24),
(444,148,13),
(442,148,17),
(443,148,21),
(446,149,14),
(445,149,18),
(447,149,22),
(450,150,15),
(448,150,19),
(449,150,23),
(451,151,16),
(453,151,20),
(452,151,24),
(456,152,13),
(454,152,17),
(455,152,21),
(458,153,14),
(457,153,18),
(459,153,22),
(462,154,15),
(460,154,19),
(461,154,23),
(463,155,16),
(465,155,20),
(464,155,24),
(468,156,13),
(466,156,17),
(467,156,21),
(470,157,14),
(469,157,18),
(471,157,22),
(474,158,15),
(472,158,19),
(473,158,23),
(475,159,16),
(477,159,20),
(476,159,24),
(480,160,13),
(478,160,17),
(479,160,21),
(482,161,14),
(481,161,18),
(483,161,22),
(486,162,15),
(484,162,19),
(485,162,23),
(487,163,16),
(489,163,20),
(488,163,24),
(492,164,13),
(490,164,17),
(491,164,21),
(494,165,14),
(493,165,18),
(495,165,22),
(498,166,15),
(496,166,19),
(497,166,23),
(499,167,16),
(501,167,20),
(500,167,24),
(504,168,13),
(502,168,17),
(503,168,21),
(506,169,14),
(505,169,18),
(507,169,22),
(510,170,15),
(508,170,19),
(509,170,23),
(511,171,16),
(513,171,20),
(512,171,24),
(516,172,13),
(514,172,17),
(515,172,21),
(518,173,14),
(517,173,18),
(519,173,22),
(522,174,15),
(520,174,19),
(521,174,23),
(523,175,16),
(525,175,20),
(524,175,24),
(528,176,13),
(526,176,17),
(527,176,21),
(530,177,14),
(529,177,18),
(531,177,22),
(534,178,15),
(532,178,19),
(533,178,23),
(535,179,16),
(537,179,20),
(536,179,24),
(540,180,13),
(538,180,17),
(539,180,21),
(542,181,14),
(541,181,18),
(543,181,22),
(546,182,15),
(544,182,19),
(545,182,23),
(547,183,16),
(549,183,20),
(548,183,24),
(552,184,13),
(550,184,17),
(551,184,21),
(554,185,14),
(553,185,18),
(555,185,22),
(558,186,15),
(556,186,19),
(557,186,23),
(559,187,16),
(561,187,20),
(560,187,24),
(564,188,13),
(562,188,17),
(563,188,21),
(566,189,14),
(565,189,18),
(567,189,22),
(570,190,15),
(568,190,19),
(569,190,23),
(571,191,16),
(573,191,20),
(572,191,24),
(576,192,13),
(574,192,17),
(575,192,21),
(578,193,14),
(577,193,18),
(579,193,22),
(582,194,15),
(580,194,19),
(581,194,23),
(583,195,16),
(585,195,20),
(584,195,24),
(588,196,13),
(586,196,17),
(587,196,21),
(590,197,14),
(589,197,18),
(591,197,22),
(594,198,15),
(592,198,19),
(593,198,23),
(595,199,16),
(597,199,20),
(596,199,24),
(600,200,13),
(598,200,17),
(599,200,21);
/*!40000 ALTER TABLE `dj_profiles_music_styles` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext DEFAULT NULL,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) unsigned NOT NULL CHECK (`action_flag` >= 0),
  `change_message` longtext NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_auth_user_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `django_admin_log` VALUES
(1,'2026-08-13 21:56:22.669532','1','Remboursement 100 EUR - paiement #132',1,'[{\"added\": {}}]',27,443);
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `django_content_type` VALUES
(31,'accounts','accountdeletionrequest'),
(7,'accounts','clientprofile'),
(32,'accounts','djapplication'),
(8,'accounts','djprofile'),
(1,'admin','logentry'),
(3,'auth','group'),
(2,'auth','permission'),
(4,'auth','user'),
(14,'availability','djavailability'),
(15,'bookings','booking'),
(20,'bookings','bookingequipment'),
(28,'bookings','cancellationrequest'),
(21,'bookings','contract'),
(16,'bookings','playlist'),
(17,'bookings','playlistsong'),
(22,'bookings','preparatoryappointment'),
(18,'bookings','quote'),
(23,'bookings','quoteoption'),
(24,'bookings','review'),
(19,'bookings','venue'),
(13,'catalog','equipment'),
(9,'catalog','eventtype'),
(10,'catalog','musicstyle'),
(11,'catalog','package'),
(12,'catalog','serviceoption'),
(5,'contenttypes','contenttype'),
(25,'payments','invoice'),
(26,'payments','payment'),
(27,'payments','refund'),
(6,'sessions','session'),
(29,'token_blacklist','blacklistedtoken'),
(30,'token_blacklist','outstandingtoken');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_migrations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `django_migrations` VALUES
(1,'catalog','0001_initial','2026-07-26 18:44:34.496788'),
(2,'catalog','0002_equipment_alter_eventtype_options_and_more','2026-07-26 18:44:34.997753'),
(3,'contenttypes','0001_initial','2026-07-26 18:44:35.084715'),
(4,'auth','0001_initial','2026-07-26 18:44:35.949301'),
(5,'accounts','0001_initial','2026-07-26 18:44:36.173972'),
(6,'accounts','0002_alter_clientprofile_options_alter_djprofile_options_and_more','2026-07-26 18:44:36.755383'),
(7,'admin','0001_initial','2026-07-26 18:44:36.932563'),
(8,'admin','0002_logentry_remove_auto_add','2026-07-26 18:44:36.945871'),
(9,'admin','0003_logentry_add_action_flag_choices','2026-07-26 18:44:36.952163'),
(10,'contenttypes','0002_remove_content_type_name','2026-07-26 18:44:37.079143'),
(11,'auth','0002_alter_permission_name_max_length','2026-07-26 18:44:37.163357'),
(12,'auth','0003_alter_user_email_max_length','2026-07-26 18:44:37.222237'),
(13,'auth','0004_alter_user_username_opts','2026-07-26 18:44:37.229229'),
(14,'auth','0005_alter_user_last_login_null','2026-07-26 18:44:37.312123'),
(15,'auth','0006_require_contenttypes_0002','2026-07-26 18:44:37.312475'),
(16,'auth','0007_alter_validators_add_error_messages','2026-07-26 18:44:37.322560'),
(17,'auth','0008_alter_user_username_max_length','2026-07-26 18:44:37.377366'),
(18,'auth','0009_alter_user_last_name_max_length','2026-07-26 18:44:37.429260'),
(19,'auth','0010_alter_group_name_max_length','2026-07-26 18:44:37.479487'),
(20,'auth','0011_update_proxy_permissions','2026-07-26 18:44:37.495387'),
(21,'auth','0012_alter_user_first_name_max_length','2026-07-26 18:44:37.548446'),
(22,'availability','0001_initial','2026-07-26 18:44:37.746185'),
(23,'availability','0002_alter_djavailability_options_and_more','2026-07-26 18:44:37.997751'),
(24,'bookings','0001_initial','2026-07-26 18:44:39.696292'),
(25,'bookings','0002_bookingequipment_contract_preparatoryappointment_and_more','2026-07-26 18:44:42.449905'),
(26,'bookings','0003_quote_music_preferences','2026-07-26 18:44:42.512579'),
(27,'catalog','0003_distinguish_adult_and_child_birthdays','2026-07-26 18:44:42.530112'),
(28,'payments','0001_initial','2026-07-26 18:44:42.913616'),
(29,'payments','0002_alter_invoice_options_alter_payment_options_and_more','2026-07-26 18:44:43.303634'),
(30,'payments','0003_alter_payment_stripe_payment_intent_id','2026-07-26 18:44:43.406346'),
(31,'sessions','0001_initial','2026-07-26 18:44:43.496656'),
(32,'payments','0004_refund','2026-08-04 10:25:54.079081'),
(33,'bookings','0004_cancellationrequest','2026-08-04 10:51:26.225233'),
(34,'bookings','0005_cancellationrequest_review_message','2026-08-04 11:01:04.353990'),
(35,'token_blacklist','0001_initial','2026-08-04 15:16:34.110646'),
(36,'token_blacklist','0002_outstandingtoken_jti_hex','2026-08-04 15:16:34.167522'),
(37,'token_blacklist','0003_auto_20171017_2007','2026-08-04 15:16:34.192453'),
(38,'token_blacklist','0004_auto_20171017_2013','2026-08-04 15:16:34.332677'),
(39,'token_blacklist','0005_remove_outstandingtoken_jti','2026-08-04 15:16:34.393689'),
(40,'token_blacklist','0006_auto_20171017_2113','2026-08-04 15:16:34.452472'),
(41,'token_blacklist','0007_auto_20171017_2214','2026-08-04 15:16:34.993804'),
(42,'token_blacklist','0008_migrate_to_bigautofield','2026-08-04 15:16:35.527970'),
(43,'token_blacklist','0010_fix_migrate_to_bigautofield','2026-08-04 15:16:35.607439'),
(44,'token_blacklist','0011_linearizes_history','2026-08-04 15:16:35.607439'),
(45,'token_blacklist','0012_alter_outstandingtoken_user','2026-08-04 15:16:35.643536'),
(46,'token_blacklist','0013_alter_blacklistedtoken_options_and_more','2026-08-04 15:16:35.656098'),
(47,'accounts','0003_accountdeletionrequest','2026-08-04 16:23:38.295084'),
(48,'accounts','0004_remove_accountdeletionrequest_unique_pending_account_deletion','2026-08-04 16:24:11.725422'),
(49,'catalog','0004_restrict_supported_offerings','2026-08-10 17:09:20.468673'),
(50,'catalog','0005_package_event_types','2026-08-10 17:22:56.353182'),
(51,'accounts','0005_djapplication','2026-08-17 19:41:11.340858');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `django_session` VALUES
('wr85k04smfai7fwn8otn5r4lxfij7vtu','.eJxVjMsOwiAQRf-FtSEGhjC4dO83kHmArZqSlHZl_HdD0oVu7znnvk2mfZvy3suaZzUXA-DN6XdlkmdZBtIHLfdmpS3bOrMdij1ot7em5XU93L-Difo0alaEc1COhQWxBEmKEh2kWok9OPCqRV0FCpooStAKWIXQRXTK5vMFaL851A:1wudL1:fhuu5GPAB0mHyz3USxY9tnWxpytRset-h4ltvtXiuwM','2026-08-27 21:51:47.496960');
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `equipment`
--

DROP TABLE IF EXISTS `equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `equipment` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `category` varchar(60) NOT NULL,
  `name` varchar(120) NOT NULL,
  `serial_number` varchar(80) NOT NULL,
  `daily_cost` decimal(10,2) NOT NULL,
  `replacement_value` decimal(10,2) NOT NULL,
  `status` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `serial_number` (`serial_number`),
  KEY `idx_equipment_category_status` (`category`,`status`),
  CONSTRAINT `equipment_daily_cost_positive` CHECK (`daily_cost` >= 0),
  CONSTRAINT `equipment_replacement_value_positive` CHECK (`replacement_value` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=241 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipment`
--

LOCK TABLES `equipment` WRITE;
/*!40000 ALTER TABLE `equipment` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `equipment` VALUES
(121,'sonorisation','Yamaha DXR 101','UDJ-SON-0001',14.00,215.00,'available'),
(122,'eclairage','Pioneer CDJ 102','UDJ-ECL-0002',16.00,250.00,'available'),
(123,'dj_booth','Pioneer DJM 103','UDJ-DJ_-0003',18.00,285.00,'available'),
(124,'micro','Shure SM 104','UDJ-MIC-0004',20.00,320.00,'available'),
(125,'cablage','Chauvet Wash 105','UDJ-CAB-0005',22.00,355.00,'available'),
(126,'structure','ADJ Beam 106','UDJ-STR-0006',24.00,390.00,'available'),
(127,'sonorisation','Klotz Cable 107','UDJ-SON-0007',26.00,425.00,'available'),
(128,'eclairage','Gravity Stand 108','UDJ-ECL-0008',28.00,460.00,'available'),
(129,'dj_booth','Sennheiser EW 109','UDJ-DJ_-0009',30.00,495.00,'available'),
(130,'micro','Denon Prime 110','UDJ-MIC-0010',32.00,530.00,'available'),
(131,'cablage','Yamaha DXR 111','UDJ-CAB-0011',34.00,565.00,'available'),
(132,'structure','Pioneer CDJ 112','UDJ-STR-0012',36.00,600.00,'available'),
(133,'sonorisation','Pioneer DJM 113','UDJ-SON-0013',38.00,635.00,'available'),
(134,'eclairage','Shure SM 114','UDJ-ECL-0014',40.00,670.00,'available'),
(135,'dj_booth','Chauvet Wash 115','UDJ-DJ_-0015',42.00,705.00,'available'),
(136,'micro','ADJ Beam 116','UDJ-MIC-0016',44.00,740.00,'available'),
(137,'cablage','Klotz Cable 117','UDJ-CAB-0017',46.00,775.00,'available'),
(138,'structure','Gravity Stand 118','UDJ-STR-0018',48.00,810.00,'available'),
(139,'sonorisation','Sennheiser EW 119','UDJ-SON-0019',50.00,845.00,'available'),
(140,'eclairage','Denon Prime 120','UDJ-ECL-0020',12.00,880.00,'available'),
(141,'dj_booth','Yamaha DXR 121','UDJ-DJ_-0021',14.00,915.00,'available'),
(142,'micro','Pioneer CDJ 122','UDJ-MIC-0022',16.00,950.00,'available'),
(143,'cablage','Pioneer DJM 123','UDJ-CAB-0023',18.00,985.00,'available'),
(144,'structure','Shure SM 124','UDJ-STR-0024',20.00,1020.00,'available'),
(145,'sonorisation','Chauvet Wash 125','UDJ-SON-0025',22.00,1055.00,'available'),
(146,'eclairage','ADJ Beam 126','UDJ-ECL-0026',24.00,1090.00,'available'),
(147,'dj_booth','Klotz Cable 127','UDJ-DJ_-0027',26.00,1125.00,'available'),
(148,'micro','Gravity Stand 128','UDJ-MIC-0028',28.00,1160.00,'available'),
(149,'cablage','Sennheiser EW 129','UDJ-CAB-0029',30.00,1195.00,'available'),
(150,'structure','Denon Prime 130','UDJ-STR-0030',32.00,180.00,'available'),
(151,'sonorisation','Yamaha DXR 131','UDJ-SON-0031',34.00,215.00,'available'),
(152,'eclairage','Pioneer CDJ 132','UDJ-ECL-0032',36.00,250.00,'available'),
(153,'dj_booth','Pioneer DJM 133','UDJ-DJ_-0033',38.00,285.00,'available'),
(154,'micro','Shure SM 134','UDJ-MIC-0034',40.00,320.00,'available'),
(155,'cablage','Chauvet Wash 135','UDJ-CAB-0035',42.00,355.00,'available'),
(156,'structure','ADJ Beam 136','UDJ-STR-0036',44.00,390.00,'available'),
(157,'sonorisation','Klotz Cable 137','UDJ-SON-0037',46.00,425.00,'maintenance'),
(158,'eclairage','Gravity Stand 138','UDJ-ECL-0038',48.00,460.00,'available'),
(159,'dj_booth','Sennheiser EW 139','UDJ-DJ_-0039',50.00,495.00,'available'),
(160,'micro','Denon Prime 140','UDJ-MIC-0040',12.00,530.00,'available'),
(161,'cablage','Yamaha DXR 141','UDJ-CAB-0041',14.00,565.00,'available'),
(162,'structure','Pioneer CDJ 142','UDJ-STR-0042',16.00,600.00,'available'),
(163,'sonorisation','Pioneer DJM 143','UDJ-SON-0043',18.00,635.00,'available'),
(164,'eclairage','Shure SM 144','UDJ-ECL-0044',20.00,670.00,'available'),
(165,'dj_booth','Chauvet Wash 145','UDJ-DJ_-0045',22.00,705.00,'available'),
(166,'micro','ADJ Beam 146','UDJ-MIC-0046',24.00,740.00,'available'),
(167,'cablage','Klotz Cable 147','UDJ-CAB-0047',26.00,775.00,'available'),
(168,'structure','Gravity Stand 148','UDJ-STR-0048',28.00,810.00,'available'),
(169,'sonorisation','Sennheiser EW 149','UDJ-SON-0049',30.00,845.00,'available'),
(170,'eclairage','Denon Prime 150','UDJ-ECL-0050',32.00,880.00,'available'),
(171,'dj_booth','Yamaha DXR 151','UDJ-DJ_-0051',34.00,915.00,'available'),
(172,'micro','Pioneer CDJ 152','UDJ-MIC-0052',36.00,950.00,'available'),
(173,'cablage','Pioneer DJM 153','UDJ-CAB-0053',38.00,985.00,'available'),
(174,'structure','Shure SM 154','UDJ-STR-0054',40.00,1020.00,'available'),
(175,'sonorisation','Chauvet Wash 155','UDJ-SON-0055',42.00,1055.00,'available'),
(176,'eclairage','ADJ Beam 156','UDJ-ECL-0056',44.00,1090.00,'available'),
(177,'dj_booth','Klotz Cable 157','UDJ-DJ_-0057',46.00,1125.00,'available'),
(178,'micro','Gravity Stand 158','UDJ-MIC-0058',48.00,1160.00,'available'),
(179,'cablage','Sennheiser EW 159','UDJ-CAB-0059',50.00,1195.00,'available'),
(180,'structure','Denon Prime 160','UDJ-STR-0060',12.00,180.00,'available'),
(181,'sonorisation','Yamaha DXR 161','UDJ-SON-0061',14.00,215.00,'available'),
(182,'eclairage','Pioneer CDJ 162','UDJ-ECL-0062',16.00,250.00,'available'),
(183,'dj_booth','Pioneer DJM 163','UDJ-DJ_-0063',18.00,285.00,'available'),
(184,'micro','Shure SM 164','UDJ-MIC-0064',20.00,320.00,'available'),
(185,'cablage','Chauvet Wash 165','UDJ-CAB-0065',22.00,355.00,'available'),
(186,'structure','ADJ Beam 166','UDJ-STR-0066',24.00,390.00,'available'),
(187,'sonorisation','Klotz Cable 167','UDJ-SON-0067',26.00,425.00,'available'),
(188,'eclairage','Gravity Stand 168','UDJ-ECL-0068',28.00,460.00,'available'),
(189,'dj_booth','Sennheiser EW 169','UDJ-DJ_-0069',30.00,495.00,'available'),
(190,'micro','Denon Prime 170','UDJ-MIC-0070',32.00,530.00,'available'),
(191,'cablage','Yamaha DXR 171','UDJ-CAB-0071',34.00,565.00,'available'),
(192,'structure','Pioneer CDJ 172','UDJ-STR-0072',36.00,600.00,'available'),
(193,'sonorisation','Pioneer DJM 173','UDJ-SON-0073',38.00,635.00,'available'),
(194,'eclairage','Shure SM 174','UDJ-ECL-0074',40.00,670.00,'maintenance'),
(195,'dj_booth','Chauvet Wash 175','UDJ-DJ_-0075',42.00,705.00,'available'),
(196,'micro','ADJ Beam 176','UDJ-MIC-0076',44.00,740.00,'available'),
(197,'cablage','Klotz Cable 177','UDJ-CAB-0077',46.00,775.00,'available'),
(198,'structure','Gravity Stand 178','UDJ-STR-0078',48.00,810.00,'available'),
(199,'sonorisation','Sennheiser EW 179','UDJ-SON-0079',50.00,845.00,'available'),
(200,'eclairage','Denon Prime 180','UDJ-ECL-0080',12.00,880.00,'available'),
(201,'dj_booth','Yamaha DXR 181','UDJ-DJ_-0081',14.00,915.00,'available'),
(202,'micro','Pioneer CDJ 182','UDJ-MIC-0082',16.00,950.00,'available'),
(203,'cablage','Pioneer DJM 183','UDJ-CAB-0083',18.00,985.00,'available'),
(204,'structure','Shure SM 184','UDJ-STR-0084',20.00,1020.00,'available'),
(205,'sonorisation','Chauvet Wash 185','UDJ-SON-0085',22.00,1055.00,'available'),
(206,'eclairage','ADJ Beam 186','UDJ-ECL-0086',24.00,1090.00,'available'),
(207,'dj_booth','Klotz Cable 187','UDJ-DJ_-0087',26.00,1125.00,'available'),
(208,'micro','Gravity Stand 188','UDJ-MIC-0088',28.00,1160.00,'available'),
(209,'cablage','Sennheiser EW 189','UDJ-CAB-0089',30.00,1195.00,'available'),
(210,'structure','Denon Prime 190','UDJ-STR-0090',32.00,180.00,'available'),
(211,'sonorisation','Yamaha DXR 191','UDJ-SON-0091',34.00,215.00,'available'),
(212,'eclairage','Pioneer CDJ 192','UDJ-ECL-0092',36.00,250.00,'available'),
(213,'dj_booth','Pioneer DJM 193','UDJ-DJ_-0093',38.00,285.00,'available'),
(214,'micro','Shure SM 194','UDJ-MIC-0094',40.00,320.00,'available'),
(215,'cablage','Chauvet Wash 195','UDJ-CAB-0095',42.00,355.00,'available'),
(216,'structure','ADJ Beam 196','UDJ-STR-0096',44.00,390.00,'available'),
(217,'sonorisation','Klotz Cable 197','UDJ-SON-0097',46.00,425.00,'available'),
(218,'eclairage','Gravity Stand 198','UDJ-ECL-0098',48.00,460.00,'available'),
(219,'dj_booth','Sennheiser EW 199','UDJ-DJ_-0099',50.00,495.00,'available'),
(220,'micro','Denon Prime 200','UDJ-MIC-0100',12.00,530.00,'available'),
(221,'cablage','Yamaha DXR 201','UDJ-CAB-0101',14.00,565.00,'available'),
(222,'structure','Pioneer CDJ 202','UDJ-STR-0102',16.00,600.00,'available'),
(223,'sonorisation','Pioneer DJM 203','UDJ-SON-0103',18.00,635.00,'available'),
(224,'eclairage','Shure SM 204','UDJ-ECL-0104',20.00,670.00,'available'),
(225,'dj_booth','Chauvet Wash 205','UDJ-DJ_-0105',22.00,705.00,'available'),
(226,'micro','ADJ Beam 206','UDJ-MIC-0106',24.00,740.00,'available'),
(227,'cablage','Klotz Cable 207','UDJ-CAB-0107',26.00,775.00,'available'),
(228,'structure','Gravity Stand 208','UDJ-STR-0108',28.00,810.00,'available'),
(229,'sonorisation','Sennheiser EW 209','UDJ-SON-0109',30.00,845.00,'available'),
(230,'eclairage','Denon Prime 210','UDJ-ECL-0110',32.00,880.00,'available'),
(231,'dj_booth','Yamaha DXR 211','UDJ-DJ_-0111',34.00,915.00,'maintenance'),
(232,'micro','Pioneer CDJ 212','UDJ-MIC-0112',36.00,950.00,'available'),
(233,'cablage','Pioneer DJM 213','UDJ-CAB-0113',38.00,985.00,'available'),
(234,'structure','Shure SM 214','UDJ-STR-0114',40.00,1020.00,'available'),
(235,'sonorisation','Chauvet Wash 215','UDJ-SON-0115',42.00,1055.00,'available'),
(236,'eclairage','ADJ Beam 216','UDJ-ECL-0116',44.00,1090.00,'available'),
(237,'dj_booth','Klotz Cable 217','UDJ-DJ_-0117',46.00,1125.00,'available'),
(238,'micro','Gravity Stand 218','UDJ-MIC-0118',48.00,1160.00,'available'),
(239,'cablage','Sennheiser EW 219','UDJ-CAB-0119',50.00,1195.00,'available'),
(240,'structure','Denon Prime 220','UDJ-STR-0120',12.00,180.00,'available');
/*!40000 ALTER TABLE `equipment` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `event_types`
--

DROP TABLE IF EXISTS `event_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  `requires_preparatory_meeting` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_types`
--

LOCK TABLES `event_types` WRITE;
/*!40000 ALTER TABLE `event_types` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `event_types` VALUES
(1,'Anniversaire enfant',0),
(10,'Mariage',1),
(11,'Anniversaire adulte',0),
(12,'Soirée d\'entreprise',1),
(13,'Bal étudiant',0),
(14,'Baptême',0),
(15,'Fête communale',1),
(16,'Soirée privée',0),
(17,'Événement associatif',1);
/*!40000 ALTER TABLE `event_types` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `invoice_number` varchar(40) NOT NULL,
  `invoice_type` varchar(20) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` varchar(20) NOT NULL,
  `issued_at` datetime(6) NOT NULL,
  `due_at` datetime(6) NOT NULL,
  `booking_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_number` (`invoice_number`),
  KEY `invoices_booking_id_aeea72d7_fk_bookings_id` (`booking_id`),
  KEY `idx_invoice_status` (`status`),
  CONSTRAINT `invoices_booking_id_aeea72d7_fk_bookings_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  CONSTRAINT `invoice_amount_positive` CHECK (`amount` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=131 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `invoices` VALUES
(1,'UDJ-INV-2026-0001','deposit',226.69,'paid','2026-04-16 08:00:00.000000','2026-04-23 08:00:00.000000',1),
(2,'UDJ-INV-2026-0002','balance',528.93,'paid','2026-06-05 08:00:00.000000','2026-06-12 08:00:00.000000',1),
(3,'UDJ-INV-2026-0003','deposit',284.59,'paid','2026-04-17 08:00:00.000000','2026-04-24 08:00:00.000000',2),
(4,'UDJ-INV-2026-0004','balance',664.05,'sent','2026-06-06 08:00:00.000000','2026-06-13 08:00:00.000000',2),
(5,'UDJ-INV-2026-0005','deposit',342.50,'paid','2026-04-18 08:00:00.000000','2026-04-25 08:00:00.000000',3),
(6,'UDJ-INV-2026-0006','balance',799.16,'paid','2026-06-07 08:00:00.000000','2026-06-14 08:00:00.000000',3),
(7,'UDJ-INV-2026-0007','deposit',304.40,'sent','2026-04-19 08:00:00.000000','2026-04-26 08:00:00.000000',4),
(8,'UDJ-INV-2026-0008','balance',710.28,'sent','2026-06-08 08:00:00.000000','2026-06-15 08:00:00.000000',4),
(9,'UDJ-INV-2026-0009','deposit',362.31,'sent','2026-04-20 08:00:00.000000','2026-04-27 08:00:00.000000',5),
(10,'UDJ-INV-2026-0010','balance',845.39,'sent','2026-06-09 08:00:00.000000','2026-06-16 08:00:00.000000',5),
(11,'UDJ-INV-2026-0011','deposit',388.72,'paid','2026-04-21 08:00:00.000000','2026-04-28 08:00:00.000000',6),
(12,'UDJ-INV-2026-0012','balance',907.00,'sent','2026-06-10 08:00:00.000000','2026-06-17 08:00:00.000000',6),
(13,'UDJ-INV-2026-0013','deposit',446.62,'paid','2026-04-22 08:00:00.000000','2026-04-29 08:00:00.000000',7),
(14,'UDJ-INV-2026-0014','balance',1042.12,'sent','2026-06-11 08:00:00.000000','2026-06-18 08:00:00.000000',7),
(15,'UDJ-INV-2026-0015','deposit',408.53,'paid','2026-04-23 08:00:00.000000','2026-04-30 08:00:00.000000',8),
(16,'UDJ-INV-2026-0016','balance',953.23,'paid','2026-06-12 08:00:00.000000','2026-06-19 08:00:00.000000',8),
(17,'UDJ-INV-2026-0017','deposit',466.43,'sent','2026-04-24 08:00:00.000000','2026-05-01 08:00:00.000000',9),
(18,'UDJ-INV-2026-0018','balance',1088.35,'sent','2026-06-13 08:00:00.000000','2026-06-20 08:00:00.000000',9),
(19,'UDJ-INV-2026-0019','deposit',524.34,'sent','2026-04-25 08:00:00.000000','2026-05-02 08:00:00.000000',10),
(20,'UDJ-INV-2026-0020','balance',1223.46,'sent','2026-06-14 08:00:00.000000','2026-06-21 08:00:00.000000',10),
(21,'UDJ-INV-2026-0021','deposit',297.25,'paid','2026-04-26 08:00:00.000000','2026-05-03 08:00:00.000000',11),
(22,'UDJ-INV-2026-0022','balance',693.57,'sent','2026-06-15 08:00:00.000000','2026-06-22 08:00:00.000000',11),
(23,'UDJ-INV-2026-0023','deposit',227.65,'paid','2026-04-27 08:00:00.000000','2026-05-04 08:00:00.000000',12),
(24,'UDJ-INV-2026-0024','balance',531.19,'sent','2026-06-16 08:00:00.000000','2026-06-23 08:00:00.000000',12),
(25,'UDJ-INV-2026-0025','deposit',285.56,'paid','2026-04-28 08:00:00.000000','2026-05-05 08:00:00.000000',13),
(26,'UDJ-INV-2026-0026','balance',666.30,'paid','2026-06-17 08:00:00.000000','2026-06-24 08:00:00.000000',13),
(27,'UDJ-INV-2026-0027','deposit',343.46,'sent','2026-04-29 08:00:00.000000','2026-05-06 08:00:00.000000',14),
(28,'UDJ-INV-2026-0028','balance',801.42,'sent','2026-06-18 08:00:00.000000','2026-06-25 08:00:00.000000',14),
(29,'UDJ-INV-2026-0029','deposit',401.37,'sent','2026-04-30 08:00:00.000000','2026-05-07 08:00:00.000000',15),
(30,'UDJ-INV-2026-0030','balance',936.53,'sent','2026-06-19 08:00:00.000000','2026-06-26 08:00:00.000000',15),
(31,'UDJ-INV-2026-0031','deposit',363.28,'paid','2026-05-01 08:00:00.000000','2026-05-08 08:00:00.000000',16),
(32,'UDJ-INV-2026-0032','balance',847.64,'sent','2026-06-20 08:00:00.000000','2026-06-27 08:00:00.000000',16),
(33,'UDJ-INV-2026-0033','deposit',421.18,'paid','2026-05-02 08:00:00.000000','2026-05-09 08:00:00.000000',17),
(34,'UDJ-INV-2026-0034','balance',982.76,'sent','2026-06-21 08:00:00.000000','2026-06-28 08:00:00.000000',17),
(35,'UDJ-INV-2026-0035','deposit',447.59,'paid','2026-05-03 08:00:00.000000','2026-05-10 08:00:00.000000',18),
(36,'UDJ-INV-2026-0036','balance',1044.37,'paid','2026-06-22 08:00:00.000000','2026-06-29 08:00:00.000000',18),
(37,'UDJ-INV-2026-0037','deposit',505.49,'sent','2026-05-04 08:00:00.000000','2026-05-11 08:00:00.000000',19),
(38,'UDJ-INV-2026-0038','balance',1179.49,'sent','2026-06-23 08:00:00.000000','2026-06-30 08:00:00.000000',19),
(39,'UDJ-INV-2026-0039','deposit',467.40,'sent','2026-05-05 08:00:00.000000','2026-05-12 08:00:00.000000',20),
(40,'UDJ-INV-2026-0040','balance',1090.60,'sent','2026-06-24 08:00:00.000000','2026-07-01 08:00:00.000000',20),
(41,'UDJ-INV-2026-0041','deposit',240.31,'paid','2026-05-06 08:00:00.000000','2026-05-13 08:00:00.000000',21),
(42,'UDJ-INV-2026-0042','deposit',298.21,'paid','2026-05-07 08:00:00.000000','2026-05-14 08:00:00.000000',22),
(43,'UDJ-INV-2026-0043','deposit',356.12,'paid','2026-05-08 08:00:00.000000','2026-05-15 08:00:00.000000',23),
(44,'UDJ-INV-2026-0044','deposit',286.52,'sent','2026-05-09 08:00:00.000000','2026-05-16 08:00:00.000000',24),
(45,'UDJ-INV-2026-0045','deposit',344.43,'sent','2026-05-10 08:00:00.000000','2026-05-17 08:00:00.000000',25),
(46,'UDJ-INV-2026-0046','deposit',402.34,'paid','2026-05-11 08:00:00.000000','2026-05-18 08:00:00.000000',26),
(47,'UDJ-INV-2026-0047','deposit',460.24,'paid','2026-05-12 08:00:00.000000','2026-05-19 08:00:00.000000',27),
(48,'UDJ-INV-2026-0048','deposit',422.15,'paid','2026-05-13 08:00:00.000000','2026-05-20 08:00:00.000000',28),
(49,'UDJ-INV-2026-0049','deposit',480.05,'sent','2026-05-14 08:00:00.000000','2026-05-21 08:00:00.000000',29),
(50,'UDJ-INV-2026-0050','deposit',506.46,'sent','2026-05-15 08:00:00.000000','2026-05-22 08:00:00.000000',30),
(51,'UDJ-INV-2026-0051','deposit',279.37,'paid','2026-05-16 08:00:00.000000','2026-05-23 08:00:00.000000',31),
(52,'UDJ-INV-2026-0052','deposit',241.27,'paid','2026-05-17 08:00:00.000000','2026-05-24 08:00:00.000000',32),
(53,'UDJ-INV-2026-0053','deposit',299.18,'paid','2026-05-18 08:00:00.000000','2026-05-25 08:00:00.000000',33),
(54,'UDJ-INV-2026-0054','deposit',357.08,'sent','2026-05-19 08:00:00.000000','2026-05-26 08:00:00.000000',34),
(55,'UDJ-INV-2026-0055','deposit',414.99,'sent','2026-05-20 08:00:00.000000','2026-05-27 08:00:00.000000',35),
(56,'UDJ-INV-2026-0056','deposit',345.40,'paid','2026-05-21 08:00:00.000000','2026-05-28 08:00:00.000000',36),
(57,'UDJ-INV-2026-0057','deposit',403.30,'paid','2026-05-22 08:00:00.000000','2026-05-29 08:00:00.000000',37),
(58,'UDJ-INV-2026-0058','deposit',461.21,'paid','2026-05-23 08:00:00.000000','2026-05-30 08:00:00.000000',38),
(59,'UDJ-INV-2026-0059','deposit',519.11,'sent','2026-05-24 08:00:00.000000','2026-05-31 08:00:00.000000',39),
(60,'UDJ-INV-2026-0060','deposit',481.02,'sent','2026-05-25 08:00:00.000000','2026-06-01 08:00:00.000000',40),
(61,'UDJ-INV-2026-0061','deposit',253.93,'paid','2026-05-26 08:00:00.000000','2026-06-02 08:00:00.000000',41),
(62,'UDJ-INV-2026-0062','deposit',280.33,'paid','2026-05-27 08:00:00.000000','2026-06-03 08:00:00.000000',42),
(63,'UDJ-INV-2026-0063','deposit',338.24,'paid','2026-05-28 08:00:00.000000','2026-06-04 08:00:00.000000',43),
(64,'UDJ-INV-2026-0064','deposit',300.14,'sent','2026-05-29 08:00:00.000000','2026-06-05 08:00:00.000000',44),
(65,'UDJ-INV-2026-0065','deposit',358.05,'sent','2026-05-30 08:00:00.000000','2026-06-06 08:00:00.000000',45),
(66,'UDJ-INV-2026-0066','deposit',415.96,'paid','2026-05-31 08:00:00.000000','2026-06-07 08:00:00.000000',46),
(67,'UDJ-INV-2026-0067','deposit',473.86,'paid','2026-06-01 08:00:00.000000','2026-06-08 08:00:00.000000',47),
(68,'UDJ-INV-2026-0068','deposit',404.27,'paid','2026-06-02 08:00:00.000000','2026-06-09 08:00:00.000000',48),
(69,'UDJ-INV-2026-0069','deposit',462.17,'sent','2026-06-03 08:00:00.000000','2026-06-10 08:00:00.000000',49),
(70,'UDJ-INV-2026-0070','deposit',520.08,'sent','2026-06-04 08:00:00.000000','2026-06-11 08:00:00.000000',50),
(71,'UDJ-INV-2026-0071','deposit',292.99,'paid','2026-06-05 08:00:00.000000','2026-06-12 08:00:00.000000',51),
(72,'UDJ-INV-2026-0072','deposit',254.89,'paid','2026-06-06 08:00:00.000000','2026-06-13 08:00:00.000000',52),
(73,'UDJ-INV-2026-0073','deposit',312.80,'paid','2026-06-07 08:00:00.000000','2026-06-14 08:00:00.000000',53),
(74,'UDJ-INV-2026-0074','deposit',339.20,'sent','2026-06-08 08:00:00.000000','2026-06-15 08:00:00.000000',54),
(75,'UDJ-INV-2026-0075','deposit',397.11,'sent','2026-06-09 08:00:00.000000','2026-06-16 08:00:00.000000',55),
(76,'UDJ-INV-2026-0076','deposit',359.02,'paid','2026-06-10 08:00:00.000000','2026-06-17 08:00:00.000000',56),
(77,'UDJ-INV-2026-0077','deposit',416.92,'paid','2026-06-11 08:00:00.000000','2026-06-18 08:00:00.000000',57),
(78,'UDJ-INV-2026-0078','deposit',474.83,'paid','2026-06-12 08:00:00.000000','2026-06-19 08:00:00.000000',58),
(79,'UDJ-INV-2026-0079','deposit',532.73,'sent','2026-06-13 08:00:00.000000','2026-06-20 08:00:00.000000',59),
(80,'UDJ-INV-2026-0080','deposit',463.14,'sent','2026-06-14 08:00:00.000000','2026-06-21 08:00:00.000000',60),
(81,'UDJ-INV-2026-0081','deposit',236.05,'paid','2026-06-15 08:00:00.000000','2026-06-22 08:00:00.000000',61),
(82,'UDJ-INV-2026-0082','deposit',293.95,'paid','2026-06-16 08:00:00.000000','2026-06-23 08:00:00.000000',62),
(83,'UDJ-INV-2026-0083','deposit',351.86,'paid','2026-06-17 08:00:00.000000','2026-06-24 08:00:00.000000',63),
(84,'UDJ-INV-2026-0084','deposit',313.76,'sent','2026-06-18 08:00:00.000000','2026-06-25 08:00:00.000000',64),
(85,'UDJ-INV-2026-0085','deposit',371.67,'sent','2026-06-19 08:00:00.000000','2026-06-26 08:00:00.000000',65),
(86,'UDJ-INV-2026-0086','deposit',398.08,'paid','2026-06-20 08:00:00.000000','2026-06-27 08:00:00.000000',66),
(87,'UDJ-INV-2026-0087','deposit',455.98,'paid','2026-06-21 08:00:00.000000','2026-06-28 08:00:00.000000',67),
(88,'UDJ-INV-2026-0088','deposit',417.89,'paid','2026-06-22 08:00:00.000000','2026-06-29 08:00:00.000000',68),
(89,'UDJ-INV-2026-0089','deposit',475.79,'sent','2026-06-23 08:00:00.000000','2026-06-30 08:00:00.000000',69),
(90,'UDJ-INV-2026-0090','deposit',533.70,'sent','2026-06-24 08:00:00.000000','2026-07-01 08:00:00.000000',70),
(91,'UDJ-INV-2026-0091','deposit',306.61,'paid','2026-06-25 08:00:00.000000','2026-07-02 08:00:00.000000',71),
(92,'UDJ-INV-2026-0092','deposit',237.01,'paid','2026-06-26 08:00:00.000000','2026-07-03 08:00:00.000000',72),
(93,'UDJ-INV-2026-0093','deposit',294.92,'paid','2026-06-27 08:00:00.000000','2026-07-04 08:00:00.000000',73),
(94,'UDJ-INV-2026-0094','deposit',352.82,'sent','2026-06-28 08:00:00.000000','2026-07-05 08:00:00.000000',74),
(95,'UDJ-INV-2026-0095','deposit',410.73,'sent','2026-06-29 08:00:00.000000','2026-07-06 08:00:00.000000',75),
(96,'UDJ-INV-2026-0096','deposit',372.64,'paid','2026-06-30 08:00:00.000000','2026-07-07 08:00:00.000000',76),
(97,'UDJ-INV-2026-0097','deposit',430.54,'paid','2026-07-01 08:00:00.000000','2026-07-08 08:00:00.000000',77),
(98,'UDJ-INV-2026-0098','deposit',456.95,'paid','2026-07-02 08:00:00.000000','2026-07-09 08:00:00.000000',78),
(99,'UDJ-INV-2026-0099','deposit',514.85,'sent','2026-07-03 08:00:00.000000','2026-07-10 08:00:00.000000',79),
(100,'UDJ-INV-2026-0100','deposit',476.76,'sent','2026-07-04 08:00:00.000000','2026-07-11 08:00:00.000000',80),
(101,'UDJ-INV-2026-0101','deposit',249.67,'paid','2026-07-05 08:00:00.000000','2026-07-12 08:00:00.000000',81),
(102,'UDJ-INV-2026-0102','deposit',307.57,'paid','2026-07-06 08:00:00.000000','2026-07-13 08:00:00.000000',82),
(103,'UDJ-INV-2026-0103','deposit',365.48,'paid','2026-07-07 08:00:00.000000','2026-07-14 08:00:00.000000',83),
(104,'UDJ-INV-2026-0104','deposit',295.88,'sent','2026-07-08 08:00:00.000000','2026-07-15 08:00:00.000000',84),
(105,'UDJ-INV-2026-0105','deposit',353.79,'sent','2026-07-09 08:00:00.000000','2026-07-16 08:00:00.000000',85),
(106,'UDJ-INV-2026-0106','deposit',411.70,'paid','2026-07-10 08:00:00.000000','2026-07-17 08:00:00.000000',86),
(107,'UDJ-INV-2026-0107','deposit',469.60,'paid','2026-07-11 08:00:00.000000','2026-07-18 08:00:00.000000',87),
(108,'UDJ-INV-2026-0108','deposit',431.51,'paid','2026-07-12 08:00:00.000000','2026-07-19 08:00:00.000000',88),
(109,'UDJ-INV-2026-0109','deposit',489.41,'sent','2026-07-13 08:00:00.000000','2026-07-20 08:00:00.000000',89),
(110,'UDJ-INV-2026-0110','deposit',515.82,'sent','2026-07-14 08:00:00.000000','2026-07-21 08:00:00.000000',90),
(111,'UDJ-INV-2026-0111','deposit',288.73,'paid','2026-07-15 08:00:00.000000','2026-07-22 08:00:00.000000',91),
(112,'UDJ-INV-2026-0112','deposit',250.63,'paid','2026-07-16 08:00:00.000000','2026-07-23 08:00:00.000000',92),
(113,'UDJ-INV-2026-0113','deposit',308.54,'paid','2026-07-17 08:00:00.000000','2026-07-24 08:00:00.000000',93),
(114,'UDJ-INV-2026-0114','deposit',366.44,'sent','2026-07-18 08:00:00.000000','2026-07-25 08:00:00.000000',94),
(115,'UDJ-INV-2026-0115','deposit',409.53,'sent','2026-07-19 08:00:00.000000','2026-07-26 08:00:00.000000',95),
(116,'UDJ-INV-2026-0116','deposit',339.94,'paid','2026-07-20 08:00:00.000000','2026-07-27 08:00:00.000000',96),
(117,'UDJ-INV-2026-0117','deposit',397.84,'paid','2026-07-21 08:00:00.000000','2026-07-28 08:00:00.000000',97),
(118,'UDJ-INV-2026-0118','deposit',455.75,'paid','2026-07-22 08:00:00.000000','2026-07-29 08:00:00.000000',98),
(119,'UDJ-INV-2026-0119','deposit',513.65,'sent','2026-07-23 08:00:00.000000','2026-07-30 08:00:00.000000',99),
(120,'UDJ-INV-2026-0120','deposit',475.56,'sent','2026-07-24 08:00:00.000000','2026-07-31 08:00:00.000000',100),
(121,'UDJ-INV-2026-0121','deposit',248.47,'paid','2026-07-25 08:00:00.000000','2026-08-01 08:00:00.000000',101),
(122,'UDJ-INV-2026-0122','deposit',274.87,'paid','2026-07-26 08:00:00.000000','2026-08-02 08:00:00.000000',102),
(123,'UDJ-INV-2026-0123','deposit',332.78,'paid','2026-07-27 08:00:00.000000','2026-08-03 08:00:00.000000',103),
(124,'UDJ-INV-2026-0124','deposit',294.68,'sent','2026-07-28 08:00:00.000000','2026-08-04 08:00:00.000000',104),
(125,'UDJ-INV-2026-0125','deposit',352.59,'sent','2026-07-29 08:00:00.000000','2026-08-05 08:00:00.000000',105),
(126,'UDJ-INV-2026-0126','deposit',410.50,'paid','2026-07-30 08:00:00.000000','2026-08-06 08:00:00.000000',106),
(127,'UDJ-INV-2026-0127','deposit',468.40,'paid','2026-07-31 08:00:00.000000','2026-08-07 08:00:00.000000',107),
(128,'UDJ-INV-2026-0128','deposit',398.81,'paid','2026-08-01 08:00:00.000000','2026-08-08 08:00:00.000000',108),
(129,'UDJ-INV-2026-0129','deposit',456.71,'sent','2026-08-02 08:00:00.000000','2026-08-09 08:00:00.000000',109),
(130,'UDJ-INV-2026-0130','deposit',514.62,'sent','2026-08-03 08:00:00.000000','2026-08-10 08:00:00.000000',110);
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `music_styles`
--

DROP TABLE IF EXISTS `music_styles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `music_styles` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `music_styles`
--

LOCK TABLES `music_styles` WRITE;
/*!40000 ALTER TABLE `music_styles` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `music_styles` VALUES
(13,'Afrobeats'),
(19,'Années 80'),
(20,'Années 90'),
(21,'Dancehall'),
(23,'Électro'),
(14,'Hip-hop'),
(15,'House'),
(22,'Latino'),
(18,'Pop internationale'),
(17,'R&B'),
(16,'Techno'),
(24,'Variété française');
/*!40000 ALTER TABLE `music_styles` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `packages`
--

DROP TABLE IF EXISTS `packages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `packages` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) NOT NULL,
  `included_hours` decimal(4,1) NOT NULL,
  `base_price` decimal(10,2) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  CONSTRAINT `package_base_price_positive` CHECK (`base_price` >= 0),
  CONSTRAINT `package_included_hours_positive` CHECK (`included_hours` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `packages`
--

LOCK TABLES `packages` WRITE;
/*!40000 ALTER TABLE `packages` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `packages` VALUES
(11,'Essentiel','Prestation DJ simple avec sonorisation légère.',3.0,420.00,1),
(12,'Classic','Animation complète pour soirée privée.',5.0,690.00,1),
(13,'Premium','DJ, sonorisation renforcée et éclairage d\'ambiance.',6.0,950.00,1),
(14,'Mariage Silver','Formule mariage avec rendez-vous préparatoire.',7.0,1250.00,1),
(15,'Mariage Gold','Formule mariage complète avec options avancées.',9.0,1690.00,1),
(16,'Entreprise','Solution pour événement professionnel.',5.0,1100.00,0),
(17,'Festival local','Prestation extérieure avec matériel renforcé.',8.0,1800.00,0),
(18,'Étudiant','Formule adaptée aux bals et soirées étudiantes.',5.0,590.00,0),
(19,'Lounge','Ambiance musicale douce pour cocktail.',4.0,520.00,0),
(20,'Sur mesure','Contrat personnalisé selon les besoins.',1.0,250.00,1);
/*!40000 ALTER TABLE `packages` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `packages_event_types`
--

DROP TABLE IF EXISTS `packages_event_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `packages_event_types` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `package_id` bigint(20) NOT NULL,
  `eventtype_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `packages_event_types_package_id_eventtype_id_c982e6b9_uniq` (`package_id`,`eventtype_id`),
  KEY `packages_event_types_eventtype_id_a15eb9ad_fk_event_types_id` (`eventtype_id`),
  CONSTRAINT `packages_event_types_eventtype_id_a15eb9ad_fk_event_types_id` FOREIGN KEY (`eventtype_id`) REFERENCES `event_types` (`id`),
  CONSTRAINT `packages_event_types_package_id_870c1d8f_fk_packages_id` FOREIGN KEY (`package_id`) REFERENCES `packages` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `packages_event_types`
--

LOCK TABLES `packages_event_types` WRITE;
/*!40000 ALTER TABLE `packages_event_types` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `packages_event_types` VALUES
(2,11,1),
(3,11,10),
(4,11,11),
(1,11,16),
(6,12,1),
(7,12,10),
(8,12,11),
(5,12,16),
(10,13,1),
(11,13,10),
(12,13,11),
(9,13,16),
(13,14,10),
(14,15,10),
(16,20,1),
(17,20,10),
(18,20,11),
(15,20,16);
/*!40000 ALTER TABLE `packages_event_types` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `stripe_session_id` varchar(190) NOT NULL,
  `stripe_payment_intent_id` varchar(190) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) NOT NULL,
  `status` varchar(20) NOT NULL,
  `paid_at` datetime(6) DEFAULT NULL,
  `booking_id` bigint(20) NOT NULL,
  `invoice_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stripe_session_id` (`stripe_session_id`),
  UNIQUE KEY `stripe_payment_intent_id` (`stripe_payment_intent_id`),
  KEY `payments_booking_id_fa2b6c3e_fk_bookings_id` (`booking_id`),
  KEY `payments_invoice_id_09b5e2bf_fk_invoices_id` (`invoice_id`),
  CONSTRAINT `payments_booking_id_fa2b6c3e_fk_bookings_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  CONSTRAINT `payments_invoice_id_09b5e2bf_fk_invoices_id` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`),
  CONSTRAINT `payment_amount_positive` CHECK (`amount` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=133 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `payments` VALUES
(1,'cs_test_udj_000001','pi_test_udj_000001',226.69,'EUR','paid','2026-06-15 08:00:00.000000',1,1),
(2,'cs_test_udj_000002','pi_test_udj_000002',528.93,'EUR','pending',NULL,1,2),
(3,'cs_test_udj_000003','pi_test_udj_000003',284.59,'EUR','paid','2026-06-17 08:00:00.000000',2,3),
(4,'cs_test_udj_000004','pi_test_udj_000004',664.05,'EUR','pending',NULL,2,4),
(5,'cs_test_udj_000005','pi_test_udj_000005',342.50,'EUR','paid','2026-06-19 08:00:00.000000',3,5),
(6,'cs_test_udj_000006','pi_test_udj_000006',799.16,'EUR','paid','2026-06-20 08:00:00.000000',3,6),
(7,'cs_test_udj_000007','pi_test_udj_000007',304.40,'EUR','pending',NULL,4,7),
(8,'cs_test_udj_000008','pi_test_udj_000008',710.28,'EUR','pending',NULL,4,8),
(9,'cs_test_udj_000009','pi_test_udj_000009',362.31,'EUR','pending',NULL,5,9),
(10,'cs_test_udj_000010','pi_test_udj_000010',845.39,'EUR','pending',NULL,5,10),
(11,'cs_test_udj_000011','pi_test_udj_000011',388.72,'EUR','paid','2026-06-25 08:00:00.000000',6,11),
(12,'cs_test_udj_000012','pi_test_udj_000012',907.00,'EUR','pending',NULL,6,12),
(13,'cs_test_udj_000013','pi_test_udj_000013',446.62,'EUR','paid','2026-06-27 08:00:00.000000',7,13),
(14,'cs_test_udj_000014','pi_test_udj_000014',1042.12,'EUR','pending',NULL,7,14),
(15,'cs_test_udj_000015','pi_test_udj_000015',408.53,'EUR','paid','2026-06-29 08:00:00.000000',8,15),
(16,'cs_test_udj_000016','pi_test_udj_000016',953.23,'EUR','paid','2026-06-30 08:00:00.000000',8,16),
(17,'cs_test_udj_000017','pi_test_udj_000017',466.43,'EUR','failed',NULL,9,17),
(18,'cs_test_udj_000018','pi_test_udj_000018',1088.35,'EUR','pending',NULL,9,18),
(19,'cs_test_udj_000019','pi_test_udj_000019',524.34,'EUR','pending',NULL,10,19),
(20,'cs_test_udj_000020','pi_test_udj_000020',1223.46,'EUR','pending',NULL,10,20),
(21,'cs_test_udj_000021','pi_test_udj_000021',297.25,'EUR','paid','2026-07-05 08:00:00.000000',11,21),
(22,'cs_test_udj_000022','pi_test_udj_000022',693.57,'EUR','pending',NULL,11,22),
(23,'cs_test_udj_000023','pi_test_udj_000023',227.65,'EUR','paid','2026-07-07 08:00:00.000000',12,23),
(24,'cs_test_udj_000024','pi_test_udj_000024',531.19,'EUR','pending',NULL,12,24),
(25,'cs_test_udj_000025','pi_test_udj_000025',285.56,'EUR','paid','2026-07-09 08:00:00.000000',13,25),
(26,'cs_test_udj_000026','pi_test_udj_000026',666.30,'EUR','paid','2026-07-10 08:00:00.000000',13,26),
(27,'cs_test_udj_000027','pi_test_udj_000027',343.46,'EUR','pending',NULL,14,27),
(28,'cs_test_udj_000028','pi_test_udj_000028',801.42,'EUR','pending',NULL,14,28),
(29,'cs_test_udj_000029','pi_test_udj_000029',401.37,'EUR','pending',NULL,15,29),
(30,'cs_test_udj_000030','pi_test_udj_000030',936.53,'EUR','pending',NULL,15,30),
(31,'cs_test_udj_000031','pi_test_udj_000031',363.28,'EUR','paid','2026-06-15 08:00:00.000000',16,31),
(32,'cs_test_udj_000032','pi_test_udj_000032',847.64,'EUR','pending',NULL,16,32),
(33,'cs_test_udj_000033','pi_test_udj_000033',421.18,'EUR','paid','2026-06-17 08:00:00.000000',17,33),
(34,'cs_test_udj_000034','pi_test_udj_000034',982.76,'EUR','failed',NULL,17,34),
(35,'cs_test_udj_000035','pi_test_udj_000035',447.59,'EUR','paid','2026-06-19 08:00:00.000000',18,35),
(36,'cs_test_udj_000036','pi_test_udj_000036',1044.37,'EUR','paid','2026-06-20 08:00:00.000000',18,36),
(37,'cs_test_udj_000037','pi_test_udj_000037',505.49,'EUR','pending',NULL,19,37),
(38,'cs_test_udj_000038','pi_test_udj_000038',1179.49,'EUR','pending',NULL,19,38),
(39,'cs_test_udj_000039','pi_test_udj_000039',467.40,'EUR','pending',NULL,20,39),
(40,'cs_test_udj_000040','pi_test_udj_000040',1090.60,'EUR','pending',NULL,20,40),
(41,'cs_test_udj_000041','pi_test_udj_000041',240.31,'EUR','paid','2026-06-25 08:00:00.000000',21,41),
(42,'cs_test_udj_000042','pi_test_udj_000042',298.21,'EUR','paid','2026-06-26 08:00:00.000000',22,42),
(43,'cs_test_udj_000043','pi_test_udj_000043',356.12,'EUR','paid','2026-06-27 08:00:00.000000',23,43),
(44,'cs_test_udj_000044','pi_test_udj_000044',286.52,'EUR','pending',NULL,24,44),
(45,'cs_test_udj_000045','pi_test_udj_000045',344.43,'EUR','pending',NULL,25,45),
(46,'cs_test_udj_000046','pi_test_udj_000046',402.34,'EUR','paid','2026-06-30 08:00:00.000000',26,46),
(47,'cs_test_udj_000047','pi_test_udj_000047',460.24,'EUR','paid','2026-07-01 08:00:00.000000',27,47),
(48,'cs_test_udj_000048','pi_test_udj_000048',422.15,'EUR','paid','2026-07-02 08:00:00.000000',28,48),
(49,'cs_test_udj_000049','pi_test_udj_000049',480.05,'EUR','pending',NULL,29,49),
(50,'cs_test_udj_000050','pi_test_udj_000050',506.46,'EUR','pending',NULL,30,50),
(51,'cs_test_udj_000051','pi_test_udj_000051',279.37,'EUR','paid','2026-07-05 08:00:00.000000',31,51),
(52,'cs_test_udj_000052','pi_test_udj_000052',241.27,'EUR','paid','2026-07-06 08:00:00.000000',32,52),
(53,'cs_test_udj_000053','pi_test_udj_000053',299.18,'EUR','paid','2026-07-07 08:00:00.000000',33,53),
(54,'cs_test_udj_000054','pi_test_udj_000054',357.08,'EUR','pending',NULL,34,54),
(55,'cs_test_udj_000055','pi_test_udj_000055',414.99,'EUR','pending',NULL,35,55),
(56,'cs_test_udj_000056','pi_test_udj_000056',345.40,'EUR','paid','2026-07-10 08:00:00.000000',36,56),
(57,'cs_test_udj_000057','pi_test_udj_000057',403.30,'EUR','paid','2026-07-11 08:00:00.000000',37,57),
(58,'cs_test_udj_000058','pi_test_udj_000058',461.21,'EUR','paid','2026-07-12 08:00:00.000000',38,58),
(59,'cs_test_udj_000059','pi_test_udj_000059',519.11,'EUR','pending',NULL,39,59),
(60,'cs_test_udj_000060','pi_test_udj_000060',481.02,'EUR','pending',NULL,40,60),
(61,'cs_test_udj_000061','pi_test_udj_000061',253.93,'EUR','paid','2026-06-15 08:00:00.000000',41,61),
(62,'cs_test_udj_000062','pi_test_udj_000062',280.33,'EUR','paid','2026-06-16 08:00:00.000000',42,62),
(63,'cs_test_udj_000063','pi_test_udj_000063',338.24,'EUR','paid','2026-06-17 08:00:00.000000',43,63),
(64,'cs_test_udj_000064','pi_test_udj_000064',300.14,'EUR','pending',NULL,44,64),
(65,'cs_test_udj_000065','pi_test_udj_000065',358.05,'EUR','pending',NULL,45,65),
(66,'cs_test_udj_000066','pi_test_udj_000066',415.96,'EUR','paid','2026-06-20 08:00:00.000000',46,66),
(67,'cs_test_udj_000067','pi_test_udj_000067',473.86,'EUR','paid','2026-06-21 08:00:00.000000',47,67),
(68,'cs_test_udj_000068','pi_test_udj_000068',404.27,'EUR','paid','2026-06-22 08:00:00.000000',48,68),
(69,'cs_test_udj_000069','pi_test_udj_000069',462.17,'EUR','pending',NULL,49,69),
(70,'cs_test_udj_000070','pi_test_udj_000070',520.08,'EUR','pending',NULL,50,70),
(71,'cs_test_udj_000071','pi_test_udj_000071',292.99,'EUR','paid','2026-06-25 08:00:00.000000',51,71),
(72,'cs_test_udj_000072','pi_test_udj_000072',254.89,'EUR','paid','2026-06-26 08:00:00.000000',52,72),
(73,'cs_test_udj_000073','pi_test_udj_000073',312.80,'EUR','paid','2026-06-27 08:00:00.000000',53,73),
(74,'cs_test_udj_000074','pi_test_udj_000074',339.20,'EUR','pending',NULL,54,74),
(75,'cs_test_udj_000075','pi_test_udj_000075',397.11,'EUR','pending',NULL,55,75),
(76,'cs_test_udj_000076','pi_test_udj_000076',359.02,'EUR','paid','2026-06-30 08:00:00.000000',56,76),
(77,'cs_test_udj_000077','pi_test_udj_000077',416.92,'EUR','paid','2026-07-01 08:00:00.000000',57,77),
(78,'cs_test_udj_000078','pi_test_udj_000078',474.83,'EUR','paid','2026-07-02 08:00:00.000000',58,78),
(79,'cs_test_udj_000079','pi_test_udj_000079',532.73,'EUR','pending',NULL,59,79),
(80,'cs_test_udj_000080','pi_test_udj_000080',463.14,'EUR','pending',NULL,60,80),
(81,'cs_test_udj_000081','pi_test_udj_000081',236.05,'EUR','paid','2026-07-05 08:00:00.000000',61,81),
(82,'cs_test_udj_000082','pi_test_udj_000082',293.95,'EUR','paid','2026-07-06 08:00:00.000000',62,82),
(83,'cs_test_udj_000083','pi_test_udj_000083',351.86,'EUR','paid','2026-07-07 08:00:00.000000',63,83),
(84,'cs_test_udj_000084','pi_test_udj_000084',313.76,'EUR','pending',NULL,64,84),
(85,'cs_test_udj_000085','pi_test_udj_000085',371.67,'EUR','failed',NULL,65,85),
(86,'cs_test_udj_000086','pi_test_udj_000086',398.08,'EUR','paid','2026-07-10 08:00:00.000000',66,86),
(87,'cs_test_udj_000087','pi_test_udj_000087',455.98,'EUR','paid','2026-07-11 08:00:00.000000',67,87),
(88,'cs_test_udj_000088','pi_test_udj_000088',417.89,'EUR','paid','2026-07-12 08:00:00.000000',68,88),
(89,'cs_test_udj_000089','pi_test_udj_000089',475.79,'EUR','pending',NULL,69,89),
(90,'cs_test_udj_000090','pi_test_udj_000090',533.70,'EUR','pending',NULL,70,90),
(91,'cs_test_udj_000091','pi_test_udj_000091',306.61,'EUR','paid','2026-06-15 08:00:00.000000',71,91),
(92,'cs_test_udj_000092','pi_test_udj_000092',237.01,'EUR','paid','2026-06-16 08:00:00.000000',72,92),
(93,'cs_test_udj_000093','pi_test_udj_000093',294.92,'EUR','paid','2026-06-17 08:00:00.000000',73,93),
(94,'cs_test_udj_000094','pi_test_udj_000094',352.82,'EUR','pending',NULL,74,94),
(95,'cs_test_udj_000095','pi_test_udj_000095',410.73,'EUR','pending',NULL,75,95),
(96,'cs_test_udj_000096','pi_test_udj_000096',372.64,'EUR','paid','2026-06-20 08:00:00.000000',76,96),
(97,'cs_test_udj_000097','pi_test_udj_000097',430.54,'EUR','paid','2026-06-21 08:00:00.000000',77,97),
(98,'cs_test_udj_000098','pi_test_udj_000098',456.95,'EUR','paid','2026-06-22 08:00:00.000000',78,98),
(99,'cs_test_udj_000099','pi_test_udj_000099',514.85,'EUR','pending',NULL,79,99),
(100,'cs_test_udj_000100','pi_test_udj_000100',476.76,'EUR','pending',NULL,80,100),
(101,'cs_test_udj_000101','pi_test_udj_000101',249.67,'EUR','paid','2026-06-25 08:00:00.000000',81,101),
(102,'cs_test_udj_000102','pi_test_udj_000102',307.57,'EUR','paid','2026-06-26 08:00:00.000000',82,102),
(103,'cs_test_udj_000103','pi_test_udj_000103',365.48,'EUR','paid','2026-06-27 08:00:00.000000',83,103),
(104,'cs_test_udj_000104','pi_test_udj_000104',295.88,'EUR','pending',NULL,84,104),
(105,'cs_test_udj_000105','pi_test_udj_000105',353.79,'EUR','pending',NULL,85,105),
(106,'cs_test_udj_000106','pi_test_udj_000106',411.70,'EUR','paid','2026-06-30 08:00:00.000000',86,106),
(107,'cs_test_udj_000107','pi_test_udj_000107',469.60,'EUR','paid','2026-07-01 08:00:00.000000',87,107),
(108,'cs_test_udj_000108','pi_test_udj_000108',431.51,'EUR','paid','2026-07-02 08:00:00.000000',88,108),
(109,'cs_test_udj_000109','pi_test_udj_000109',489.41,'EUR','pending',NULL,89,109),
(110,'cs_test_udj_000110','pi_test_udj_000110',515.82,'EUR','pending',NULL,90,110),
(111,'cs_test_udj_000111','pi_test_udj_000111',288.73,'EUR','paid','2026-07-05 08:00:00.000000',91,111),
(112,'cs_test_udj_000112','pi_test_udj_000112',250.63,'EUR','paid','2026-07-06 08:00:00.000000',92,112),
(113,'cs_test_udj_000113','pi_test_udj_000113',308.54,'EUR','paid','2026-07-07 08:00:00.000000',93,113),
(114,'cs_test_udj_000114','pi_test_udj_000114',366.44,'EUR','pending',NULL,94,114),
(115,'cs_test_udj_000115','pi_test_udj_000115',409.53,'EUR','pending',NULL,95,115),
(116,'cs_test_udj_000116','pi_test_udj_000116',339.94,'EUR','paid','2026-07-10 08:00:00.000000',96,116),
(117,'cs_test_udj_000117','pi_test_udj_000117',397.84,'EUR','paid','2026-07-11 08:00:00.000000',97,117),
(118,'cs_test_udj_000118','pi_test_udj_000118',455.75,'EUR','paid','2026-07-12 08:00:00.000000',98,118),
(119,'cs_test_udj_000119','pi_test_udj_000119',513.65,'EUR','failed',NULL,99,119),
(120,'cs_test_udj_000120','pi_test_udj_000120',475.56,'EUR','pending',NULL,100,120),
(121,'cs_test_udj_000121','pi_test_udj_000121',248.47,'EUR','paid','2026-06-15 08:00:00.000000',101,121),
(122,'cs_test_udj_000122','pi_test_udj_000122',274.87,'EUR','paid','2026-06-16 08:00:00.000000',102,122),
(123,'cs_test_udj_000123','pi_test_udj_000123',332.78,'EUR','paid','2026-06-17 08:00:00.000000',103,123),
(124,'cs_test_udj_000124','pi_test_udj_000124',294.68,'EUR','pending',NULL,104,124),
(125,'cs_test_udj_000125','pi_test_udj_000125',352.59,'EUR','pending',NULL,105,125),
(126,'cs_test_udj_000126','pi_test_udj_000126',410.50,'EUR','paid','2026-06-20 08:00:00.000000',106,126),
(127,'cs_test_udj_000127','pi_test_udj_000127',468.40,'EUR','paid','2026-06-21 08:00:00.000000',107,127),
(128,'cs_test_udj_000128','pi_test_udj_000128',398.81,'EUR','paid','2026-06-22 08:00:00.000000',108,128),
(129,'cs_test_udj_000129','pi_test_udj_000129',456.71,'EUR','pending',NULL,109,129),
(130,'cs_test_udj_000130','pi_test_udj_000130',514.62,'EUR','pending',NULL,110,130),
(131,'cs_test_a15OALANI6mCb8IMHNDolaGLYrex4O89yVk79aDYuFRxKGFIxsNpKSc90U',NULL,528.93,'EUR','pending',NULL,1,2),
(132,'cs_test_a1k05KiuLoaogNZVN0bgkM4s9EKE7p7aIb6N0ZxlIgc2ov1GOOqnoNLheW','pi_3U45suEpYsrME2au1EkAE4sc',528.93,'EUR','paid','2026-08-13 21:10:16.844394',1,2);
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `playlist_songs`
--

DROP TABLE IF EXISTS `playlist_songs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `playlist_songs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(160) NOT NULL,
  `artist` varchar(120) NOT NULL,
  `preference_level` varchar(30) NOT NULL,
  `playlist_id` bigint(20) NOT NULL,
  `status` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `playlist_songs_playlist_id_99c5daf1_fk_playlists_id` (`playlist_id`),
  CONSTRAINT `playlist_songs_playlist_id_99c5daf1_fk_playlists_id` FOREIGN KEY (`playlist_id`) REFERENCES `playlists` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=221 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `playlist_songs`
--

LOCK TABLES `playlist_songs` WRITE;
/*!40000 ALTER TABLE `playlist_songs` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `playlist_songs` VALUES
(1,'September version 2','Earth Wind and Fire','play_if_possible',1,'approved'),
(2,'Freed From Desire version 3','Gala','play_if_possible',2,'approved'),
(3,'Jerusalema version 1','Master KG','play_if_possible',3,'approved'),
(4,'Alors on danse version 2','Stromae','play_if_possible',4,'approved'),
(5,'Billie Jean version 3','Michael Jackson','must_play',5,'approved'),
(6,'Djadja version 1','Aya Nakamura','play_if_possible',6,'approved'),
(7,'Uptown Funk version 2','Bruno Mars','play_if_possible',7,'requested'),
(8,'Crazy in Love version 3','Beyoncé','play_if_possible',8,'approved'),
(9,'Destination Calabria version 1','Alex Gaudino','play_if_possible',9,'approved'),
(10,'Levitating version 2','Dua Lipa','must_play',10,'approved'),
(11,'September version 3','Earth Wind and Fire','play_if_possible',11,'approved'),
(12,'Freed From Desire version 1','Gala','play_if_possible',12,'approved'),
(13,'Jerusalema version 2','Master KG','play_if_possible',13,'approved'),
(14,'Alors on danse version 3','Stromae','play_if_possible',14,'requested'),
(15,'Billie Jean version 1','Michael Jackson','must_play',15,'approved'),
(16,'Djadja version 2','Aya Nakamura','play_if_possible',16,'approved'),
(17,'Uptown Funk version 3','Bruno Mars','play_if_possible',17,'approved'),
(18,'Crazy in Love version 1','Beyoncé','play_if_possible',18,'approved'),
(19,'Destination Calabria version 2','Alex Gaudino','play_if_possible',19,'approved'),
(20,'Levitating version 3','Dua Lipa','must_play',20,'approved'),
(21,'September version 1','Earth Wind and Fire','play_if_possible',21,'requested'),
(22,'Freed From Desire version 2','Gala','play_if_possible',22,'approved'),
(23,'Jerusalema version 3','Master KG','play_if_possible',23,'approved'),
(24,'Alors on danse version 1','Stromae','play_if_possible',24,'approved'),
(25,'Billie Jean version 2','Michael Jackson','must_play',25,'approved'),
(26,'Djadja version 3','Aya Nakamura','play_if_possible',26,'approved'),
(27,'Uptown Funk version 1','Bruno Mars','play_if_possible',27,'approved'),
(28,'Crazy in Love version 2','Beyoncé','play_if_possible',28,'requested'),
(29,'Destination Calabria version 3','Alex Gaudino','play_if_possible',29,'approved'),
(30,'Levitating version 1','Dua Lipa','must_play',30,'approved'),
(31,'September version 2','Earth Wind and Fire','play_if_possible',31,'approved'),
(32,'Freed From Desire version 3','Gala','play_if_possible',32,'approved'),
(33,'Jerusalema version 1','Master KG','play_if_possible',33,'approved'),
(34,'Alors on danse version 2','Stromae','play_if_possible',34,'approved'),
(35,'Billie Jean version 3','Michael Jackson','must_play',35,'requested'),
(36,'Djadja version 1','Aya Nakamura','play_if_possible',36,'approved'),
(37,'Uptown Funk version 2','Bruno Mars','play_if_possible',37,'approved'),
(38,'Crazy in Love version 3','Beyoncé','play_if_possible',38,'approved'),
(39,'Destination Calabria version 1','Alex Gaudino','play_if_possible',39,'approved'),
(40,'Levitating version 2','Dua Lipa','must_play',40,'approved'),
(41,'September version 3','Earth Wind and Fire','play_if_possible',41,'approved'),
(42,'Freed From Desire version 1','Gala','play_if_possible',42,'requested'),
(43,'Jerusalema version 2','Master KG','play_if_possible',43,'approved'),
(44,'Alors on danse version 3','Stromae','play_if_possible',44,'approved'),
(45,'Billie Jean version 1','Michael Jackson','must_play',45,'approved'),
(46,'Djadja version 2','Aya Nakamura','play_if_possible',46,'approved'),
(47,'Uptown Funk version 3','Bruno Mars','play_if_possible',47,'approved'),
(48,'Crazy in Love version 1','Beyoncé','play_if_possible',48,'approved'),
(49,'Destination Calabria version 2','Alex Gaudino','play_if_possible',49,'requested'),
(50,'Levitating version 3','Dua Lipa','must_play',50,'approved'),
(51,'September version 1','Earth Wind and Fire','play_if_possible',51,'approved'),
(52,'Freed From Desire version 2','Gala','play_if_possible',52,'approved'),
(53,'Jerusalema version 3','Master KG','play_if_possible',53,'approved'),
(54,'Alors on danse version 1','Stromae','play_if_possible',54,'approved'),
(55,'Billie Jean version 2','Michael Jackson','must_play',55,'approved'),
(56,'Djadja version 3','Aya Nakamura','play_if_possible',56,'requested'),
(57,'Uptown Funk version 1','Bruno Mars','play_if_possible',57,'approved'),
(58,'Crazy in Love version 2','Beyoncé','play_if_possible',58,'approved'),
(59,'Destination Calabria version 3','Alex Gaudino','play_if_possible',59,'approved'),
(60,'Levitating version 1','Dua Lipa','must_play',60,'approved'),
(61,'September version 2','Earth Wind and Fire','play_if_possible',61,'approved'),
(62,'Freed From Desire version 3','Gala','play_if_possible',62,'approved'),
(63,'Jerusalema version 1','Master KG','play_if_possible',63,'requested'),
(64,'Alors on danse version 2','Stromae','play_if_possible',64,'approved'),
(65,'Billie Jean version 3','Michael Jackson','must_play',65,'approved'),
(66,'Djadja version 1','Aya Nakamura','play_if_possible',66,'approved'),
(67,'Uptown Funk version 2','Bruno Mars','play_if_possible',67,'approved'),
(68,'Crazy in Love version 3','Beyoncé','play_if_possible',68,'approved'),
(69,'Destination Calabria version 1','Alex Gaudino','play_if_possible',69,'approved'),
(70,'Levitating version 2','Dua Lipa','must_play',70,'requested'),
(71,'September version 3','Earth Wind and Fire','play_if_possible',71,'approved'),
(72,'Freed From Desire version 1','Gala','play_if_possible',72,'approved'),
(73,'Jerusalema version 2','Master KG','play_if_possible',73,'approved'),
(74,'Alors on danse version 3','Stromae','play_if_possible',74,'approved'),
(75,'Billie Jean version 1','Michael Jackson','must_play',75,'approved'),
(76,'Djadja version 2','Aya Nakamura','play_if_possible',76,'approved'),
(77,'Uptown Funk version 3','Bruno Mars','play_if_possible',77,'requested'),
(78,'Crazy in Love version 1','Beyoncé','play_if_possible',78,'approved'),
(79,'Destination Calabria version 2','Alex Gaudino','play_if_possible',79,'approved'),
(80,'Levitating version 3','Dua Lipa','must_play',80,'approved'),
(81,'September version 1','Earth Wind and Fire','play_if_possible',81,'approved'),
(82,'Freed From Desire version 2','Gala','play_if_possible',82,'approved'),
(83,'Jerusalema version 3','Master KG','play_if_possible',83,'approved'),
(84,'Alors on danse version 1','Stromae','play_if_possible',84,'requested'),
(85,'Billie Jean version 2','Michael Jackson','must_play',85,'approved'),
(86,'Djadja version 3','Aya Nakamura','play_if_possible',86,'approved'),
(87,'Uptown Funk version 1','Bruno Mars','play_if_possible',87,'approved'),
(88,'Crazy in Love version 2','Beyoncé','play_if_possible',88,'approved'),
(89,'Destination Calabria version 3','Alex Gaudino','play_if_possible',89,'approved'),
(90,'Levitating version 1','Dua Lipa','must_play',90,'approved'),
(91,'September version 2','Earth Wind and Fire','play_if_possible',91,'requested'),
(92,'Freed From Desire version 3','Gala','play_if_possible',92,'approved'),
(93,'Jerusalema version 1','Master KG','play_if_possible',93,'approved'),
(94,'Alors on danse version 2','Stromae','play_if_possible',94,'approved'),
(95,'Billie Jean version 3','Michael Jackson','must_play',95,'approved'),
(96,'Djadja version 1','Aya Nakamura','play_if_possible',96,'approved'),
(97,'Uptown Funk version 2','Bruno Mars','play_if_possible',97,'approved'),
(98,'Crazy in Love version 3','Beyoncé','play_if_possible',98,'requested'),
(99,'Destination Calabria version 1','Alex Gaudino','play_if_possible',99,'approved'),
(100,'Levitating version 2','Dua Lipa','must_play',100,'approved'),
(101,'September version 3','Earth Wind and Fire','play_if_possible',101,'approved'),
(102,'Freed From Desire version 1','Gala','play_if_possible',102,'approved'),
(103,'Jerusalema version 2','Master KG','play_if_possible',103,'approved'),
(104,'Alors on danse version 3','Stromae','play_if_possible',104,'approved'),
(105,'Billie Jean version 1','Michael Jackson','must_play',105,'requested'),
(106,'Djadja version 2','Aya Nakamura','play_if_possible',106,'approved'),
(107,'Uptown Funk version 3','Bruno Mars','play_if_possible',107,'approved'),
(108,'Crazy in Love version 1','Beyoncé','play_if_possible',108,'approved'),
(109,'Destination Calabria version 2','Alex Gaudino','play_if_possible',109,'approved'),
(110,'Levitating version 3','Dua Lipa','must_play',110,'approved'),
(111,'September version 1','Earth Wind and Fire','play_if_possible',1,'approved'),
(112,'Freed From Desire version 2','Gala','play_if_possible',2,'requested'),
(113,'Jerusalema version 3','Master KG','play_if_possible',3,'approved'),
(114,'Alors on danse version 1','Stromae','play_if_possible',4,'approved'),
(115,'Billie Jean version 2','Michael Jackson','must_play',5,'approved'),
(116,'Djadja version 3','Aya Nakamura','play_if_possible',6,'approved'),
(117,'Uptown Funk version 1','Bruno Mars','play_if_possible',7,'approved'),
(118,'Crazy in Love version 2','Beyoncé','play_if_possible',8,'approved'),
(119,'Destination Calabria version 3','Alex Gaudino','play_if_possible',9,'requested'),
(120,'Levitating version 1','Dua Lipa','must_play',10,'approved'),
(121,'September version 2','Earth Wind and Fire','play_if_possible',11,'approved'),
(122,'Freed From Desire version 3','Gala','play_if_possible',12,'approved'),
(123,'Jerusalema version 1','Master KG','play_if_possible',13,'approved'),
(124,'Alors on danse version 2','Stromae','play_if_possible',14,'approved'),
(125,'Billie Jean version 3','Michael Jackson','must_play',15,'approved'),
(126,'Djadja version 1','Aya Nakamura','play_if_possible',16,'requested'),
(127,'Uptown Funk version 2','Bruno Mars','play_if_possible',17,'approved'),
(128,'Crazy in Love version 3','Beyoncé','play_if_possible',18,'approved'),
(129,'Destination Calabria version 1','Alex Gaudino','play_if_possible',19,'approved'),
(130,'Levitating version 2','Dua Lipa','must_play',20,'approved'),
(131,'September version 3','Earth Wind and Fire','play_if_possible',21,'approved'),
(132,'Freed From Desire version 1','Gala','play_if_possible',22,'approved'),
(133,'Jerusalema version 2','Master KG','play_if_possible',23,'requested'),
(134,'Alors on danse version 3','Stromae','play_if_possible',24,'approved'),
(135,'Billie Jean version 1','Michael Jackson','must_play',25,'approved'),
(136,'Djadja version 2','Aya Nakamura','play_if_possible',26,'approved'),
(137,'Uptown Funk version 3','Bruno Mars','play_if_possible',27,'approved'),
(138,'Crazy in Love version 1','Beyoncé','play_if_possible',28,'approved'),
(139,'Destination Calabria version 2','Alex Gaudino','play_if_possible',29,'approved'),
(140,'Levitating version 3','Dua Lipa','must_play',30,'requested'),
(141,'September version 1','Earth Wind and Fire','play_if_possible',31,'approved'),
(142,'Freed From Desire version 2','Gala','play_if_possible',32,'approved'),
(143,'Jerusalema version 3','Master KG','play_if_possible',33,'approved'),
(144,'Alors on danse version 1','Stromae','play_if_possible',34,'approved'),
(145,'Billie Jean version 2','Michael Jackson','must_play',35,'approved'),
(146,'Djadja version 3','Aya Nakamura','play_if_possible',36,'approved'),
(147,'Uptown Funk version 1','Bruno Mars','play_if_possible',37,'requested'),
(148,'Crazy in Love version 2','Beyoncé','play_if_possible',38,'approved'),
(149,'Destination Calabria version 3','Alex Gaudino','play_if_possible',39,'approved'),
(150,'Levitating version 1','Dua Lipa','must_play',40,'approved'),
(151,'September version 2','Earth Wind and Fire','play_if_possible',41,'approved'),
(152,'Freed From Desire version 3','Gala','play_if_possible',42,'approved'),
(153,'Jerusalema version 1','Master KG','play_if_possible',43,'approved'),
(154,'Alors on danse version 2','Stromae','play_if_possible',44,'requested'),
(155,'Billie Jean version 3','Michael Jackson','must_play',45,'approved'),
(156,'Djadja version 1','Aya Nakamura','play_if_possible',46,'approved'),
(157,'Uptown Funk version 2','Bruno Mars','play_if_possible',47,'approved'),
(158,'Crazy in Love version 3','Beyoncé','play_if_possible',48,'approved'),
(159,'Destination Calabria version 1','Alex Gaudino','play_if_possible',49,'approved'),
(160,'Levitating version 2','Dua Lipa','must_play',50,'approved'),
(161,'September version 3','Earth Wind and Fire','play_if_possible',51,'requested'),
(162,'Freed From Desire version 1','Gala','play_if_possible',52,'approved'),
(163,'Jerusalema version 2','Master KG','play_if_possible',53,'approved'),
(164,'Alors on danse version 3','Stromae','play_if_possible',54,'approved'),
(165,'Billie Jean version 1','Michael Jackson','must_play',55,'approved'),
(166,'Djadja version 2','Aya Nakamura','play_if_possible',56,'approved'),
(167,'Uptown Funk version 3','Bruno Mars','play_if_possible',57,'approved'),
(168,'Crazy in Love version 1','Beyoncé','play_if_possible',58,'requested'),
(169,'Destination Calabria version 2','Alex Gaudino','play_if_possible',59,'approved'),
(170,'Levitating version 3','Dua Lipa','must_play',60,'approved'),
(171,'September version 1','Earth Wind and Fire','play_if_possible',61,'approved'),
(172,'Freed From Desire version 2','Gala','play_if_possible',62,'approved'),
(173,'Jerusalema version 3','Master KG','play_if_possible',63,'approved'),
(174,'Alors on danse version 1','Stromae','play_if_possible',64,'approved'),
(175,'Billie Jean version 2','Michael Jackson','must_play',65,'requested'),
(176,'Djadja version 3','Aya Nakamura','play_if_possible',66,'approved'),
(177,'Uptown Funk version 1','Bruno Mars','play_if_possible',67,'approved'),
(178,'Crazy in Love version 2','Beyoncé','play_if_possible',68,'approved'),
(179,'Destination Calabria version 3','Alex Gaudino','play_if_possible',69,'approved'),
(180,'Levitating version 1','Dua Lipa','must_play',70,'approved'),
(181,'September version 2','Earth Wind and Fire','play_if_possible',71,'approved'),
(182,'Freed From Desire version 3','Gala','play_if_possible',72,'requested'),
(183,'Jerusalema version 1','Master KG','play_if_possible',73,'approved'),
(184,'Alors on danse version 2','Stromae','play_if_possible',74,'approved'),
(185,'Billie Jean version 3','Michael Jackson','must_play',75,'approved'),
(186,'Djadja version 1','Aya Nakamura','play_if_possible',76,'approved'),
(187,'Uptown Funk version 2','Bruno Mars','play_if_possible',77,'approved'),
(188,'Crazy in Love version 3','Beyoncé','play_if_possible',78,'approved'),
(189,'Destination Calabria version 1','Alex Gaudino','play_if_possible',79,'requested'),
(190,'Levitating version 2','Dua Lipa','must_play',80,'approved'),
(191,'September version 3','Earth Wind and Fire','play_if_possible',81,'approved'),
(192,'Freed From Desire version 1','Gala','play_if_possible',82,'approved'),
(193,'Jerusalema version 2','Master KG','play_if_possible',83,'approved'),
(194,'Alors on danse version 3','Stromae','play_if_possible',84,'approved'),
(195,'Billie Jean version 1','Michael Jackson','must_play',85,'approved'),
(196,'Djadja version 2','Aya Nakamura','play_if_possible',86,'requested'),
(197,'Uptown Funk version 3','Bruno Mars','play_if_possible',87,'approved'),
(198,'Crazy in Love version 1','Beyoncé','play_if_possible',88,'approved'),
(199,'Destination Calabria version 2','Alex Gaudino','play_if_possible',89,'approved'),
(200,'Levitating version 3','Dua Lipa','must_play',90,'approved'),
(201,'September version 1','Earth Wind and Fire','play_if_possible',91,'approved'),
(202,'Freed From Desire version 2','Gala','play_if_possible',92,'approved'),
(203,'Jerusalema version 3','Master KG','play_if_possible',93,'requested'),
(204,'Alors on danse version 1','Stromae','play_if_possible',94,'approved'),
(205,'Billie Jean version 2','Michael Jackson','must_play',95,'approved'),
(206,'Djadja version 3','Aya Nakamura','play_if_possible',96,'approved'),
(207,'Uptown Funk version 1','Bruno Mars','play_if_possible',97,'approved'),
(208,'Crazy in Love version 2','Beyoncé','play_if_possible',98,'approved'),
(209,'Destination Calabria version 3','Alex Gaudino','play_if_possible',99,'approved'),
(210,'Levitating version 1','Dua Lipa','must_play',100,'requested'),
(211,'September version 2','Earth Wind and Fire','play_if_possible',101,'approved'),
(212,'Freed From Desire version 3','Gala','play_if_possible',102,'approved'),
(213,'Jerusalema version 1','Master KG','play_if_possible',103,'approved'),
(214,'Alors on danse version 2','Stromae','play_if_possible',104,'approved'),
(215,'Billie Jean version 3','Michael Jackson','must_play',105,'approved'),
(216,'Djadja version 1','Aya Nakamura','play_if_possible',106,'approved'),
(217,'Uptown Funk version 2','Bruno Mars','play_if_possible',107,'requested'),
(218,'Crazy in Love version 3','Beyoncé','play_if_possible',108,'approved'),
(219,'Destination Calabria version 1','Alex Gaudino','play_if_possible',109,'approved'),
(220,'Levitating version 2','Dua Lipa','must_play',110,'approved');
/*!40000 ALTER TABLE `playlist_songs` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `playlists`
--

DROP TABLE IF EXISTS `playlists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `playlists` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `notes` varchar(255) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `booking_id` bigint(20) NOT NULL,
  `main_style_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_id` (`booking_id`),
  KEY `playlists_main_style_id_5c483738_fk_music_styles_id` (`main_style_id`),
  CONSTRAINT `playlists_booking_id_70c4181c_fk_bookings_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  CONSTRAINT `playlists_main_style_id_5c483738_fk_music_styles_id` FOREIGN KEY (`main_style_id`) REFERENCES `music_styles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=111 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `playlists`
--

LOCK TABLES `playlists` WRITE;
/*!40000 ALTER TABLE `playlists` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `playlists` VALUES
(1,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-01 08:00:00.000000',1,13),
(2,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-02 08:00:00.000000',2,14),
(3,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-03 08:00:00.000000',3,15),
(4,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-04 08:00:00.000000',4,16),
(5,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-05 08:00:00.000000',5,17),
(6,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-06 08:00:00.000000',6,18),
(7,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-07 08:00:00.000000',7,19),
(8,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-08 08:00:00.000000',8,20),
(9,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-09 08:00:00.000000',9,21),
(10,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-10 08:00:00.000000',10,22),
(11,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-11 08:00:00.000000',11,23),
(12,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-12 08:00:00.000000',12,24),
(13,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-13 08:00:00.000000',13,13),
(14,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-14 08:00:00.000000',14,14),
(15,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-15 08:00:00.000000',15,15),
(16,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-16 08:00:00.000000',16,16),
(17,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-17 08:00:00.000000',17,17),
(18,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-18 08:00:00.000000',18,18),
(19,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-19 08:00:00.000000',19,19),
(20,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-20 08:00:00.000000',20,20),
(21,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-21 08:00:00.000000',21,21),
(22,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-22 08:00:00.000000',22,22),
(23,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-23 08:00:00.000000',23,23),
(24,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-24 08:00:00.000000',24,24),
(25,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-25 08:00:00.000000',25,13),
(26,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-26 08:00:00.000000',26,14),
(27,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-27 08:00:00.000000',27,15),
(28,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-28 08:00:00.000000',28,16),
(29,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-29 08:00:00.000000',29,17),
(30,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-30 08:00:00.000000',30,18),
(31,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-05-31 08:00:00.000000',31,19),
(32,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-01 08:00:00.000000',32,20),
(33,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-02 08:00:00.000000',33,21),
(34,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-03 08:00:00.000000',34,22),
(35,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-04 08:00:00.000000',35,23),
(36,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-05 08:00:00.000000',36,24),
(37,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-06 08:00:00.000000',37,13),
(38,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-07 08:00:00.000000',38,14),
(39,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-08 08:00:00.000000',39,15),
(40,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-09 08:00:00.000000',40,16),
(41,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-10 08:00:00.000000',41,17),
(42,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-11 08:00:00.000000',42,18),
(43,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-12 08:00:00.000000',43,19),
(44,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-13 08:00:00.000000',44,20),
(45,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-14 08:00:00.000000',45,21),
(46,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-15 08:00:00.000000',46,22),
(47,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-16 08:00:00.000000',47,23),
(48,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-17 08:00:00.000000',48,24),
(49,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-18 08:00:00.000000',49,13),
(50,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-19 08:00:00.000000',50,14),
(51,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-20 08:00:00.000000',51,15),
(52,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-21 08:00:00.000000',52,16),
(53,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-22 08:00:00.000000',53,17),
(54,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-23 08:00:00.000000',54,18),
(55,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-24 08:00:00.000000',55,19),
(56,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-25 08:00:00.000000',56,20),
(57,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-26 08:00:00.000000',57,21),
(58,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-27 08:00:00.000000',58,22),
(59,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-28 08:00:00.000000',59,23),
(60,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-29 08:00:00.000000',60,24),
(61,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-06-30 08:00:00.000000',61,13),
(62,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-01 08:00:00.000000',62,14),
(63,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-02 08:00:00.000000',63,15),
(64,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-03 08:00:00.000000',64,16),
(65,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-04 08:00:00.000000',65,17),
(66,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-05 08:00:00.000000',66,18),
(67,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-06 08:00:00.000000',67,19),
(68,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-07 08:00:00.000000',68,20),
(69,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-08 08:00:00.000000',69,21),
(70,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-09 08:00:00.000000',70,22),
(71,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-10 08:00:00.000000',71,23),
(72,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-11 08:00:00.000000',72,24),
(73,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-12 08:00:00.000000',73,13),
(74,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-13 08:00:00.000000',74,14),
(75,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-14 08:00:00.000000',75,15),
(76,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-15 08:00:00.000000',76,16),
(77,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-16 08:00:00.000000',77,17),
(78,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-17 08:00:00.000000',78,18),
(79,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-18 08:00:00.000000',79,19),
(80,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-19 08:00:00.000000',80,20),
(81,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-20 08:00:00.000000',81,21),
(82,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-21 08:00:00.000000',82,22),
(83,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-22 08:00:00.000000',83,23),
(84,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-23 08:00:00.000000',84,24),
(85,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-24 08:00:00.000000',85,13),
(86,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-25 08:00:00.000000',86,14),
(87,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-26 08:00:00.000000',87,15),
(88,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-27 08:00:00.000000',88,16),
(89,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-28 08:00:00.000000',89,17),
(90,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-29 08:00:00.000000',90,18),
(91,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-30 08:00:00.000000',91,19),
(92,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-07-31 08:00:00.000000',92,20),
(93,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-01 08:00:00.000000',93,21),
(94,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-02 08:00:00.000000',94,22),
(95,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-03 08:00:00.000000',95,23),
(96,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-04 08:00:00.000000',96,24),
(97,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-05 08:00:00.000000',97,13),
(98,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-06 08:00:00.000000',98,14),
(99,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-07 08:00:00.000000',99,15),
(100,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-08 08:00:00.000000',100,16),
(101,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-09 08:00:00.000000',101,17),
(102,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-10 08:00:00.000000',102,18),
(103,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-11 08:00:00.000000',103,19),
(104,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-12 08:00:00.000000',104,20),
(105,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-13 08:00:00.000000',105,21),
(106,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-14 08:00:00.000000',106,22),
(107,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-15 08:00:00.000000',107,23),
(108,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-16 08:00:00.000000',108,24),
(109,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-17 08:00:00.000000',109,13),
(110,'Prévoir une ouverture dynamique et respecter la liste des titres interdits communiquée par le client.','2026-08-18 08:00:00.000000',110,14);
/*!40000 ALTER TABLE `playlists` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `preparatory_appointments`
--

DROP TABLE IF EXISTS `preparatory_appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `preparatory_appointments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `scheduled_at` datetime(6) NOT NULL,
  `mode` varchar(20) NOT NULL,
  `status` varchar(20) NOT NULL,
  `notes` longtext NOT NULL,
  `booking_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `preparatory_appointments_booking_id_e4a993fb_fk_bookings_id` (`booking_id`),
  CONSTRAINT `preparatory_appointments_booking_id_e4a993fb_fk_bookings_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `preparatory_appointments`
--

LOCK TABLES `preparatory_appointments` WRITE;
/*!40000 ALTER TABLE `preparatory_appointments` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `preparatory_appointments` VALUES
(1,'2026-08-14 08:00:00.000000','online','planned','L\'organisation',1);
/*!40000 ALTER TABLE `preparatory_appointments` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `quote_options`
--

DROP TABLE IF EXISTS `quote_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `quote_options` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `quantity` smallint(5) unsigned NOT NULL CHECK (`quantity` >= 0),
  `unit_price` decimal(10,2) NOT NULL,
  `quote_id` bigint(20) NOT NULL,
  `service_option_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_quote_service_option` (`quote_id`,`service_option_id`),
  KEY `quote_options_service_option_id_0fae51fc_fk_service_options_id` (`service_option_id`),
  CONSTRAINT `quote_options_quote_id_7799bde0_fk_quotes_id` FOREIGN KEY (`quote_id`) REFERENCES `quotes` (`id`),
  CONSTRAINT `quote_options_service_option_id_0fae51fc_fk_service_options_id` FOREIGN KEY (`service_option_id`) REFERENCES `service_options` (`id`),
  CONSTRAINT `quote_option_quantity_positive` CHECK (`quantity` > 0),
  CONSTRAINT `quote_option_unit_price_positive` CHECK (`unit_price` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=241 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quote_options`
--

LOCK TABLES `quote_options` WRITE;
/*!40000 ALTER TABLE `quote_options` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `quote_options` VALUES
(1,2,86.00,1,14),
(2,1,176.00,1,19),
(3,1,104.00,2,15),
(4,2,194.00,2,20),
(5,2,122.00,3,16),
(6,1,212.00,3,21),
(7,1,140.00,4,17),
(8,2,230.00,4,22),
(9,2,158.00,5,18),
(10,1,248.00,5,23),
(11,1,176.00,6,19),
(12,2,266.00,6,24),
(13,2,194.00,7,20),
(14,1,68.00,7,13),
(15,1,212.00,8,21),
(16,2,86.00,8,14),
(17,2,230.00,9,22),
(18,1,104.00,9,15),
(19,1,248.00,10,23),
(20,2,122.00,10,16),
(21,2,266.00,11,24),
(22,1,140.00,11,17),
(23,1,68.00,12,13),
(24,2,158.00,12,18),
(25,2,86.00,13,14),
(26,1,176.00,13,19),
(27,1,104.00,14,15),
(28,2,194.00,14,20),
(29,2,122.00,15,16),
(30,1,212.00,15,21),
(31,1,140.00,16,17),
(32,2,230.00,16,22),
(33,2,158.00,17,18),
(34,1,248.00,17,23),
(35,1,176.00,18,19),
(36,2,266.00,18,24),
(37,2,194.00,19,20),
(38,1,68.00,19,13),
(39,1,212.00,20,21),
(40,2,86.00,20,14),
(41,2,230.00,21,22),
(42,1,104.00,21,15),
(43,1,248.00,22,23),
(44,2,122.00,22,16),
(45,2,266.00,23,24),
(46,1,140.00,23,17),
(47,1,68.00,24,13),
(48,2,158.00,24,18),
(49,2,86.00,25,14),
(50,1,176.00,25,19),
(51,1,104.00,26,15),
(52,2,194.00,26,20),
(53,2,122.00,27,16),
(54,1,212.00,27,21),
(55,1,140.00,28,17),
(56,2,230.00,28,22),
(57,2,158.00,29,18),
(58,1,248.00,29,23),
(59,1,176.00,30,19),
(60,2,266.00,30,24),
(61,2,194.00,31,20),
(62,1,68.00,31,13),
(63,1,212.00,32,21),
(64,2,86.00,32,14),
(65,2,230.00,33,22),
(66,1,104.00,33,15),
(67,1,248.00,34,23),
(68,2,122.00,34,16),
(69,2,266.00,35,24),
(70,1,140.00,35,17),
(71,1,68.00,36,13),
(72,2,158.00,36,18),
(73,2,86.00,37,14),
(74,1,176.00,37,19),
(75,1,104.00,38,15),
(76,2,194.00,38,20),
(77,2,122.00,39,16),
(78,1,212.00,39,21),
(79,1,140.00,40,17),
(80,2,230.00,40,22),
(81,2,158.00,41,18),
(82,1,248.00,41,23),
(83,1,176.00,42,19),
(84,2,266.00,42,24),
(85,2,194.00,43,20),
(86,1,68.00,43,13),
(87,1,212.00,44,21),
(88,2,86.00,44,14),
(89,2,230.00,45,22),
(90,1,104.00,45,15),
(91,1,248.00,46,23),
(92,2,122.00,46,16),
(93,2,266.00,47,24),
(94,1,140.00,47,17),
(95,1,68.00,48,13),
(96,2,158.00,48,18),
(97,2,86.00,49,14),
(98,1,176.00,49,19),
(99,1,104.00,50,15),
(100,2,194.00,50,20),
(101,2,122.00,51,16),
(102,1,212.00,51,21),
(103,1,140.00,52,17),
(104,2,230.00,52,22),
(105,2,158.00,53,18),
(106,1,248.00,53,23),
(107,1,176.00,54,19),
(108,2,266.00,54,24),
(109,2,194.00,55,20),
(110,1,68.00,55,13),
(111,1,212.00,56,21),
(112,2,86.00,56,14),
(113,2,230.00,57,22),
(114,1,104.00,57,15),
(115,1,248.00,58,23),
(116,2,122.00,58,16),
(117,2,266.00,59,24),
(118,1,140.00,59,17),
(119,1,68.00,60,13),
(120,2,158.00,60,18),
(121,2,86.00,61,14),
(122,1,176.00,61,19),
(123,1,104.00,62,15),
(124,2,194.00,62,20),
(125,2,122.00,63,16),
(126,1,212.00,63,21),
(127,1,140.00,64,17),
(128,2,230.00,64,22),
(129,2,158.00,65,18),
(130,1,248.00,65,23),
(131,1,176.00,66,19),
(132,2,266.00,66,24),
(133,2,194.00,67,20),
(134,1,68.00,67,13),
(135,1,212.00,68,21),
(136,2,86.00,68,14),
(137,2,230.00,69,22),
(138,1,104.00,69,15),
(139,1,248.00,70,23),
(140,2,122.00,70,16),
(141,2,266.00,71,24),
(142,1,140.00,71,17),
(143,1,68.00,72,13),
(144,2,158.00,72,18),
(145,2,86.00,73,14),
(146,1,176.00,73,19),
(147,1,104.00,74,15),
(148,2,194.00,74,20),
(149,2,122.00,75,16),
(150,1,212.00,75,21),
(151,1,140.00,76,17),
(152,2,230.00,76,22),
(153,2,158.00,77,18),
(154,1,248.00,77,23),
(155,1,176.00,78,19),
(156,2,266.00,78,24),
(157,2,194.00,79,20),
(158,1,68.00,79,13),
(159,1,212.00,80,21),
(160,2,86.00,80,14),
(161,2,230.00,81,22),
(162,1,104.00,81,15),
(163,1,248.00,82,23),
(164,2,122.00,82,16),
(165,2,266.00,83,24),
(166,1,140.00,83,17),
(167,1,68.00,84,13),
(168,2,158.00,84,18),
(169,2,86.00,85,14),
(170,1,176.00,85,19),
(171,1,104.00,86,15),
(172,2,194.00,86,20),
(173,2,122.00,87,16),
(174,1,212.00,87,21),
(175,1,140.00,88,17),
(176,2,230.00,88,22),
(177,2,158.00,89,18),
(178,1,248.00,89,23),
(179,1,176.00,90,19),
(180,2,266.00,90,24),
(181,2,194.00,91,20),
(182,1,68.00,91,13),
(183,1,212.00,92,21),
(184,2,86.00,92,14),
(185,2,230.00,93,22),
(186,1,104.00,93,15),
(187,1,248.00,94,23),
(188,2,122.00,94,16),
(189,2,266.00,95,24),
(190,1,140.00,95,17),
(191,1,68.00,96,13),
(192,2,158.00,96,18),
(193,2,86.00,97,14),
(194,1,176.00,97,19),
(195,1,104.00,98,15),
(196,2,194.00,98,20),
(197,2,122.00,99,16),
(198,1,212.00,99,21),
(199,1,140.00,100,17),
(200,2,230.00,100,22),
(201,2,158.00,101,18),
(202,1,248.00,101,23),
(203,1,176.00,102,19),
(204,2,266.00,102,24),
(205,2,194.00,103,20),
(206,1,68.00,103,13),
(207,1,212.00,104,21),
(208,2,86.00,104,14),
(209,2,230.00,105,22),
(210,1,104.00,105,15),
(211,1,248.00,106,23),
(212,2,122.00,106,16),
(213,2,266.00,107,24),
(214,1,140.00,107,17),
(215,1,68.00,108,13),
(216,2,158.00,108,18),
(217,2,86.00,109,14),
(218,1,176.00,109,19),
(219,1,104.00,110,15),
(220,2,194.00,110,20),
(221,2,122.00,111,16),
(222,1,212.00,111,21),
(223,1,140.00,112,17),
(224,2,230.00,112,22),
(225,2,158.00,113,18),
(226,1,248.00,113,23),
(227,1,176.00,114,19),
(228,2,266.00,114,24),
(229,2,194.00,115,20),
(230,1,68.00,115,13),
(231,1,212.00,116,21),
(232,2,86.00,116,14),
(233,2,230.00,117,22),
(234,1,104.00,117,15),
(235,1,248.00,118,23),
(236,2,122.00,118,16),
(237,2,266.00,119,24),
(238,1,140.00,119,17),
(239,1,68.00,120,13),
(240,2,158.00,120,18);
/*!40000 ALTER TABLE `quote_options` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `quotes`
--

DROP TABLE IF EXISTS `quotes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `quotes` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `event_date` date NOT NULL,
  `start_time` time(6) NOT NULL,
  `duration_hours` decimal(4,1) NOT NULL,
  `guest_count` smallint(5) unsigned NOT NULL CHECK (`guest_count` >= 0),
  `status` varchar(20) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `travel_fee` decimal(10,2) NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `deposit_amount` decimal(10,2) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  `event_type_id` bigint(20) NOT NULL,
  `package_id` bigint(20) NOT NULL,
  `venue_id` bigint(20) NOT NULL,
  `distance_km` decimal(6,2) NOT NULL,
  `parking_available` tinyint(1) NOT NULL,
  `music_preferences` longtext NOT NULL,
  PRIMARY KEY (`id`),
  KEY `quotes_venue_id_85614e66_fk_venues_id` (`venue_id`),
  KEY `quotes_client_id_689522ba_fk_client_profiles_id` (`client_id`),
  KEY `quotes_event_type_id_6a0f9734_fk_event_types_id` (`event_type_id`),
  KEY `quotes_package_id_fff932b5_fk_packages_id` (`package_id`),
  KEY `idx_quote_event_date` (`event_date`),
  KEY `idx_quote_status` (`status`),
  CONSTRAINT `quotes_client_id_689522ba_fk_client_profiles_id` FOREIGN KEY (`client_id`) REFERENCES `client_profiles` (`id`),
  CONSTRAINT `quotes_event_type_id_6a0f9734_fk_event_types_id` FOREIGN KEY (`event_type_id`) REFERENCES `event_types` (`id`),
  CONSTRAINT `quotes_package_id_fff932b5_fk_packages_id` FOREIGN KEY (`package_id`) REFERENCES `packages` (`id`),
  CONSTRAINT `quotes_venue_id_85614e66_fk_venues_id` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`),
  CONSTRAINT `quote_total_positive` CHECK (`total_amount` >= 0),
  CONSTRAINT `quote_deposit_positive` CHECK (`deposit_amount` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quotes`
--

LOCK TABLES `quotes` WRITE;
/*!40000 ALTER TABLE `quotes` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `quotes` VALUES
(1,'2026-08-16','19:00:00.000000',4.5,41,'accepted',752.50,3.12,755.62,226.69,'2026-02-25 09:00:00.000000',121,10,11,241,4.80,1,''),
(2,'2026-08-17','20:00:00.000000',5.0,42,'accepted',945.00,3.64,948.64,284.59,'2026-02-26 09:00:00.000000',122,11,12,242,5.60,1,''),
(3,'2026-08-18','21:00:00.000000',5.5,43,'accepted',1137.50,4.16,1141.66,342.50,'2026-02-27 09:00:00.000000',123,12,13,243,6.40,0,''),
(4,'2026-08-19','18:00:00.000000',6.0,44,'accepted',1010.00,4.68,1014.68,304.40,'2026-02-28 09:00:00.000000',124,13,14,244,7.20,1,''),
(5,'2026-08-20','19:00:00.000000',6.5,45,'accepted',1202.50,5.20,1207.70,362.31,'2026-03-01 09:00:00.000000',125,14,15,245,8.00,1,''),
(6,'2026-08-21','20:00:00.000000',4.0,46,'accepted',1290.00,5.72,1295.72,388.72,'2026-03-02 09:00:00.000000',126,15,16,246,8.80,0,''),
(7,'2026-08-22','21:00:00.000000',4.5,47,'accepted',1482.50,6.24,1488.74,446.62,'2026-03-03 09:00:00.000000',127,16,17,247,9.60,1,''),
(8,'2026-08-23','18:00:00.000000',5.0,48,'accepted',1355.00,6.76,1361.76,408.53,'2026-03-04 09:00:00.000000',128,17,18,248,10.40,1,''),
(9,'2026-08-24','19:00:00.000000',5.5,49,'accepted',1547.50,7.28,1554.78,466.43,'2026-03-05 09:00:00.000000',129,10,19,249,11.20,0,''),
(10,'2026-08-25','20:00:00.000000',6.0,50,'accepted',1740.00,7.80,1747.80,524.34,'2026-03-06 09:00:00.000000',130,11,20,250,12.00,1,''),
(11,'2026-08-26','21:00:00.000000',6.5,51,'accepted',982.50,8.32,990.82,297.25,'2026-03-07 09:00:00.000000',131,12,11,251,12.80,1,''),
(12,'2026-08-27','18:00:00.000000',4.0,52,'accepted',750.00,8.84,758.84,227.65,'2026-03-08 09:00:00.000000',132,13,12,252,13.60,0,''),
(13,'2026-08-28','19:00:00.000000',4.5,53,'accepted',942.50,9.36,951.86,285.56,'2026-03-09 09:00:00.000000',133,14,13,253,14.40,1,''),
(14,'2026-08-29','20:00:00.000000',5.0,54,'accepted',1135.00,9.88,1144.88,343.46,'2026-03-10 09:00:00.000000',134,15,14,254,15.20,1,''),
(15,'2026-08-30','21:00:00.000000',5.5,55,'accepted',1327.50,10.40,1337.90,401.37,'2026-03-11 09:00:00.000000',135,16,15,255,16.00,0,''),
(16,'2026-08-31','18:00:00.000000',6.0,56,'accepted',1200.00,10.92,1210.92,363.28,'2026-03-12 09:00:00.000000',136,17,16,256,16.80,1,''),
(17,'2026-09-01','19:00:00.000000',6.5,57,'accepted',1392.50,11.44,1403.94,421.18,'2026-03-13 09:00:00.000000',137,10,17,257,17.60,1,''),
(18,'2026-09-02','20:00:00.000000',4.0,58,'accepted',1480.00,11.96,1491.96,447.59,'2026-03-14 09:00:00.000000',138,11,18,258,18.40,0,''),
(19,'2026-09-03','21:00:00.000000',4.5,59,'accepted',1672.50,12.48,1684.98,505.49,'2026-03-15 09:00:00.000000',139,12,19,259,19.20,1,''),
(20,'2026-09-04','18:00:00.000000',5.0,60,'accepted',1545.00,13.00,1558.00,467.40,'2026-03-16 09:00:00.000000',140,13,20,260,20.00,1,''),
(21,'2026-09-05','19:00:00.000000',5.5,61,'accepted',787.50,13.52,801.02,240.31,'2026-03-17 09:00:00.000000',141,14,11,261,20.80,0,''),
(22,'2026-09-06','20:00:00.000000',6.0,62,'accepted',980.00,14.04,994.04,298.21,'2026-03-18 09:00:00.000000',142,15,12,262,21.60,1,''),
(23,'2026-09-07','21:00:00.000000',6.5,63,'accepted',1172.50,14.56,1187.06,356.12,'2026-03-19 09:00:00.000000',143,16,13,263,22.40,1,''),
(24,'2026-09-08','18:00:00.000000',4.0,64,'accepted',940.00,15.08,955.08,286.52,'2026-03-20 09:00:00.000000',144,17,14,264,23.20,0,''),
(25,'2026-09-09','19:00:00.000000',4.5,65,'accepted',1132.50,15.60,1148.10,344.43,'2026-03-21 09:00:00.000000',145,10,15,265,24.00,1,''),
(26,'2026-09-10','20:00:00.000000',5.0,66,'accepted',1325.00,16.12,1341.12,402.34,'2026-03-22 09:00:00.000000',146,11,16,266,24.80,1,''),
(27,'2026-09-11','21:00:00.000000',5.5,67,'accepted',1517.50,16.64,1534.14,460.24,'2026-03-23 09:00:00.000000',147,12,17,267,25.60,0,''),
(28,'2026-09-12','18:00:00.000000',6.0,68,'accepted',1390.00,17.16,1407.16,422.15,'2026-03-24 09:00:00.000000',148,13,18,268,26.40,1,''),
(29,'2026-09-13','19:00:00.000000',6.5,69,'accepted',1582.50,17.68,1600.18,480.05,'2026-03-25 09:00:00.000000',149,14,19,269,27.20,1,''),
(30,'2026-09-14','20:00:00.000000',4.0,70,'accepted',1670.00,18.20,1688.20,506.46,'2026-03-26 09:00:00.000000',150,15,20,270,28.00,0,''),
(31,'2026-09-15','21:00:00.000000',4.5,71,'accepted',912.50,18.72,931.22,279.37,'2026-03-27 09:00:00.000000',151,16,11,271,28.80,1,''),
(32,'2026-09-16','18:00:00.000000',5.0,72,'accepted',785.00,19.24,804.24,241.27,'2026-03-28 09:00:00.000000',152,17,12,272,29.60,1,''),
(33,'2026-09-17','19:00:00.000000',5.5,73,'accepted',977.50,19.76,997.26,299.18,'2026-03-29 08:00:00.000000',153,10,13,273,30.40,0,''),
(34,'2026-09-18','20:00:00.000000',6.0,74,'accepted',1170.00,20.28,1190.28,357.08,'2026-03-30 08:00:00.000000',154,11,14,274,31.20,1,''),
(35,'2026-09-19','21:00:00.000000',6.5,75,'accepted',1362.50,20.80,1383.30,414.99,'2026-03-31 08:00:00.000000',155,12,15,275,32.00,1,''),
(36,'2026-09-20','18:00:00.000000',4.0,76,'accepted',1130.00,21.32,1151.32,345.40,'2026-04-01 08:00:00.000000',156,13,16,276,32.80,0,''),
(37,'2026-09-21','19:00:00.000000',4.5,77,'accepted',1322.50,21.84,1344.34,403.30,'2026-04-02 08:00:00.000000',157,14,17,277,33.60,1,''),
(38,'2026-09-22','20:00:00.000000',5.0,78,'accepted',1515.00,22.36,1537.36,461.21,'2026-04-03 08:00:00.000000',158,15,18,278,34.40,1,''),
(39,'2026-09-23','21:00:00.000000',5.5,79,'accepted',1707.50,22.88,1730.38,519.11,'2026-04-04 08:00:00.000000',159,16,19,279,35.20,0,''),
(40,'2026-09-24','18:00:00.000000',6.0,80,'accepted',1580.00,23.40,1603.40,481.02,'2026-04-05 08:00:00.000000',160,17,20,280,36.00,1,''),
(41,'2026-09-25','19:00:00.000000',6.5,81,'accepted',822.50,23.92,846.42,253.93,'2026-04-06 08:00:00.000000',161,10,11,281,36.80,1,''),
(42,'2026-09-26','20:00:00.000000',4.0,82,'accepted',910.00,24.44,934.44,280.33,'2026-04-07 08:00:00.000000',162,11,12,282,37.60,0,''),
(43,'2026-09-27','21:00:00.000000',4.5,83,'accepted',1102.50,24.96,1127.46,338.24,'2026-04-08 08:00:00.000000',163,12,13,283,38.40,1,''),
(44,'2026-09-28','18:00:00.000000',5.0,84,'accepted',975.00,25.48,1000.48,300.14,'2026-04-09 08:00:00.000000',164,13,14,284,39.20,1,''),
(45,'2026-09-29','19:00:00.000000',5.5,85,'accepted',1167.50,26.00,1193.50,358.05,'2026-04-10 08:00:00.000000',165,14,15,285,40.00,0,''),
(46,'2026-09-30','20:00:00.000000',6.0,86,'accepted',1360.00,26.52,1386.52,415.96,'2026-04-11 08:00:00.000000',166,15,16,286,40.80,1,''),
(47,'2026-10-01','21:00:00.000000',6.5,87,'accepted',1552.50,27.04,1579.54,473.86,'2026-04-12 08:00:00.000000',167,16,17,287,41.60,1,''),
(48,'2026-10-02','18:00:00.000000',4.0,88,'accepted',1320.00,27.56,1347.56,404.27,'2026-04-13 08:00:00.000000',168,17,18,288,42.40,0,''),
(49,'2026-10-03','19:00:00.000000',4.5,89,'accepted',1512.50,28.08,1540.58,462.17,'2026-04-14 08:00:00.000000',169,10,19,289,43.20,1,''),
(50,'2026-10-04','20:00:00.000000',5.0,90,'accepted',1705.00,28.60,1733.60,520.08,'2026-04-15 08:00:00.000000',170,11,20,290,44.00,1,''),
(51,'2026-10-05','21:00:00.000000',5.5,91,'accepted',947.50,29.12,976.62,292.99,'2026-04-16 08:00:00.000000',171,12,11,291,44.80,0,''),
(52,'2026-10-06','18:00:00.000000',6.0,92,'accepted',820.00,29.64,849.64,254.89,'2026-04-17 08:00:00.000000',172,13,12,292,45.60,1,''),
(53,'2026-10-07','19:00:00.000000',6.5,93,'accepted',1012.50,30.16,1042.66,312.80,'2026-04-18 08:00:00.000000',173,14,13,293,46.40,1,''),
(54,'2026-10-08','20:00:00.000000',4.0,94,'accepted',1100.00,30.68,1130.68,339.20,'2026-04-19 08:00:00.000000',174,15,14,294,47.20,0,''),
(55,'2026-10-09','21:00:00.000000',4.5,95,'accepted',1292.50,31.20,1323.70,397.11,'2026-04-20 08:00:00.000000',175,16,15,295,48.00,1,''),
(56,'2026-10-10','18:00:00.000000',5.0,96,'accepted',1165.00,31.72,1196.72,359.02,'2026-04-21 08:00:00.000000',176,17,16,296,48.80,1,''),
(57,'2026-10-11','19:00:00.000000',5.5,97,'accepted',1357.50,32.24,1389.74,416.92,'2026-04-22 08:00:00.000000',177,10,17,297,49.60,0,''),
(58,'2026-10-12','20:00:00.000000',6.0,98,'accepted',1550.00,32.76,1582.76,474.83,'2026-04-23 08:00:00.000000',178,11,18,298,50.40,1,''),
(59,'2026-10-13','21:00:00.000000',6.5,99,'accepted',1742.50,33.28,1775.78,532.73,'2026-04-24 08:00:00.000000',179,12,19,299,51.20,1,''),
(60,'2026-10-14','18:00:00.000000',4.0,100,'accepted',1510.00,33.80,1543.80,463.14,'2026-04-25 08:00:00.000000',180,13,20,300,52.00,0,''),
(61,'2026-10-15','19:00:00.000000',4.5,101,'accepted',752.50,34.32,786.82,236.05,'2026-04-26 08:00:00.000000',181,14,11,301,52.80,1,''),
(62,'2026-10-16','20:00:00.000000',5.0,102,'accepted',945.00,34.84,979.84,293.95,'2026-04-27 08:00:00.000000',182,15,12,302,53.60,1,''),
(63,'2026-10-17','21:00:00.000000',5.5,103,'accepted',1137.50,35.36,1172.86,351.86,'2026-04-28 08:00:00.000000',183,16,13,303,54.40,0,''),
(64,'2026-10-18','18:00:00.000000',6.0,104,'accepted',1010.00,35.88,1045.88,313.76,'2026-04-29 08:00:00.000000',184,17,14,304,55.20,1,''),
(65,'2026-10-19','19:00:00.000000',6.5,105,'accepted',1202.50,36.40,1238.90,371.67,'2026-04-30 08:00:00.000000',185,10,15,305,56.00,1,''),
(66,'2026-10-20','20:00:00.000000',4.0,106,'accepted',1290.00,36.92,1326.92,398.08,'2026-05-01 08:00:00.000000',186,11,16,306,56.80,0,''),
(67,'2026-10-21','21:00:00.000000',4.5,107,'accepted',1482.50,37.44,1519.94,455.98,'2026-05-02 08:00:00.000000',187,12,17,307,57.60,1,''),
(68,'2026-10-22','18:00:00.000000',5.0,108,'accepted',1355.00,37.96,1392.96,417.89,'2026-05-03 08:00:00.000000',188,13,18,308,58.40,1,''),
(69,'2026-10-23','19:00:00.000000',5.5,109,'accepted',1547.50,38.48,1585.98,475.79,'2026-05-04 08:00:00.000000',189,14,19,309,59.20,0,''),
(70,'2026-10-24','20:00:00.000000',6.0,110,'accepted',1740.00,39.00,1779.00,533.70,'2026-05-05 08:00:00.000000',190,15,20,310,60.00,1,''),
(71,'2026-10-25','21:00:00.000000',6.5,111,'accepted',982.50,39.52,1022.02,306.61,'2026-05-06 08:00:00.000000',191,16,11,311,60.80,1,''),
(72,'2026-10-26','18:00:00.000000',4.0,112,'accepted',750.00,40.04,790.04,237.01,'2026-05-07 08:00:00.000000',192,17,12,312,61.60,0,''),
(73,'2026-10-27','19:00:00.000000',4.5,113,'accepted',942.50,40.56,983.06,294.92,'2026-05-08 08:00:00.000000',193,10,13,313,62.40,1,''),
(74,'2026-10-28','20:00:00.000000',5.0,114,'accepted',1135.00,41.08,1176.08,352.82,'2026-05-09 08:00:00.000000',194,11,14,314,63.20,1,''),
(75,'2026-10-29','21:00:00.000000',5.5,115,'accepted',1327.50,41.60,1369.10,410.73,'2026-05-10 08:00:00.000000',195,12,15,315,64.00,0,''),
(76,'2026-10-30','18:00:00.000000',6.0,116,'accepted',1200.00,42.12,1242.12,372.64,'2026-05-11 08:00:00.000000',196,13,16,316,64.80,1,''),
(77,'2026-10-31','19:00:00.000000',6.5,117,'accepted',1392.50,42.64,1435.14,430.54,'2026-05-12 08:00:00.000000',197,14,17,317,65.60,1,''),
(78,'2026-11-01','20:00:00.000000',4.0,118,'accepted',1480.00,43.16,1523.16,456.95,'2026-05-13 08:00:00.000000',198,15,18,318,66.40,0,''),
(79,'2026-11-02','21:00:00.000000',4.5,119,'accepted',1672.50,43.68,1716.18,514.85,'2026-05-14 08:00:00.000000',199,16,19,319,67.20,1,''),
(80,'2026-11-03','18:00:00.000000',5.0,120,'accepted',1545.00,44.20,1589.20,476.76,'2026-05-15 08:00:00.000000',200,17,20,320,68.00,1,''),
(81,'2026-11-04','19:00:00.000000',5.5,121,'accepted',787.50,44.72,832.22,249.67,'2026-05-16 08:00:00.000000',201,10,11,321,68.80,0,''),
(82,'2026-11-05','20:00:00.000000',6.0,122,'accepted',980.00,45.24,1025.24,307.57,'2026-05-17 08:00:00.000000',202,11,12,322,69.60,1,''),
(83,'2026-11-06','21:00:00.000000',6.5,123,'accepted',1172.50,45.76,1218.26,365.48,'2026-05-18 08:00:00.000000',203,12,13,323,70.40,1,''),
(84,'2026-11-07','18:00:00.000000',4.0,124,'accepted',940.00,46.28,986.28,295.88,'2026-05-19 08:00:00.000000',204,13,14,324,71.20,0,''),
(85,'2026-11-08','19:00:00.000000',4.5,125,'accepted',1132.50,46.80,1179.30,353.79,'2026-05-20 08:00:00.000000',205,14,15,325,72.00,1,''),
(86,'2026-11-09','20:00:00.000000',5.0,126,'accepted',1325.00,47.32,1372.32,411.70,'2026-05-21 08:00:00.000000',206,15,16,326,72.80,1,''),
(87,'2026-11-10','21:00:00.000000',5.5,127,'accepted',1517.50,47.84,1565.34,469.60,'2026-05-22 08:00:00.000000',207,16,17,327,73.60,0,''),
(88,'2026-11-11','18:00:00.000000',6.0,128,'accepted',1390.00,48.36,1438.36,431.51,'2026-05-23 08:00:00.000000',208,17,18,328,74.40,1,''),
(89,'2026-11-12','19:00:00.000000',6.5,129,'accepted',1582.50,48.88,1631.38,489.41,'2026-05-24 08:00:00.000000',209,10,19,329,75.20,1,''),
(90,'2026-11-13','20:00:00.000000',4.0,130,'accepted',1670.00,49.40,1719.40,515.82,'2026-05-25 08:00:00.000000',210,11,20,330,76.00,0,''),
(91,'2026-11-14','21:00:00.000000',4.5,131,'accepted',912.50,49.92,962.42,288.73,'2026-05-26 08:00:00.000000',211,12,11,331,76.80,1,''),
(92,'2026-11-15','18:00:00.000000',5.0,132,'accepted',785.00,50.44,835.44,250.63,'2026-05-27 08:00:00.000000',212,13,12,332,77.60,1,''),
(93,'2026-11-16','19:00:00.000000',5.5,133,'accepted',977.50,50.96,1028.46,308.54,'2026-05-28 08:00:00.000000',213,14,13,333,78.40,0,''),
(94,'2026-11-17','20:00:00.000000',6.0,134,'accepted',1170.00,51.48,1221.48,366.44,'2026-05-29 08:00:00.000000',214,15,14,334,79.20,1,''),
(95,'2026-11-18','21:00:00.000000',6.5,135,'accepted',1362.50,2.60,1365.10,409.53,'2026-05-30 08:00:00.000000',215,16,15,335,4.00,1,''),
(96,'2026-11-19','18:00:00.000000',4.0,136,'accepted',1130.00,3.12,1133.12,339.94,'2026-05-31 08:00:00.000000',216,17,16,336,4.80,0,''),
(97,'2026-11-20','19:00:00.000000',4.5,137,'accepted',1322.50,3.64,1326.14,397.84,'2026-06-01 08:00:00.000000',217,10,17,337,5.60,1,''),
(98,'2026-11-21','20:00:00.000000',5.0,138,'accepted',1515.00,4.16,1519.16,455.75,'2026-06-02 08:00:00.000000',218,11,18,338,6.40,1,''),
(99,'2026-11-22','21:00:00.000000',5.5,139,'accepted',1707.50,4.68,1712.18,513.65,'2026-06-03 08:00:00.000000',219,12,19,339,7.20,0,''),
(100,'2026-11-23','18:00:00.000000',6.0,140,'accepted',1580.00,5.20,1585.20,475.56,'2026-06-04 08:00:00.000000',220,13,20,340,8.00,1,''),
(101,'2026-11-24','19:00:00.000000',6.5,141,'accepted',822.50,5.72,828.22,248.47,'2026-06-05 08:00:00.000000',221,14,11,341,8.80,1,''),
(102,'2026-11-25','20:00:00.000000',4.0,142,'accepted',910.00,6.24,916.24,274.87,'2026-06-06 08:00:00.000000',222,15,12,342,9.60,0,''),
(103,'2026-11-26','21:00:00.000000',4.5,143,'accepted',1102.50,6.76,1109.26,332.78,'2026-06-07 08:00:00.000000',223,16,13,343,10.40,1,''),
(104,'2026-11-27','18:00:00.000000',5.0,144,'accepted',975.00,7.28,982.28,294.68,'2026-06-08 08:00:00.000000',224,17,14,344,11.20,1,''),
(105,'2026-11-28','19:00:00.000000',5.5,145,'accepted',1167.50,7.80,1175.30,352.59,'2026-06-09 08:00:00.000000',225,10,15,345,12.00,0,''),
(106,'2026-11-29','20:00:00.000000',6.0,146,'accepted',1360.00,8.32,1368.32,410.50,'2026-06-10 08:00:00.000000',226,11,16,346,12.80,1,''),
(107,'2026-11-30','21:00:00.000000',6.5,147,'accepted',1552.50,8.84,1561.34,468.40,'2026-06-11 08:00:00.000000',227,12,17,347,13.60,1,''),
(108,'2026-12-01','18:00:00.000000',4.0,148,'accepted',1320.00,9.36,1329.36,398.81,'2026-06-12 08:00:00.000000',228,13,18,348,14.40,0,''),
(109,'2026-12-02','19:00:00.000000',4.5,149,'accepted',1512.50,9.88,1522.38,456.71,'2026-06-13 08:00:00.000000',229,14,19,349,15.20,1,''),
(110,'2026-12-03','20:00:00.000000',5.0,150,'accepted',1705.00,10.40,1715.40,514.62,'2026-06-14 08:00:00.000000',230,15,20,350,16.00,1,''),
(111,'2026-12-04','21:00:00.000000',5.5,151,'sent',947.50,10.92,958.42,287.53,'2026-06-15 08:00:00.000000',231,16,11,351,16.80,0,''),
(112,'2026-12-05','18:00:00.000000',6.0,152,'sent',820.00,11.44,831.44,249.43,'2026-06-16 08:00:00.000000',232,17,12,352,17.60,1,''),
(113,'2026-12-06','19:00:00.000000',6.5,153,'sent',1012.50,11.96,1024.46,307.34,'2026-06-17 08:00:00.000000',233,10,13,353,18.40,1,''),
(114,'2026-12-07','20:00:00.000000',4.0,154,'sent',1100.00,12.48,1112.48,333.74,'2026-06-18 08:00:00.000000',234,11,14,354,19.20,0,''),
(115,'2026-12-08','21:00:00.000000',4.5,155,'sent',1292.50,13.00,1305.50,391.65,'2026-06-19 08:00:00.000000',235,12,15,355,20.00,1,''),
(116,'2026-12-09','18:00:00.000000',5.0,156,'sent',1165.00,13.52,1178.52,353.56,'2026-06-20 08:00:00.000000',236,13,16,356,20.80,1,''),
(117,'2026-12-10','19:00:00.000000',5.5,157,'sent',1357.50,14.04,1371.54,411.46,'2026-06-21 08:00:00.000000',237,14,17,357,21.60,0,''),
(118,'2026-12-11','20:00:00.000000',6.0,158,'sent',1550.00,14.56,1564.56,469.37,'2026-06-22 08:00:00.000000',238,15,18,358,22.40,1,''),
(119,'2026-12-12','21:00:00.000000',6.5,159,'sent',1742.50,15.08,1757.58,527.27,'2026-06-23 08:00:00.000000',239,16,19,359,23.20,1,''),
(120,'2026-12-13','18:00:00.000000',4.0,160,'sent',1510.00,15.60,1525.60,457.68,'2026-06-24 08:00:00.000000',240,17,20,360,24.00,0,'');
/*!40000 ALTER TABLE `quotes` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `refunds`
--

DROP TABLE IF EXISTS `refunds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `refunds` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `stripe_refund_id` varchar(190) DEFAULT NULL,
  `idempotency_key` uuid NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) NOT NULL,
  `reason` varchar(40) NOT NULL,
  `internal_reason` varchar(255) NOT NULL,
  `status` varchar(20) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `processed_at` datetime(6) DEFAULT NULL,
  `payment_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idempotency_key` (`idempotency_key`),
  UNIQUE KEY `stripe_refund_id` (`stripe_refund_id`),
  KEY `refunds_payment_id_075bbbe0_fk_payments_id` (`payment_id`),
  KEY `idx_refund_status_created` (`status`,`created_at`),
  CONSTRAINT `refunds_payment_id_075bbbe0_fk_payments_id` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`),
  CONSTRAINT `refund_amount_positive` CHECK (`amount` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refunds`
--

LOCK TABLES `refunds` WRITE;
/*!40000 ALTER TABLE `refunds` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `refunds` VALUES
(1,NULL,'d704a619-ab57-4692-a255-aa9ab8f554d5',100.00,'EUR','requested_by_customer','remboursement','succeeded','2026-08-13 21:56:22.665267',NULL,132);
/*!40000 ALTER TABLE `refunds` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `reviews` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `rating` smallint(5) unsigned NOT NULL CHECK (`rating` >= 0),
  `comment` varchar(255) NOT NULL,
  `status` varchar(20) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `booking_id` bigint(20) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  `dj_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_id` (`booking_id`),
  KEY `reviews_client_id_6232284c_fk_client_profiles_id` (`client_id`),
  KEY `reviews_dj_id_57214121_fk_dj_profiles_id` (`dj_id`),
  CONSTRAINT `reviews_booking_id_45ca787d_fk_bookings_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  CONSTRAINT `reviews_client_id_6232284c_fk_client_profiles_id` FOREIGN KEY (`client_id`) REFERENCES `client_profiles` (`id`),
  CONSTRAINT `reviews_dj_id_57214121_fk_dj_profiles_id` FOREIGN KEY (`dj_id`) REFERENCES `dj_profiles` (`id`),
  CONSTRAINT `review_rating_between_1_and_5` CHECK (`rating` >= 1 and `rating` <= 5)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `reviews` VALUES
(1,5,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-10 08:00:00.000000',1,121,101),
(2,4,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-11 08:00:00.000000',2,122,102),
(3,5,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-12 08:00:00.000000',3,123,103),
(4,4,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-13 08:00:00.000000',4,124,104),
(5,5,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-14 08:00:00.000000',5,125,105),
(6,4,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-15 08:00:00.000000',6,126,106),
(7,5,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-16 08:00:00.000000',7,127,107),
(8,4,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-17 08:00:00.000000',8,128,108),
(9,5,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-18 08:00:00.000000',9,129,109),
(10,4,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-19 08:00:00.000000',10,130,110),
(11,5,'Prestation très professionnelle et piste de danse remplie toute la soirée.','pending','2026-06-20 08:00:00.000000',11,131,111),
(12,4,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-21 08:00:00.000000',12,132,112),
(13,5,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-22 08:00:00.000000',13,133,113),
(14,4,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-23 08:00:00.000000',14,134,114),
(15,5,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-24 08:00:00.000000',15,135,115),
(16,4,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-25 08:00:00.000000',16,136,116),
(17,5,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-26 08:00:00.000000',17,137,117),
(18,4,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-27 08:00:00.000000',18,138,118),
(19,5,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-28 08:00:00.000000',19,139,119),
(20,4,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-09 08:00:00.000000',20,140,120),
(21,5,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-10 08:00:00.000000',21,141,121),
(22,4,'Très bonne communication avant l\'événement et excellente adaptation au public.','pending','2026-06-11 08:00:00.000000',22,142,122),
(23,5,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-12 08:00:00.000000',23,143,123),
(24,4,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-13 08:00:00.000000',24,144,124),
(25,5,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-14 08:00:00.000000',25,145,125),
(26,4,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-15 08:00:00.000000',26,146,126),
(27,5,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-16 08:00:00.000000',27,147,127),
(28,4,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-17 08:00:00.000000',28,148,128),
(29,5,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-18 08:00:00.000000',29,149,129),
(30,4,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-19 08:00:00.000000',30,150,130),
(31,5,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-20 08:00:00.000000',31,151,131),
(32,4,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-21 08:00:00.000000',32,152,132),
(33,5,'Matériel propre, installation ponctuelle et ambiance réussie.','pending','2026-06-22 08:00:00.000000',33,153,133),
(34,4,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-23 08:00:00.000000',34,154,134),
(35,5,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-24 08:00:00.000000',35,155,135),
(36,4,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-25 08:00:00.000000',36,156,136),
(37,5,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-26 08:00:00.000000',37,157,137),
(38,4,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-27 08:00:00.000000',38,158,138),
(39,5,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-28 08:00:00.000000',39,159,139),
(40,4,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-09 08:00:00.000000',40,160,140),
(41,5,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-10 08:00:00.000000',41,161,141),
(42,4,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-11 08:00:00.000000',42,162,142),
(43,5,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-12 08:00:00.000000',43,163,143),
(44,4,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','pending','2026-06-13 08:00:00.000000',44,164,144),
(45,5,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-14 08:00:00.000000',45,165,145),
(46,4,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-15 08:00:00.000000',46,166,146),
(47,5,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-16 08:00:00.000000',47,167,147),
(48,4,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-17 08:00:00.000000',48,168,148),
(49,5,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-18 08:00:00.000000',49,169,149),
(50,4,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-19 08:00:00.000000',50,170,150),
(51,5,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-20 08:00:00.000000',51,171,151),
(52,4,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-21 08:00:00.000000',52,172,152),
(53,5,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-22 08:00:00.000000',53,173,153),
(54,4,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-23 08:00:00.000000',54,174,154),
(55,5,'Très bon choix musical et respect de la playlist demandée.','pending','2026-06-24 08:00:00.000000',55,175,155),
(56,4,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-25 08:00:00.000000',56,176,156),
(57,5,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-26 08:00:00.000000',57,177,157),
(58,4,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-27 08:00:00.000000',58,178,158),
(59,5,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-28 08:00:00.000000',59,179,159),
(60,4,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-09 08:00:00.000000',60,180,160),
(61,5,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-10 08:00:00.000000',61,181,161),
(62,4,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-11 08:00:00.000000',62,182,162),
(63,5,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-12 08:00:00.000000',63,183,163),
(64,4,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-13 08:00:00.000000',64,184,164),
(65,5,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-14 08:00:00.000000',65,185,165),
(66,4,'Prestation très professionnelle et piste de danse remplie toute la soirée.','pending','2026-06-15 08:00:00.000000',66,186,166),
(67,5,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-16 08:00:00.000000',67,187,167),
(68,4,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-17 08:00:00.000000',68,188,168),
(69,5,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-18 08:00:00.000000',69,189,169),
(70,4,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-19 08:00:00.000000',70,190,170),
(71,5,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-20 08:00:00.000000',71,191,171),
(72,4,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-21 08:00:00.000000',72,192,172),
(73,5,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-22 08:00:00.000000',73,193,173),
(74,4,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-23 08:00:00.000000',74,194,174),
(75,5,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-24 08:00:00.000000',75,195,175),
(76,4,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-25 08:00:00.000000',76,196,176),
(77,5,'Très bonne communication avant l\'événement et excellente adaptation au public.','pending','2026-06-26 08:00:00.000000',77,197,177),
(78,4,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-27 08:00:00.000000',78,198,178),
(79,5,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-28 08:00:00.000000',79,199,179),
(80,4,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-09 08:00:00.000000',80,200,180),
(81,5,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-10 08:00:00.000000',81,201,181),
(82,4,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-11 08:00:00.000000',82,202,182),
(83,5,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-12 08:00:00.000000',83,203,183),
(84,4,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-13 08:00:00.000000',84,204,184),
(85,5,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-14 08:00:00.000000',85,205,185),
(86,4,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-15 08:00:00.000000',86,206,186),
(87,5,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-16 08:00:00.000000',87,207,187),
(88,4,'Matériel propre, installation ponctuelle et ambiance réussie.','pending','2026-06-17 08:00:00.000000',88,208,188),
(89,5,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-18 08:00:00.000000',89,209,189),
(90,4,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-19 08:00:00.000000',90,210,190),
(91,5,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-20 08:00:00.000000',91,211,191),
(92,4,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-21 08:00:00.000000',92,212,192),
(93,5,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-22 08:00:00.000000',93,213,193),
(94,4,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','published','2026-06-23 08:00:00.000000',94,214,194),
(95,5,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-24 08:00:00.000000',95,215,195),
(96,4,'Prestation très professionnelle et piste de danse remplie toute la soirée.','published','2026-06-25 08:00:00.000000',96,216,196),
(97,5,'Très bonne communication avant l\'événement et excellente adaptation au public.','published','2026-06-26 08:00:00.000000',97,217,197),
(98,4,'Matériel propre, installation ponctuelle et ambiance réussie.','published','2026-06-27 08:00:00.000000',98,218,198),
(99,5,'Le rendez-vous préparatoire a permis de clarifier tous les besoins.','pending','2026-06-28 08:00:00.000000',99,219,199),
(100,4,'Très bon choix musical et respect de la playlist demandée.','published','2026-06-09 08:00:00.000000',100,220,200);
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `service_options`
--

DROP TABLE IF EXISTS `service_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_options` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `price_type` varchar(20) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  CONSTRAINT `service_option_unit_price_positive` CHECK (`unit_price` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_options`
--

LOCK TABLES `service_options` WRITE;
/*!40000 ALTER TABLE `service_options` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `service_options` VALUES
(13,'Éclairage architectural','fixed',180.00,1),
(14,'Machine à fumée','fixed',70.00,1),
(15,'Micro sans fil supplémentaire','fixed',35.00,1),
(16,'Sonorisation grande salle','fixed',260.00,1),
(17,'Animation jeux mariage','fixed',120.00,1),
(18,'Heure supplémentaire','hourly',95.00,1),
(19,'Écran projection','fixed',140.00,1),
(20,'Karaoké','fixed',160.00,1),
(21,'Technicien lumière','hourly',55.00,1),
(22,'Déplacement longue distance','fixed',90.00,1),
(23,'Pack vinyle','fixed',130.00,1),
(24,'Rendez-vous présentiel supplémentaire','fixed',60.00,1);
/*!40000 ALTER TABLE `service_options` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `token_blacklist_blacklistedtoken`
--

DROP TABLE IF EXISTS `token_blacklist_blacklistedtoken`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `token_blacklist_blacklistedtoken` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `blacklisted_at` datetime(6) NOT NULL,
  `token_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_id` (`token_id`),
  CONSTRAINT `token_blacklist_blacklistedtoken_token_id_3cc7fe56_fk` FOREIGN KEY (`token_id`) REFERENCES `token_blacklist_outstandingtoken` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `token_blacklist_blacklistedtoken`
--

LOCK TABLES `token_blacklist_blacklistedtoken` WRITE;
/*!40000 ALTER TABLE `token_blacklist_blacklistedtoken` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `token_blacklist_blacklistedtoken` VALUES
(1,'2026-08-13 20:51:21.118539',1),
(2,'2026-08-13 21:10:17.840538',2);
/*!40000 ALTER TABLE `token_blacklist_blacklistedtoken` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `token_blacklist_outstandingtoken`
--

DROP TABLE IF EXISTS `token_blacklist_outstandingtoken`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `token_blacklist_outstandingtoken` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `token` longtext NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `expires_at` datetime(6) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `jti` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_blacklist_outstandingtoken_jti_hex_d9bdf6f7_uniq` (`jti`),
  KEY `token_blacklist_outs_user_id_83bc629a_fk_auth_user` (`user_id`),
  CONSTRAINT `token_blacklist_outs_user_id_83bc629a_fk_auth_user` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `token_blacklist_outstandingtoken`
--

LOCK TABLES `token_blacklist_outstandingtoken` WRITE;
/*!40000 ALTER TABLE `token_blacklist_outstandingtoken` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `token_blacklist_outstandingtoken` VALUES
(1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4NzI1Njc3MSwiaWF0IjoxNzg2NjUxOTcxLCJqdGkiOiJmYjdmNGM1MmU4YWU0YmZiOGFjN2FlYWJjODQyYjA1YyIsInVzZXJfaWQiOiIyMjMiLCJoYXNoX3Bhc3N3b3JkIjoiQTVBMEJEMDM5MkIxOEY1MUJCQzQxMUYzQTJGOUE5NUUifQ.BWj6y5HIzot1pCDpJn96bo-cwwd3jp5u-FJ3ssR8RD4','2026-08-13 20:12:51.270441','2026-08-20 20:12:51.000000',223,'fb7f4c52e8ae4bfb8ac7aeabc842b05c'),
(2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4NzI1OTA4MSwiaWF0IjoxNzg2NjU0MjgxLCJqdGkiOiI5MTgyYzRmYzIxMDM0YTMzOTYyOGZjYTI3OWIyODY0NSIsInVzZXJfaWQiOiIyMjMiLCJoYXNoX3Bhc3N3b3JkIjoiQTVBMEJEMDM5MkIxOEY1MUJCQzQxMUYzQTJGOUE5NUUifQ.KTeBPdOBW15nESputz-EnVqDjEiWj0lTOpRqzS88xWM','2026-08-13 20:51:21.106386','2026-08-20 20:51:21.000000',223,'9182c4fc21034a339628fca279b28645'),
(3,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4NzI2MDIxNywiaWF0IjoxNzg2NjU1NDE3LCJqdGkiOiIxM2E2ZWY0YWFmYmY0OTFlYWU4ZDA1ZmU1NzgyOWViYSIsInVzZXJfaWQiOiIyMjMiLCJoYXNoX3Bhc3N3b3JkIjoiQTVBMEJEMDM5MkIxOEY1MUJCQzQxMUYzQTJGOUE5NUUifQ.QKwy-YkBR4rsHzV_gaQ_WspVzo11nnp6FjFXQ6ZSzzk','2026-08-13 21:10:17.828709','2026-08-20 21:10:17.000000',223,'13a6ef4aafbf491eae8d05fe57829eba');
/*!40000 ALTER TABLE `token_blacklist_outstandingtoken` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Table structure for table `venues`
--

DROP TABLE IF EXISTS `venues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `venues` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `street` varchar(160) NOT NULL,
  `postal_code` varchar(20) NOT NULL,
  `city` varchar(80) NOT NULL,
  `country` varchar(80) NOT NULL,
  `has_parking` tinyint(1) NOT NULL,
  `distance_km_from_base` decimal(6,2) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `venues_client_id_5fd89154_fk_client_profiles_id` (`client_id`),
  KEY `idx_venue_city` (`city`),
  CONSTRAINT `venues_client_id_5fd89154_fk_client_profiles_id` FOREIGN KEY (`client_id`) REFERENCES `client_profiles` (`id`),
  CONSTRAINT `venue_distance_positive` CHECK (`distance_km_from_base` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=361 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venues`
--

LOCK TABLES `venues` WRITE;
/*!40000 ALTER TABLE `venues` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `venues` VALUES
(241,'Salle Lumière 1','Avenue de la Fête 11','1000','Bruxelles','Belgique',1,4.80,121),
(242,'Espace Harmonie 2','Avenue de la Fête 12','1050','Ixelles','Belgique',1,5.60,122),
(243,'Domaine du Parc 3','Avenue de la Fête 13','1030','Schaerbeek','Belgique',0,6.40,123),
(244,'Loft Central 4','Avenue de la Fête 14','1070','Anderlecht','Belgique',1,7.20,124),
(245,'Château Bellevue 5','Avenue de la Fête 15','1080','Molenbeek-Saint-Jean','Belgique',1,8.00,125),
(246,'Maison Communale 6','Avenue de la Fête 16','1180','Uccle','Belgique',0,8.80,126),
(247,'The Event Hall 7','Avenue de la Fête 17','4000','Liege','Belgique',1,9.60,127),
(248,'Studio Canal 8','Avenue de la Fête 18','5000','Namur','Belgique',1,10.40,128),
(249,'Salle Lumière 9','Avenue de la Fête 19','6000','Charleroi','Belgique',0,11.20,129),
(250,'Espace Harmonie 10','Avenue de la Fête 20','7000','Mons','Belgique',1,12.00,130),
(251,'Domaine du Parc 11','Avenue de la Fête 21','2000','Anvers','Belgique',1,12.80,131),
(252,'Loft Central 12','Avenue de la Fête 22','9000','Gand','Belgique',0,13.60,132),
(253,'Château Bellevue 13','Avenue de la Fête 23','3000','Louvain','Belgique',1,14.40,133),
(254,'Maison Communale 14','Avenue de la Fête 24','2800','Malines','Belgique',1,15.20,134),
(255,'The Event Hall 15','Avenue de la Fête 25','8000','Bruges','Belgique',0,16.00,135),
(256,'Studio Canal 16','Avenue de la Fête 26','7500','Tournai','Belgique',1,16.80,136),
(257,'Salle Lumière 17','Avenue de la Fête 27','1000','Bruxelles','Belgique',1,17.60,137),
(258,'Espace Harmonie 18','Avenue de la Fête 28','1050','Ixelles','Belgique',0,18.40,138),
(259,'Domaine du Parc 19','Avenue de la Fête 29','1030','Schaerbeek','Belgique',1,19.20,139),
(260,'Loft Central 20','Avenue de la Fête 30','1070','Anderlecht','Belgique',1,20.00,140),
(261,'Château Bellevue 21','Avenue de la Fête 31','1080','Molenbeek-Saint-Jean','Belgique',0,20.80,141),
(262,'Maison Communale 22','Avenue de la Fête 32','1180','Uccle','Belgique',1,21.60,142),
(263,'The Event Hall 23','Avenue de la Fête 33','4000','Liege','Belgique',1,22.40,143),
(264,'Studio Canal 24','Avenue de la Fête 34','5000','Namur','Belgique',0,23.20,144),
(265,'Salle Lumière 25','Avenue de la Fête 35','6000','Charleroi','Belgique',1,24.00,145),
(266,'Espace Harmonie 26','Avenue de la Fête 36','7000','Mons','Belgique',1,24.80,146),
(267,'Domaine du Parc 27','Avenue de la Fête 37','2000','Anvers','Belgique',0,25.60,147),
(268,'Loft Central 28','Avenue de la Fête 38','9000','Gand','Belgique',1,26.40,148),
(269,'Château Bellevue 29','Avenue de la Fête 39','3000','Louvain','Belgique',1,27.20,149),
(270,'Maison Communale 30','Avenue de la Fête 40','2800','Malines','Belgique',0,28.00,150),
(271,'The Event Hall 31','Avenue de la Fête 41','8000','Bruges','Belgique',1,28.80,151),
(272,'Studio Canal 32','Avenue de la Fête 42','7500','Tournai','Belgique',1,29.60,152),
(273,'Salle Lumière 33','Avenue de la Fête 43','1000','Bruxelles','Belgique',0,30.40,153),
(274,'Espace Harmonie 34','Avenue de la Fête 44','1050','Ixelles','Belgique',1,31.20,154),
(275,'Domaine du Parc 35','Avenue de la Fête 45','1030','Schaerbeek','Belgique',1,32.00,155),
(276,'Loft Central 36','Avenue de la Fête 46','1070','Anderlecht','Belgique',0,32.80,156),
(277,'Château Bellevue 37','Avenue de la Fête 47','1080','Molenbeek-Saint-Jean','Belgique',1,33.60,157),
(278,'Maison Communale 38','Avenue de la Fête 48','1180','Uccle','Belgique',1,34.40,158),
(279,'The Event Hall 39','Avenue de la Fête 49','4000','Liege','Belgique',0,35.20,159),
(280,'Studio Canal 40','Avenue de la Fête 50','5000','Namur','Belgique',1,36.00,160),
(281,'Salle Lumière 41','Avenue de la Fête 51','6000','Charleroi','Belgique',1,36.80,161),
(282,'Espace Harmonie 42','Avenue de la Fête 52','7000','Mons','Belgique',0,37.60,162),
(283,'Domaine du Parc 43','Avenue de la Fête 53','2000','Anvers','Belgique',1,38.40,163),
(284,'Loft Central 44','Avenue de la Fête 54','9000','Gand','Belgique',1,39.20,164),
(285,'Château Bellevue 45','Avenue de la Fête 55','3000','Louvain','Belgique',0,40.00,165),
(286,'Maison Communale 46','Avenue de la Fête 56','2800','Malines','Belgique',1,40.80,166),
(287,'The Event Hall 47','Avenue de la Fête 57','8000','Bruges','Belgique',1,41.60,167),
(288,'Studio Canal 48','Avenue de la Fête 58','7500','Tournai','Belgique',0,42.40,168),
(289,'Salle Lumière 49','Avenue de la Fête 59','1000','Bruxelles','Belgique',1,43.20,169),
(290,'Espace Harmonie 50','Avenue de la Fête 60','1050','Ixelles','Belgique',1,44.00,170),
(291,'Domaine du Parc 51','Avenue de la Fête 61','1030','Schaerbeek','Belgique',0,44.80,171),
(292,'Loft Central 52','Avenue de la Fête 62','1070','Anderlecht','Belgique',1,45.60,172),
(293,'Château Bellevue 53','Avenue de la Fête 63','1080','Molenbeek-Saint-Jean','Belgique',1,46.40,173),
(294,'Maison Communale 54','Avenue de la Fête 64','1180','Uccle','Belgique',0,47.20,174),
(295,'The Event Hall 55','Avenue de la Fête 65','4000','Liege','Belgique',1,48.00,175),
(296,'Studio Canal 56','Avenue de la Fête 66','5000','Namur','Belgique',1,48.80,176),
(297,'Salle Lumière 57','Avenue de la Fête 67','6000','Charleroi','Belgique',0,49.60,177),
(298,'Espace Harmonie 58','Avenue de la Fête 68','7000','Mons','Belgique',1,50.40,178),
(299,'Domaine du Parc 59','Avenue de la Fête 69','2000','Anvers','Belgique',1,51.20,179),
(300,'Loft Central 60','Avenue de la Fête 70','9000','Gand','Belgique',0,52.00,180),
(301,'Château Bellevue 61','Avenue de la Fête 71','3000','Louvain','Belgique',1,52.80,181),
(302,'Maison Communale 62','Avenue de la Fête 72','2800','Malines','Belgique',1,53.60,182),
(303,'The Event Hall 63','Avenue de la Fête 73','8000','Bruges','Belgique',0,54.40,183),
(304,'Studio Canal 64','Avenue de la Fête 74','7500','Tournai','Belgique',1,55.20,184),
(305,'Salle Lumière 65','Avenue de la Fête 75','1000','Bruxelles','Belgique',1,56.00,185),
(306,'Espace Harmonie 66','Avenue de la Fête 76','1050','Ixelles','Belgique',0,56.80,186),
(307,'Domaine du Parc 67','Avenue de la Fête 77','1030','Schaerbeek','Belgique',1,57.60,187),
(308,'Loft Central 68','Avenue de la Fête 78','1070','Anderlecht','Belgique',1,58.40,188),
(309,'Château Bellevue 69','Avenue de la Fête 79','1080','Molenbeek-Saint-Jean','Belgique',0,59.20,189),
(310,'Maison Communale 70','Avenue de la Fête 80','1180','Uccle','Belgique',1,60.00,190),
(311,'The Event Hall 71','Avenue de la Fête 81','4000','Liege','Belgique',1,60.80,191),
(312,'Studio Canal 72','Avenue de la Fête 82','5000','Namur','Belgique',0,61.60,192),
(313,'Salle Lumière 73','Avenue de la Fête 83','6000','Charleroi','Belgique',1,62.40,193),
(314,'Espace Harmonie 74','Avenue de la Fête 84','7000','Mons','Belgique',1,63.20,194),
(315,'Domaine du Parc 75','Avenue de la Fête 85','2000','Anvers','Belgique',0,64.00,195),
(316,'Loft Central 76','Avenue de la Fête 86','9000','Gand','Belgique',1,64.80,196),
(317,'Château Bellevue 77','Avenue de la Fête 87','3000','Louvain','Belgique',1,65.60,197),
(318,'Maison Communale 78','Avenue de la Fête 88','2800','Malines','Belgique',0,66.40,198),
(319,'The Event Hall 79','Avenue de la Fête 89','8000','Bruges','Belgique',1,67.20,199),
(320,'Studio Canal 80','Avenue de la Fête 90','7500','Tournai','Belgique',1,68.00,200),
(321,'Salle Lumière 81','Avenue de la Fête 91','1000','Bruxelles','Belgique',0,68.80,201),
(322,'Espace Harmonie 82','Avenue de la Fête 92','1050','Ixelles','Belgique',1,69.60,202),
(323,'Domaine du Parc 83','Avenue de la Fête 93','1030','Schaerbeek','Belgique',1,70.40,203),
(324,'Loft Central 84','Avenue de la Fête 94','1070','Anderlecht','Belgique',0,71.20,204),
(325,'Château Bellevue 85','Avenue de la Fête 95','1080','Molenbeek-Saint-Jean','Belgique',1,72.00,205),
(326,'Maison Communale 86','Avenue de la Fête 96','1180','Uccle','Belgique',1,72.80,206),
(327,'The Event Hall 87','Avenue de la Fête 97','4000','Liege','Belgique',0,73.60,207),
(328,'Studio Canal 88','Avenue de la Fête 98','5000','Namur','Belgique',1,74.40,208),
(329,'Salle Lumière 89','Avenue de la Fête 99','6000','Charleroi','Belgique',1,75.20,209),
(330,'Espace Harmonie 90','Avenue de la Fête 100','7000','Mons','Belgique',0,76.00,210),
(331,'Domaine du Parc 91','Avenue de la Fête 101','2000','Anvers','Belgique',1,76.80,211),
(332,'Loft Central 92','Avenue de la Fête 102','9000','Gand','Belgique',1,77.60,212),
(333,'Château Bellevue 93','Avenue de la Fête 103','3000','Louvain','Belgique',0,78.40,213),
(334,'Maison Communale 94','Avenue de la Fête 104','2800','Malines','Belgique',1,79.20,214),
(335,'The Event Hall 95','Avenue de la Fête 105','8000','Bruges','Belgique',1,4.00,215),
(336,'Studio Canal 96','Avenue de la Fête 106','7500','Tournai','Belgique',0,4.80,216),
(337,'Salle Lumière 97','Avenue de la Fête 107','1000','Bruxelles','Belgique',1,5.60,217),
(338,'Espace Harmonie 98','Avenue de la Fête 108','1050','Ixelles','Belgique',1,6.40,218),
(339,'Domaine du Parc 99','Avenue de la Fête 109','1030','Schaerbeek','Belgique',0,7.20,219),
(340,'Loft Central 100','Avenue de la Fête 110','1070','Anderlecht','Belgique',1,8.00,220),
(341,'Château Bellevue 101','Avenue de la Fête 111','1080','Molenbeek-Saint-Jean','Belgique',1,8.80,221),
(342,'Maison Communale 102','Avenue de la Fête 112','1180','Uccle','Belgique',0,9.60,222),
(343,'The Event Hall 103','Avenue de la Fête 113','4000','Liege','Belgique',1,10.40,223),
(344,'Studio Canal 104','Avenue de la Fête 114','5000','Namur','Belgique',1,11.20,224),
(345,'Salle Lumière 105','Avenue de la Fête 115','6000','Charleroi','Belgique',0,12.00,225),
(346,'Espace Harmonie 106','Avenue de la Fête 116','7000','Mons','Belgique',1,12.80,226),
(347,'Domaine du Parc 107','Avenue de la Fête 117','2000','Anvers','Belgique',1,13.60,227),
(348,'Loft Central 108','Avenue de la Fête 118','9000','Gand','Belgique',0,14.40,228),
(349,'Château Bellevue 109','Avenue de la Fête 119','3000','Louvain','Belgique',1,15.20,229),
(350,'Maison Communale 110','Avenue de la Fête 120','2800','Malines','Belgique',1,16.00,230),
(351,'The Event Hall 111','Avenue de la Fête 121','8000','Bruges','Belgique',0,16.80,231),
(352,'Studio Canal 112','Avenue de la Fête 122','7500','Tournai','Belgique',1,17.60,232),
(353,'Salle Lumière 113','Avenue de la Fête 123','1000','Bruxelles','Belgique',1,18.40,233),
(354,'Espace Harmonie 114','Avenue de la Fête 124','1050','Ixelles','Belgique',0,19.20,234),
(355,'Domaine du Parc 115','Avenue de la Fête 125','1030','Schaerbeek','Belgique',1,20.00,235),
(356,'Loft Central 116','Avenue de la Fête 126','1070','Anderlecht','Belgique',1,20.80,236),
(357,'Château Bellevue 117','Avenue de la Fête 127','1080','Molenbeek-Saint-Jean','Belgique',0,21.60,237),
(358,'Maison Communale 118','Avenue de la Fête 128','1180','Uccle','Belgique',1,22.40,238),
(359,'The Event Hall 119','Avenue de la Fête 129','4000','Liege','Belgique',1,23.20,239),
(360,'Studio Canal 120','Avenue de la Fête 130','5000','Namur','Belgique',0,24.00,240);
/*!40000 ALTER TABLE `venues` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping routines for database 'ultimate_dj_django'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-08-17 21:43:38
