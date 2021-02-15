# CFSSL cheatsheet

Scripts to quickly generate CSRs for simple use cases and interpret the output from MS AD certificate services.

## Usage

Generate a key and corresponding CSR for `subdomain.company.com, *.subdomain.company.com`:

```bash
./gencsr.sh subdomain.company.com
```

Go to your company Microsoft Active Directory Certificates Services endpoint and select

```
Request a certificate
->
Submit a certificate request by using a base-64-encoded CMC or PKCS #10 file
```

then fill out the form with the contents of the generated CSR file and the string outputted by the script as in the image:

![CSR form](/img/csr.png)

then download the base64 encoded certificate chain (usually served with a filename `certnew.p7b`)

![Download form](/img/download.png)

and run `./decode.sh`:

```bash
./decode.sh certnew.p7b subdomain.company.com
```

`./gencsr.sh` allows some customization with environment variables `NAMES_C`, `NAMES_L`, `NAMES_O`, and `EXPIRY`. See the script for details, their function is relatively self-explanatory.

### Signing Profile (for reference)

```go
type SigningProfile struct {
        Usage               []string     `json:"usages"`
        IssuerURL           []string     `json:"issuer_urls"`
        OCSP                string       `json:"ocsp_url"`
        CRL                 string       `json:"crl_url"`
        CAConstraint        CAConstraint `json:"ca_constraint"`
        OCSPNoCheck         bool         `json:"ocsp_no_check"`
        ExpiryString        string       `json:"expiry"`
        BackdateString      string       `json:"backdate"`
        AuthKeyName         string       `json:"auth_key"`
        CopyExtensions      bool         `json:"copy_extensions"`
        PrevAuthKeyName     string       `json:"prev_auth_key"` // to support key rotation
        RemoteName          string       `json:"remote"`
        NotBefore           time.Time    `json:"not_before"`
        NotAfter            time.Time    `json:"not_after"`
        NameWhitelistString string       `json:"name_whitelist"`
        AuthRemote          AuthRemote   `json:"auth_remote"`
        CTLogServers        []string     `json:"ct_log_servers"`
        AllowedExtensions   []OID        `json:"allowed_extensions"`
        CertStore           string       `json:"cert_store"`
}
```
