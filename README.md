# 使用Terraform创建OpenCat Team所需的资源

支持私有部署的[OpenCat for Team](https://twitter.com/waylybaye/status/1640534612719079424)已经发布了！如果你熟悉Terraform，可以使用本项目来快速创建OpenCat Team所需的资源。

## 部署过程

### 下载本项目

```bash
git clone git@github.com:tianshanghong/opencat-team-terraform.git
cd opencat-team-terraform
```

### 安装 Terraform

Terraform是一个用于创建、管理和升级云资源的工具。你可以在[这里](https://www.terraform.io/downloads.html)下载Terraform。

### 创建`terraform.tfvars`文件

```bash
cp terraform.tfvars.example terraform.tfvars
```

根据你的实际情况修改`terraform.tfvars`文件中的变量值。

* aws_region 你的AWS Region，例如"ap-northeast-1"
* private_key_path 设置你要使用的密钥的本地路径，例如"~/.ssh/my-key.pem"。如果没有密钥，请参考[创建密钥对 - Amazon Elastic Compute Cloud](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/create-key-pairs.html#having-ec2-create-your-key-pair)。
* key_name = "<your-key-name>" 你的密钥对的名称。例如"my-key"。
* ec2_ami = "<your-ami-id>"  要采用的Amazon Machine Images (AMI)。例如，"ami-01a777eb1a2618535" (Ubuntu 22.04 TLS, ap-northeast-1, arm64)。
* domain_name = "<your-domain-name>" 你要使用的域名，例如"example.com"。
* sub_domain_name = "<your-sub-domain-name>"  你要使用的子域名，例如"gpt"（DNS将指向gpt.example.com）。

### 初始化Terraform

```bash
terraform init
```

### 创建资源

```bash
terraform apply
```

确认无误后，输入`yes`开始创建。

### 在域名注册商将设置Name Server指向AWS Route53（根据实际情况）

如果你是在其他域名服务商注册的域名（例如：GoDaddy，Google Domain），你需要将域名的Name Server指向AWS Route53。

例如，如果你的AWS Region是`ap-northeast-1`，你需要到[https://ap-northeast-1.console.aws.amazon.com/route53/v2/hostedzones](https://ap-northeast-1.console.aws.amazon.com/route53/v2/hostedzones)，找到由Terraform创建的的zone。点击表格中你的Hosted zone name，进入Hosted zone详情页面。在页面上侧的Hosted zone details中找到Name servers，将这些Name servers设置到你的域名注册商。

Name servers可能是这样的：

```
ns-1825.awsdns-36.co.uk
ns-1121.awsdns-12.org
ns-341.awsdns-42.com
ns-916.awsdns-50.net
```

### 配置OpenCat Team
上述配置完成后，服务器配置就完成。此时可以进入OpenCat Team的管理页面，配置OpenCat Team。