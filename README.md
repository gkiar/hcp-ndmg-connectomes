# hcp-ndmg-connectomes
Instructions for running HCP data with ndmg (functional and diffusion) on AWS with Clowdr/Boutiques

Links:
- https://github.com/gkiar/hcp-ndmg-connectomes
- To log in to the console: https://console.aws.amazon.com
- To check the usage: log in with email and check the billing dashboard
- To describe tools: https://boutiques.github.io
- To launch tools: https://clowdr.github.io

AWS dictionary:
- EC2/ECS: shows what computers are running/turned on
- Batch: manages your cluster
- S3: manages your storage
- IAM: manages your users
- Cloudwatch: monitors your logs

Using Clowdr:


... On Amazon:

    clowdr cloud <tool-descriptor.json> \
                 <tool-inputs.json> \
                 s3://<path-to-clowdr-outputs> \
                 s3://<path-to-input-data> \
                 aws \
                 <path-to-aws-credentials.csv> \
                 -Vb \
                 --region us-east-1

... On Compute Canada:

    clowdr local <tool-descriptor.json> \
                 <tool-inputs.json> \
                 <path-to-clowdr-outputs> \
                 --cluster slurm \
                 -bV \
                 --simg ~/bids-ndmg.simg \
                 -a account:rpp-aevans-ab,time:2:00:00,mem=18G \
                 -v /project/6013484/gkiar/:/project/6013484/gkiar/



(`-Vb` makes it verbose and BIDS-aware)
