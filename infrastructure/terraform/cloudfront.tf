# ============================================================
# M4 - Frontend S3 + CloudFront + ALB API routing
# ============================================================

resource "aws_s3_bucket" "frontend" {
  bucket        = "ticketdesk-frontend-956118719056"
  force_destroy = true

  tags = {
    Name        = "ticketdesk-frontend"
    Project     = "ticketdesk"
    Owner       = "Mouktik"
    Environment = "dev"
    CostCenter  = "TicketDesk"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# ============================================================
# CloudFront Origin Access Control
# TEMPORARILY DISABLED
# AWS account verification required
# ============================================================

# resource "aws_cloudfront_origin_access_control" "frontend" {
#   name                              = "ticketdesk-frontend-oac"
#   description                       = "CloudFront access to private TicketDesk frontend S3 bucket"
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }


# ============================================================
# S3 bucket policy
# TEMPORARILY DISABLED
# Depends on CloudFront distribution
# ============================================================

# data "aws_iam_policy_document" "frontend_bucket_policy" {
#   statement {
#     sid    = "AllowCloudFrontReadOnly"
#     effect = "Allow"
#
#     principals {
#       type        = "Service"
#       identifiers = ["cloudfront.amazonaws.com"]
#     }
#
#     actions = [
#       "s3:GetObject"
#     ]
#
#     resources = [
#       "${aws_s3_bucket.frontend.arn}/*"
#     ]
#
#     condition {
#       test     = "StringEquals"
#       variable = "AWS:SourceArn"
#
#       values = [
#         aws_cloudfront_distribution.ticketdesk.arn
#       ]
#     }
#   }
# }

# resource "aws_s3_bucket_policy" "frontend" {
#   bucket = aws_s3_bucket.frontend.id
#   policy = data.aws_iam_policy_document.frontend_bucket_policy.json
# }


# ============================================================
# CloudFront Distribution
# TEMPORARILY DISABLED
# AWS account verification required
# ============================================================

# resource "aws_cloudfront_distribution" "ticketdesk" {
#   enabled             = true
#   comment             = "TicketDesk frontend and API"
#   default_root_object = "index.html"
#
#   # ----------------------------------------------------------
#   # S3 frontend origin
#   # ----------------------------------------------------------
#
#   origin {
#     domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
#     origin_id                = "ticketdesk-frontend-s3"
#     origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
#   }
#
#   # ----------------------------------------------------------
#   # Existing ALB API origin
#   # ----------------------------------------------------------
#
#   origin {
#     domain_name = data.aws_lb.app.dns_name
#     origin_id   = "ticketdesk-api-alb"
#
#     custom_origin_config {
#       http_port              = 80
#       https_port             = 443
#       origin_protocol_policy = "http-only"
#       origin_ssl_protocols   = ["TLSv1.2"]
#     }
#   }
#
#   # ----------------------------------------------------------
#   # Default behavior - frontend from S3
#   # ----------------------------------------------------------
#
#   default_cache_behavior {
#     target_origin_id       = "ticketdesk-frontend-s3"
#     viewer_protocol_policy = "redirect-to-https"
#
#     allowed_methods = [
#       "GET",
#       "HEAD",
#       "OPTIONS"
#     ]
#
#     cached_methods = [
#       "GET",
#       "HEAD"
#     ]
#
#     forwarded_values {
#       query_string = false
#
#       cookies {
#         forward = "none"
#       }
#     }
#
#     min_ttl     = 0
#     default_ttl = 86400
#     max_ttl     = 31536000
#   }
#
#   # ----------------------------------------------------------
#   # /api/* - send requests to existing ALB
#   # ----------------------------------------------------------
#
#   ordered_cache_behavior {
#     path_pattern           = "/api/*"
#     target_origin_id       = "ticketdesk-api-alb"
#     viewer_protocol_policy = "redirect-to-https"
#
#     allowed_methods = [
#       "DELETE",
#       "GET",
#       "HEAD",
#       "OPTIONS",
#       "PATCH",
#       "POST",
#       "PUT"
#     ]
#
#     cached_methods = [
#       "GET",
#       "HEAD"
#     ]
#
#     forwarded_values {
#       query_string = true
#
#       headers = [
#         "Authorization",
#         "Content-Type",
#         "Origin",
#         "Accept"
#       ]
#
#       cookies {
#         forward = "all"
#       }
#     }
#
#     min_ttl     = 0
#     default_ttl = 0
#     max_ttl     = 0
#   }
#
#   # ----------------------------------------------------------
#   # SPA fallback
#   # ----------------------------------------------------------
#
#   custom_error_response {
#     error_code         = 403
#     response_code      = 200
#     response_page_path = "/index.html"
#   }
#
#   custom_error_response {
#     error_code         = 404
#     response_code      = 200
#     response_page_path = "/index.html"
#   }
#
#   # ----------------------------------------------------------
#   # Restrictions
#   # ----------------------------------------------------------
#
#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }
#
#   # ----------------------------------------------------------
#   # CloudFront default HTTPS certificate
#   # ----------------------------------------------------------
#
#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }
#
#   # ----------------------------------------------------------
#   # Required tags
#   # ----------------------------------------------------------
#
#   tags = {
#     Name        = "ticketdesk-cloudfront"
#     Project     = "ticketdesk"
#     Owner       = "Mouktik"
#     Environment = "dev"
#     CostCenter  = "TicketDesk"
#   }
# }


# ============================================================
# CloudFront Outputs
# TEMPORARILY DISABLED
# ============================================================

# output "cloudfront_distribution_id" {
#   description = "TicketDesk CloudFront distribution ID"
#   value       = aws_cloudfront_distribution.ticketdesk.id
# }

# output "cloudfront_domain_name" {
#   description = "TicketDesk CloudFront domain"
#   value       = aws_cloudfront_distribution.ticketdesk.domain_name
# }


# ============================================================
# Frontend Files
# Upload frontend files to the S3 bucket
# ============================================================

locals {
  frontend_files = fileset(
    "${path.module}/../../TicketDeck_Frontend",
    "**/*"
  )

  frontend_mime_types = {
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    json = "application/json"
    png  = "image/png"
    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    svg  = "image/svg+xml"
    ico  = "image/x-icon"
    txt  = "text/plain"
  }
}

resource "aws_s3_object" "frontend" {
  for_each = local.frontend_files

  bucket = aws_s3_bucket.frontend.id

  key    = each.value
  source = "${path.module}/../../TicketDeck_Frontend/${each.value}"

  etag = filemd5(
    "${path.module}/../../TicketDeck_Frontend/${each.value}"
  )

  content_type = lookup(
    local.frontend_mime_types,
    lower(element(split(".", each.value), length(split(".", each.value)) - 1)),
    "application/octet-stream"
  )
}