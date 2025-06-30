<?php
$servername = "{{ db_endpoint }}";
$username = "admin";
$password = "SecurePass123!";
$dbname = "lamp_db";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully to database!";
?>