# SERVER1: 'MASTER-SERVER' (with Jenkins, Maven, Docker, Ansible, Trivy)
# STEP1: CREATING A SECURITY GROUP FOR JENKINS SERVER
# Description: Allow SSH, HTTP, HTTPS, 8080, 8081
resource "aws_security_group" "my_security_group1" {
  name        = "my-security-group1"
  description = "Allow SSH, HTTP, HTTPS, 8080 for Jenkins & Maven"
  # SSH Inbound Rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH Outbound Rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# STEP2: CREATE AN JENKINS EC2 INSTANCE USING EXISTING PEM KEY
# Note: i. First create a pem-key manually from the AWS console
#      ii. Copy it in the same directory as your terraform code
resource "aws_instance" "my_ec2_instance1" {
  ami                    = "ami-02dfbd4ff395f2a1b"
  instance_type          = "t3a.medium"
  vpc_security_group_ids = [aws_security_group.my_security_group1.id]
  key_name               = "key-name" # paste your key-name here, do not use extension '.pem'

  # Consider EBS volume 30GB
  root_block_device {
    volume_size = 30    # Volume size 30 GB
    volume_type = "gp3" # General Purpose SSD
  }

  tags = {
    Name = "MASTER-SERVER"
  }
  user_data = <<-EOF
    #!/bin/bash
    # wait for 1min before EC2 initialization
    sleep 60
    sudo wget https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
    sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
    sudo yum install -y apache-maven
    sudo yum install java-1.8.0-devel -y
  EOF

  # STEP3: USING REMOTE-EXEC PROVISIONER TO INSTALL TOOLS
  provisioner "remote-exec" {
    # ESTABLISHING SSH CONNECTION WITH EC2
    connection {
      type        = "ssh"
      private_key = file("./key-name.pem") # replace with your key-name 
      user        = "ec2-user"
      host        = self.public_ip
    }

    inline = [
  # wait for 200sec before EC2 initialization
  "sleep 200",

  # Install Git 
  "sudo yum install -y git",

  # Install Jenkins
  "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
  "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key",
  "sudo yum install -y java-17-amazon-corretto",
  "sudo yum install -y jenkins",
  "sudo systemctl enable jenkins",
  "sudo systemctl start jenkins",

  # Install Maven (added)
  "sudo yum install -y maven",
  "mvn -version",

  # Install Docker
  "sudo yum update -y",
  "sudo yum install -y docker",
  "sudo systemctl start docker",
  "sudo systemctl enable docker",
  "sudo usermod -aG docker jenkins",
  "sudo chmod 666 /var/run/docker.sock",

  # Install Trivy
  "sudo rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.18.3/trivy_0.18.3_Linux-64bit.rpm",

  # Install Ansible
  "sudo yum update -y",
  "sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
  "sudo yum install -y git python python-devel python-pip openssl ansible"
]
  }
}

# STEP3: OUTPUT PUBLIC IP OF EC2 INSTANCE
output "ACCESS_YOUR_JENKINS_HERE" {
  value = "http://${aws_instance.my_ec2_instance1.public_ip}:8080"
}

output "Jenkins_Initial_Password" {
  value = "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
}

# STEP4: OUTPUT PUBLIC IP OF EC2 INSTANCE
output "MASTER_SERVER_PUBLIC_IP" {
  value = aws_instance.my_ec2_instance1.public_ip
}

# STEP5: OUTPUT PRIVATE IP OF EC2 INSTANCE
output "MASTER_SERVER_PRIVATE_IP" {
  value = aws_instance.my_ec2_instance1.private_ip
}
