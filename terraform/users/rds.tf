
# Security Group to allow inbound access to the RDS instance
resource "aws_security_group" "rds_security_group" {
  name        = "rds_security_group"
  description = "Security group for RDS MySQL access"
  vpc_id      = aws_vpc.main.id
  # Allow MySQL port access from anywhere (use a more restrictive source if needed)
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows all IPs; restrict this in production
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-security-group"
  }
}

resource "aws_db_instance" "mydb" {
  identifier             = "my-database"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  port                   = 3306
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]


  db_subnet_group_name = aws_db_subnet_group.subnet_group.name

  # Enable backup and retention policy
  backup_retention_period = 7
  skip_final_snapshot     = true


}

output "rds_endpoint" {
  value       = aws_db_instance.mydb.address
  description = "The private endpoint of the RDS instance."
}




