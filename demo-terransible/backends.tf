terraform {
  cloud {

    organization = "vcdemo-terransible"

    workspaces {
      name = "terransible"
    }
  }
}
