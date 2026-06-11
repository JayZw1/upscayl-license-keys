# Upscayl 密钥库

这个文件夹用于上传到你的公开 GitHub 仓库。软件会读取 `day.json`、`month.json`、`year.json`、`century.json` 来判断密钥是否有效。

密钥文件里保存的是密钥的 SHA-256 哈希，不是明文密钥。你可以公开仓库，但不要把生成脚本输出的真实密钥发到公开页面里。

## 生成密钥

在 PowerShell 里进入这个文件夹，然后运行：

```powershell
.\scripts\New-LicenseKey.ps1 -Duration day
.\scripts\New-LicenseKey.ps1 -Duration month
.\scripts\New-LicenseKey.ps1 -Duration year
.\scripts\New-LicenseKey.ps1 -Duration century
```

脚本会输出真实密钥，例如：

```text
真实密钥: UPSCAYL-DAY-ABCD-EFGH-IJKL-MNOP
```

把这个真实密钥发给用户。JSON 文件里只会保存哈希。

## 禁用密钥

如果要让某个密钥失效，运行：

```powershell
.\scripts\Revoke-LicenseKey.ps1 -Key "用户的真实密钥"
```

脚本会找到对应哈希并把 `active` 改成 `false`。上传 GitHub 后，软件下次启动会拦住这个密钥。

## 上传 GitHub 后修改软件配置

上传到 GitHub 公开仓库后，把软件里的这个文件改成你的真实 Raw 地址：

```text
F:\codex\Upscayl\resources\license-config.json
```

示例：

```json
{
  "licenseUrls": {
    "day": "https://raw.githubusercontent.com/你的用户名/你的仓库名/main/day.json",
    "month": "https://raw.githubusercontent.com/你的用户名/你的仓库名/main/month.json",
    "year": "https://raw.githubusercontent.com/你的用户名/你的仓库名/main/year.json",
    "century": "https://raw.githubusercontent.com/你的用户名/你的仓库名/main/century.json"
  }
}
```
