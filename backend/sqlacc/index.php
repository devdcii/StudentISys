<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

include 'config/dbcon.php';

$search = isset($_GET['search']) ? $_GET['search'] : '';

if (!empty($search)) {
    // Search for students by name, student_id, or course
    $stmt = $conn->prepare("SELECT * FROM sqlinfo WHERE name LIKE ? OR student_id LIKE ? OR course LIKE ? ORDER BY name ASC");
    $searchTerm = "%" . $search . "%";
    $stmt->bind_param("sss", $searchTerm, $searchTerm, $searchTerm);
} else {
    // Get all students
    $stmt = $conn->prepare("SELECT * FROM sqlinfo ORDER BY name ASC");
}

$stmt->execute();
$result = $stmt->get_result();

$students = array();
while($row = $result->fetch_assoc()) {
    $students[] = $row;
}

echo json_encode($students);

$stmt->close();
$conn->close();
?>