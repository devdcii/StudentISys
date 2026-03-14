<?php
// Set headers for JSON response and CORS
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

// Include database connection
require_once 'config/dbcon.php';

try {
    // Get and decode JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Check if JSON decoding was successful
    if ($input === null) {
        echo json_encode(['status' => 'error', 'message' => 'Invalid JSON data']);
        exit();
    }
    
    // Check connection
    if ($conn->connect_error) {
        echo json_encode(['status' => 'error', 'message' => 'Database connection failed: ' . $conn->connect_error]);
        exit();
    }
    
    // Validate input data
    if (empty($input['name']) || empty($input['student_id']) || empty($input['email']) || empty($input['course']) || empty($input['year_level'])) {
        echo json_encode(['status' => 'error', 'message' => 'Missing required fields: name, student_id, email, course, year_level']);
        exit();
    }
    
    // Check if student ID already exists
    $checkStmt = $conn->prepare("SELECT student_id FROM sqlinfo WHERE student_id = ?");
    if ($checkStmt === false) {
        echo json_encode(['status' => 'error', 'message' => 'Database prepare error: ' . $conn->error]);
        exit();
    }
    
    $checkStmt->bind_param("s", $input['student_id']);
    $checkStmt->execute();
    $result = $checkStmt->get_result();
    
    if ($result->num_rows > 0) {
        echo json_encode(['status' => 'error', 'message' => 'Student ID already exists']);
        $checkStmt->close();
        exit();
    }
    $checkStmt->close();
    
    // Process GPA - handle it properly for binding
    $gpa_value = null;
    $include_gpa = false;
    
    if (!empty($input['gpa']) && is_numeric($input['gpa'])) {
        $gpa_value = floatval($input['gpa']);
        $include_gpa = true;
    }
    
    // Handle the SQL statement based on whether GPA is provided or not
    if ($include_gpa) {
        // If GPA is provided, include it in the insert
        $stmt = $conn->prepare("INSERT INTO sqlinfo (name, student_id, email, course, year_level, gpa) VALUES (?, ?, ?, ?, ?, ?)");
        if ($stmt === false) {
            echo json_encode(['status' => 'error', 'message' => 'Database prepare failed: ' . $conn->error]);
            exit();
        }
        
        // Create variables for binding (required for pass-by-reference)
        $name = $input['name'];
        $student_id = $input['student_id'];
        $email = $input['email'];
        $course = $input['course'];
        $year_level = intval($input['year_level']);
        
        // Bind parameters with GPA
        $stmt->bind_param("ssssis", $name, $student_id, $email, $course, $year_level, $gpa_value);
    } else {
        // If GPA is not provided, don't include it in the insert
        $stmt = $conn->prepare("INSERT INTO sqlinfo (name, student_id, email, course, year_level) VALUES (?, ?, ?, ?, ?)");
        if ($stmt === false) {
            echo json_encode(['status' => 'error', 'message' => 'Database prepare failed: ' . $conn->error]);
            exit();
        }
        
        // Create variables for binding (required for pass-by-reference)
        $name = $input['name'];
        $student_id = $input['student_id'];
        $email = $input['email'];
        $course = $input['course'];
        $year_level = intval($input['year_level']);
        
        // Bind parameters without GPA
        $stmt->bind_param("ssssi", $name, $student_id, $email, $course, $year_level);
    }
    
    // Execute the statement
    if ($stmt->execute()) {
        echo json_encode(['status' => 'success', 'message' => 'Student added successfully', 'student_id' => $input['student_id']]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Error adding student: ' . $stmt->error]);
    }
    
    $stmt->close();
    
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'Server error: ' . $e->getMessage()]);
} finally {
    // Close connection
    if (isset($conn)) {
        $conn->close();
    }
}
?>