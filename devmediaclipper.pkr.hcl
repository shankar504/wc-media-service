packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = " >=0.0.2 "
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "media-clipper" {
  region      = "us-west-2"
  source_ami = "ami-0456132376dc9918b"
  instance_type = "t2.micro"
  ssh_username = "ec2-user"
  vpc_id      = "vpc-012ae848bc2ca2e2a"
  subnet_id    = "subnet-0971a7fd49754b2bf"
  ami_name = "DevMediaClipperService-VERNAME-${local.timestamp}"
  ssh_keypair_name = "NonprodDuclo"
  ssh_private_key_file   = "/opt/.secret/NonprodDuclo.pem"

}

build {
  sources = [
    "source.amazon-ebs.media-clipper"
  ]

  provisioner "shell" {
    inline = [
      "export HOME=/home/ec2-user/",
      "cd /home/ec2-user",
      "sudo rm -rf dev github out-1690882604-1534.ts stressTesting stressTesting.zip poc",
      "sudo systemctl stop media-clipper-service.service",
      "sudo rm -rf /home/ec2-user/ffmpeg_build",
      "git clone -b BRANCHNAME https://duclo-cloudops:XXXXXXXXX@github.com/duclo/media-clipper-service.git",
      "sudo wget -O /home/ec2-user/ffmpeg_build.zip --user=media-repo --password=XXXXXXXXXXX https://repository.duclo.net/repository/duclo-media/dev/clipperservice/ffmpeg_build-latest.zip",
      "cd /home/ec2-user",
      "sudo unzip ffmpeg_build.zip",
      "sudo rm -rf /home/ec2-user/ClipperService/clipperservice /home/ec2-user/ffmpeg_build.zip",
      "sudo mv /home/ec2-user/media-clipper-service /home/ec2-user/ClipperService/clipperservice",
      "sudo systemctl start media-clipper-service.service",
    ]
  }

  post-processor "manifest" {
    output = "devmediaclipper.json"
    strip_path = true
  }
}
