ssh-keygen -f ~/.clap/private/id_rsa
clapp cluster start cluster-t2.micro-[2-4-8]x
clapp cluster action <cluster-id> gromacs run --extra="amount=NUMBER" --nodes <master-id>
clapp cluster action <cluster-id>  gromacs fetch-result --nodes <master-id>

