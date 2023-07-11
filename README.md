# Object Storage (S3) Terraform module for Yandex.Cloud

## Features

- Create an service account with `storage.admin` permissions to create a Bucket.
- Create a KMS key for encryption.
- Create the Bucket.
- Apply the Bucket Policy.
- Apply the Bucket Policy for Yandex Cloud Console.
- Apply CORS rules.
- Apply predefined acl or grant permissions.
- Enable website hosting.
- Enable versioning and object lock.
- Enable objects lifecycle.
- Enable logging.
- Enable server-side encryption.

### Service account

The module allows you to configure a service account using a `storage_admin_service_account` variable.  
By default, the variable is set to an empty map. In this case, the module will automatically:
- create a service account with the `storage-admin` name prefix
- create a static access key for the account
- grant `storage.admin` permissions to the created service account  

You can specify the name of the service account to be created or change the name prefix.

You can also specify an existing service account with `storage.admin` permissions to create a bucket.  
> An existing service account must be in the same folder where the bucket will be created.  

In this case, the module will NOT automatically create a service account, will NOT create a static access key, and will NOT be given `storage.admin` permissions to the service account.

### Bucket policy

By default, bucket policy is not enabled.  
You can set the policy in a `policy` variable. Bucket policy for the Yandex Cloud Console can only be set in a separate `policy_console` variable.  
There are several use cases here:
- If `policy_console` is enabled and `policy` is enabled, access will be configured both from Yandex Cloud Console and from other sources.

- If `policy` is enabled, but `policy_console` is not enabled, then the policy will be set. Access to the bucket from Yandex Cloud Console will be denied.

- If `policy_console` is enabled, but `policy` is not enabled, then only access from Yandex Cloud Console will be configured.  

> An allowing rule for the storage admin service account will be automatically added to the policy in all cases so that Terraform does not lose access to the bucket.

When `policy_console` is enabled but no principals are defined, then all principals can have access.
```tf
policy_console = {
  enabled = true
}
```

### Server-side encryption

By default, bucket encryption is not enabled.
The module allows you to enable bucket encryption using a `server_side_encryption_configuration` variable.  
```tf
server_side_encryption_configuration = {
  enabled = true
}
```
In this case, a KMS key will be automatically generated, the service account will granted `kms.keys.encrypterDecrypter` permissions, and bucket encryption will be enabled.
> If an existing service account is used, then `kms.keys.encrypterDecrypter` permissions will NOT be automatically granted to it.  

The parameters of the KMS key that will be automatically generated can be defined in the `sse_kms_key_configuration` variable.  

You can also specify an existing KMS key.  
> An existing KMS key must be in the same folder where the bucket will be created.  
```tf
server_side_encryption_configuration = {
  enabled = true
  kms_master_key_id = "abjitgs2vjxxxxxxxxxx"
}
```

### HTTPS certificate for bucket.

By default, https certificate for bucket is not enabled.  
The module allows you to set an existing certificate from Yandex Cloud Certificate Manager.  
```tf
https = {
  existing_certificate_id = "crtitgs2vjxxxxxxxxxx"
}
```

The module also allows you to create a managed Let's Encrypt certificate in Yandex Cloud Certificate Manager.  
In this case, you must specify the list of certificate domains and the ID of the public Yandex Cloud DNS zone in which the corresponding records for validation will be created.  
```tf
https = {
  certificate = {
    domains = ["one.example.com", "two.example.com"]
    public_dns_zone_id = "dnsitgs2vjxxxxxxxxxx"
  }
}
```
You can also define other certificate options such as name, name prefix, description, etc.

## How to configure Terraform to use a module

