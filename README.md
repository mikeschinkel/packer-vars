# Packer Vars Example 

## Or, why does it have to be this hard?

This repo was created to provide an example to illustrate my comments on this Github issue for @nywilken who so graciously offered to understand the use-case and possibly even address the difficulty of my use-case.

## Use-case
Basically the use-case did the following, **each with its own `.pkr.hcl` file**. This process assumes an 'ova-builder` VM on VMware vCenter that will have been created by a different Packer template.

| Step      | Description                                                                  |
|-----------|------------------------------------------------------------------------------|
| `setup`   | Ensures the 'ova-builder` VM is running and the vCenter has required config. |
| `clean`   | Ensures the VM is in a clean state, e.g. prior artifacts deleted.            |
| `app`     | Build a GoLang app on the VM.                                                |
| `iso`     | Builds a Linux ISO containing the GoLang App.                                |
| `upload`  | Uploads the build ISO to a vCenter Datastore.                                |
| `install` | Installs the ISO to create a new 'App' VM on vCenter.                        |
| `export`  | Exports the App VM back down to 'ova-builder' as an OVA file.                |
| `jfrog`   | Uploads the resulant OVA to jFrog Artifactory.                               |


The above is even a simplification but is hopefully detailed enough to give a clear picture of the process.

## Example
Aside from the code being proprietary and owned by a former client it would be far too complex to serve as a clarifying example, so I create the simplest example I could to illustrate the problem.

This example has two (2) steps: `step1` and `step2` and their respective Packer templates are `./step1/step1.pkr.hcl` and `./step2/step2.pkr.hcl`.  The example also has a shared `/vars.json` which contains shared vars for logging into SSH and one var for each step, `step1_var=foo` and `step2_var=bar`, respectively. 

All these steps do is they both use the null builder to reach into a Linux machine via SSH and then run an inline script echoing their variable's value.

### Running the working example
To see this example work:

1. Make sure you have Packer installed _(of course)_,
2. Clone this repo to a macOS or Linux machine.
3. Ensure you are in the `working` branch, which is the repo's default.
4. Change the `ssh_*` properties in `./vars.json` to point to a host, user and password of a computer or VM you can SSH into, and then  
4. Run `make`


## The Problem
The problem is that Packer requires you to declare `step2_var` in `./step1/step1.pkr.hcl` even though /step1/step1.pkr.hcl` never references or otherwise uses `step2_var`, — as the following table illustrates:

| Step    | Packer Template         | Template Uses<br>property in<br>`./vars.json` | Template does<br>NOT use: |           
|---------|-------------------------|-----------------------------------------------|---------------------------|
| `step1` | `./step1/step1.pkr.hcl` | `step1_var=foo`                               | `step2_var`               |
| `step2` | `./step2/step2.pkr.hcl` | `step2_var=bar`                               | `step1_var`               |


### Running the "warnings" example

To experience the problem this repo is trying to illustrate:

1. Make sure performed the steps for the `working` example first.
2. Checkout the `warnings` branch.
2. Run `make`


You should get the following output; notice the **warnings**:

```
packer build -force -var-file="./vars.json" "step1"
Warning: Undefined variable

A "step2_var" variable was set but was not found in known variables. To declare
variable "step2_var", place this block in one of your .pkr files, such as
variables.pkr.hcl


null.step2: output will be in this color.

==> null.step2: Using SSH communicator to connect: iso-builder.local
==> null.step2: Waiting for SSH to become available...
==> null.step2: Connected to SSH!
==> null.step2: Provisioning with shell script: /var/folders/fg/1dfmwyrx3wxbhj5lbdqpt7bw0000gn/T/packer-shell1383820945
    null.step2: We are running step 'foo'
Build 'null.step2' finished after 658 milliseconds 319 microseconds.

==> Wait completed after 658 milliseconds 394 microseconds

==> Builds finished. The artifacts of successful builds are:
--> null.step2: Did not export anything. This is the null builder
packer build -force -var-file="./vars.json" "step2"
Warning: Undefined variable

A "step1_var" variable was set but was not found in known variables. To declare
variable "step1_var", place this block in one of your .pkr files, such as
variables.pkr.hcl


null.step2: output will be in this color.

==> null.step2: Using SSH communicator to connect: iso-builder.local
==> null.step2: Waiting for SSH to become available...
==> null.step2: Connected to SSH!
==> null.step2: Provisioning with shell script: /var/folders/fg/1dfmwyrx3wxbhj5lbdqpt7bw0000gn/T/packer-shell2044896123
    null.step2: We are running step 'bar'
Build 'null.step2' finished after 373 milliseconds 507 microseconds.

==> Wait completed after 373 milliseconds 568 microseconds

==> Builds finished. The artifacts of successful builds are:
--> null.step2: Did not export anything. This is the null builder

```

## The Desired Solution

Simply provide a command-line switch that will suppress those warnings.

## Epilogue

I tested this in Packer `1.18.3` but I _swear_ that earlier versions of Packer threw errors and failed to buiild instead of throwing warnings. Or at least that is what I remember. 

So a warning is not as bad as an error, and if it never threw an error and always provided a warning then, as they say, my bad. 

But still, a command-line switch to suppress would be much appreciated.