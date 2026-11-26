output "all_public_ips" {
  description = "Public IP of every VM"
  value       = { for k, v in azurerm_public_ip.pip : k => v.ip_address }
}

output "lb_public_ip" {
  description = "Public IP of the load balancer (open this in your browser)"
  value       = azurerm_public_ip.pip["lb"].ip_address
}

output "web_private_ips" {
  description = "Private IPs of the web nodes (used by the LB config)"
  value       = { for k, v in azurerm_network_interface.nic : k => v.private_ip_address if startswith(k, "web") }
}

output "ssh_examples" {
  description = "Ready-to-use SSH commands"
  value       = { for k, v in azurerm_public_ip.pip : k => "ssh ${var.admin_username}@${v.ip_address}" }
}
