variables {
  ssh_username  = ""
  ssh_password  = ""
  ssh_host = ""

  step1_var =""
  #step2_var =""   Commenting this out generates warnings
}

source "null" "step2" {
  ssh_host     = "${var.ssh_host}"
  ssh_password = "${var.ssh_password}"
  ssh_username = "${var.ssh_username}"
}

build {
  sources = ["sources.null.step2"]
  provisioner "shell" {
    inline = [
      "echo \"We are running step '${var.step1_var}'\""
    ]
  }
}