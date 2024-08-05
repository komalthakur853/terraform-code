# main.tf

# AWS Prod Network VPC
module "vpc_prod" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0" # Specify a version for better stability

  name            = "AWS-prod-Network"
  cidr            = var.vpc_prod_cidr
  azs             = data.aws_availability_zones.available.names
  private_subnets = var.vpc_prod_private_subnets
  public_subnets  = var.vpc_prod_public_subnets

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    Name        = "AWS-prod-Network"
    Terraform   = "true"
    Environment = "prod"
  }

  public_subnet_tags = {
    Name = "AWS-prod-public-subnet"
  }

  private_subnet_tags = {
    Name = "AWS-prod-private-subnet"
  }
}

# AWS Non-prod Network VPC
module "vpc_non_prod" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name            = "AWS-Non-prod-Network"
  cidr            = var.vpc_non_prod_cidr
  azs             = data.aws_availability_zones.available.names
  private_subnets = var.vpc_non_prod_private_subnets
  public_subnets  = var.vpc_non_prod_public_subnets

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    Name        = "AWS-Non-prod-Network"
    Terraform   = "true"
    Environment = "non-prod"
  }

  public_subnet_tags = {
    Name = "AWS-Non-prod-public-subnet"
  }

  private_subnet_tags = {
    Name = "AWS-Non-prod-private-subnet"
  }
}

# AWS Mgmt Network VPC
module "vpc_mgmt" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name            = "AWS-mgmt-Network"
  cidr            = var.vpc_mgmt_cidr
  azs             = data.aws_availability_zones.available.names
  private_subnets = var.vpc_mgmt_private_subnets
  public_subnets  = var.vpc_mgmt_public_subnets

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    Name        = "AWS-mgmt-Network"
    Terraform   = "true"
    Environment = "mgmt"
  }


  public_subnet_tags = {
    Name = "AWS-mgmt-public-subnet"
  }

  private_subnet_tags = {
    Name = "AWS-mgmt-private-subnet"
  }
}

# Security Group for Non-prod Network
module "non_prod_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "non-prod-sg"
  description = "Security group for non-prod network"
  vpc_id      = module.vpc_non_prod.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      description = "Redis"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      description = "Prometheus"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      description = "Grafana"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8001
      to_port     = 8001
      protocol    = "tcp"
      description = "Redis Insight"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name        = "non-prod-sg"
    Environment = "non-prod"
    Terraform   = "true"
  }
}

module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  for_each = {
    "redis_standalone" = {
      name          = "redis-standalone"
      instance_type = "t2.medium"
      subnet_id     = module.vpc_non_prod.private_subnets[0]
      ami           = data.aws_ami.redis.id
      public_ip     = false
    },
    "redis_sentinel" = {
      name          = "redis-sentinel"
      instance_type = "t2.medium"
      subnet_id     = module.vpc_non_prod.private_subnets[0]
      ami           = data.aws_ami.redis.id
      public_ip     = false
    },
    "redis_cluster" = {
      name          = "redis-cluster"
      instance_type = "t2.medium"
      subnet_id     = module.vpc_non_prod.private_subnets[0]
      ami           = data.aws_ami.redis.id
      public_ip     = false
    },
    "observability" = {
      name          = "observability"
      instance_type = "t2.micro"
      subnet_id     = module.vpc_non_prod.public_subnets[0]
      ami           = data.aws_ami.ubuntu.id
      public_ip     = true
    },
    "bastion" = {
      name          = "bastion"
      instance_type = "t2.medium"
      subnet_id     = module.vpc_non_prod.public_subnets[0]
      ami           = data.aws_ami.ubuntu.id
      public_ip     = true
    }
  }

  name = each.value.name

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  key_name                    = var.key_name
  monitoring                  = true
  vpc_security_group_ids      = [module.non_prod_sg.security_group_id]
  subnet_id                   = each.value.subnet_id
  associate_public_ip_address = each.value.public_ip
  user_data                   = each.key != "observability" ? file("/home/komal_jaiswal/AWS-Network/debian_dependency_installation.sh") : ""

  tags = {
    Name        = each.value.name
    Terraform   = "true"
    Environment = "non-prod"
  }
}

# Application Load Balancer
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name               = "non-prod-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc_non_prod.vpc_id
  subnets            = module.vpc_non_prod.public_subnets
  security_groups    = [module.non_prod_sg.security_group_id]

  target_groups = [
    {
      name_prefix      = "prom-"
      backend_protocol = "HTTP"
      backend_port     = 9090
      target_type      = "instance"
      targets = {
        observability = {
          target_id = module.ec2_instances["observability"].id
          port      = 9090
        }
      }
    },
    {
      name_prefix      = "graf-"
      backend_protocol = "HTTP"
      backend_port     = 3000
      target_type      = "instance"
      targets = {
        observability = {
          target_id = module.ec2_instances["observability"].id
          port      = 3000
        }
      }
    },
    {
      name_prefix      = "redis-"
      backend_protocol = "HTTP"
      backend_port     = 8001
      target_type      = "instance"
      targets = {
        redis_standalone = {
          target_id = module.ec2_instances["redis_standalone"].id
          port      = 8001
        }
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "non-prod"
  }
}
