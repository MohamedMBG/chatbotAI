# ChatbotAI Networking Module
# VPC and networking infrastructure

#==============================================================================
# VPC (VIRTUAL PRIVATE CLOUD)
#==============================================================================

resource "digitalocean_vpc" "main" {
  name     = "${var.name_prefix}-vpc"
  region   = var.region
  ip_range = var.vpc_cidr
  
  description = "Private network for ChatbotAI ${var.environment} environment"
}

#==============================================================================
# FIREWALL RULES
#==============================================================================

# Web application firewall (allows HTTP/HTTPS traffic)
resource "digitalocean_firewall" "web" {
  name = "${var.name_prefix}-web-fw"
  
  # Allow HTTP traffic from anywhere
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  # Allow HTTPS traffic from anywhere
  inbound_rule {
    protocol         = "tcp"  
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  # Allow API traffic on port 8000
  inbound_rule {
    protocol         = "tcp"
    port_range       = "8000"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  # Allow SSH for emergency access (restrict to specific IPs in production)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22" 
    source_addresses = var.allowed_ssh_ips
  }
  
  # Allow all outbound traffic
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  tags = [
    "${var.environment}",
    "web-tier",
    "chatbotai"
  ]
}

# Database firewall (only allows internal VPC traffic)
resource "digitalocean_firewall" "database" {
  name = "${var.name_prefix}-db-fw"
  
  # PostgreSQL access from VPC only
  inbound_rule {
    protocol    = "tcp"
    port_range  = "5432"
    source_tags = ["${var.environment}", "app-tier"]
  }
  
  # Redis access from VPC only
  inbound_rule {
    protocol    = "tcp"
    port_range  = "6379" 
    source_tags = ["${var.environment}", "app-tier"]
  }
  
  # Allow outbound for backups and updates
  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0"]
  }
  
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0"]
  }
  
  tags = [
    "${var.environment}",
    "database-tier", 
    "chatbotai"
  ]
}

#==============================================================================
# LOAD BALANCER (if needed for high availability)
#==============================================================================

# Create load balancer for production environment
resource "digitalocean_loadbalancer" "main" {
  count = var.environment == "production" ? 1 : 0
  
  name     = "${var.name_prefix}-lb"
  region   = var.region
  vpc_uuid = digitalocean_vpc.main.id
  
  # HTTPS forwarding rule
  forwarding_rule {
    entry_protocol  = "https"
    entry_port      = 443
    target_protocol = "http"
    target_port     = 8000
    certificate_name = var.ssl_certificate_name != "" ? var.ssl_certificate_name : null
    tls_passthrough = false
  }
  
  # HTTP forwarding rule (redirect to HTTPS)
  forwarding_rule {
    entry_protocol  = "http"
    entry_port      = 80
    target_protocol = "http"
    target_port     = 8000
  }
  
  # Health check configuration
  healthcheck {
    protocol               = "http"
    port                   = 8000
    path                   = "/api/health"
    check_interval_seconds = 10
    response_timeout_seconds = 5
    unhealthy_threshold    = 3
    healthy_threshold      = 2
  }
  
  # Sticky sessions for adult content (user preference continuity)
  sticky_sessions {
    type               = "cookies"
    cookie_name        = "chatbotai_session"
    cookie_ttl_seconds = 3600
  }
  
  # Enable PROXY protocol for real IP addresses
  enable_proxy_protocol = true
  
  # Security: Disable HTTP/2 for better control (optional)
  disable_lets_encrypt_dns_records = false
}

#==============================================================================
# DOMAIN RECORDS (if managing DNS through DigitalOcean)
#==============================================================================

# Only create domain records if managing DNS through DO
resource "digitalocean_domain" "main" {
  count = var.manage_dns ? 1 : 0
  
  name = var.domain_name
}

# A record pointing to load balancer or app platform
resource "digitalocean_record" "main" {
  count = var.manage_dns ? 1 : 0
  
  domain = digitalocean_domain.main[0].name
  type   = "A"
  name   = var.environment == "production" ? "@" : var.environment
  value  = var.environment == "production" && length(digitalocean_loadbalancer.main) > 0 ? digitalocean_loadbalancer.main[0].ip : var.app_platform_ip
  ttl    = 3600
}

# CNAME for www subdomain
resource "digitalocean_record" "www" {
  count = var.manage_dns && var.environment == "production" ? 1 : 0
  
  domain = digitalocean_domain.main[0].name
  type   = "CNAME" 
  name   = "www"
  value  = "${digitalocean_domain.main[0].name}."
  ttl    = 3600
}

# CNAME for API subdomain
resource "digitalocean_record" "api" {
  count = var.manage_dns ? 1 : 0
  
  domain = digitalocean_domain.main[0].name
  type   = "CNAME"
  name   = "api"
  value  = var.environment == "production" ? "${digitalocean_domain.main[0].name}." : "${var.environment}.${digitalocean_domain.main[0].name}."
  ttl    = 3600
}

#==============================================================================
# RESERVED IP (for production stability)
#==============================================================================

resource "digitalocean_reserved_ip" "main" {
  count  = var.environment == "production" ? 1 : 0
  region = var.region
  type   = "assign"
}

#==============================================================================
# MONITORING ENDPOINTS
#==============================================================================

# Create monitoring checks for network endpoints
resource "digitalocean_monitor_alert" "load_balancer_health" {
  count = var.environment == "production" && length(digitalocean_loadbalancer.main) > 0 ? 1 : 0
  
  alerts {
    email = [var.alert_email]
    slack {
      channel = "#infrastructure-alerts"
      url     = var.slack_webhook_url
    }
  }
  
  window      = "5m"
  type        = "v1/insights/droplet/load_1"
  compare     = "GreaterThan"
  value       = 3
  enabled     = true
  entities    = []
  description = "${var.environment} load balancer health check"
}