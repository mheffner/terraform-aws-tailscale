#################################
## Subnet Router EC2 Instance ##
###############################

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC which the Tailscale Subnet Router EC2 instance will run in."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The Subnet IDs which the Tailscale Subnet Router EC2 instance will run in. These *should* be private subnets."
}

variable "additional_security_group_ids" {
  default     = []
  type        = list(string)
  description = "Additional Security Group IDs to associate with the Tailscale Subnet Router EC2 instance."
}

variable "create_run_shell_document" {
  default     = true
  type        = bool
  description = "Whether or not to create the SSM-SessionManagerRunShell SSM Document."
}

variable "session_logging_enabled" {
  default     = true
  type        = bool
  description = <<EOF
  To enable CloudWatch and S3 session logging or not.
  Note this does not apply to SSH sessions as AWS cannot log those sessions.
  EOF
}

variable "session_logging_kms_key_alias" {
  default     = "alias/session_logging"
  type        = string
  description = <<EOF
  Alias name for `session_logging` KMS Key.
  This is only applied if 2 conditions are met: (1) `session_logging_kms_key_arn` is unset,
  (2) `session_logging_encryption_enabled` = true.
  EOF
}


variable "session_logging_ssm_document_name" {
  default     = "SSM-SessionManagerRunShell-Tailscale"
  type        = string
  description = <<EOF
  Name for `session_logging` SSM document.
  This is only applied if 2 conditions are met: (1) `session_logging_enabled` = true,
  (2) `create_run_shell_document` = true.
  EOF
}

variable "key_pair_name" {
  default     = null
  type        = string
  description = "The name of the key-pair to associate with the Tailscale Subnet Router EC2 instance."
}

variable "user_data" {
  default     = ""
  type        = string
  description = <<EOF
  The user_data to use for the Tailscale Subnet Router EC2 instance.
  You can use this to automate installation of all the required command line tools.
  EOF
}

variable "ami" {
  default     = ""
  type        = string
  description = <<EOF
  The AMI to use for the Tailscale Subnet Router EC2 instance.
  If not provided, the latest Amazon Linux 2 AMI will be used.
  Note: This will update periodically as AWS releases updates to their AL2 AMI.
  Pin to a specific AMI if you would like to avoid these updates.
  EOF
}

variable "instance_type" {
  default     = "t3.nano"
  type        = string
  description = "The instance type to use for the Tailscale Subnet Router EC2 instance."
}

variable "instance_count" {
  default     = 1
  type        = number
  description = "The number of Tailscale Subnet Router EC2 instances you would like to deploy."
}

################
## Tailscale ##
##############

variable "advertise_routes" {
  default     = []
  type        = list(string)
  description = <<EOF
  The routes (expressed as CIDRs) to advertise as part of the Tailscale Subnet Router.
  Example: ["10.0.2.0/24", "0.0.1.0/24"]
  EOF
  validation {
    condition     = can([for route in var.advertise_routes : cidrsubnet(route, 0, 0)])
    error_message = "All elements in the list must be valid CIDR blocks."
  }
}

variable "expiry" {
  default     = 7776000
  type        = number
  description = "The expiry of the auth key in seconds."
}

variable "preauthorized" {
  default     = true
  type        = bool
  description = "Determines whether or not the machines authenticated by the key will be authorized for the tailnet by default."
}

variable "ephemeral" {
  default     = false
  type        = bool
  description = "Indicates if the key is ephemeral."
}

variable "reusable" {
  default     = true
  type        = bool
  description = " Indicates if the key is reusable or single-use."
}
