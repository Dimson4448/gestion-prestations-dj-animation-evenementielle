-- MariaDB dump 10.19  Distrib 10.4.28-MariaDB, for Win64 (AMD64)
--
-- Host: 127.0.0.1    Database: ultimate_dj_django
-- Session and JWT token data are intentionally omitted from this versioned dump.
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
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account_deletion_requests`
--

DROP TABLE IF EXISTS `account_deletion_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_deletion_requests`
--

LOCK TABLES `account_deletion_requests` WRITE;
/*!40000 ALTER TABLE `account_deletion_requests` DISABLE KEYS */;
INSERT INTO `account_deletion_requests` VALUES (1,'je n\'ai plus besoin de cette application','cancelled','','2026-10-10 15:34:38.031648',NULL,247,NULL),(2,'plus besoin','approved','Compte désactivé automatiquement : aucun contrat signé ni paiement à régulariser.','2026-10-10 15:57:38.167334','2026-10-10 15:57:38.166227',248,NULL),(3,'plus de besoin de ça','approved','Compte désactivé automatiquement : aucun contrat signé ni paiement à régulariser.','2026-10-10 16:03:55.972029','2026-10-10 16:03:55.972029',247,NULL);
/*!40000 ALTER TABLE `account_deletion_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_notifications`
--

DROP TABLE IF EXISTS `account_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_notifications` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `notification_type` varchar(20) NOT NULL,
  `title` varchar(180) NOT NULL,
  `message` longtext NOT NULL,
  `link` varchar(120) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `read_at` datetime(6) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_notif_user_read_created` (`user_id`,`read_at`,`created_at`),
  CONSTRAINT `account_notifications_user_id_6ec47a5d_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_notifications`
--

