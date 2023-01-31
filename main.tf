locals {
  tailscale_tags = [for k, v in module.this.tags : "tag:${v}" if k == "Name"]
}

data "template_file" "userdata" {
  template = file("${path.module}/userdata.sh.tpl")
  vars = {
    routes   = join(",", var.advertise_routes)
    authkey  = tailscale_tailnet_key.default.key
    hostname = module.this.id
  }
}

module "tailscale_subnet_router" {
  source = "git::https://github.com/masterpointio/terraform-aws-ssm-agent.git?ref=tags/0.15.1"

  context = module.this.context
  tags    = module.this.tags

  vpc_id                    = var.vpc_id
  subnet_ids                = var.subnet_ids
  key_pair_name             = var.key_pair_name
  create_run_shell_document = var.create_run_shell_document

  session_logging_kms_key_alias     = var.session_logging_kms_key_alias
  session_logging_enabled           = var.session_logging_enabled
  session_logging_ssm_document_name = var.session_logging_ssm_document_name

  ami            = var.ami
  instance_type  = var.instance_type
  instance_count = var.instance_count

  user_data = base64encode(length(var.user_data) > 0 ? var.user_data : data.template_file.userdata.rendered)
}

resource "tailscale_tailnet_key" "default" {
  reusable      = var.reusable
  ephemeral     = var.ephemeral
  preauthorized = var.preauthorized
  expiry        = var.expiry

  # A device is automatically tagged when it is authenticated with this key.
  tags = local.tailscale_tags
}