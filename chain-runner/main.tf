terraform {
  cloud {
    organization = "gabe-lab"

    workspaces {
      tags = ["multispace:chain-runner"]
    }
  }
  required_providers {
    tfe = {
      source = "hashicorp/tfe"

      # Latest fixes for tfe_workspace_run
      version = ">= 0.46.0"
    }
  }
}

variable "tfc_org" {
  type = string
}

provider "tfe" {
  organization = var.tfc_org
}


locals {
  workspaces = [
    "3-chain-A",
    "3-chain-B",
    "3-chain-C",
  ]
}

data "tfe_workspace" "ws" {
  for_each = toset(local.workspaces)
  name     = each.key
}

resource "tfe_workspace_run" "A" {
  workspace_id = data.tfe_workspace.ws["3-chain-A"].id

  apply {
    wait_for_run   = true
    manual_confirm = false
  }

  destroy {
    wait_for_run   = true
    manual_confirm = false
  }
}

resource "tfe_workspace_run" "B" {
  workspace_id = data.tfe_workspace.ws["3-chain-B"].id

  depends_on = [tfe_workspace_run.A]

  apply {
    wait_for_run   = true
    manual_confirm = false
  }

  destroy {
    wait_for_run   = true
    manual_confirm = false
  }
}

resource "tfe_workspace_run" "C" {
  workspace_id = data.tfe_workspace.ws["3-chain-C"].id

  depends_on = [tfe_workspace_run.B]

  apply {
    wait_for_run   = true
    manual_confirm = false
  }

  destroy {
    wait_for_run   = true
    manual_confirm = false
  }
}