- Install [YC CLI](https://cloud.yandex.com/docs/cli/quickstart)
- Add environment variables for terraform auth in Yandex.Cloud

```bash
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

- The module requires the mandatory configuration of the AWS provider, otherwise there will be an error.  
Create a `provider.tf` file with the following content:

```tf
provider "aws" {
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}
```

## Best practices

The recommended bucket configuration is shown in the example [hardening](./examples/hardening/)

### Examples

See [examples section](./examples/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | > 3.3 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | 0.92 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | > 3.3 |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.92 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_string.unique_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [yandex_cm_certificate.this](https://registry.terraform.io/providers/yandex-cloud/yandex/0.92/docs/resources/cm_certificate) | resource |
| [yandex_dns_recordset.this](https://registry.terraform.io/providers/yandex-cloud/yandex/0.92/docs/resources/dns_recordset) | resource |
| [yandex_iam_service_account.storage_admin](https://registry.terraform.io/providers/yandex-cloud/yandex/0.92/docs/resources/iam_service_account) | resource |
| [yandex_iam_service_account_static_access_key.storage_admin](https://registry.terraform.io/providers/yandex-cloud/yandex/0.92/docs/resources/iam_service_account_static_access_key) | resource |
| [yandex_kms_symmetric_key.this](https://registry.terraform.io/providers/yandex-cloud/yandex/0.92/docs/resources/kms_symmetric_key) | resource |
| [yandex_resourcemanager_folder_iam_member.kms_storage_admin_sa](https://registry.terraform.io/providers/yandex-cloud/yandex/0.92/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.storage_admin](https://registry.terraform.io/providers/yandex-cloud/yandex/0.92/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_storage_bucket.this](https://registry.terraform.io/providers/yandex-cloud/yandex/0.92/docs/resources/storage_bucket) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [yandex_client_config.client](https://registry.terraform.io/providers/yandex-cloud/yandex/0.92/docs/data-sources/client_config) | data source |
| [yandex_iam_service_account.existing_account](https://registry.terraform.io/providers/yandex-cloud/yandex/0.92/docs/data-sources/iam_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acl"></a> [acl](#input\_acl) | (Optional) The predefined ACL to apply. Defaults to `private`. Conflicts with `grant` object.<br>    To change ACL after creation, service account with `storage.admin` role should be used, though this role is not necessary to create a bucket with any ACL.<br>    For more information see https://cloud.yandex.com/en/docs/storage/concepts/acl#predefined-acls. | `string` | `null` | no |
| <a name="input_anonymous_access_flags"></a> [anonymous\_access\_flags](#input\_anonymous\_access\_flags) | (Optional) Object provides various access to objects.<br>    For more information see https://cloud.yandex.com/en/docs/storage/operations/buckets/bucket-availability.<br><br>    Configuration attributes:<br>      list        - (Optional) Allows to read objects in bucket anonymously.<br>      read        - (Optional) Allows to list object in bucket anonymously.<br>      config\_read - (Optional) Allows to list bucket configuration anonymously.<br><br>    It will try to create bucket using IAM-token in provider config, not using access\_key. | <pre>object({<br>    list        = optional(bool)<br>    read        = optional(bool)<br>    config_read = optional(bool)<br>  })</pre> | `null` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | (Required) The name of the bucket. | `string` | `null` | no |
| <a name="input_cors_rule"></a> [cors\_rule](#input\_cors\_rule) | (Optional) List of objets containing rules for Cross-Origin Resource Sharing.<br>    For more information see https://cloud.yandex.com/en/docs/storage/concepts/cors.<br><br>    Configuration attributes:<br>      allowed\_headers - (Optional) Specifies which headers are allowed.<br>      allowed\_methods - (Required) Specifies which methods are allowed. Can be `GET`, `PUT`, `POST`, `DELETE` or `HEAD` (case sensitive).<br>      allowed\_origins - (Required) Specifies which origins are allowed.<br>      expose\_headers  - (Optional) Specifies expose header in the response.<br>      max\_age\_seconds - (Optional) Specifies time in seconds that browser can cache the response for a preflight request. | <pre>list(object({<br>    allowed_headers = optional(set(string))<br>    allowed_methods = set(string)<br>    allowed_origins = set(string)<br>    expose_headers  = optional(set(string))<br>    max_age_seconds = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_default_storage_class"></a> [default\_storage\_class](#input\_default\_storage\_class) | (Optional) Storage class which is used for storing objects by default.<br>    For more information see https://cloud.yandex.com/en/docs/storage/concepts/storage-class.<br><br>    Available values are: `STANDARD`, `COLD`, `ICE`. Default is `STANDARD`.<br>    It will try to create bucket using IAM-token in provider block, not using access\_key. | `string` | `"STANDARD"` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | (Optional) The ID of the Yandex Cloud Folder that the resources belongs to.<br><br>    Allows to create bucket in different folder.<br>    It will try to create bucket using IAM-token in provider config, not using access\_key.<br>    If omitted, folder\_id specified in provider config and access\_key is used. | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | (Optional) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are NOT recoverable. | `bool` | `false` | no |
| <a name="input_grant"></a> [grant](#input\_grant) | (Optional) List of objects for an ACL policy grant. Conflicts with `acl` variable.<br>    To manage grant argument, service account with `storage.admin` role should be used.<br>    For more information see https://cloud.yandex.com/en/docs/storage/concepts/acl#permissions-types.<br><br>    Configuration attributes:<br>      id          - (Optional) Permission recipient ID.<br>      type        - (Required) Permission recipient type.<br>      uri         - (Optional) System group URI.<br>      permissions - (Required) List of assigned permissions. | <pre>list(object({<br>    id          = optional(string)<br>    type        = string<br>    uri         = optional(string)<br>    permissions = set(string)<br>  }))</pre> | `[]` | no |
| <a name="input_https"></a> [https](#input\_https) | (Optional) Object manages https certificate for bucket.<br>    For more information see https://cloud.yandex.com/en/docs/storage/operations/hosting/certificate.<br><br>    At least one of `certificate`, `existing_certificate_id` must be specified.<br><br>    Configuration attributes:<br>      existing\_certificate\_id - (Optional) Id of an existing certificate in Yandex Cloud Certificate Manager, that will be used for the bucket.<br>      certificate             - (Optional) Object allows to manage the parameters for generating a managed HTTPS certificate in Yandex Cloud Certificate Manager.<br><br>    The `certificate` object supports the following attributes:<br>      domains             - (Required) Domains for this certificate.<br>      public\_dns\_zone\_id  - (Required) The id of the DNS zone in which record set will reside.<br>      dns\_records\_ttl     - (Optional) The time-to-live of DNS record set (seconds). Default value is `300`.<br>      name                - (Optional) Certificate name. Conflicts with `name_prefix`.<br>      name\_prefix         - (Optional) Prefix of the certificate name. A unique certificate name will be generated using the prefix. Default value is `s3-https-certificate`. Conflicts with `name`.<br>      description         - (Optional) Certificate description.<br>      labels              - (Optional) Labels to assign to certificate.<br>      deletion\_protection - (Optional) Prevents certificate deletion. Default value is `false`.<br><br>    It will try to create bucket using IAM-token in provider config, not using access\_key. | <pre>object({<br>    existing_certificate_id = optional(string)<br>    certificate = optional(object({<br>      domains             = set(string)<br>      public_dns_zone_id  = string<br>      dns_records_ttl     = optional(number, 300)<br>      name                = optional(string)<br>      name_prefix         = optional(string)<br>      description         = optional(string, "Certificate for S3 static website.")<br>      labels              = optional(map(string))<br>      deletion_protection = optional(bool, false)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_lifecycle_rule"></a> [lifecycle\_rule](#input\_lifecycle\_rule) | (Optional) List of objects with configuration of object lifecycle management.<br>    For more information see https://cloud.yandex.com/en/docs/storage/concepts/lifecycles.<br><br>    Configuration attributes:<br>      enabled                                - (Required) Specifies lifecycle rule status.<br>      id                                     - (Optional) Unique identifier for the rule. Must be less than or equal to 255 characters in length.<br>      prefix                                 - (Optional) Object key prefix identifying one or more objects to which the rule applies.<br>      abort\_incomplete\_multipart\_upload\_days - (Optional) Specifies the number of days after initiating a multipart upload when the multipart upload must be completed.<br>      expiration                             - (Optional) Specifies a period in the object's expire.<br>      transition                             - (Optional) Specifies a period in the object's transitions.<br>      noncurrent\_version\_expiration          - (Optional) Specifies when noncurrent object versions expire.<br>      noncurrent\_version\_transition          - (Optional) Specifies when noncurrent object versions transitions.<br><br>    At least one of `abort_incomplete_multipart_upload_days`, `expiration`, `transition`, `noncurrent_version_expiration`, `noncurrent_version_transition` must be specified.<br><br>    The `expiration` object supports the following attributes:<br>      date                         - (Optional) Specifies the date after which you want the corresponding action to take effect.<br>      days                         - (Optional) Specifies the number of days after object creation when the specific rule action takes effect.<br>      expired\_object\_delete\_marker - (Optional) On a versioned bucket (versioning-enabled or versioning-suspended bucket), you can add this element in the lifecycle configuration to direct Object Storage to delete expired object delete markers.<br><br>    The `transition` object supports the following attributes:<br>      date          - (Optional) Specifies the date after which you want the corresponding action to take effect.<br>      days          - (Optional) Specifies the number of days after object creation when the specific rule action takes effect.<br>      storage\_class - (Required) Specifies the storage class to which you want the object to transition. Can only be `COLD` or `STANDARD_IA`.<br><br>    The `noncurrent_version_expiration` object supports the following attributes:<br>      days - (Required) Specifies the number of days noncurrent object versions expire.<br><br>    The `noncurrent_version_transition` object supports the following attributes:<br>      days          - (Required) Specifies the number of days noncurrent object versions transition.<br>      storage\_class - (Required) Specifies the storage class to which you want the noncurrent object versions to transition. Can only be `COLD` or `STANDARD_IA`. | <pre>list(object({<br>    enabled                                = bool<br>    id                                     = optional(string)<br>    prefix                                 = optional(string)<br>    abort_incomplete_multipart_upload_days = optional(number)<br>    expiration = optional(object({<br>      date                         = optional(string)<br>      days                         = optional(number)<br>      expired_object_delete_marker = optional(bool)<br>    }))<br>    transition = optional(object({<br>      date          = optional(string)<br>      days          = optional(number)<br>      storage_class = string<br>    }))<br>    noncurrent_version_expiration = optional(object({<br>      days = number<br>    }))<br>    noncurrent_version_transition = optional(object({<br>      days          = number<br>      storage_class = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | (Optional) Configuration of bucket logging.<br>    For more information see https://cloud.yandex.com/en/docs/storage/concepts/server-logs.<br><br>    Configuration attributes:<br>      target\_bucket - (Required) The name of the bucket that will receive the log objects.<br>      target\_prefix - (Optional) To specify a key prefix for log objects. | <pre>object({<br>    target_bucket = string<br>    target_prefix = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | (Optional) The size of bucket, in bytes.<br>    For more information see https://cloud.yandex.com/en/docs/storage/operations/buckets/limit-max-volume.<br><br>    It will try to create bucket using IAM-token in provider block, not using access\_key. | `number` | `null` | no |
| <a name="input_object_lock_configuration"></a> [object\_lock\_configuration](#input\_object\_lock\_configuration) | (Optional) Configuration of object lock management.<br>    For more information see https://cloud.yandex.com/en/docs/storage/concepts/object-lock.<br><br>    Configuration attributes:<br>      object\_lock\_enabled - (Optional) Enable object locking in a bucket. Require versioning to be enabled.<br>      rule                - (Optional) Specifies a default locking configuration for added objects. Require object\_lock\_enabled to be enabled.<br><br>    The `rule` object consists of a nested `default_retention` object, which in turn supports the following attributes:<br>      mode  - (Required) Specifies a type of object lock. One of `GOVERNANCE` or `COMPLIANCE` (case sensitive).<br>      days  - (Optional) Specifies a retention period in days after uploading an object version. It must be a positive integer. You can't set it simultaneously with years.<br>      years - (Optional) Specifies a retention period in years after uploading an object version. It must be a positive integer. You can't set it simultaneously with days. | <pre>object({<br>    object_lock_enabled = optional(string, "Enabled")<br>    rule = optional(object({<br>      default_retention = object({<br>        mode  = string<br>        days  = optional(number)<br>        years = optional(number)<br>      })<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) Object storage policy.<br>    For more information see https://cloud.yandex.com/en/docs/storage/concepts/policy.<br><br>    NOTE: Bucket policy for Yandex Cloud Console is defined in a separate `policy_console` variable.<br><br>    Configuration attributes:<br>      enabled    - (Required) Enable policy.<br>      id         - (Optional) General information about the policy. Some Yandex Cloud services require the uniqueness of this value.<br>      version    - (Optional) Access policy description version. Possible values is `2012-10-17`.<br>      statements - (Optional) List of bucket policy rules.<br><br>    Objects in the `statements` supports the following attributes:<br>      sid           - (Optional) Rule ID.<br>      effect        - (Optional) Specifies whether the requested action is denied or allowed. Possible values: `Allow`, `Deny`. Defaults to `Allow`.<br>      actions       - (Required) Determines the action to be executed when the policy is triggered.<br>      resources     - (Required) Specifies the list of the resources that the action will be performed on. Prefix `arn:aws:s3:::` can be omitted from resource names.<br>      principal     - (Optional) ID of the recipient of the requested permission.<br>      not\_principal - (Optional) ID of the entity that will not receive the requested permission.<br>      condition     - (Optional) Condition that will be checked.<br><br>    The `principal` object supports the following attributes:<br>      type        - (Required) Type of the entity. Possible values: `*`, `CanonicalUser`.<br>      identifiers - (Required) List of IDs.<br><br>    The `not_principal` object supports the following attributes:<br>      type        - (Required) Type of the entity. Possible value is `CanonicalUser`.<br>      identifiers - (Required) List of IDs.<br><br>    The `condition` object supports the following attributes:<br>      type   - (Required) Condition type.<br>      key    - (Required) Specifies the condition whose value will be checked.<br>      values - (Required) List of values. | <pre>object({<br>    enabled = bool<br>    statements = optional(list(object({<br>      sid       = optional(string)<br>      effect    = optional(string)<br>      actions   = list(string)<br>      resources = list(string)<br>      principal = optional(object({<br>        type        = string<br>        identifiers = list(string)<br>      }))<br>      not_principal = optional(object({<br>        type        = string<br>        identifiers = list(string)<br>      }))<br>      condition = optional(object({<br>        type   = string<br>        key    = string<br>        values = list(any)<br>      }))<br>    })))<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
| <a name="input_policy_console"></a> [policy\_console](#input\_policy\_console) | (Optional) Object storage policy for Yandex Cloud Console (Web UI).<br>    For more information see https://cloud.yandex.com/en/docs/storage/concepts/policy#console-access.<br><br>    Configuration attributes:<br>      enabled       - (Required) Enable policy for Yandex Cloud Console.<br>      sid           - (Optional) Rule ID.<br>      effect        - (Optional) Specifies whether the requested action is denied or allowed. Possible values: `Allow`, `Deny`. Defaults to `Allow`.<br>      principal     - (Optional) ID of the recipient of the requested permission.<br>      not\_principal - (Optional) ID of the entity that will not receive the requested permission.<br><br>    The `principal` object supports the following attributes:<br>      type        - (Required) Type of the entity. Possible values: `*`, `CanonicalUser`.<br>      identifiers - (Required) List of IDs.<br><br>    The `not_principal` object supports the following attributes:<br>      type        - (Required) Type of the entity. Possible value is `CanonicalUser`.<br>      identifiers - (Required) List of IDs. | <pre>object({<br>    enabled = bool<br>    sid     = optional(string)<br>    effect  = optional(string)<br>    principal = optional(object({<br>      type        = string<br>      identifiers = list(string)<br>    }))<br>    not_principal = optional(object({<br>      type        = string<br>      identifiers = list(string)<br>    }))<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
| <a name="input_server_side_encryption_configuration"></a> [server\_side\_encryption\_configuration](#input\_server\_side\_encryption\_configuration) | (Optional) Object with configuration of server-side encryption for the bucket.<br>    For more information see https://cloud.yandex.com/en/docs/storage/concepts/encryption.<br><br>    Configuration attributes:<br>      enabled           - (Required) Enable server-side encryption for the bucket.<br>      sse\_algorithm     - (Required) The server-side encryption algorithm to use. Single valid value is `aws:kms`.<br>      kms\_master\_key\_id - (Optional) The KMS master key ID used for the server-side encryption. Allows to specify an existing KMS key for the server-side encryption. If omitted, the KMS key will be generated with parameters in the `sse_kms_key_configuration` variable. | <pre>object({<br>    enabled           = bool<br>    sse_algorithm     = optional(string, "aws:kms")<br>    kms_master_key_id = optional(string)<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
| <a name="input_sse_kms_key_configuration"></a> [sse\_kms\_key\_configuration](#input\_sse\_kms\_key\_configuration) | (Optional) Object with a KMS key configuration.<br>    For more information see https://cloud.yandex.com/en/docs/kms/concepts.<br><br>    Only used for an auto-generated KMS key.<br>    Will be ignored, if attribute `kms_master_key_id` is set in variable `server_side_encryption_configuration`.<br><br>    Configuration attributes:<br>      name                - (Optional) Name of the key. If omitted, Terraform will assign a random, unique name. Conflicts with `name_prefix`.<br>      name\_prefix         - (Optional) Prefix of the key name. A unique KMS key name will be generated using the prefix. Conflicts with `name`.<br>      description         - (Optional) Description of the key.<br>      default\_algorithm   - (Optional) Encryption algorithm to be used with a new key version, generated with the next rotation. Default value is `AES_256`.<br>      rotation\_period     - (Optional) Interval between automatic rotations. To disable automatic rotation, omit this parameter. Default value is `8760h` (1 year).<br>      deletion\_protection - (Optional) Prevents key deletion. Default value is `false`. | <pre>object({<br>    name                = optional(string)<br>    name_prefix         = optional(string)<br>    description         = optional(string, "KMS key for Object storage server-side encryption.")<br>    default_algorithm   = optional(string, "AES_256")<br>    rotation_period     = optional(string, "8760h")<br>    deletion_protection = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_storage_admin_service_account"></a> [storage\_admin\_service\_account](#input\_storage\_admin\_service\_account) | (Optional) Allows to manage storage admin service account for the bucket.<br><br>    Configuration attributes:<br>      name                        - (Optional) The name of the service account to be generated. Conflicts with `name_prefix` and `existing_account_id`.<br>      name\_prefix                 - (Optional) Prefix of the service account name. A unique service account name will be generated using the prefix. Conflicts with `name` and `existing_account_id`.<br>      description                 - (Optional) Description of the service account to be generated.<br>      existing\_account\_id         - (Optional) Allows to specify an existing service account ID to manage the bucket. The service account must have `storage.admin` permissions in the folder. Conflicts with `name` and `name_prefix`.<br>      existing\_account\_access\_key - (Optional) The access key of an existing service account to use when applying changes. If omitted, `storage_access_key` specified in provider config is used.<br>      existing\_account\_secret\_key - (Optional) The secret key of an existing service account to use when applying changes. If omitted, `storage_secret_key` specified in provider config is used.<br><br>    By default, if the object is not set in the input variables of the module, a service account will be automatically generated with the name prefix `storage-admin`,<br>    an access key will be automatically generated with random name, and the role of `storage.admin` will be assigned to the generated service account. | <pre>object({<br>    name                        = optional(string)<br>    name_prefix                 = optional(string)<br>    description                 = optional(string, "Service account for Object storage admin.")<br>    existing_account_id         = optional(string)<br>    existing_account_access_key = optional(string)<br>    existing_account_secret_key = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Object for setting tags (or labels) for bucket.<br>    For more information see https://cloud.yandex.com/en/docs/storage/concepts/tags. | `map(string)` | `{}` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | (Optional) Enable versioning.<br>    Once you version-enable a bucket, it can never return to an unversioned state. You can, however, suspend versioning on that bucket. Disabled by default.<br>    For more information see https://cloud.yandex.com/en/docs/storage/concepts/versioning.<br><br>    Configuration attributes:<br>      enabled - (Required) Enable versioning. | <pre>object({<br>    enabled = bool<br>  })</pre> | `null` | no |
| <a name="input_website"></a> [website](#input\_website) | (Optional) Object for static web-site hosting or redirect configuration.<br>    For more information see https://cloud.yandex.com/en/docs/storage/concepts/hosting.<br><br>    Configuration attributes:<br>      index\_document           - (Required, unless using redirect\_all\_requests\_to) Storage returns this index document when requests are made to the root domain or any of the subfolders.<br>      error\_document           - (Optional) An absolute path to the document to return in case of a 4XX error.<br>      routing\_rules            - (Optional) List of json arrays containing routing rules describing redirect behavior and when redirects are applied. For more information see https://cloud.yandex.com/en/docs/storage/s3/api-ref/hosting/upload#request-scheme.<br>      redirect\_all\_requests\_to - (Optional) A hostname to redirect all website requests for this bucket to. Hostname can optionally be prefixed with a protocol (http:// or https://) to use when redirecting requests. The default is the protocol that is used in the original request. When set, other website configuration attributes will be skiped.<br><br>    The `routing_rules` object supports the following attributes:<br>      condition - (Optional) Object used for conditions that trigger the redirect. If a routing rule doesn't contain any conditions, all the requests are redirected.<br>      redirect  - (Required) Object for configure redirect a request to a different page, different host, or change the protocol.<br><br>    The `condition` object supports the following attributes:<br>      key\_prefix\_equals               - (Optional) Sets the name prefix for the request-originating object.<br>      http\_error\_code\_returned\_equals - (Optional) Specifies the error code that triggers a redirect.<br><br>    The `redirect` object supports the following attributes:<br>      protocol                - (Optional) In the Location response header, a redirect indicates the protocol scheme (http or https) to be used.<br>      host\_name               - (Optional) In the Location response header, a redirect indicates the host name to be used.<br>      replace\_key\_prefix\_with - (Optional) Specifies the name prefix of the object key replacing `key_prefix_equals` in the redirect request. Incompatible with `replace_key_with`.<br>      replace\_key\_with        - (Optional) Specifies the object key to be used in the Location header. Incompatible with `replace_key_prefix_with`.<br>      http\_redirect\_code      - (Optional) In the Location response header, a redirect specifies the HTTP redirect code. Possible values: any 3xx code.<br><br>    The default value for index\_document is used in case, when a website object is specified in the module input variables,<br>    but the index\_document or redirect\_all\_requests\_to are not set. | <pre>object({<br>    index_document = optional(string, "index.html")<br>    error_document = optional(string)<br>    routing_rules = optional(list(object({<br>      condition = optional(object({<br>        key_prefix_equals               = optional(string)<br>        http_error_code_returned_equals = optional(string)<br>      }))<br>      redirect = object({<br>        protocol                = optional(string)<br>        host_name               = optional(string)<br>        replace_key_prefix_with = optional(string)<br>        replace_key_with        = optional(string)<br>        http_redirect_code      = optional(string)<br>      })<br>    })))<br>    redirect_all_requests_to = optional(string)<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | The bucket domain name. |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name of the bucket. |
| <a name="output_cm_certificate_id"></a> [cm\_certificate\_id](#output\_cm\_certificate\_id) | Certificate ID of the generated HTTPS certificate in Yandex Cloud Certificate Manager |
| <a name="output_kms_master_key_id"></a> [kms\_master\_key\_id](#output\_kms\_master\_key\_id) | The KMS master key ID used for the server-side encryption. |
| <a name="output_storage_admin_access_key"></a> [storage\_admin\_access\_key](#output\_storage\_admin\_access\_key) | Static access key of the autogenerated Object storage admin service account. |
| <a name="output_storage_admin_secret_key"></a> [storage\_admin\_secret\_key](#output\_storage\_admin\_secret\_key) | Static secret key of the autogenerated Object storage admin service account. |
| <a name="output_storage_admin_service_account_id"></a> [storage\_admin\_service\_account\_id](#output\_storage\_admin\_service\_account\_id) | Service account ID of the Object storage admin. |
| <a name="output_website_domain"></a> [website\_domain](#output\_website\_domain) | The domain of the website endpoint. |
| <a name="output_website_endpoint"></a> [website\_endpoint](#output\_website\_endpoint) | The website endpoint. |
<!-- END_TF_DOCS -->
