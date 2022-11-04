variables {
  ssh_username  = ""
  ssh_password  = ""
  ssh_host = ""

  step1_var =""
  step2_var ="" # Why do I have to declare this here?  I don't use it ANYWHERE in here.
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