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
    
    // Validate that ID is provided
    if (empty($input['id'])) {
        echo json_encode(['status' => 'error', 'message' => 'Student ID is required for deletion']);
        exit();
    }
    
    // Check if student exists first
    $checkStmt = $conn->prepare("SELECT id, name, student_id FROM sqlinfo WHERE id = ?");
    if ($checkStmt === false) {
        echo json_encode(['status' => 'error', 'message' => 'Database prepare error: ' . $conn->error]);
        exit();
    }
    
    $checkStmt->bind_param("i", $input['id']);
    $checkStmt->execute();
    $result = $checkStmt->get_result();
    
    if ($result->num_rows == 0) {
        echo json_encode(['status' => 'error', 'message' => 'Student not found']);
        $checkStmt->close();
        exit();
    }
    
    // Get student info before deletion (for confirmation message)
    $studentData = $result->fetch_assoc();
    $checkStmt->close();
    
    // Delete the student
    $deleteStmt = $conn->prepare("DELETE FROM sqlinfo WHERE id = ?");
    if ($deleteStmt === false) {
        echo json_encode(['status' => 'error', 'message' => 'Database prepare failed: ' . $conn->error]);
        exit();
    }
    
    $deleteStmt->bind_param("i", $input['id']);
    
    if ($deleteStmt->execute()) {
        if ($deleteStmt->affected_rows > 0) {
            echo json_encode([
                'status' => 'success', 
                'message' => 'Student "' . $studentData['name'] . '" (ID: ' . $studentData['student_id'] . ') has been deleted successfully',
                'deleted_student' => $studentData
            ]);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'No student was deleted']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Error deleting student: ' . $deleteStmt->error]);
    }
    
    $deleteStmt->close();
    
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => 'Server error: ' . $e->getMessage()]);
} finally {
    // Close connection
    if (isset($conn)) {
        $conn->close();
    }
}
?>