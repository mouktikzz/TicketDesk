# Import blocks make the first plan an adoption plan, not a create plan.
# Do not run apply until the plan shows no unintended changes.
import {
  to = aws_vpc.ticketdesk
  id = "vpc-0b1b561ab96fac233"
}
import {
  to = aws_internet_gateway.ticketdesk
  id = "igw-051852b098253d222"
}
import {
  to = aws_subnet.public[0]
  id = "subnet-02365ec9f4ac98e0b"
}
import {
  to = aws_subnet.public[1]
  id = "subnet-09ec75640e87cc03d"
}
import {
  to = aws_subnet.private[0]
  id = "subnet-0dadaf935dad3815a"
}
import {
  to = aws_subnet.private[1]
  id = "subnet-0af74b97645e131a1"
}
import {
  to = aws_route_table.public
  id = "rtb-0b756795f5d41bbb5"
}
import {
  to = aws_route_table.private
  id = "rtb-0ccf32fe796dd924f"
}
import {
  to = aws_route.public_internet
  id = "rtb-0b756795f5d41bbb5_0.0.0.0/0"
}
import {
  to = aws_route_table_association.public[0]
  id = "subnet-02365ec9f4ac98e0b/rtb-0b756795f5d41bbb5"
}
import {
  to = aws_route_table_association.public[1]
  id = "subnet-09ec75640e87cc03d/rtb-0b756795f5d41bbb5"
}
import {
  to = aws_route_table_association.private[0]
  id = "subnet-0dadaf935dad3815a/rtb-0ccf32fe796dd924f"
}
import {
  to = aws_route_table_association.private[1]
  id = "subnet-0af74b97645e131a1/rtb-0ccf32fe796dd924f"
}
import {
  to = aws_security_group.alb
  id = "sg-00e87eebde7f90e50"
}
import {
  to = aws_security_group.api
  id = "sg-0534bba921f1dd6fb"
}
import {
  to = aws_security_group.database
  id = "sg-0d0bdccef1aa8c682"
}
import {
  to = aws_vpc_security_group_ingress_rule.alb_http
  id = "sgr-0256ce36db294c283"
}
import {
  to = aws_vpc_security_group_ingress_rule.alb_https
  id = "sgr-0a1ed21c89732c5bd"
}
import {
  to = aws_vpc_security_group_ingress_rule.api_from_alb
  id = "sgr-07a8dd44510b33f8a"
}
import {
  to = aws_vpc_security_group_ingress_rule.database_from_api
  id = "sgr-09a0b5a63ad45cd6a"
}
