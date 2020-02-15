 output "nat_ip" {
  value = "${module.subnet_privat.public_ip}"
 }
output "Site_name" {
  value = "${module.alb.app_adress}"
}
