# Instructions

## Generate up to date patch file

Run `tool/get_current_e2e_patch.sh` to generate a new patch file that goes from electric e2e to dart e2e.


## Update the e2e source from electric

Run `tool/update_e2e_files.sh` to update the e2e tests and files from electric. 

If there are any conflicts some files `<name>.rej` will be generated.
In order to fix this issues we can do.

`wiggle --replace <name> <name>.rej`

This will update the file `<name>` with Git like conflicts which can be resolved in the IDE. 