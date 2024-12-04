resource "aws_security_group" "rds_sg" {
  name        = "rds_security_group"
  description = "Allow inbound access to RDS from backend"
  vpc_id      = aws_vpc.main_vpc.id
  ingress {
    from_port   = 3306 # MySQL port; use 5432 for PostgreSQL
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your backend's IP for security
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "RDS Security Group"
  }
}
# Create Subnet Group for RDS
resource "aws_db_subnet_group" "app_db_subnet_group" {
  name        = "app_db_subnet_group"
  description = "Subnet group for RDS instance"
  subnet_ids  = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id] # Include both subnets
  tags = {
    Name = "RDS Subnet Group"
  }
}
# RDS Instance
resource "aws_db_instance" "app_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql" # Use "postgres" for PostgreSQL
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "app_database" # Database name
  username               = "admin"        # Master username
  password               = "strongpassword123" # Replace with a strong password
  parameter_group_name   = "default.mysql8.0"
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.app_db_subnet_group.name # Correct subnet group
  tags = {
    Name = "App Database"
    Environment = "Production"
  }
}
# Output: Database Endpoint
output "rds_endpoint" {
  value = aws_db_instance.app_db.endpoint
}
