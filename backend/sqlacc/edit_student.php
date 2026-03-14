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
    
    // Validate that ID is provided (this is required to identify which student to update)
    if (empty($input['id'])) {
        echo json_encode(['status' => 'error', 'message' => 'Student ID is required for update']);
        exit();
    }
    
    // Check if student exists and get current data
    $checkStmt = $conn->prepare("SELECT * FROM sqlinfo WHERE id = ?");
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
    
    // Get current student data
    $currentData = $result->fetch_assoc();
    $checkStmt->close();
    
    // Build update data - only update fields that are provided and not empty
    $updateFields = [];
    $updateValues = [];
    $paramTypes = "";
    
    // Handle name
    if (isset($input['name']) && trim($input['name']) !== '') {
        $updateFields[] = "name = ?";
        $updateValues[] = trim($input['name']);
        $paramTypes .= "s";
    }
    
    // Handle student_id
    if (isset($input['student_id']) && trim($input['student_id']) !== '') {
        $new_student_id = trim($input['student_id']);
        
        // Check if student ID already exists for another student
        if ($new_student_id !== $currentData['student_id']) {
            $checkDuplicateStmt = $conn->prepare("SELECT id FROM sqlinfo WHERE student_id = ? AND id != ?");
            if ($checkDuplicateStmt === false) {
                echo json_encode(['status' => 'error', 'message' => 'Database prepare error: ' . $conn->error]);
                exit();
            }
            
            $checkDuplicateStmt->bind_param("si", $new_student_id, $input['id']);
            $checkDuplicateStmt->execute();
            $duplicateResult = $checkDuplicateStmt->get_result();
            
            if ($duplicateResult->num_rows > 0) {
                echo json_encode(['status' => 'error', 'message' => 'Student ID already exists for another student']);
                $checkDuplicateStmt->close();
                exit();
            }
            $checkDuplicateStmt->close();
        }
        
        $updateFields[] = "student_id = ?";
        $updateValues[] = $new_student_id;
        $paramTypes .= "s";
    }
    
    // Handle email
    if (isset($input['email']) && trim($input['email']) !== '') {
        $updateFields[] = "email = ?";
        $updateValues[] = trim($input['email']);
        $paramTypes .= "s";
    }
    
    // Handle course
    if (isset($input['course']) && trim($input['course']) !== '') {
        $updateFields[] = "course = ?";
        $updateValues[] = trim($input['course']);
        $paramTypes .= "s";
    }
    
    // Handle year_level
    if (isset($input['year_level']) && $input['year_level'] !== '' && is_numeric($input['year_level'])) {
        $year_level = intval($input['year_level']);
        if ($year_level >= 0) { // Allow 0 and positive values
            $updateFields[] = "year_level = ?";
            $updateValues[] = $year_level;
            $paramTypes .= "i";
        }
    }
    
    // Handle GPA - special case: allow empty string to set to NULL
    if (isset($input['gpa'])) {
        if (trim($input['gpa']) === '') {
            // Empty string means set to NULL
            $updateFields[] = "gpa = NULL";
        } else if (is_numeric($input['gpa'])) {
            // Valid numeric value
            $updateFields[] = "gpa = ?";
            $updateValues[] = floatval($input['gpa']);
            $paramTypes .= "d";
        }
    }
    
    // Check if there are any fields to update
    if (empty($updateFields)) {
        echo json_encode(['status' => 'info', 'message' => 'No valid fields provided for update']);
        exit();
    }
    
    // Build and execute update query
    $sql = "UPDATE sqlinfo SET " . implode(", ", $updateFields) . " WHERE id = ?";
    $paramTypes .= "i"; // for the id parameter
    $updateValues[] = intval($input['id']); // Add the id to the end
    
    $stmt = $conn->prepare($sql);
    if ($stmt === false) {
        echo json_encode(['status' => 'error', 'message' => 'Database prepare failed: ' . $conn->error]);
        exit();
    }
    
    // Bind parameters dynamically
    $stmt->bind_param($paramTypes, ...$updateValues);
    
    // Execute the statement
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            // Get updated data to return
            $getUpdatedStmt = $conn->prepare("SELECT * FROM sqlinfo WHERE id = ?");
            $getUpdatedStmt->bind_param("i", $input['id']);
            $getUpdatedStmt->execute();
            $updatedResult = $getUpdatedStmt->get_result();
            $updatedData = $updatedResult->fetch_assoc();
            $getUpdatedStmt->close();
            
            echo json_encode([
                'status' => 'success', 
                'message' => 'Student updated successfully',
                'updated_data' => $updatedData
            ]);
        } else {
            echo json_encode(['status' => 'info', 'message' => 'No changes were made to the student information']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Error updating student: ' . $stmt->error]);
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