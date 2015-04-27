-- MySQL dump 10.13  Distrib 5.6.22, for osx10.8 (x86_64)
--
-- Host: localhost    Database: cewp459
-- ------------------------------------------------------
-- Server version	5.6.22

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Music234`
--

DROP TABLE IF EXISTS `Music234`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Music234` (
  `studentID` int(6) NOT NULL,
  `Assignment` int(1) NOT NULL,
  `Grade` int(1) DEFAULT NULL,
  KEY `studentID` (`studentID`),
  CONSTRAINT `music234_ibfk_1` FOREIGN KEY (`studentID`) REFERENCES `students` (`studentID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Music234`
--

LOCK TABLES `Music234` WRITE;
/*!40000 ALTER TABLE `Music234` DISABLE KEYS */;
INSERT INTO `Music234` VALUES (1,1,76),(2,2,100),(3,3,100),(1,2,68),(1,3,89),(2,1,58),(2,3,74),(3,1,60),(3,2,80);
/*!40000 ALTER TABLE `Music234` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Music322`
--

DROP TABLE IF EXISTS `Music322`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Music322` (
  `studentID` int(6) NOT NULL,
  `Assignment` int(1) NOT NULL,
  `Grade` int(1) DEFAULT NULL,
  KEY `studentID` (`studentID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Music322`
--

LOCK TABLES `Music322` WRITE;
/*!40000 ALTER TABLE `Music322` DISABLE KEYS */;
INSERT INTO `Music322` VALUES (1,1,91),(2,2,69),(3,3,76),(1,2,76),(1,3,82),(2,1,65),(2,3,69),(3,1,70),(3,2,88);
/*!40000 ALTER TABLE `Music322` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Music405`
--

DROP TABLE IF EXISTS `Music405`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Music405` (
  `studentID` int(6) NOT NULL,
  `Assignment` int(1) NOT NULL,
  `Grade` int(1) DEFAULT NULL,
  KEY `studentID` (`studentID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Music405`
--

LOCK TABLES `Music405` WRITE;
/*!40000 ALTER TABLE `Music405` DISABLE KEYS */;
INSERT INTO `Music405` VALUES (1,1,88),(2,2,98),(3,3,89),(1,2,77),(1,3,72),(2,1,55),(2,3,87),(3,1,71),(3,2,79);
/*!40000 ALTER TABLE `Music405` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `students` (
  `LastName` varchar(30) NOT NULL,
  `FirstName` varchar(30) NOT NULL,
  `studentID` int(6) NOT NULL AUTO_INCREMENT,
  `Classes` varchar(7) DEFAULT NULL,
  PRIMARY KEY (`studentID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES ('Jones','Quincy',1,NULL),('Martin','George',2,NULL),('Rubin','Rick',3,NULL);
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-03-04 11:23:39
