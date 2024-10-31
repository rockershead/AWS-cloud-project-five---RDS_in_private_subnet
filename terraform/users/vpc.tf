
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = "${var.vpc_name}_tf"
  }
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "${var.vpc_name}_rds_subnet_group"
  subnet_ids = tolist(aws_subnet.private_subnets[*].id)


}


resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.vpc_name}_private_${count.index + 1}"
  }
}

resource "aws_security_group" "lambda_security_group" {

  name = "${var.vpc_name}_lambdas_sg"

  vpc_id = aws_vpc.main.id



  ingress {

    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "any"

  }


  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

}