LOCK TABLES `account_notifications` WRITE;
/*!40000 ALTER TABLE `account_notifications` DISABLE KEYS */;
INSERT INTO `account_notifications` VALUES (1,'booking','Ultimate DJ - nouveau message','Nouveau message dans la réservation n°111.','/dj','2026-10-08 07:52:51.886414',NULL,445),(2,'booking','Ultimate DJ - nouveau message','Nouveau message dans la réservation n°111.','/administration','2026-10-08 07:52:51.886414','2026-10-08 11:53:37.650452',443),(3,'booking','Ultimate DJ - nouveau message','Nouveau message dans la réservation n°111.','/administration','2026-10-08 07:52:51.902218',NULL,444),(4,'booking','Ultimate DJ - nouveau message','Nouveau message dans la réservation n°111.','/dj','2026-10-08 08:38:51.660171',NULL,445),(5,'booking','Ultimate DJ - nouveau message','Nouveau message dans la réservation n°111.','/administration','2026-10-08 08:38:51.665231','2026-10-08 11:53:35.802924',443),(6,'booking','Ultimate DJ - nouveau message','Nouveau message dans la réservation n°111.','/administration','2026-10-08 08:38:51.667053',NULL,444),(7,'booking','Ultimate DJ - nouveau message','Nouveau message dans la réservation n°111.','/compte','2026-10-08 08:55:38.261254',NULL,448),(8,'booking','Ultimate DJ - nouveau message','Nouveau message dans la réservation n°111.','/administration','2026-10-08 08:55:38.266252','2026-10-08 11:53:31.995187',443),(9,'booking','Ultimate DJ - nouveau message','Nouveau message dans la réservation n°111.','/administration','2026-10-08 08:55:38.281904',NULL,444),(10,'booking','Ultimate DJ - demande de devis n°124 reçue','Votre demande de devis n°124 pour le 14/10/2026 a bien été enregistrée. Vous serez averti de chaque décision dans votre espace client et par e-mail.','/compte','2026-10-10 07:59:01.887025','2026-10-10 08:02:01.629815',449),(11,'booking','Ultimate DJ - nouvelle demande de prestation','Une demande de prestation n°124, prévue le 14/10/2026, vous attend dans votre espace DJ.','/dj','2026-10-10 07:59:02.729363',NULL,445),(12,'booking','Ultimate DJ - nouveau devis n°124','Une nouvelle demande de devis n°124 est à traiter pour le 14/10/2026.','/administration','2026-10-10 07:59:02.738980',NULL,443),(13,'booking','Ultimate DJ - nouveau devis n°124','Une nouvelle demande de devis n°124 est à traiter pour le 14/10/2026.','/administration','2026-10-10 07:59:02.745443',NULL,444),(14,'booking','Ultimate DJ - nouveau compte client','Un nouveau compte client vient d\'être créé et attend la confirmation de son e-mail.','/administration','2026-10-10 12:52:53.640157',NULL,443),(15,'booking','Ultimate DJ - nouveau compte client','Un nouveau compte client vient d\'être créé et attend la confirmation de son e-mail.','/administration','2026-10-10 12:52:53.656280',NULL,444),(16,'booking','Ultimate DJ - demande de devis n°125 reçue','Votre demande de devis n°125 pour le 15/10/2026 a bien été enregistrée. Vous serez averti de chaque décision dans votre espace client et par e-mail.','/compte','2026-10-10 12:58:38.926283',NULL,450),(17,'booking','Ultimate DJ - nouveau devis n°125','Une nouvelle demande de devis n°125 est à traiter pour le 15/10/2026.','/administration','2026-10-10 12:58:38.939134',NULL,443),(18,'booking','Ultimate DJ - nouveau devis n°125','Une nouvelle demande de devis n°125 est à traiter pour le 15/10/2026.','/administration','2026-10-10 12:58:38.939134',NULL,444),(19,'booking','Ultimate DJ - demande de prestation à examiner','L\'administration a validé la demande n°125, prévue le 15/10/2026. Vous pouvez maintenant l\'accepter ou la refuser dans votre espace DJ.','/dj','2026-10-10 13:02:05.403613',NULL,445),(20,'booking','Ultimate DJ - prestation n°112 acceptée','Votre prestation du 14/10/2026 est acceptée. Le contrat UDJ-CON-2026-000112 et la facture d\'acompte UDJ-ACP-2026-000112 sont disponibles dans votre espace client.','/compte','2026-10-10 13:02:21.965725',NULL,449),(21,'booking','Ultimate DJ - devis accepté, réservation n°112','La réservation n°112 a été créée pour le 14/10/2026. Contrat UDJ-CON-2026-000112 et facture UDJ-ACP-2026-000112 générés.','/administration','2026-10-10 13:02:21.971214',NULL,443),(22,'booking','Ultimate DJ - devis accepté, réservation n°112','La réservation n°112 a été créée pour le 14/10/2026. Contrat UDJ-CON-2026-000112 et facture UDJ-ACP-2026-000112 générés.','/administration','2026-10-10 13:02:21.974737',NULL,444),(23,'booking','Ultimate DJ - prestation n°113 acceptée','Votre prestation du 15/10/2026 est acceptée. Le contrat UDJ-CON-2026-000113 et la facture d\'acompte UDJ-ACP-2026-000113 sont disponibles dans votre espace client.','/compte','2026-10-10 13:02:26.219730',NULL,450),(24,'booking','Ultimate DJ - devis accepté, réservation n°113','La réservation n°113 a été créée pour le 15/10/2026. Contrat UDJ-CON-2026-000113 et facture UDJ-ACP-2026-000113 générés.','/administration','2026-10-10 13:02:26.229357',NULL,443),(25,'booking','Ultimate DJ - devis accepté, réservation n°113','La réservation n°113 a été créée pour le 15/10/2026. Contrat UDJ-CON-2026-000113 et facture UDJ-ACP-2026-000113 générés.','/administration','2026-10-10 13:02:26.234521',NULL,444),(26,'booking','Ultimate DJ - contrat UDJ-CON-2026-000113 signé','Votre signature du contrat UDJ-CON-2026-000113 a été enregistrée pour la réservation n°113.','/compte','2026-10-10 13:06:26.276923',NULL,450),(27,'booking','Ultimate DJ - contrat UDJ-CON-2026-000113 signé','Le contrat UDJ-CON-2026-000113 de la réservation n°113 vient d\'être signé.','/administration','2026-10-10 13:06:26.283261',NULL,443),(28,'booking','Ultimate DJ - contrat UDJ-CON-2026-000113 signé','Le contrat UDJ-CON-2026-000113 de la réservation n°113 vient d\'être signé.','/administration','2026-10-10 13:06:26.283261',NULL,444),(29,'booking','Ultimate DJ - facture de solde UDJ-SOL-2026-000111','La prestation n°111 est clôturée. Votre facture de solde UDJ-SOL-2026-000111, d\'un montant de 649.60 EUR, est disponible dans votre espace client.','/compte','2026-10-10 13:11:56.618901',NULL,448),(30,'payment','Ultimate DJ - paiement confirmé UDJ-ACP-2026-000113','Votre paiement de 353.40 EUR pour la facture UDJ-ACP-2026-000113 a été confirmé par Stripe.\n\nLa facture mise à jour est disponible dans votre espace client.','/compte','2026-10-10 13:34:33.793431',NULL,450),(31,'payment','Ultimate DJ - paiement confirmé UDJ-ACP-2026-000113','Un paiement de 353.40 EUR a été confirmé pour la facture UDJ-ACP-2026-000113.','/administration','2026-10-10 13:34:33.810863',NULL,443),(32,'payment','Ultimate DJ - paiement confirmé UDJ-ACP-2026-000113','Un paiement de 353.40 EUR a été confirmé pour la facture UDJ-ACP-2026-000113.','/administration','2026-10-10 13:34:33.810863',NULL,444),(33,'booking','Ultimate DJ - rendez-vous de la réservation n°113','Le rendez-vous préparatoire est maintenant « Proposé au DJ » pour le 11/10/2026 15:00.\n\nMessage : —','/dj','2026-10-10 13:38:46.770313',NULL,445),(34,'booking','Ultimate DJ - rendez-vous de la réservation n°111','Le rendez-vous préparatoire est maintenant « Réalisé » pour le 24/08/2026 13:00.\n\nMessage : —','/compte','2026-10-10 13:53:18.911592',NULL,448),(35,'booking','Ultimate DJ - rendez-vous de la réservation n°113','Le rendez-vous préparatoire est maintenant « Accepté par les deux parties » pour le 11/10/2026 13:00.\n\nMessage : —','/compte','2026-10-10 13:53:57.520791',NULL,450),(36,'booking','Ultimate DJ - facture de solde UDJ-SOL-2026-000113','La prestation n°113 est clôturée. Votre facture de solde UDJ-SOL-2026-000113, d\'un montant de 824.60 EUR, est disponible dans votre espace client.','/compte','2026-10-10 14:26:09.521157',NULL,450),(37,'payment','Ultimate DJ - paiement confirmé UDJ-SOL-2026-000113','Votre paiement de 824.60 EUR pour la facture UDJ-SOL-2026-000113 a été confirmé par Stripe.\n\nLa facture mise à jour est disponible dans votre espace client.','/compte','2026-10-10 14:28:52.045182',NULL,450),(38,'payment','Ultimate DJ - paiement confirmé UDJ-SOL-2026-000113','Un paiement de 824.60 EUR a été confirmé pour la facture UDJ-SOL-2026-000113.','/administration','2026-10-10 14:28:52.053094',NULL,443),(39,'payment','Ultimate DJ - paiement confirmé UDJ-SOL-2026-000113','Un paiement de 824.60 EUR a été confirmé pour la facture UDJ-SOL-2026-000113.','/administration','2026-10-10 14:28:52.057891',NULL,444),(40,'review','Ultimate DJ - nouvel avis client','Un avis de 5/5 a été publié pour la réservation n°113.','/dj','2026-10-10 14:38:17.786879',NULL,445),(41,'booking','Ultimate DJ - demande de suppression de compte','Une demande de suppression de compte est en attente de traitement dans l\'administration.','/administration','2026-10-10 15:34:38.040555',NULL,443),(42,'booking','Ultimate DJ - demande de suppression de compte','Une demande de suppression de compte est en attente de traitement dans l\'administration.','/administration','2026-10-10 15:34:38.046432',NULL,444),(43,'booking','Ultimate DJ - compte client désactivé','Un client a supprimé son compte sans engagement financier ; les dossiers non contractuels ont été libérés.','/administration','2026-10-10 15:57:38.181445',NULL,443),(44,'booking','Ultimate DJ - compte client désactivé','Un client a supprimé son compte sans engagement financier ; les dossiers non contractuels ont été libérés.','/administration','2026-10-10 15:57:38.188274',NULL,444),(45,'booking','Ultimate DJ - compte client désactivé','Un client a supprimé son compte sans engagement financier ; les dossiers non contractuels ont été libérés.','/administration','2026-10-10 16:03:55.996478',NULL,443),(46,'booking','Ultimate DJ - compte client désactivé','Un client a supprimé son compte sans engagement financier ; les dossiers non contractuels ont été libérés.','/administration','2026-10-10 16:03:56.001479',NULL,444);
/*!40000 ALTER TABLE `account_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=141 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add log entry',1,'add_logentry'),(2,'Can change log entry',1,'change_logentry'),(3,'Can delete log entry',1,'delete_logentry'),(4,'Can view log entry',1,'view_logentry'),(5,'Can add permission',2,'add_permission'),(6,'Can change permission',2,'change_permission'),(7,'Can delete permission',2,'delete_permission'),(8,'Can view permission',2,'view_permission'),(9,'Can add group',3,'add_group'),(10,'Can change group',3,'change_group'),(11,'Can delete group',3,'delete_group'),(12,'Can view group',3,'view_group'),(13,'Can add user',4,'add_user'),(14,'Can change user',4,'change_user'),(15,'Can delete user',4,'delete_user'),(16,'Can view user',4,'view_user'),(17,'Can add content type',5,'add_contenttype'),(18,'Can change content type',5,'change_contenttype'),(19,'Can delete content type',5,'delete_contenttype'),(20,'Can view content type',5,'view_contenttype'),(21,'Can add session',6,'add_session'),(22,'Can change session',6,'change_session'),(23,'Can delete session',6,'delete_session'),(24,'Can view session',6,'view_session'),(25,'Can add profil client',7,'add_clientprofile'),(26,'Can change profil client',7,'change_clientprofile'),(27,'Can delete profil client',7,'delete_clientprofile'),(28,'Can view profil client',7,'view_clientprofile'),(29,'Can add profil DJ',8,'add_djprofile'),(30,'Can change profil DJ',8,'change_djprofile'),(31,'Can delete profil DJ',8,'delete_djprofile'),(32,'Can view profil DJ',8,'view_djprofile'),(33,'Can add type d\'événement',9,'add_eventtype'),(34,'Can change type d\'événement',9,'change_eventtype'),(35,'Can delete type d\'événement',9,'delete_eventtype'),(36,'Can view type d\'événement',9,'view_eventtype'),(37,'Can add style musical',10,'add_musicstyle'),(38,'Can change style musical',10,'change_musicstyle'),(39,'Can delete style musical',10,'delete_musicstyle'),(40,'Can view style musical',10,'view_musicstyle'),(41,'Can add package',11,'add_package'),(42,'Can change package',11,'change_package'),(43,'Can delete package',11,'delete_package'),(44,'Can view package',11,'view_package'),(45,'Can add option de service',12,'add_serviceoption'),(46,'Can change option de service',12,'change_serviceoption'),(47,'Can delete option de service',12,'delete_serviceoption'),(48,'Can view option de service',12,'view_serviceoption'),(49,'Can add matériel',13,'add_equipment'),(50,'Can change matériel',13,'change_equipment'),(51,'Can delete matériel',13,'delete_equipment'),(52,'Can view matériel',13,'view_equipment'),(53,'Can add créneau DJ',14,'add_djavailability'),(54,'Can change créneau DJ',14,'change_djavailability'),(55,'Can delete créneau DJ',14,'delete_djavailability'),(56,'Can view créneau DJ',14,'view_djavailability'),(57,'Can add réservation',15,'add_booking'),(58,'Can change réservation',15,'change_booking'),(59,'Can delete réservation',15,'delete_booking'),(60,'Can view réservation',15,'view_booking'),(61,'Can add playlist',16,'add_playlist'),(62,'Can change playlist',16,'change_playlist'),(63,'Can delete playlist',16,'delete_playlist'),(64,'Can view playlist',16,'view_playlist'),(65,'Can add chanson de playlist',17,'add_playlistsong'),(66,'Can change chanson de playlist',17,'change_playlistsong'),(67,'Can delete chanson de playlist',17,'delete_playlistsong'),(68,'Can view chanson de playlist',17,'view_playlistsong'),(69,'Can add devis',18,'add_quote'),(70,'Can change devis',18,'change_quote'),(71,'Can delete devis',18,'delete_quote'),(72,'Can view devis',18,'view_quote'),(73,'Can add lieu',19,'add_venue'),(74,'Can change lieu',19,'change_venue'),(75,'Can delete lieu',19,'delete_venue'),(76,'Can view lieu',19,'view_venue'),(77,'Can add matériel de réservation',20,'add_bookingequipment'),(78,'Can change matériel de réservation',20,'change_bookingequipment'),(79,'Can delete matériel de réservation',20,'delete_bookingequipment'),(80,'Can view matériel de réservation',20,'view_bookingequipment'),(81,'Can add contrat',21,'add_contract'),(82,'Can change contrat',21,'change_contract'),(83,'Can delete contrat',21,'delete_contract'),(84,'Can view contrat',21,'view_contract'),(85,'Can add rendez-vous préparatoire',22,'add_preparatoryappointment'),(86,'Can change rendez-vous préparatoire',22,'change_preparatoryappointment'),(87,'Can delete rendez-vous préparatoire',22,'delete_preparatoryappointment'),(88,'Can view rendez-vous préparatoire',22,'view_preparatoryappointment'),(89,'Can add option de devis',23,'add_quoteoption'),(90,'Can change option de devis',23,'change_quoteoption'),(91,'Can delete option de devis',23,'delete_quoteoption'),(92,'Can view option de devis',23,'view_quoteoption'),(93,'Can add avis client',24,'add_review'),(94,'Can change avis client',24,'change_review'),(95,'Can delete avis client',24,'delete_review'),(96,'Can view avis client',24,'view_review'),(97,'Can add facture',25,'add_invoice'),(98,'Can change facture',25,'change_invoice'),(99,'Can delete facture',25,'delete_invoice'),(100,'Can view facture',25,'view_invoice'),(101,'Can add paiement',26,'add_payment'),(102,'Can change paiement',26,'change_payment'),(103,'Can delete paiement',26,'delete_payment'),(104,'Can view paiement',26,'view_payment'),(105,'Can add remboursement',27,'add_refund'),(106,'Can change remboursement',27,'change_refund'),(107,'Can delete remboursement',27,'delete_refund'),(108,'Can view remboursement',27,'view_refund'),(109,'Can add demande d\'annulation',28,'add_cancellationrequest'),(110,'Can change demande d\'annulation',28,'change_cancellationrequest'),(111,'Can delete demande d\'annulation',28,'delete_cancellationrequest'),(112,'Can view demande d\'annulation',28,'view_cancellationrequest'),(113,'Can add Blacklisted Token',29,'add_blacklistedtoken'),(114,'Can change Blacklisted Token',29,'change_blacklistedtoken'),(115,'Can delete Blacklisted Token',29,'delete_blacklistedtoken'),(116,'Can view Blacklisted Token',29,'view_blacklistedtoken'),(117,'Can add Outstanding Token',30,'add_outstandingtoken'),(118,'Can change Outstanding Token',30,'change_outstandingtoken'),(119,'Can delete Outstanding Token',30,'delete_outstandingtoken'),(120,'Can view Outstanding Token',30,'view_outstandingtoken'),(121,'Can add demande de suppression de compte',31,'add_accountdeletionrequest'),(122,'Can change demande de suppression de compte',31,'change_accountdeletionrequest'),(123,'Can delete demande de suppression de compte',31,'delete_accountdeletionrequest'),(124,'Can view demande de suppression de compte',31,'view_accountdeletionrequest'),(125,'Can add candidature DJ',32,'add_djapplication'),(126,'Can change candidature DJ',32,'change_djapplication'),(127,'Can delete candidature DJ',32,'delete_djapplication'),(128,'Can view candidature DJ',32,'view_djapplication'),(129,'Can add notification',33,'add_notification'),(130,'Can change notification',33,'change_notification'),(131,'Can delete notification',33,'delete_notification'),(132,'Can view notification',33,'view_notification'),(133,'Can add préférence de notification',34,'add_notificationpreference'),(134,'Can change préférence de notification',34,'change_notificationpreference'),(135,'Can delete préférence de notification',34,'delete_notificationpreference'),(136,'Can view préférence de notification',34,'view_notificationpreference'),(137,'Can add message de dossier',35,'add_bookingmessage'),(138,'Can change message de dossier',35,'change_bookingmessage'),(139,'Can delete message de dossier',35,'delete_bookingmessage'),(140,'Can view message de dossier',35,'view_bookingmessage');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=469 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
INSERT INTO `auth_user` VALUES (443,'pbkdf2_sha256$1000000$OpNY9OObozexvBm5ftUq6u$GFsu759r8BKlISqjo0o7aplBsFb4cTul5OlPmEMTAS0=','2026-10-10 07:34:35.857627',1,'admin@ultimate-dj.test','Vianney','Tchamako','admin@ultimate-dj.test',1,1,'2026-07-04 08:00:00.000000'),(444,'pbkdf2_sha256$600000$staff$hashdemo',NULL,0,'staff@ultimate-dj.test','Dimitri','Moreau','staff@ultimate-dj.test',1,1,'2026-07-04 08:00:00.000000'),(445,'pbkdf2_sha256$1000000$9e65SK4pgrxnJeIilmDzuO$f68x8iVy2qOjgsQX5qxJT2AAjCEwSyK0s+x1zFzwxDI=',NULL,0,'UltimateDJ','Vianney Dimitri','TCHAMAKO','legacy-445@example.test',0,1,'2026-08-17 20:03:34.000000'),(446,'pbkdf2_sha256$1000000$tmhr4S8iQAZ9jXrn3Ipn3n$IM9GiQX6/8wNuBmk6P1U1M1RIEhOaZ8UQ/ki9F8fN0M=',NULL,0,'legacy-446@example.test','Vianney Dimitri','TCHAMAKO','legacy-446@example.test',0,0,'2026-08-20 22:06:14.773853'),(447,'pbkdf2_sha256$1000000$R5WTo0ikYkGuHGUJdmEVIJ$AkBRSbJ3fvBPPP/dD0M7aXpOVZ+j3+4gU0Nrnl5RGjA=',NULL,0,'TCHOKONTE','franck','TCHOKONTE','legacy-447@example.test',0,0,'2026-08-20 22:20:11.294964'),(448,'pbkdf2_sha256$1000000$A6m9yt8Co2tSkJQQ0f6xhP$trqbNQ45wsKTWpqSk4N+ad8ZwyBq2cmnptfRcoLv8d4=',NULL,0,'chuabemarlyse','Marlyse','Chuabe','legacy-448@example.test',0,1,'2026-08-20 22:31:52.961623'),(449,'pbkdf2_sha256$1000000$ChSr0dcEnJJrLE82piG3It$PBWorXGSbkwld9L54y0sfHJL2QV7T16CWCn24XupeBw=',NULL,0,'Samanta','Samanta','Nguimzap','ultimate.dj.be+samanta@gmail.com',0,1,'2026-10-09 20:31:36.351593'),(450,'pbkdf2_sha256$1000000$9AXvFyNOSYgRxef8uaTZfg$t4NPIrR1aLi7vJi7o3CqU5fXaGDxaJf7Ml42Br3bYoA=',NULL,0,'Gloria','Gloria','Divine','ultimate.dj.be+gloria@gmail.com',0,1,'2026-10-10 12:52:51.324860'),(451,'pbkdf2_sha256$1000000$Tt2KBweloNyRy6hZBc9nmV$zGBTcw/WathluAYLqfMdaixEgYKpoaLd5yDRrOeyrr0=',NULL,0,'camille.desmet','Camille','De Smet','ultimate.dj.be+camille.desmet@gmail.com',0,1,'2026-10-10 15:03:48.948453'),(452,'pbkdf2_sha256$1000000$z8gniOwEWSeqr2rNbDnGKR$guZM3Grsxi3fYYxBtY2P0fdFn94Gj11d90e8MSmZrGs=',NULL,0,'nora.elmansouri','Nora','El Mansouri','ultimate.dj.be+nora.elmansouri@gmail.com',0,1,'2026-10-10 15:03:49.449720'),(453,'pbkdf2_sha256$1000000$7L9WVHAeJ4OQ2E3XhvKgiB$pFUsA/ZOzZCoqW7iW6vPBecc1IvXuB98bwu8fI47MWA=',NULL,0,'arthur.lambert','Arthur','Lambert','ultimate.dj.be+arthur.lambert@gmail.com',0,1,'2026-10-10 15:03:49.947743'),(454,'pbkdf2_sha256$1000000$DO5mbSSE8lBCTmo1PdRIKW$18q9QLm964o5T8VX5LWTaoj5f5XJp0lOUMcbA0f+mps=',NULL,0,'ines.vandamme','Inès','Van Damme','ultimate.dj.be+ines.vandamme@gmail.com',0,1,'2026-10-10 15:03:50.446418'),(455,'pbkdf2_sha256$1000000$Cm2fHK2P7Ya7FLo7j9uZX6$NX9GmlOOTM0CNU1Y3BepMREp8v1a52h5BoICzR71Fpg=',NULL,0,'lucas.verhaegen','Lucas','Verhaegen','ultimate.dj.be+lucas.verhaegen@gmail.com',0,1,'2026-10-10 15:03:50.930131'),(456,'pbkdf2_sha256$1000000$1Mgge7IiQuwjhZ3QOqaG5b$bWwLIhxt2+4ViOgKwScEobhT+QBypg/IVG/UuA0wncI=',NULL,0,'clara.vandenberg','Clara','Vandenberg','ultimate.dj.be+clara.vandenberg@gmail.com',0,1,'2026-10-10 15:03:51.432534'),(457,'pbkdf2_sha256$1000000$aLWzJWZEVuwGwf3BtnYE7Z$5n0xyUBa8QwR8eB3qJFjPXiGtDU6/fiBEi/dxQ11SNU=',NULL,0,'thomas.vermeulen','Thomas','Vermeulen','ultimate.dj.be+thomas.vermeulen@gmail.com',0,1,'2026-10-10 15:03:51.931370'),(458,'pbkdf2_sha256$1000000$dCxXWoJdAuCBoPXfsqfS7D$MxNrywVkuUDJa4NgYfSwrH46RtaKqwzaC5ZsXqOF3xs=',NULL,0,'elise.dewilde','Élise','De Wilde','ultimate.dj.be+elise.dewilde@gmail.com',0,1,'2026-10-10 15:03:52.417069'),(459,'pbkdf2_sha256$1000000$zEutRYOGAK7PfldESNxgNs$BB3yRbkr2NC0pbde2YV4dH+G22LhOunb3JfgqOGfMcE=',NULL,0,'nathan.leclercq','Nathan','Leclercq','ultimate.dj.be+nathan.leclercq@gmail.com',0,1,'2026-10-10 15:03:52.924113'),(460,'pbkdf2_sha256$1000000$kIGCXedMa0EU65EALObm1k$PMAVeKsKiZ3vdLV+zrj5zwZhx7EWPGIoj6aIVX9jA5E=',NULL,0,'ines.dupont','Inès','Dupont','ultimate.dj.be+ines.dupont@gmail.com',0,1,'2026-10-10 15:03:53.413382'),(461,'pbkdf2_sha256$1000000$z8ktkQVegTQz9XSzmXTJQz$XOamxs+FJOLBbA4jr9UQdtmBhnFZMzqWxYdRX0UDBis=',NULL,0,'julien.massart','Julien','Massart','ultimate.dj.be+julien.massart@gmail.com',0,1,'2026-10-10 15:03:53.914027'),(462,'pbkdf2_sha256$1000000$YU5RI3Om6sZnaP1TldvyHw$8IErbhC6pHlihhGjssLFXxsHJf1b3090MwUepEYwUbg=',NULL,0,'lotte.vandamme','Lotte','Van Damme','ultimate.dj.be+lotte.vandamme@gmail.com',0,1,'2026-10-10 15:03:54.400883'),(463,'pbkdf2_sha256$1000000$AAyNsc4D8g18ZUS3nW3EcT$pZbh9N+Ldnnf4uItee6UD2BCcEXWBFYCyuyFcZfmumk=',NULL,0,'arnaud.peeters','Arnaud','Peeters','ultimate.dj.be+arnaud.peeters@gmail.com',0,1,'2026-10-10 15:03:54.897065'),(464,'pbkdf2_sha256$1000000$wbrPCtGNkmF6kwuc2hUo0g$Vmge5i73NhLXYDZiVGQTSt8Mi7mMf5z/xzrZfKsaTOU=',NULL,0,'eva.janssen','Eva','Janssen','ultimate.dj.be+eva.janssen@gmail.com',0,1,'2026-10-10 15:03:55.396698'),(465,'pbkdf2_sha256$1000000$gZfHne89sQNRxXrNAgd1RJ$cVc5Wx5VoBmWptOV4bNZxOoX5FHHjRsZN0jG/y+GiN8=',NULL,0,'romain.delcourt','Romain','Delcourt','ultimate.dj.be+romain.delcourt@gmail.com',0,1,'2026-10-10 15:03:55.892999'),(466,'pbkdf2_sha256$1000000$smZSJYWeARAwtGOzcn54qU$ygK/5VfVrB77woFIDUmRX35OKdgcYefVunsgPTMlQY8=',NULL,0,'maarten.desmet','Maarten','De Smet','ultimate.dj.be+maarten.desmet@gmail.com',0,1,'2026-10-10 15:03:56.380293'),(467,'pbkdf2_sha256$1000000$3AaJfqDdWqOXfIrOjMzEFY$PqYGYkG+0TpJ6ffekyAXB3EeS2iOlPBTBxHXbIfk11g=',NULL,0,'margot.dubois','Margot','Dubois','ultimate.dj.be+margot.dubois@gmail.com',0,1,'2026-10-10 16:05:21.635192'),(468,'pbkdf2_sha256$1000000$CMWFKI11d81loUmSTo8l5N$lYgRY8hrWGAMJRxBCNMPf/QE3BipypH3rD2FB4qM7tU=',NULL,0,'youssef.benali','Youssef','Benali','ultimate.dj.be+youssef.benali@gmail.com',0,1,'2026-10-10 16:05:22.144632');
/*!40000 ALTER TABLE `auth_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40000 ALTER TABLE `auth_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40000 ALTER TABLE `auth_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `booking_equipment`
--

DROP TABLE IF EXISTS `booking_equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40000 ALTER TABLE `booking_equipment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `booking_messages`
--

DROP TABLE IF EXISTS `booking_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `booking_messages` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `body` longtext NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `read_at` datetime(6) DEFAULT NULL,
  `booking_id` bigint(20) NOT NULL,
  `sender_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `booking_messages_sender_id_119770a5_fk_auth_user_id` (`sender_id`),
  KEY `idx_message_booking_created` (`booking_id`,`created_at`),
  CONSTRAINT `booking_messages_booking_id_17f26f2a_fk_bookings_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  CONSTRAINT `booking_messages_sender_id_119770a5_fk_auth_user_id` FOREIGN KEY (`sender_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `booking_messages`
--

LOCK TABLES `booking_messages` WRITE;
/*!40000 ALTER TABLE `booking_messages` DISABLE KEYS */;
INSERT INTO `booking_messages` VALUES (2,'salut','2026-10-08 08:38:51.652531',NULL,111,448),(3,'salut. Comment allez-vous?','2026-10-08 08:55:38.251654',NULL,111,445);
/*!40000 ALTER TABLE `booking_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `end_date` date DEFAULT NULL,
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
  CONSTRAINT `booking_total_positive` CHECK (`total_amount` >= 0),
  CONSTRAINT `booking_deposit_positive` CHECK (`deposit_required` >= 0),
  CONSTRAINT `booking_end_after_start` CHECK (`end_date` > `event_date` or `end_date` = `event_date` and `end_time` > `start_time` or `end_date` is null and `end_time` > `start_time`)
) ENGINE=InnoDB AUTO_INCREMENT=123 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookings`
--

LOCK TABLES `bookings` WRITE;
/*!40000 ALTER TABLE `bookings` DISABLE KEYS */;
INSERT INTO `bookings` VALUES (111,'2026-08-30','18:00:00.000000','02:00:00.000000','performed',928.00,278.40,1,'','2026-08-20 23:33:03.121077',243,201,1,20,123,362,'2026-08-31'),(112,'2026-10-14','18:00:00.000000','02:00:00.000000','preparatory_meeting',937.75,281.32,0,'','2026-10-10 13:02:20.434395',244,201,11,20,124,365,'2026-10-15'),(113,'2026-10-15','18:00:00.000000','04:00:00.000000','paid',1178.00,353.40,1,'','2026-10-10 13:02:24.864976',245,201,16,12,125,366,'2026-10-16'),(120,'2026-11-07','19:00:00.000000','00:00:00.000000','preparatory_meeting',662.00,198.60,0,'','2026-10-10 19:10:53.176290',246,202,11,11,138,374,'2026-11-08'),(121,'2026-11-14','19:00:00.000000','00:00:00.000000','confirmed',662.00,198.60,1,'','2026-10-10 19:10:53.194129',251,202,11,11,139,375,'2026-11-15'),(122,'2026-11-21','19:00:00.000000','00:00:00.000000','paid',662.00,198.60,1,'','2026-10-10 19:10:53.229752',246,202,11,11,140,376,'2026-11-22');
/*!40000 ALTER TABLE `bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cancellation_requests`
--

DROP TABLE IF EXISTS `cancellation_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40000 ALTER TABLE `cancellation_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_profiles`
--

DROP TABLE IF EXISTS `client_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=253 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_profiles`
--

LOCK TABLES `client_profiles` WRITE;
/*!40000 ALTER TABLE `client_profiles` DISABLE KEYS */;
INSERT INTO `client_profiles` VALUES (241,'fr','1995-07-23','+32465779848','kerkskenhoek 56, 9450 Haaltert','Haaltert','9450','2026-08-20 22:06:15.285663',446),(242,'fr','1995-02-23','+32 455 67 78 90','promenade de l\'alma 54, woluwe saint-lambert','Bruxelles','54','2026-08-20 22:20:11.792060',447),(243,'fr','1989-03-03','+32 466 18 13 55','kerkskenhoek 56, 9450 Haaltert','Haaltert','9450','2026-08-20 22:31:53.433145',448),(244,'fr','2000-04-15','0472 34 29 38','kerkskenhoek 56, 9450 Haaltert','Haaltert','kerkskenhoek 56, 945','2026-10-09 20:31:37.000857',449),(245,'fr','2008-08-09','0465 56 97 64','buke 114','Zottegem','9620','2026-10-10 12:52:51.842928',450),(246,'fr','1990-01-01','0470 12 34 56','Rue de la Loi 18','Bruxelles','1000','2026-10-10 15:03:49.449720',451),(247,'fr','1990-01-01','0471 23 45 67','Rue Vinâve d\'Île 22','Liège','4000','2026-10-10 15:03:49.947743',452),(248,'fr','1990-01-01','0472 34 56 78','Rue de Fer 31','Namur','5000','2026-10-10 15:03:50.429615',453),(249,'fr','1990-01-01','0473 45 67 89','Korenmarkt 9','Gand','9000','2026-10-10 15:03:50.930131',454),(250,'fr','1990-01-01','0474 56 78 90','Stationsstraat 14','Haaltert','9450','2026-10-10 15:03:51.412860',455),(251,'fr','1990-01-01','0475 67 89 01','Rue de Nimy 42','Mons','7000','2026-10-10 16:05:22.134891',467),(252,'fr','1990-01-01','0476 78 90 12','Meir 63','Anvers','2000','2026-10-10 16:05:22.650628',468);
/*!40000 ALTER TABLE `client_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contracts`
--

DROP TABLE IF EXISTS `contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=113 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contracts`
--

LOCK TABLES `contracts` WRITE;
/*!40000 ALTER TABLE `contracts` DISABLE KEYS */;
INSERT INTO `contracts` VALUES (101,'UDJ-CON-2026-000111','signed','Annulation et remboursement selon les conditions générales Ultimate DJ.','2026-08-20 23:35:20.501300','2026-08-20 23:33:03.123100',111),(102,'UDJ-CON-2026-000112','sent','Annulation et remboursement selon les conditions générales Ultimate DJ.',NULL,'2026-10-10 13:02:20.436476',112),(103,'UDJ-CON-2026-000113','signed','Annulation et remboursement selon les conditions générales Ultimate DJ.','2026-10-10 13:06:24.710457','2026-10-10 13:02:24.865974',113),(110,'UDJ-CON-2026-000120','sent','Annulation et remboursement selon les conditions générales Ultimate DJ.',NULL,'2026-10-10 19:10:53.178339',120),(111,'UDJ-CON-2026-000121','signed','Annulation et remboursement selon les conditions générales Ultimate DJ.','2026-10-08 19:10:53.201357','2026-10-10 19:10:53.197330',121),(112,'UDJ-CON-2026-000122','signed','Annulation et remboursement selon les conditions générales Ultimate DJ.','2026-10-08 19:10:53.235266','2026-10-10 19:10:53.231740',122);
/*!40000 ALTER TABLE `contracts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dj_applications`
--

DROP TABLE IF EXISTS `dj_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dj_applications`
--

LOCK TABLES `dj_applications` WRITE;
/*!40000 ALTER TABLE `dj_applications` DISABLE KEYS */;
INSERT INTO `dj_applications` VALUES (1,'DJ Ultimate','1995-07-23','+32 465779848','Haaltert','fr','je suis le meilleur DJ de ma génération','tout',20.00,2,'private/dj-applications/identity/2026/08/carte_de_séjour_TCHAMAKO_2025-2026.pdf','private/dj-applications/insurance/2026/08/Equivalence_TCHAMAKO.pdf','approved','','2026-08-17 20:03:34.824562',NULL,NULL,445);
/*!40000 ALTER TABLE `dj_applications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dj_availabilities`
--

DROP TABLE IF EXISTS `dj_availabilities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dj_availabilities` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `available_date` date NOT NULL,
  `start_time` time(6) NOT NULL,
  `end_time` time(6) NOT NULL,
  `status` varchar(20) NOT NULL,
  `dj_id` bigint(20) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `end_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_dj_availability_slot` (`dj_id`,`available_date`,`start_time`),
  KEY `idx_availability_search` (`available_date`,`status`),
  CONSTRAINT `dj_availabilities_dj_id_9082b635_fk_dj_profiles_id` FOREIGN KEY (`dj_id`) REFERENCES `dj_profiles` (`id`),
  CONSTRAINT `availability_end_after_start` CHECK (`end_date` > `available_date` or `end_date` = `available_date` and `end_time` > `start_time` or `end_date` is null and `end_time` > `start_time`)
) ENGINE=InnoDB AUTO_INCREMENT=514 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dj_availabilities`
--

LOCK TABLES `dj_availabilities` WRITE;
/*!40000 ALTER TABLE `dj_availabilities` DISABLE KEYS */;
INSERT INTO `dj_availabilities` VALUES (481,'2026-08-22','17:00:00.000000','05:00:00.000000','available',201,'2026-08-20 21:50:57.000000','','2026-08-23'),(482,'2026-08-23','17:00:00.000000','05:00:00.000000','available',201,'2026-08-20 21:52:48.000000','','2026-08-24'),(483,'2026-08-28','17:00:00.000000','05:00:00.000000','available',201,'2026-08-20 21:53:02.000000','','2026-08-29'),(484,'2026-08-29','17:00:00.000000','05:00:00.000000','available',201,'2026-08-20 21:53:11.000000','','2026-08-30'),(485,'2026-08-30','17:00:00.000000','05:00:00.000000','occupied',201,'2026-08-20 21:53:18.000000','Réservation #111','2026-08-31'),(486,'2026-10-08','18:00:00.000000','23:59:00.000000','available',201,'2026-10-07 14:07:08.532811','','2026-10-08'),(487,'2026-10-14','18:00:00.000000','04:00:00.000000','reserved',201,'2026-10-07 14:08:04.192387','Réservation #112','2026-10-15'),(488,'2026-10-16','18:00:00.000000','04:00:00.000000','available',201,'2026-10-07 14:08:35.390398','','2026-10-17'),(489,'2026-10-17','18:00:00.000000','04:00:00.000000','available',201,'2026-10-07 14:08:52.445868','','2026-10-18'),(490,'2026-10-12','18:00:00.000000','04:00:00.000000','available',201,'2026-10-10 13:15:10.951915','','2026-10-13'),(491,'2026-10-13','18:00:00.000000','04:00:00.000000','available',201,'2026-10-10 13:15:29.773405','','2026-10-14'),(492,'2026-10-17','18:00:00.000000','04:00:00.000000','available',202,'2026-10-10 15:03:51.913564','Créneau de démonstration jury','2026-10-18'),(493,'2026-10-24','18:00:00.000000','04:00:00.000000','available',202,'2026-10-10 15:03:51.931370','Créneau de démonstration jury','2026-10-25'),(494,'2026-10-17','18:00:00.000000','04:00:00.000000','available',203,'2026-10-10 15:03:52.417069','Créneau de démonstration jury','2026-10-18'),(495,'2026-10-24','18:00:00.000000','04:00:00.000000','available',203,'2026-10-10 15:03:52.417069','Créneau de démonstration jury','2026-10-25'),(496,'2026-10-17','18:00:00.000000','04:00:00.000000','available',204,'2026-10-10 15:03:52.916652','Créneau de démonstration jury','2026-10-18'),(497,'2026-10-24','18:00:00.000000','04:00:00.000000','available',204,'2026-10-10 15:03:52.916652','Créneau de démonstration jury','2026-10-25'),(498,'2026-10-17','18:00:00.000000','04:00:00.000000','available',205,'2026-10-10 15:03:53.413382','Créneau de démonstration jury','2026-10-18'),(499,'2026-10-24','18:00:00.000000','04:00:00.000000','available',205,'2026-10-10 15:03:53.413382','Créneau de démonstration jury','2026-10-25'),(500,'2026-10-17','18:00:00.000000','04:00:00.000000','available',206,'2026-10-10 15:03:53.914027','Créneau de démonstration jury','2026-10-18'),(501,'2026-10-24','18:00:00.000000','04:00:00.000000','available',206,'2026-10-10 15:03:53.914027','Créneau de démonstration jury','2026-10-25'),(502,'2026-10-17','18:00:00.000000','04:00:00.000000','available',207,'2026-10-10 15:03:54.400883','Créneau de démonstration jury','2026-10-18'),(503,'2026-10-24','18:00:00.000000','04:00:00.000000','available',207,'2026-10-10 15:03:54.400883','Créneau de démonstration jury','2026-10-25'),(504,'2026-10-17','18:00:00.000000','04:00:00.000000','available',208,'2026-10-10 15:03:54.897065','Créneau de démonstration jury','2026-10-18'),(505,'2026-10-24','18:00:00.000000','04:00:00.000000','available',208,'2026-10-10 15:03:54.897065','Créneau de démonstration jury','2026-10-25'),(506,'2026-10-17','18:00:00.000000','04:00:00.000000','available',209,'2026-10-10 15:03:55.394119','Créneau de démonstration jury','2026-10-18'),(507,'2026-10-24','18:00:00.000000','04:00:00.000000','available',209,'2026-10-10 15:03:55.396131','Créneau de démonstration jury','2026-10-25'),(508,'2026-10-17','18:00:00.000000','04:00:00.000000','available',210,'2026-10-10 15:03:55.880030','Créneau de démonstration jury','2026-10-18'),(509,'2026-10-24','18:00:00.000000','04:00:00.000000','available',210,'2026-10-10 15:03:55.880030','Créneau de démonstration jury','2026-10-25'),(510,'2026-10-17','18:00:00.000000','04:00:00.000000','available',211,'2026-10-10 15:03:56.380293','Créneau de démonstration jury','2026-10-18'),(511,'2026-10-24','18:00:00.000000','04:00:00.000000','available',211,'2026-10-10 15:03:56.380293','Créneau de démonstration jury','2026-10-25'),(512,'2026-10-17','18:00:00.000000','04:00:00.000000','available',212,'2026-10-10 15:03:56.879981','Créneau de démonstration jury','2026-10-18'),(513,'2026-10-24','18:00:00.000000','04:00:00.000000','available',212,'2026-10-10 15:03:56.879981','Créneau de démonstration jury','2026-10-25');
/*!40000 ALTER TABLE `dj_availabilities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dj_profiles`
--

DROP TABLE IF EXISTS `dj_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=213 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dj_profiles`
--

LOCK TABLES `dj_profiles` WRITE;
/*!40000 ALTER TABLE `dj_profiles` DISABLE KEYS */;
INSERT INTO `dj_profiles` VALUES (201,'DJ Ultimate','je suis le meilleur DJ de ma génération',20.00,0.60,2,1,445),(202,'DJ Clara Vandenberg','DJ professionnel basé à Bruxelles, spécialisé en afrobeats, pop, house.',95.00,0.60,6,1,456),(203,'DJ Thomas Vermeulen','DJ professionnel basé à Anvers, spécialisé en house, techno, pop.',100.00,0.60,7,1,457),(204,'DJ Élise De Wilde','DJ professionnel basé à Gand, spécialisé en disco, funk, années 90.',90.00,0.60,8,1,458),(205,'DJ Nathan Leclercq','DJ professionnel basé à Liège, spécialisé en rap, r&b, afrobeats.',95.00,0.60,9,1,459),(206,'DJ Inès Dupont','DJ professionnel basé à Charleroi, spécialisé en pop, dance, années 80.',85.00,0.60,10,1,460),(207,'DJ Julien Massart','DJ professionnel basé à Namur, spécialisé en chanson française, pop, soul.',88.00,0.60,11,1,461),(208,'DJ Lotte Van Damme','DJ professionnel basé à Bruges, spécialisé en ambient, jazz, lounge.',92.00,0.60,12,1,462),(209,'DJ Arnaud Peeters','DJ professionnel basé à Louvain, spécialisé en electro, house, indie pop.',98.00,0.60,13,1,463),(210,'DJ Eva Janssen','DJ professionnel basé à Hasselt, spécialisé en latin pop, reggaeton, dancehall.',90.00,0.60,6,1,464),(211,'DJ Romain Delcourt','DJ professionnel basé à Mons, spécialisé en rock, pop rock, blues.',86.00,0.60,7,1,465),(212,'DJ Maarten De Smet','DJ professionnel basé à Haaltert, spécialisé en pop, disco, afrobeats.',89.00,0.60,8,1,466);
/*!40000 ALTER TABLE `dj_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dj_profiles_music_styles`
--

DROP TABLE IF EXISTS `dj_profiles_music_styles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dj_profiles_music_styles` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `djprofile_id` bigint(20) NOT NULL,
  `musicstyle_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dj_profiles_music_styles_djprofile_id_musicstyle__eb786132_uniq` (`djprofile_id`,`musicstyle_id`),
  KEY `dj_profiles_music_st_musicstyle_id_b125fa6d_fk_music_sty` (`musicstyle_id`),
  CONSTRAINT `dj_profiles_music_st_musicstyle_id_b125fa6d_fk_music_sty` FOREIGN KEY (`musicstyle_id`) REFERENCES `music_styles` (`id`),
  CONSTRAINT `dj_profiles_music_styles_djprofile_id_39ccf4aa_fk_dj_profiles_id` FOREIGN KEY (`djprofile_id`) REFERENCES `dj_profiles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=627 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dj_profiles_music_styles`
--

LOCK TABLES `dj_profiles_music_styles` WRITE;
/*!40000 ALTER TABLE `dj_profiles_music_styles` DISABLE KEYS */;
INSERT INTO `dj_profiles_music_styles` VALUES (601,202,13),(602,202,15),(604,203,15),(603,203,16),(606,204,20),(605,204,57),(607,204,69),(610,205,13),(608,205,17),(609,205,114),(611,206,19),(612,206,54),(614,207,47),(613,207,125),(616,208,29),(615,208,85),(618,209,15),(617,209,82),(619,210,21),(621,210,93),(620,210,116),(622,211,37),(623,211,108),(624,211,117),(626,212,13),(625,212,57);
/*!40000 ALTER TABLE `dj_profiles_music_styles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
INSERT INTO `django_admin_log` VALUES (1,'2026-08-13 21:56:22.669532','1','Remboursement 100 EUR - paiement #132',1,'[{\"added\": {}}]',27,443),(2,'2026-08-20 20:49:08.756908','445','UltimateDJ',2,'[{\"changed\": {\"fields\": [\"Active\"]}}]',4,443),(3,'2026-08-20 20:50:03.699311','1','DJ Ultimate — Approuvée',2,'[{\"changed\": {\"fields\": [\"Statut\"]}}]',32,443),(4,'2026-08-20 22:21:20.413966','242','franck TCHOKONTE',2,'[]',7,443),(5,'2026-08-20 22:22:44.711460','241','Vianney Dimitri TCHAMAKO',2,'[]',7,443),(6,'2026-08-20 22:23:21.535926','242','franck TCHOKONTE',2,'[]',7,443),(7,'2026-08-20 22:32:16.494596','243','Marlyse Chuabe',2,'[]',7,443),(8,'2026-08-20 23:00:58.220223','201','DJ Ultimate',2,'[{\"changed\": {\"fields\": [\"Disponible\"]}}]',8,443),(9,'2026-08-20 23:02:04.197664','1','DJ Ultimate — Approuvée',2,'[]',32,443),(10,'2026-08-20 23:03:26.592864','481','DJ Ultimate - 2026-08-22 17:00:00',2,'[]',14,443),(11,'2026-08-20 23:03:42.453989','482','DJ Ultimate - 2026-08-23 17:00:00',2,'[]',14,443),(12,'2026-08-20 23:03:45.726756','483','DJ Ultimate - 2026-08-28 17:00:00',2,'[]',14,443),(13,'2026-08-20 23:03:52.507257','483','DJ Ultimate - 2026-08-28 17:00:00',2,'[]',14,443),(14,'2026-08-20 23:03:55.403825','484','DJ Ultimate - 2026-08-29 17:00:00',2,'[]',14,443),(15,'2026-08-20 23:03:58.877711','485','DJ Ultimate - 2026-08-30 17:00:00',2,'[]',14,443),(16,'2026-08-21 20:58:32.308974','101','4/5 - Réservation #111 - 2026-08-30',2,'[{\"changed\": {\"fields\": [\"Statut\"]}}]',24,443);
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (31,'accounts','accountdeletionrequest'),(7,'accounts','clientprofile'),(32,'accounts','djapplication'),(8,'accounts','djprofile'),(33,'accounts','notification'),(34,'accounts','notificationpreference'),(1,'admin','logentry'),(3,'auth','group'),(2,'auth','permission'),(4,'auth','user'),(14,'availability','djavailability'),(15,'bookings','booking'),(20,'bookings','bookingequipment'),(35,'bookings','bookingmessage'),(28,'bookings','cancellationrequest'),(21,'bookings','contract'),(16,'bookings','playlist'),(17,'bookings','playlistsong'),(22,'bookings','preparatoryappointment'),(18,'bookings','quote'),(23,'bookings','quoteoption'),(24,'bookings','review'),(19,'bookings','venue'),(13,'catalog','equipment'),(9,'catalog','eventtype'),(10,'catalog','musicstyle'),(11,'catalog','package'),(12,'catalog','serviceoption'),(5,'contenttypes','contenttype'),(25,'payments','invoice'),(26,'payments','payment'),(27,'payments','refund'),(6,'sessions','session'),(29,'token_blacklist','blacklistedtoken'),(30,'token_blacklist','outstandingtoken');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_migrations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'catalog','0001_initial','2026-07-26 18:44:34.496788'),(2,'catalog','0002_equipment_alter_eventtype_options_and_more','2026-07-26 18:44:34.997753'),(3,'contenttypes','0001_initial','2026-07-26 18:44:35.084715'),(4,'auth','0001_initial','2026-07-26 18:44:35.949301'),(5,'accounts','0001_initial','2026-07-26 18:44:36.173972'),(6,'accounts','0002_alter_clientprofile_options_alter_djprofile_options_and_more','2026-07-26 18:44:36.755383'),(7,'admin','0001_initial','2026-07-26 18:44:36.932563'),(8,'admin','0002_logentry_remove_auto_add','2026-07-26 18:44:36.945871'),(9,'admin','0003_logentry_add_action_flag_choices','2026-07-26 18:44:36.952163'),(10,'contenttypes','0002_remove_content_type_name','2026-07-26 18:44:37.079143'),(11,'auth','0002_alter_permission_name_max_length','2026-07-26 18:44:37.163357'),(12,'auth','0003_alter_user_email_max_length','2026-07-26 18:44:37.222237'),(13,'auth','0004_alter_user_username_opts','2026-07-26 18:44:37.229229'),(14,'auth','0005_alter_user_last_login_null','2026-07-26 18:44:37.312123'),(15,'auth','0006_require_contenttypes_0002','2026-07-26 18:44:37.312475'),(16,'auth','0007_alter_validators_add_error_messages','2026-07-26 18:44:37.322560'),(17,'auth','0008_alter_user_username_max_length','2026-07-26 18:44:37.377366'),(18,'auth','0009_alter_user_last_name_max_length','2026-07-26 18:44:37.429260'),(19,'auth','0010_alter_group_name_max_length','2026-07-26 18:44:37.479487'),(20,'auth','0011_update_proxy_permissions','2026-07-26 18:44:37.495387'),(21,'auth','0012_alter_user_first_name_max_length','2026-07-26 18:44:37.548446'),(22,'availability','0001_initial','2026-07-26 18:44:37.746185'),(23,'availability','0002_alter_djavailability_options_and_more','2026-07-26 18:44:37.997751'),(24,'bookings','0001_initial','2026-07-26 18:44:39.696292'),(25,'bookings','0002_bookingequipment_contract_preparatoryappointment_and_more','2026-07-26 18:44:42.449905'),(26,'bookings','0003_quote_music_preferences','2026-07-26 18:44:42.512579'),(27,'catalog','0003_distinguish_adult_and_child_birthdays','2026-07-26 18:44:42.530112'),(28,'payments','0001_initial','2026-07-26 18:44:42.913616'),(29,'payments','0002_alter_invoice_options_alter_payment_options_and_more','2026-07-26 18:44:43.303634'),(30,'payments','0003_alter_payment_stripe_payment_intent_id','2026-07-26 18:44:43.406346'),(31,'sessions','0001_initial','2026-07-26 18:44:43.496656'),(32,'payments','0004_refund','2026-08-04 10:25:54.079081'),(33,'bookings','0004_cancellationrequest','2026-08-04 10:51:26.225233'),(34,'bookings','0005_cancellationrequest_review_message','2026-08-04 11:01:04.353990'),(35,'token_blacklist','0001_initial','2026-08-04 15:16:34.110646'),(36,'token_blacklist','0002_outstandingtoken_jti_hex','2026-08-04 15:16:34.167522'),(37,'token_blacklist','0003_auto_20171017_2007','2026-08-04 15:16:34.192453'),(38,'token_blacklist','0004_auto_20171017_2013','2026-08-04 15:16:34.332677'),(39,'token_blacklist','0005_remove_outstandingtoken_jti','2026-08-04 15:16:34.393689'),(40,'token_blacklist','0006_auto_20171017_2113','2026-08-04 15:16:34.452472'),(41,'token_blacklist','0007_auto_20171017_2214','2026-08-04 15:16:34.993804'),(42,'token_blacklist','0008_migrate_to_bigautofield','2026-08-04 15:16:35.527970'),(43,'token_blacklist','0010_fix_migrate_to_bigautofield','2026-08-04 15:16:35.607439'),(44,'token_blacklist','0011_linearizes_history','2026-08-04 15:16:35.607439'),(45,'token_blacklist','0012_alter_outstandingtoken_user','2026-08-04 15:16:35.643536'),(46,'token_blacklist','0013_alter_blacklistedtoken_options_and_more','2026-08-04 15:16:35.656098'),(47,'accounts','0003_accountdeletionrequest','2026-08-04 16:23:38.295084'),(48,'accounts','0004_remove_accountdeletionrequest_unique_pending_account_deletion','2026-08-04 16:24:11.725422'),(49,'catalog','0004_restrict_supported_offerings','2026-08-10 17:09:20.468673'),(50,'catalog','0005_package_event_types','2026-08-10 17:22:56.353182'),(51,'accounts','0005_djapplication','2026-08-17 19:41:11.340858'),(52,'availability','0003_djavailability_end_date','2026-08-20 21:40:48.707857'),(53,'bookings','0006_booking_end_date','2026-08-20 21:40:48.992553'),(54,'bookings','0007_add_dj_quote_decision','2026-08-20 23:17:24.289713'),(55,'availability','0004_alter_djavailability_status','2026-08-20 23:47:02.342097'),(56,'bookings','0008_appointment_negotiation','2026-08-21 12:23:35.144591'),(57,'catalog','0006_require_preparatory_meetings','2026-08-21 13:04:57.617076'),(58,'bookings','0009_playlist_multiple_styles','2026-08-21 20:26:00.390177'),(59,'catalog','0007_expand_world_music_styles','2026-08-21 21:10:36.673830'),(60,'bookings','0010_playlist_public_catalogue','2026-08-21 21:35:18.633274'),(61,'bookings','0011_review_multiple_per_booking','2026-10-07 14:43:17.109340'),(62,'accounts','0006_notification','2026-10-07 16:34:26.368265'),(63,'accounts','0007_communication_preferences','2026-10-08 06:11:18.260506'),(64,'bookings','0012_communication_preferences','2026-10-08 06:11:18.507863'),(65,'bookings','0013_review_moderation','2026-10-08 06:14:55.661251'),(66,'payments','0005_invoice_last_payment_reminder_at','2026-10-08 11:59:42.734612'),(67,'payments','0006_payment_privacy_policy_consent','2026-10-08 21:16:58.684507'),(68,'bookings','0014_playlist_main_style_optional','2026-10-10 13:46:45.462173');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `equipment`
--

DROP TABLE IF EXISTS `equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
INSERT INTO `equipment` VALUES (121,'sonorisation','Yamaha DXR 101','UDJ-SON-0001',14.00,215.00,'available'),(122,'eclairage','Pioneer CDJ 102','UDJ-ECL-0002',16.00,250.00,'available'),(123,'dj_booth','Pioneer DJM 103','UDJ-DJ_-0003',18.00,285.00,'available'),(124,'micro','Shure SM 104','UDJ-MIC-0004',20.00,320.00,'available'),(125,'cablage','Chauvet Wash 105','UDJ-CAB-0005',22.00,355.00,'available'),(126,'structure','ADJ Beam 106','UDJ-STR-0006',24.00,390.00,'available'),(127,'sonorisation','Klotz Cable 107','UDJ-SON-0007',26.00,425.00,'available'),(128,'eclairage','Gravity Stand 108','UDJ-ECL-0008',28.00,460.00,'available'),(129,'dj_booth','Sennheiser EW 109','UDJ-DJ_-0009',30.00,495.00,'available'),(130,'micro','Denon Prime 110','UDJ-MIC-0010',32.00,530.00,'available'),(131,'cablage','Yamaha DXR 111','UDJ-CAB-0011',34.00,565.00,'available'),(132,'structure','Pioneer CDJ 112','UDJ-STR-0012',36.00,600.00,'available'),(133,'sonorisation','Pioneer DJM 113','UDJ-SON-0013',38.00,635.00,'available'),(134,'eclairage','Shure SM 114','UDJ-ECL-0014',40.00,670.00,'available'),(135,'dj_booth','Chauvet Wash 115','UDJ-DJ_-0015',42.00,705.00,'available'),(136,'micro','ADJ Beam 116','UDJ-MIC-0016',44.00,740.00,'available'),(137,'cablage','Klotz Cable 117','UDJ-CAB-0017',46.00,775.00,'available'),(138,'structure','Gravity Stand 118','UDJ-STR-0018',48.00,810.00,'available'),(139,'sonorisation','Sennheiser EW 119','UDJ-SON-0019',50.00,845.00,'available'),(140,'eclairage','Denon Prime 120','UDJ-ECL-0020',12.00,880.00,'available'),(141,'dj_booth','Yamaha DXR 121','UDJ-DJ_-0021',14.00,915.00,'available'),(142,'micro','Pioneer CDJ 122','UDJ-MIC-0022',16.00,950.00,'available'),(143,'cablage','Pioneer DJM 123','UDJ-CAB-0023',18.00,985.00,'available'),(144,'structure','Shure SM 124','UDJ-STR-0024',20.00,1020.00,'available'),(145,'sonorisation','Chauvet Wash 125','UDJ-SON-0025',22.00,1055.00,'available'),(146,'eclairage','ADJ Beam 126','UDJ-ECL-0026',24.00,1090.00,'available'),(147,'dj_booth','Klotz Cable 127','UDJ-DJ_-0027',26.00,1125.00,'available'),(148,'micro','Gravity Stand 128','UDJ-MIC-0028',28.00,1160.00,'available'),(149,'cablage','Sennheiser EW 129','UDJ-CAB-0029',30.00,1195.00,'available'),(150,'structure','Denon Prime 130','UDJ-STR-0030',32.00,180.00,'available'),(151,'sonorisation','Yamaha DXR 131','UDJ-SON-0031',34.00,215.00,'available'),(152,'eclairage','Pioneer CDJ 132','UDJ-ECL-0032',36.00,250.00,'available'),(153,'dj_booth','Pioneer DJM 133','UDJ-DJ_-0033',38.00,285.00,'available'),(154,'micro','Shure SM 134','UDJ-MIC-0034',40.00,320.00,'available'),(155,'cablage','Chauvet Wash 135','UDJ-CAB-0035',42.00,355.00,'available'),(156,'structure','ADJ Beam 136','UDJ-STR-0036',44.00,390.00,'available'),(157,'sonorisation','Klotz Cable 137','UDJ-SON-0037',46.00,425.00,'maintenance'),(158,'eclairage','Gravity Stand 138','UDJ-ECL-0038',48.00,460.00,'available'),(159,'dj_booth','Sennheiser EW 139','UDJ-DJ_-0039',50.00,495.00,'available'),(160,'micro','Denon Prime 140','UDJ-MIC-0040',12.00,530.00,'available'),(161,'cablage','Yamaha DXR 141','UDJ-CAB-0041',14.00,565.00,'available'),(162,'structure','Pioneer CDJ 142','UDJ-STR-0042',16.00,600.00,'available'),(163,'sonorisation','Pioneer DJM 143','UDJ-SON-0043',18.00,635.00,'available'),(164,'eclairage','Shure SM 144','UDJ-ECL-0044',20.00,670.00,'available'),(165,'dj_booth','Chauvet Wash 145','UDJ-DJ_-0045',22.00,705.00,'available'),(166,'micro','ADJ Beam 146','UDJ-MIC-0046',24.00,740.00,'available'),(167,'cablage','Klotz Cable 147','UDJ-CAB-0047',26.00,775.00,'available'),(168,'structure','Gravity Stand 148','UDJ-STR-0048',28.00,810.00,'available'),(169,'sonorisation','Sennheiser EW 149','UDJ-SON-0049',30.00,845.00,'available'),(170,'eclairage','Denon Prime 150','UDJ-ECL-0050',32.00,880.00,'available'),(171,'dj_booth','Yamaha DXR 151','UDJ-DJ_-0051',34.00,915.00,'available'),(172,'micro','Pioneer CDJ 152','UDJ-MIC-0052',36.00,950.00,'available'),(173,'cablage','Pioneer DJM 153','UDJ-CAB-0053',38.00,985.00,'available'),(174,'structure','Shure SM 154','UDJ-STR-0054',40.00,1020.00,'available'),(175,'sonorisation','Chauvet Wash 155','UDJ-SON-0055',42.00,1055.00,'available'),(176,'eclairage','ADJ Beam 156','UDJ-ECL-0056',44.00,1090.00,'available'),(177,'dj_booth','Klotz Cable 157','UDJ-DJ_-0057',46.00,1125.00,'available'),(178,'micro','Gravity Stand 158','UDJ-MIC-0058',48.00,1160.00,'available'),(179,'cablage','Sennheiser EW 159','UDJ-CAB-0059',50.00,1195.00,'available'),(180,'structure','Denon Prime 160','UDJ-STR-0060',12.00,180.00,'available'),(181,'sonorisation','Yamaha DXR 161','UDJ-SON-0061',14.00,215.00,'available'),(182,'eclairage','Pioneer CDJ 162','UDJ-ECL-0062',16.00,250.00,'available'),(183,'dj_booth','Pioneer DJM 163','UDJ-DJ_-0063',18.00,285.00,'available'),(184,'micro','Shure SM 164','UDJ-MIC-0064',20.00,320.00,'available'),(185,'cablage','Chauvet Wash 165','UDJ-CAB-0065',22.00,355.00,'available'),(186,'structure','ADJ Beam 166','UDJ-STR-0066',24.00,390.00,'available'),(187,'sonorisation','Klotz Cable 167','UDJ-SON-0067',26.00,425.00,'available'),(188,'eclairage','Gravity Stand 168','UDJ-ECL-0068',28.00,460.00,'available'),(189,'dj_booth','Sennheiser EW 169','UDJ-DJ_-0069',30.00,495.00,'available'),(190,'micro','Denon Prime 170','UDJ-MIC-0070',32.00,530.00,'available'),(191,'cablage','Yamaha DXR 171','UDJ-CAB-0071',34.00,565.00,'available'),(192,'structure','Pioneer CDJ 172','UDJ-STR-0072',36.00,600.00,'available'),(193,'sonorisation','Pioneer DJM 173','UDJ-SON-0073',38.00,635.00,'available'),(194,'eclairage','Shure SM 174','UDJ-ECL-0074',40.00,670.00,'maintenance'),(195,'dj_booth','Chauvet Wash 175','UDJ-DJ_-0075',42.00,705.00,'available'),(196,'micro','ADJ Beam 176','UDJ-MIC-0076',44.00,740.00,'available'),(197,'cablage','Klotz Cable 177','UDJ-CAB-0077',46.00,775.00,'available'),(198,'structure','Gravity Stand 178','UDJ-STR-0078',48.00,810.00,'available'),(199,'sonorisation','Sennheiser EW 179','UDJ-SON-0079',50.00,845.00,'available'),(200,'eclairage','Denon Prime 180','UDJ-ECL-0080',12.00,880.00,'available'),(201,'dj_booth','Yamaha DXR 181','UDJ-DJ_-0081',14.00,915.00,'available'),(202,'micro','Pioneer CDJ 182','UDJ-MIC-0082',16.00,950.00,'available'),(203,'cablage','Pioneer DJM 183','UDJ-CAB-0083',18.00,985.00,'available'),(204,'structure','Shure SM 184','UDJ-STR-0084',20.00,1020.00,'available'),(205,'sonorisation','Chauvet Wash 185','UDJ-SON-0085',22.00,1055.00,'available'),(206,'eclairage','ADJ Beam 186','UDJ-ECL-0086',24.00,1090.00,'available'),(207,'dj_booth','Klotz Cable 187','UDJ-DJ_-0087',26.00,1125.00,'available'),(208,'micro','Gravity Stand 188','UDJ-MIC-0088',28.00,1160.00,'available'),(209,'cablage','Sennheiser EW 189','UDJ-CAB-0089',30.00,1195.00,'available'),(210,'structure','Denon Prime 190','UDJ-STR-0090',32.00,180.00,'available'),(211,'sonorisation','Yamaha DXR 191','UDJ-SON-0091',34.00,215.00,'available'),(212,'eclairage','Pioneer CDJ 192','UDJ-ECL-0092',36.00,250.00,'available'),(213,'dj_booth','Pioneer DJM 193','UDJ-DJ_-0093',38.00,285.00,'available'),(214,'micro','Shure SM 194','UDJ-MIC-0094',40.00,320.00,'available'),(215,'cablage','Chauvet Wash 195','UDJ-CAB-0095',42.00,355.00,'available'),(216,'structure','ADJ Beam 196','UDJ-STR-0096',44.00,390.00,'available'),(217,'sonorisation','Klotz Cable 197','UDJ-SON-0097',46.00,425.00,'available'),(218,'eclairage','Gravity Stand 198','UDJ-ECL-0098',48.00,460.00,'available'),(219,'dj_booth','Sennheiser EW 199','UDJ-DJ_-0099',50.00,495.00,'available'),(220,'micro','Denon Prime 200','UDJ-MIC-0100',12.00,530.00,'available'),(221,'cablage','Yamaha DXR 201','UDJ-CAB-0101',14.00,565.00,'available'),(222,'structure','Pioneer CDJ 202','UDJ-STR-0102',16.00,600.00,'available'),(223,'sonorisation','Pioneer DJM 203','UDJ-SON-0103',18.00,635.00,'available'),(224,'eclairage','Shure SM 204','UDJ-ECL-0104',20.00,670.00,'available'),(225,'dj_booth','Chauvet Wash 205','UDJ-DJ_-0105',22.00,705.00,'available'),(226,'micro','ADJ Beam 206','UDJ-MIC-0106',24.00,740.00,'available'),(227,'cablage','Klotz Cable 207','UDJ-CAB-0107',26.00,775.00,'available'),(228,'structure','Gravity Stand 208','UDJ-STR-0108',28.00,810.00,'available'),(229,'sonorisation','Sennheiser EW 209','UDJ-SON-0109',30.00,845.00,'available'),(230,'eclairage','Denon Prime 210','UDJ-ECL-0110',32.00,880.00,'available'),(231,'dj_booth','Yamaha DXR 211','UDJ-DJ_-0111',34.00,915.00,'maintenance'),(232,'micro','Pioneer CDJ 212','UDJ-MIC-0112',36.00,950.00,'available'),(233,'cablage','Pioneer DJM 213','UDJ-CAB-0113',38.00,985.00,'available'),(234,'structure','Shure SM 214','UDJ-STR-0114',40.00,1020.00,'available'),(235,'sonorisation','Chauvet Wash 215','UDJ-SON-0115',42.00,1055.00,'available'),(236,'eclairage','ADJ Beam 216','UDJ-ECL-0116',44.00,1090.00,'available'),(237,'dj_booth','Klotz Cable 217','UDJ-DJ_-0117',46.00,1125.00,'available'),(238,'micro','Gravity Stand 218','UDJ-MIC-0118',48.00,1160.00,'available'),(239,'cablage','Sennheiser EW 219','UDJ-CAB-0119',50.00,1195.00,'available'),(240,'structure','Denon Prime 220','UDJ-STR-0120',12.00,180.00,'available');
/*!40000 ALTER TABLE `equipment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event_types`
--

DROP TABLE IF EXISTS `event_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
INSERT INTO `event_types` VALUES (1,'Anniversaire enfant',1),(10,'Mariage',1),(11,'Anniversaire adulte',1),(12,'Soirée d\'entreprise',1),(13,'Bal étudiant',0),(14,'Baptême',0),(15,'Fête communale',1),(16,'Soirée privée',1),(17,'Événement associatif',1);
/*!40000 ALTER TABLE `event_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoices` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `invoice_number` varchar(40) NOT NULL,
  `invoice_type` varchar(20) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` varchar(20) NOT NULL,
  `issued_at` datetime(6) NOT NULL,
  `due_at` datetime(6) NOT NULL,
  `booking_id` bigint(20) NOT NULL,
  `last_payment_reminder_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_number` (`invoice_number`),
  KEY `invoices_booking_id_aeea72d7_fk_bookings_id` (`booking_id`),
  KEY `idx_invoice_status` (`status`),
  CONSTRAINT `invoices_booking_id_aeea72d7_fk_bookings_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  CONSTRAINT `invoice_amount_positive` CHECK (`amount` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=148 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
INSERT INTO `invoices` VALUES (131,'UDJ-ACP-2026-000111','deposit',278.40,'paid','2026-08-20 23:33:03.125074','2026-08-27 23:33:03.125074',111,NULL),(132,'UDJ-ACP-2026-000112','deposit',281.32,'sent','2026-10-10 13:02:20.439382','2026-10-17 13:02:20.439382',112,NULL),(133,'UDJ-ACP-2026-000113','deposit',353.40,'paid','2026-10-10 13:02:24.865974','2026-10-17 13:02:24.865974',113,NULL),(134,'UDJ-SOL-2026-000111','balance',649.60,'sent','2026-10-10 13:11:55.826281','2026-10-17 13:11:55.826281',111,NULL),(135,'UDJ-SOL-2026-000113','balance',824.60,'paid','2026-10-10 14:26:07.770112','2026-10-17 14:26:07.769080',113,NULL),(144,'UDJ-ACP-2026-000120','deposit',198.60,'sent','2026-10-10 19:10:53.181338','2026-10-17 19:10:53.180343',120,NULL),(145,'UDJ-ACP-2026-000121','deposit',198.60,'paid','2026-10-10 19:10:53.200351','2026-10-17 19:10:53.199348',121,NULL),(146,'UDJ-ACP-2026-000122','deposit',198.60,'paid','2026-10-10 19:10:53.233752','2026-10-17 19:10:53.233752',122,NULL),(147,'UDJ-SOL-2026-000122','balance',463.40,'paid','2026-10-10 19:10:53.245303','2026-10-09 19:10:53.244288',122,NULL);
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `music_styles`
--

DROP TABLE IF EXISTS `music_styles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `music_styles` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=138 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `music_styles`
--

LOCK TABLES `music_styles` WRITE;
/*!40000 ALTER TABLE `music_styles` DISABLE KEYS */;
INSERT INTO `music_styles` VALUES (25,'Acid house'),(26,'Afro house'),(27,'Afrobeat'),(13,'Afrobeats'),(28,'Amapiano'),(29,'Ambient'),(19,'Années 80'),(20,'Années 90'),(30,'Arabic pop'),(31,'Bachata'),(32,'Balkan'),(33,'Baroque'),(34,'Bhangra'),(35,'Bikutsi'),(36,'Bluegrass'),(37,'Blues'),(38,'Bollywood'),(39,'Bossa nova'),(40,'Breakbeat'),(41,'Britpop'),(42,'Calypso'),(43,'Cantopop'),(44,'Carnatic'),(45,'Celtic'),(46,'Chaâbi'),(47,'Chanson française'),(48,'Chill-out'),(49,'City pop'),(50,'Classical'),(51,'Country'),(53,'Coupé-décalé'),(52,'Cumbia'),(54,'Dance'),(21,'Dancehall'),(55,'Dangdut'),(56,'Deep house'),(57,'Disco'),(58,'Drill'),(59,'Drum and bass'),(60,'Dub'),(61,'Dubstep'),(62,'EDM'),(23,'Électro'),(63,'Enka'),(64,'Fado'),(65,'Film music'),(66,'Flamenco'),(67,'Folk'),(68,'Forró'),(69,'Funk'),(70,'Future bass'),(71,'Gamelan'),(72,'Garage rock'),(74,'Gnawa'),(73,'Gospel'),(75,'Grime'),(76,'Hard rock'),(77,'Hardcore'),(78,'Hardstyle'),(79,'Heavy metal'),(80,'Highlife'),(14,'Hip-hop'),(15,'House'),(81,'Indian classical'),(82,'Indie pop'),(83,'Indie rock'),(84,'J-pop'),(85,'Jazz'),(86,'Jungle'),(87,'K-pop'),(88,'Kizomba'),(89,'Klezmer'),(90,'Kompa'),(91,'Kuduro'),(92,'Latin jazz'),(93,'Latin pop'),(22,'Latino'),(94,'Lo-fi hip-hop'),(95,'Makossa'),(97,'Mandopop'),(96,'Mbalax'),(98,'Merengue'),(99,'Metalcore'),(100,'Minimal techno'),(101,'Musical theatre'),(102,'Ndombolo'),(103,'Neo soul'),(104,'New wave'),(105,'Opera'),(106,'Oriental'),(107,'Polka'),(18,'Pop internationale'),(108,'Pop rock'),(109,'Progressive house'),(110,'Psytrance'),(111,'Punk rock'),(112,'Qawwali'),(17,'R&B'),(113,'Raï'),(114,'Rap'),(115,'Reggae'),(116,'Reggaeton'),(117,'Rock'),(118,'Rock alternatif'),(119,'Rock and roll'),(120,'Romantic classical'),(121,'Salsa'),(122,'Samba'),(123,'Ska'),(124,'Soca'),(126,'Soukous'),(125,'Soul'),(127,'Synthpop'),(128,'Tango'),(129,'Tarab'),(130,'Tech house'),(16,'Techno'),(131,'Trance'),(132,'Trap'),(133,'Trip-hop'),(134,'Trot'),(135,'UK garage'),(24,'Variété française'),(136,'World music'),(137,'Zouk');
/*!40000 ALTER TABLE `music_styles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_preferences`
--

DROP TABLE IF EXISTS `notification_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notification_preferences` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `email_enabled` tinyint(1) NOT NULL,
  `internal_enabled` tinyint(1) NOT NULL,
  `booking_enabled` tinyint(1) NOT NULL,
  `payment_enabled` tinyint(1) NOT NULL,
  `review_enabled` tinyint(1) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `notification_preferences_user_id_08802827_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_preferences`
--

LOCK TABLES `notification_preferences` WRITE;
/*!40000 ALTER TABLE `notification_preferences` DISABLE KEYS */;
INSERT INTO `notification_preferences` VALUES (1,1,1,1,1,1,448),(2,1,1,1,1,1,445),(3,1,1,1,1,1,443),(4,1,1,1,1,1,444),(5,1,1,1,1,1,449),(6,1,1,1,1,1,450),(7,1,1,1,1,1,451),(8,1,1,1,1,1,452),(9,1,1,1,1,1,453),(10,1,1,1,1,1,454),(11,1,1,1,1,1,455),(12,1,1,1,1,1,456),(13,1,1,1,1,1,457),(14,1,1,1,1,1,458),(15,1,1,1,1,1,459),(16,1,1,1,1,1,460),(17,1,1,1,1,1,461),(18,1,1,1,1,1,462),(19,1,1,1,1,1,463),(20,1,1,1,1,1,464),(21,1,1,1,1,1,465),(22,1,1,1,1,1,466),(23,1,1,1,1,1,467),(24,1,1,1,1,1,468);
/*!40000 ALTER TABLE `notification_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `packages`
--

DROP TABLE IF EXISTS `packages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
INSERT INTO `packages` VALUES (11,'Essentiel','Prestation DJ simple avec sonorisation légère.',3.0,420.00,1),(12,'Classic','Animation complète pour soirée privée.',5.0,690.00,1),(13,'Premium','DJ, sonorisation renforcée et éclairage d\'ambiance.',6.0,950.00,1),(14,'Mariage Silver','Formule mariage avec rendez-vous préparatoire.',7.0,1250.00,1),(15,'Mariage Gold','Formule mariage complète avec options avancées.',9.0,1690.00,1),(16,'Entreprise','Solution pour événement professionnel.',5.0,1100.00,0),(17,'Festival local','Prestation extérieure avec matériel renforcé.',8.0,1800.00,0),(18,'Étudiant','Formule adaptée aux bals et soirées étudiantes.',5.0,590.00,0),(19,'Lounge','Ambiance musicale douce pour cocktail.',4.0,520.00,0),(20,'Sur mesure','Contrat personnalisé selon les besoins.',1.0,250.00,1);
/*!40000 ALTER TABLE `packages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `packages_event_types`
--

DROP TABLE IF EXISTS `packages_event_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
INSERT INTO `packages_event_types` VALUES (2,11,1),(3,11,10),(4,11,11),(1,11,16),(6,12,1),(7,12,10),(8,12,11),(5,12,16),(10,13,1),(11,13,10),(12,13,11),(9,13,16),(13,14,10),(14,15,10),(16,20,1),(17,20,10),(18,20,11),(15,20,16);
/*!40000 ALTER TABLE `packages_event_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `privacy_policy_accepted_at` datetime(6) DEFAULT NULL,
  `privacy_policy_version` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stripe_session_id` (`stripe_session_id`),
  UNIQUE KEY `stripe_payment_intent_id` (`stripe_payment_intent_id`),
  KEY `payments_booking_id_fa2b6c3e_fk_bookings_id` (`booking_id`),
  KEY `payments_invoice_id_09b5e2bf_fk_invoices_id` (`invoice_id`),
  CONSTRAINT `payments_booking_id_fa2b6c3e_fk_bookings_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  CONSTRAINT `payments_invoice_id_09b5e2bf_fk_invoices_id` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`),
  CONSTRAINT `payment_amount_positive` CHECK (`amount` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=150 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (133,'cs_test_a1kkohFx244FlM5bdBIhiqw6tzZ4s9YCDRGQn9EAkSXdMMNTjmpOHnMotv',NULL,278.40,'EUR','failed',NULL,111,131,NULL,''),(134,'cs_test_a1nSklWlXbSr79F6A7oVy5yRxB3Vc0t7CFoRk7CehAPiq2VEHNcDm4uw7O',NULL,278.40,'EUR','pending',NULL,111,131,NULL,''),(135,'cs_test_a1BffV4QcogHkpaeeG6DhqsXGEajlhQMVesklEOByQdu0iQBNYCfvr2Q5E',NULL,278.40,'EUR','pending',NULL,111,131,NULL,''),(136,'cs_test_a1xaKuHFW9rEQVd3vnMGeDi140PE7G99lDQJvFsL5KrtdHfjtDQnTEHuyh','pi_3U6rxbEpYsrME2au0SQ10Wih',278.40,'EUR','paid','2026-08-21 12:54:22.261138',111,131,NULL,''),(137,'cs_test_a15i5BVY3n2P1FtM9ptguAZMBagmeeeXTcEIDzr8Wzhk1oYbPoGeek458k',NULL,353.40,'EUR','pending',NULL,113,133,'2026-10-10 13:09:12.130442','2026-10-08'),(138,'cs_test_a1obW4lukHF9X4E405GR44URHabR5R9KqPcjMCY8Guar27f5pwVz9ghcnw',NULL,353.40,'EUR','pending',NULL,113,133,'2026-10-10 13:16:08.783572','2026-10-08'),(139,'cs_test_a1jFxyO8rY1b1ohfT7ELgoZtka5IWUoxOPnolBcXMuwCKxTj5obK47lQy5','pi_3UP0PxEpYsrME2au1m9OPUhj',353.40,'EUR','paid','2026-10-10 13:34:32.872978',113,133,'2026-10-10 13:32:53.158523','2026-10-08'),(140,'cs_test_a1DLwKGdserZAumlikyWSNlhz5bmJba11tOgtfL156HjXOCjwnBoW5uCRJ','pi_3UP1F7EpYsrME2au1JuGwDtF',824.60,'EUR','paid','2026-10-10 14:28:49.860785',113,135,'2026-10-10 14:27:04.318182','2026-10-08'),(147,'sample-deposit-121',NULL,198.60,'EUR','paid','2026-10-08 19:10:53.205415',121,145,NULL,''),(148,'sample-deposit-122',NULL,198.60,'EUR','paid','2026-10-08 19:10:53.240296',122,146,NULL,''),(149,'sample-balance-122',NULL,463.40,'EUR','paid','2026-10-09 19:10:53.246321',122,147,NULL,'');
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `playlist_songs`
--

DROP TABLE IF EXISTS `playlist_songs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=226 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `playlist_songs`
--

LOCK TABLES `playlist_songs` WRITE;
/*!40000 ALTER TABLE `playlist_songs` DISABLE KEYS */;
INSERT INTO `playlist_songs` VALUES (221,'pilé','mauvais djo','play_if_possible',111,'approved'),(222,'Dai Dai','Shakira ft Burna Boy','must_play',112,'approved'),(225,'Tout oublier','Angèle','must_play',116,'approved');
/*!40000 ALTER TABLE `playlist_songs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `playlists`
--

DROP TABLE IF EXISTS `playlists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `playlists` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `notes` varchar(255) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `booking_id` bigint(20) NOT NULL,
  `main_style_id` bigint(20) DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_id` (`booking_id`),
  KEY `playlists_main_style_id_5c483738_fk_music_styles_id` (`main_style_id`),
  CONSTRAINT `playlists_booking_id_70c4181c_fk_bookings_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  CONSTRAINT `playlists_main_style_id_5c483738_fk_music_styles_id` FOREIGN KEY (`main_style_id`) REFERENCES `music_styles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=118 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `playlists`
--

LOCK TABLES `playlists` WRITE;
/*!40000 ALTER TABLE `playlists` DISABLE KEYS */;
INSERT INTO `playlists` VALUES (111,'','2026-08-21 20:36:53.596690',111,13,1),(112,'Pop, disco et classiques des années 90, Afrobeats','2026-10-10 13:45:04.941360',113,13,1),(116,'Ambiance validée pendant le rendez-vous.','2026-10-10 19:10:53.212948',121,25,1),(117,'Afrobeats, Pop','2026-10-10 19:12:09.240590',122,13,1);
/*!40000 ALTER TABLE `playlists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `playlists_styles`
--

DROP TABLE IF EXISTS `playlists_styles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `playlists_styles` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `playlist_id` bigint(20) NOT NULL,
  `musicstyle_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `playlists_styles_playlist_id_musicstyle_id_b8026bb7_uniq` (`playlist_id`,`musicstyle_id`),
  KEY `playlists_styles_musicstyle_id_1aebfcdf_fk_music_styles_id` (`musicstyle_id`),
  CONSTRAINT `playlists_styles_musicstyle_id_1aebfcdf_fk_music_styles_id` FOREIGN KEY (`musicstyle_id`) REFERENCES `music_styles` (`id`),
  CONSTRAINT `playlists_styles_playlist_id_545344ab_fk_playlists_id` FOREIGN KEY (`playlist_id`) REFERENCES `playlists` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=131 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `playlists_styles`
--

LOCK TABLES `playlists_styles` WRITE;
/*!40000 ALTER TABLE `playlists_styles` DISABLE KEYS */;
INSERT INTO `playlists_styles` VALUES (111,111,13),(112,111,14),(113,111,15),(114,111,16),(115,111,17),(116,111,18),(117,111,19),(118,111,20),(119,111,21),(120,111,22),(121,111,23),(122,111,24),(123,112,13),(128,116,25),(129,116,26),(130,117,13);
/*!40000 ALTER TABLE `playlists_styles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `preparatory_appointments`
--

DROP TABLE IF EXISTS `preparatory_appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `preparatory_appointments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `scheduled_at` datetime(6) NOT NULL,
  `mode` varchar(20) NOT NULL,
  `status` varchar(20) NOT NULL,
  `notes` longtext NOT NULL,
  `booking_id` bigint(20) NOT NULL,
  `response_message` longtext NOT NULL,
  PRIMARY KEY (`id`),
  KEY `preparatory_appointments_booking_id_e4a993fb_fk_bookings_id` (`booking_id`),
  CONSTRAINT `preparatory_appointments_booking_id_e4a993fb_fk_bookings_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `preparatory_appointments`
--

LOCK TABLES `preparatory_appointments` WRITE;
/*!40000 ALTER TABLE `preparatory_appointments` DISABLE KEYS */;
INSERT INTO `preparatory_appointments` VALUES (2,'2026-08-24 13:00:00.000000','online','done','déroulement de l\'événement',111,''),(3,'2026-10-11 13:00:00.000000','online','accepted','',113,''),(6,'2026-10-13 19:10:53.209949','online','accepted','Préparation du déroulé de la soirée.',121,'');
/*!40000 ALTER TABLE `preparatory_appointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quote_options`
--

DROP TABLE IF EXISTS `quote_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40000 ALTER TABLE `quote_options` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quotes`
--

DROP TABLE IF EXISTS `quotes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `dj_decided_at` datetime(6) DEFAULT NULL,
  `dj_decision` varchar(20) NOT NULL,
  `requested_dj_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `quotes_venue_id_85614e66_fk_venues_id` (`venue_id`),
  KEY `quotes_client_id_689522ba_fk_client_profiles_id` (`client_id`),
  KEY `quotes_event_type_id_6a0f9734_fk_event_types_id` (`event_type_id`),
  KEY `quotes_package_id_fff932b5_fk_packages_id` (`package_id`),
  KEY `idx_quote_event_date` (`event_date`),
  KEY `idx_quote_status` (`status`),
  KEY `quotes_requested_dj_id_1dc94abb_fk_dj_profiles_id` (`requested_dj_id`),
  CONSTRAINT `quotes_client_id_689522ba_fk_client_profiles_id` FOREIGN KEY (`client_id`) REFERENCES `client_profiles` (`id`),
  CONSTRAINT `quotes_event_type_id_6a0f9734_fk_event_types_id` FOREIGN KEY (`event_type_id`) REFERENCES `event_types` (`id`),
  CONSTRAINT `quotes_package_id_fff932b5_fk_packages_id` FOREIGN KEY (`package_id`) REFERENCES `packages` (`id`),
  CONSTRAINT `quotes_requested_dj_id_1dc94abb_fk_dj_profiles_id` FOREIGN KEY (`requested_dj_id`) REFERENCES `dj_profiles` (`id`),
  CONSTRAINT `quotes_venue_id_85614e66_fk_venues_id` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`),
  CONSTRAINT `quote_total_positive` CHECK (`total_amount` >= 0),
  CONSTRAINT `quote_deposit_positive` CHECK (`deposit_amount` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=141 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quotes`
--

LOCK TABLES `quotes` WRITE;
/*!40000 ALTER TABLE `quotes` DISABLE KEYS */;
INSERT INTO `quotes` VALUES (121,'2026-08-29','17:00:00.000000',8.0,120,'sent',915.00,19.50,934.50,280.35,'2026-08-20 22:48:00.246167',243,11,20,361,30.00,1,'tout mais surtout afrobeat',NULL,'pending',NULL),(122,'2026-08-29','17:00:00.000000',8.0,120,'draft',915.00,19.50,934.50,280.35,'2026-08-20 22:49:44.652997',243,11,20,361,30.00,1,'tout mais surtout afrobeat',NULL,'pending',NULL),(123,'2026-08-30','18:00:00.000000',8.0,80,'accepted',915.00,13.00,928.00,278.40,'2026-08-20 23:31:49.655180',243,1,20,362,20.00,1,'TOUT','2026-08-20 23:33:03.135086','accepted',201),(124,'2026-10-14','18:00:00.000000',8.0,100,'accepted',915.00,22.75,937.75,281.32,'2026-10-10 07:59:00.898539',244,11,20,365,35.00,1,'Pop, disco et classiques des années 90, Chanson française, Coupé-décalé','2026-10-10 13:02:20.442708','accepted',201),(125,'2026-10-15','18:00:00.000000',10.0,130,'accepted',1165.00,13.00,1178.00,353.40,'2026-10-10 12:58:37.472301',245,16,12,366,20.00,1,'Pop, disco et classiques des années 90, Afrobeats','2026-10-10 13:02:24.865974','accepted',201),(136,'2026-10-24','19:00:00.000000',5.0,70,'draft',650.00,12.00,662.00,198.60,'2026-10-10 19:10:53.158197',246,11,11,372,12.00,1,'Afrobeats, Pop',NULL,'accepted',NULL),(137,'2026-10-31','19:00:00.000000',5.0,70,'sent',650.00,12.00,662.00,198.60,'2026-10-10 19:10:53.163214',251,11,11,373,12.00,1,'Afrobeats, Pop',NULL,'pending',202),(138,'2026-11-07','19:00:00.000000',5.0,70,'accepted',650.00,12.00,662.00,198.60,'2026-10-10 19:10:53.175265',246,11,11,374,12.00,1,'Afrobeats, Pop','2026-10-10 19:10:53.174265','accepted',202),(139,'2026-11-14','19:00:00.000000',5.0,70,'accepted',650.00,12.00,662.00,198.60,'2026-10-10 19:10:53.192117',251,11,11,375,12.00,1,'Afrobeats, Pop','2026-10-10 19:10:53.191117','accepted',202),(140,'2026-11-21','19:00:00.000000',5.0,70,'accepted',650.00,12.00,662.00,198.60,'2026-10-10 19:10:53.227590',246,11,11,376,12.00,1,'Afrobeats, Pop','2026-10-10 19:10:53.226161','accepted',202);
/*!40000 ALTER TABLE `quotes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refunds`
--

DROP TABLE IF EXISTS `refunds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40000 ALTER TABLE `refunds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reviews` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `rating` smallint(5) unsigned NOT NULL CHECK (`rating` >= 0),
  `comment` varchar(255) NOT NULL,
  `status` varchar(20) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `booking_id` bigint(20) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  `dj_id` bigint(20) NOT NULL,
  `dj_responded_at` datetime(6) DEFAULT NULL,
  `dj_response` varchar(255) NOT NULL,
  `report_reason` varchar(255) NOT NULL,
  `reported_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reviews_client_id_6232284c_fk_client_profiles_id` (`client_id`),
  KEY `reviews_dj_id_57214121_fk_dj_profiles_id` (`dj_id`),
  KEY `reviews_booking_id_45ca787d` (`booking_id`),
  CONSTRAINT `reviews_booking_id_45ca787d_fk_bookings_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  CONSTRAINT `reviews_client_id_6232284c_fk_client_profiles_id` FOREIGN KEY (`client_id`) REFERENCES `client_profiles` (`id`),
  CONSTRAINT `reviews_dj_id_57214121_fk_dj_profiles_id` FOREIGN KEY (`dj_id`) REFERENCES `dj_profiles` (`id`),
  CONSTRAINT `review_rating_between_1_and_5` CHECK (`rating` >= 1 and `rating` <= 5)
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
INSERT INTO `reviews` VALUES (101,4,'bonne ambiance','published','2026-08-21 20:52:24.764511',111,243,201,'2026-10-08 08:54:41.185123','merci','',NULL),(102,5,'J\'ai kiffé','published','2026-10-10 14:38:17.776984',113,245,201,NULL,'','',NULL),(105,5,'Une animation professionnelle et une excellente ambiance.','published','2026-10-10 19:10:53.252331',122,246,202,NULL,'Merci pour votre confiance !','',NULL);
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_options`
--

DROP TABLE IF EXISTS `service_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
INSERT INTO `service_options` VALUES (13,'Éclairage architectural','fixed',180.00,1),(14,'Machine à fumée','fixed',70.00,1),(15,'Micro sans fil supplémentaire','fixed',35.00,1),(16,'Sonorisation grande salle','fixed',260.00,1),(17,'Animation jeux mariage','fixed',120.00,1),(18,'Heure supplémentaire','hourly',95.00,1),(19,'Écran projection','fixed',140.00,1),(20,'Karaoké','fixed',160.00,1),(21,'Technicien lumière','hourly',55.00,1),(22,'Déplacement longue distance','fixed',90.00,1),(23,'Pack vinyle','fixed',130.00,1),(24,'Rendez-vous présentiel supplémentaire','fixed',60.00,1);
/*!40000 ALTER TABLE `service_options` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `token_blacklist_blacklistedtoken`
--

DROP TABLE IF EXISTS `token_blacklist_blacklistedtoken`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `token_blacklist_blacklistedtoken` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `blacklisted_at` datetime(6) NOT NULL,
  `token_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_id` (`token_id`),
  CONSTRAINT `token_blacklist_blacklistedtoken_token_id_3cc7fe56_fk` FOREIGN KEY (`token_id`) REFERENCES `token_blacklist_outstandingtoken` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=112 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `token_blacklist_blacklistedtoken`
--

LOCK TABLES `token_blacklist_blacklistedtoken` WRITE;
/*!40000 ALTER TABLE `token_blacklist_blacklistedtoken` DISABLE KEYS */;
/*!40000 ALTER TABLE `token_blacklist_blacklistedtoken` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `token_blacklist_outstandingtoken`
--

DROP TABLE IF EXISTS `token_blacklist_outstandingtoken`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=129 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `token_blacklist_outstandingtoken`
--

LOCK TABLES `token_blacklist_outstandingtoken` WRITE;
/*!40000 ALTER TABLE `token_blacklist_outstandingtoken` DISABLE KEYS */;
/*!40000 ALTER TABLE `token_blacklist_outstandingtoken` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `venues`
--

DROP TABLE IF EXISTS `venues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=377 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venues`
--

LOCK TABLES `venues` WRITE;
/*!40000 ALTER TABLE `venues` DISABLE KEYS */;
INSERT INTO `venues` VALUES (361,'domicile','kerkskenhoek 56','9450','Haaltert','Belgique',1,30.00,243),(362,'domicile','kerkeskenhoek 56','9450','Haaltert','Belgique',1,20.00,243),(363,'Haaltert','kerkskenhoek 56','9450','Haaltert','Belgique',1,35.00,244),(364,'Haaltert','kerkskenhoek 56','9450','Haaltert','Belgique',1,20.00,244),(365,'bruxelles','rue martin V 41','1200','Bruxelles','Belgique',1,35.00,244),(366,'woluwe saint-lambert','dedale du campanile','1200','Woluwe saint-lambert','Belgique',1,20.00,245),(367,'DEMO-JURY — Devis à traiter','Rue de la Loi 18','1000','Bruxelles','Belgique',0,12.00,246),(368,'DEMO-JURY — Réponse DJ attendue','Rue de Nimy 42','7000','Mons','Belgique',0,12.00,251),(369,'DEMO-JURY — Contrat et acompte','Rue de la Loi 18','1000','Bruxelles','Belgique',0,12.00,246),(370,'DEMO-JURY — Préparation','Rue de Nimy 42','7000','Mons','Belgique',0,12.00,251),(371,'DEMO-JURY — Clôturé et payé','Rue de la Loi 18','1000','Bruxelles','Belgique',0,12.00,246),(372,'Événement suivi — Devis à traiter','Rue de la Loi 18','1000','Bruxelles','Belgique',0,12.00,246),(373,'Événement suivi — Réponse DJ attendue','Rue de Nimy 42','7000','Mons','Belgique',0,12.00,251),(374,'Événement suivi — Contrat et acompte','Rue de la Loi 18','1000','Bruxelles','Belgique',0,12.00,246),(375,'Événement suivi — Préparation','Rue de Nimy 42','7000','Mons','Belgique',0,12.00,251),(376,'Événement suivi — Clôturé et payé','Rue de la Loi 18','1000','Bruxelles','Belgique',0,12.00,246);
/*!40000 ALTER TABLE `venues` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'ultimate_dj_django'
--

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
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-11 10:25:32
