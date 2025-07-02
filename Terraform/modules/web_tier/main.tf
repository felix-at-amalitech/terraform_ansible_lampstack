resource "aws_security_group" "web_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "LAMP-Web-SG"
    Tier = "Web"
  }
}

resource "aws_instance" "web" {
  ami             = "ami-0803576f0c0169402" # Amazon Linux 2
  instance_type   = "t2.micro"
  subnet_id       = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name         = var.key_name
  
  tags = {
    Name = "LAMP-Web-Server"
    Tier = "Web"
  }
  
  user_data = <<-EOF
#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x
echo "Starting user-data script at $(date)"

# Create basic test file first
echo '<h1>Basic HTML Test</h1>' > /var/www/html/test.html

yum update -y
yum install -y httpd php php-mysqlnd mysql
echo "Packages installed at $(date)"

systemctl start httpd
systemctl enable httpd
echo "Apache started at $(date)"

# Create database test
echo '<?php \$conn = new mysqli("${split(":", var.db_endpoint)[0]}", "admin", "SecurePass123!", "lampdb2025", 3306, "", MYSQLI_CLIENT_SSL_DONT_VERIFY_SERVER_CERT); if (\$conn->connect_error) { echo "DB Failed: " . \$conn->connect_error; } else { mysqli_set_charset(\$conn, "utf8"); \$result = \$conn->query("SELECT COUNT(*) as count FROM healthy_fruits"); \$row = \$result->fetch_assoc(); echo "DB Connected. Fruits: " . \$row["count"]; } ?>' > /var/www/html/basic.php
echo "Basic files created at $(date)"

# Wait for database to be ready
echo "Waiting for database..."
sleep 30

# Test database connection and log results (don't exit on failure)
echo "Testing database connection to ${split(":", var.db_endpoint)[0]}" >> /var/log/db-connection.log
mysql -h ${split(":", var.db_endpoint)[0]} -u admin -pSecurePass123! -e "SELECT 1;" >> /var/log/db-connection.log 2>&1
if [ $? -eq 0 ]; then
    echo "Database connection successful" >> /var/log/db-connection.log
else
    echo "Database connection failed, continuing anyway" >> /var/log/db-connection.log
fi

# Create database and table
echo "Creating database lampdb2025" >> /var/log/db-connection.log
mysql -h ${split(":", var.db_endpoint)[0]} -u admin -pSecurePass123! -e "CREATE DATABASE IF NOT EXISTS lampdb2025;" >> /var/log/db-connection.log 2>&1

echo "Creating table healthy_fruits" >> /var/log/db-connection.log
mysql -h ${split(":", var.db_endpoint)[0]} -u admin -pSecurePass123! lampdb2025 -e "CREATE TABLE IF NOT EXISTS healthy_fruits (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255) NOT NULL UNIQUE, benefits TEXT);" >> /var/log/db-connection.log 2>&1

# Insert data
echo "Inserting fruit data" >> /var/log/db-connection.log
mysql -h ${split(":", var.db_endpoint)[0]} -u admin -pSecurePass123! lampdb2025 -e "INSERT IGNORE INTO healthy_fruits (name, benefits) VALUES ('Pineapple', 'Rich in Vitamin C, manganese, contains bromelain for inflammation.'), ('Mango', 'High in Vitamin C, A, fiber, promotes antioxidants.'), ('Banana', 'Great for potassium, Vitamin B6, energy.'), ('Plantain', 'Starchy, rich in carbs, vitamins, minerals.'), ('Soursop', 'Vitamin C, antioxidant properties.'), ('African Star Apple', 'Calcium, Vitamin C, supports digestion.'), ('Black Velvet Tamarind', 'High in Vitamin C, iron, magnesium, fiber.'), ('Guava', 'Vitamin C, fiber, antioxidants, boosts immunity.'), ('Papaya', 'Vitamin C, A, papain aids digestion.');" >> /var/log/db-connection.log 2>&1

echo "Database setup completed" >> /var/log/db-connection.log

# Enable PHP error logging
echo 'log_errors = On' >> /etc/php.ini
echo 'error_log = /var/log/php_errors.log' >> /etc/php.ini
systemctl restart httpd

# Create multiple test pages to isolate the issue
echo '<h1>HTML Test - Working</h1>' > /var/www/html/html-test.html
echo '<?php echo "<h1>PHP Test - Working</h1>"; ?>' > /var/www/html/php-test.php
echo '<?php phpinfo(); ?>' > /var/www/html/phpinfo.php

# Test basic MySQL connection
cat > /var/www/html/db-test.php << 'DBTEST'
<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
echo "<h1>Database Connection Test</h1>";
try {
    \$conn = new mysqli('${split(":", var.db_endpoint)[0]}', 'admin', 'SecurePass123!', 'lampdb2025');
    if (\$conn->connect_error) {
        echo "<p style='color:red'>Connection failed: " . \$conn->connect_error . "</p>";
    } else {
        echo "<p style='color:green'>Connected successfully!</p>";
        \$result = \$conn->query('SELECT COUNT(*) as count FROM healthy_fruits');
        if (\$result) {
            \$row = \$result->fetch_assoc();
            echo "<p>Found " . \$row['count'] . " fruits in database</p>";
        }
        \$conn->close();
    }
} catch (Exception \$e) {
    echo "<p style='color:red'>Error: " . \$e->getMessage() . "</p>";
}
?>
DBTEST

# Create index.php with modern styling
cat > /var/www/html/index.php << 'PHPEND'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Healthy Ghanaian Fruits</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; background: white; border-radius: 20px; box-shadow: 0 20px 40px rgba(0,0,0,0.1); overflow: hidden; }
        .header { background: linear-gradient(135deg, #ff6b6b, #ffa500); color: white; text-align: center; padding: 40px 20px; }
        .header h1 { font-size: 2.5rem; margin-bottom: 10px; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); }
        .header p { font-size: 1.1rem; opacity: 0.9; }
        .content { padding: 40px; }
        .fruits-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 25px; }
        .fruit-card { background: #f8f9fa; border-radius: 15px; padding: 25px; box-shadow: 0 5px 15px rgba(0,0,0,0.08); transition: transform 0.3s ease, box-shadow 0.3s ease; border-left: 5px solid #ff6b6b; }
        .fruit-card:hover { transform: translateY(-5px); box-shadow: 0 15px 30px rgba(0,0,0,0.15); }
        .fruit-name { font-size: 1.4rem; font-weight: bold; color: #2c3e50; margin-bottom: 15px; display: flex; align-items: center; }
        .fruit-name::before { content: '🍎'; margin-right: 10px; font-size: 1.5rem; }
        .fruit-benefits { color: #555; line-height: 1.6; font-size: 1rem; }
        .stats { background: #e8f5e8; padding: 20px; border-radius: 10px; margin-bottom: 30px; text-align: center; }
        .stats h3 { color: #27ae60; margin-bottom: 10px; }
        @media (max-width: 768px) { .header h1 { font-size: 2rem; } .fruits-grid { grid-template-columns: 1fr; } .content { padding: 20px; } }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🌟 Healthy Ghanaian Fruits 🌟</h1>
            <p>Discover the amazing health benefits of Ghana's finest fruits</p>
        </div>
        <div class="content">
            <?php
            $conn = new mysqli("${split(":", var.db_endpoint)[0]}", "admin", "SecurePass123!", "lampdb2025");
            if ($conn->connect_error) die("<div style='color:red;text-align:center;'>Connection failed: " . $conn->connect_error . "</div>");
            
            $result = $conn->query("SELECT name, benefits FROM healthy_fruits");
            $count = $result->num_rows;
            
            echo "<div class='stats'><h3>🎯 Featuring $count Nutritious Fruits</h3><p>Each packed with essential vitamins and minerals for your health</p></div>";
            
            if ($result && $count > 0) {
                echo "<div class='fruits-grid'>";
                while($row = $result->fetch_assoc()) {
                    echo "<div class='fruit-card'>";
                    echo "<div class='fruit-name'>" . htmlspecialchars($row['name']) . "</div>";
                    echo "<div class='fruit-benefits'>" . htmlspecialchars($row['benefits']) . "</div>";
                    echo "</div>";
                }
                echo "</div>";
            } else {
                echo "<div style='text-align:center;color:#666;'>No fruits found in our database.</div>";
            }
            $conn->close();
            ?>
        </div>
    </div>
</body>
</html>
PHPEND

# Create fruits.php as backup
cp /var/www/html/index.php /var/www/html/fruits.php

echo "PHP files created successfully at $(date)" >> /var/log/user-data.log
ls -la /var/www/html/ >> /var/log/user-data.log
EOF
}
