resource "aci_tenant" "tenant" {
  name = "${var.tenant}"
}

resource "aci_vrf" "vrf" {
  tenant_dn = "${aci_tenant.tenant.id}"
  name      = "vrf"
}

resource "aci_bridge_domain" "bd" {
  tenant_dn          = "${aci_tenant.tenant.id}"
  relation_fv_rs_ctx = "${aci_vrf.vrf.name}"
  name               = "bd"
}

resource "aci_subnet" "bd_subnet" {
  bridge_domain_dn = "${aci_bridge_domain.bd.id}"
  name             = "Subnet"
  ip               = "${var.bd_subnet}"
}

resource "aci_application_profile" "app2" {
  tenant_dn = "${aci_tenant.tenant.id}"
  name      = "prod_app2"
}

resource "aci_application_epg" "epg1" {
  application_profile_dn = "${aci_application_profile.app2.id}"
  name                   = "epg1"
  relation_fv_rs_bd      = "${aci_bridge_domain.bd.name}"
  relation_fv_rs_dom_att = ["${var.vmm_domain_dn}"]
  relation_fv_rs_cons    = ["${aci_contract.contract_epg1_epg2.name}"]
}

resource "aci_application_epg" "epg2" {
  application_profile_dn = "${aci_application_profile.app2.id}"
  name                   = "epg2"
  relation_fv_rs_bd      = "${aci_bridge_domain.bd.name}"
  relation_fv_rs_dom_att = ["${var.vmm_domain_dn}"]
  relation_fv_rs_prov    = ["${aci_contract.contract_epg1_epg2.name}"]
}

resource "aci_contract" "contract_epg1_epg2" {
  tenant_dn = "${aci_tenant.tenant.id}"
  name      = "Web_app2"
}

resource "aci_contract_subject" "Web_subject1" {
  contract_dn                  = "${aci_contract.contract_epg1_epg2.id}"
  name                         = "Subject"
  relation_vz_rs_subj_filt_att = ["${aci_filter.allow_https.name}"]
}

resource "aci_filter" "allow_https" {
  tenant_dn = "${aci_tenant.tenant.id}"
  name      = "allow_https"
}

resource "aci_filter_entry" "https" {
  name        = "https"
  filter_dn   = "${aci_filter.allow_https.id}"
  ether_t     = "ip"
  prot        = "tcp"
  d_from_port = "https"
  d_to_port   = "https"
  stateful    = "yes"
}

output "app2" {
  value = "${aci_application_profile.app2.name}"
}

output "epg1" {
  value = "${aci_application_epg.epg1.name}"
}

output "epg2" {
  value = "${aci_application_epg.epg2.name}"
}
