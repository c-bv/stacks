# OVH Configuration

- Create a domain for the server
  - Go to your OVH dashboard: <https://www.ovh.com/manager/web/#/domain>
  - Select your domain name > go to "DNS Zone" > "Add an entry" > "A" > enter the subdomain "*" > target = IP of your server > "Next"
  
- Create access to the OVH API
  - Visit the website : <https://www.ovh.com/auth/api/createToken>
  - Fill in the various fields with the following values:
    - Application name: traefik
    - Description: traefik
    - Rights: POST /domain/zone/\* DELETE /domain/zone/\*
    - Validity: unlimited

  ```json
    {
        "accessRules": [
            {
                "method": "POST",
                "path": "/domain/zone/*"
            },
            {
                "method": "DELETE",
                "path": "/domain/zone/*"
            }
        ]
    }
  ```

  - Carefully note the following information:
    - Application key
    - Application secret
    - Consumer key
  - Go to <https://eu.api.ovh.com/console/> to check api status
