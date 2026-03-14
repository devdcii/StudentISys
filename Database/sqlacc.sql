-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 22, 2025 at 09:33 PM
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
-- Database: `sqlacc`
--

-- --------------------------------------------------------

--
-- Table structure for table `sqlinfo`
--

CREATE TABLE `sqlinfo` (
  `id` int(255) NOT NULL,
  `student_id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `course` varchar(255) NOT NULL,
  `year_level` int(255) NOT NULL,
  `gpa` decimal(3,2) NOT NULL,
  `created_at` int(11) NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sqlinfo`
--

INSERT INTO `sqlinfo` (`id`, `student_id`, `name`, `email`, `course`, `year_level`, `gpa`, `created_at`) VALUES
(1, '2025-1', 'Chan', 'chan@gmail.com', 'BSCpE', 4, 1.00, 0),
(2, '2025-2', 'Cii', 'cii@gmail.com', 'BSCpE', 4, 1.75, 0),
(3, '2025-3', 'Leohan', 'leohan@gmail.com', 'BSCpE', 4, 1.50, 0),
(4, '2025-4', 'Leotan', 'leotan@gmail.com', 'BSCS', 4, 2.25, 0),
(5, '2025-5', 'Matt', 'matt@gmail.com', 'BSCpE', 4, 2.50, 0),
(6, '2025-6', 'Rence', 'rence@gmail.com', 'BSCpE', 4, 1.75, 0),
(7, '2025-7', 'Mowitz', 'mowitz@gmail.com', 'BSCpE', 4, 2.25, 0),
(8, '2025-8', 'Joseph', 'joseph@gmail.com', 'BSCpE', 4, 1.00, 0),
(9, '2025-9', 'Deangdeang', 'deang@gmail.com', 'BSCpE', 4, 3.00, 0),
(10, '2025-10', 'Jai', 'jai@gmail.com', 'BSCpE', 4, 2.25, 0),
(11, '2025-11', 'Janeee', 'janeee@gmail.com', 'BSCpE', 4, 3.00, 0),
(12, '2025-12', 'Chiii', 'chiii@gmail.com', 'BSIT', 2, 2.25, 0),
(13, '2025-13', 'Ren', 'ren@gmail.com', 'BSCS', 3, 2.25, 0),
(14, '2025-14', 'Secondhand', 'secondhand@gmail.com', 'BSHM', 4, 2.75, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `sqlinfo`
--
ALTER TABLE `sqlinfo`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `sqlinfo`
--
ALTER TABLE `sqlinfo`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
