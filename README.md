# aws-terraform

# lambda

•	To get your instance retrieved by the Lambda function you need to add tags to it.

•	We use a ec2 instance name “diablo”

•	In this script, I've used Key: `stop` and Value : `StopWeekDays` You can modify it as per your choice.

•	Note: Cron expressions are evaluated in UTC. Be sure to adjust the expression for your preferred time zone.
  Here we set server "diablo" will shut down @12:00 UTC
