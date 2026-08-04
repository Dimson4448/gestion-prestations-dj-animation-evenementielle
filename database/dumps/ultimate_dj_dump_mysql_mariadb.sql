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
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
  PRIMARY KEY (`id`),
  KEY `cancellation_requests_booking_id_8edac695_fk_bookings_id` (`booking_id`),
  KEY `cancellation_requests_reviewed_by_id_d1c90040_fk_auth_user_id` (`reviewed_by_id`),
  KEY `idx_cancel_request_status` (`status`,`requested_at`),
  CONSTRAINT `cancellation_requests_booking_id_8edac695_fk_bookings_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  CONSTRAINT `cancellation_requests_reviewed_by_id_d1c90040_fk_auth_user_id` FOREIGN KEY (`reviewed_by_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

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

-- Dump completed on 2026-07-26 21:36:20
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
(33,'bookings','0004_cancellationrequest','2026-08-04 10:51:26.225233');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `django_content_type` VALUES
(7,'accounts','clientprofile'),
(8,'accounts','djprofile'),
(1,'admin','logentry'),
(3,'auth','group'),
(2,'auth','permission'),
(4,'auth','user'),
(14,'availability','djavailability'),
(15,'bookings','booking'),
(20,'bookings','bookingequipment'),
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
(6,'sessions','session');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;
commit;

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
(104,'Can view paiement',26,'view_payment');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;
commit;

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
(16,'Entreprise','Solution pour événement professionnel.',5.0,1100.00,1),
(17,'Festival local','Prestation extérieure avec matériel renforcé.',8.0,1800.00,1),
(18,'Étudiant','Formule adaptée aux bals et soirées étudiantes.',5.0,590.00,1),
(19,'Lounge','Ambiance musicale douce pour cocktail.',4.0,520.00,1),
(20,'Sur mesure','Contrat personnalisé selon les besoins.',1.0,250.00,1);
/*!40000 ALTER TABLE `packages` ENABLE KEYS */;
UNLOCK TABLES;
commit;

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
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-07-26 21:36:20
