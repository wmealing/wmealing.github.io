
# Table of Contents

1.  [Why sign a kernel module ?](#org7c35ac3)
2.  [How is it signed ?](#orgd6213d0)
3.  [Kernel modules information.](#org76eda05)
    1.  [Module location](#orge79c53b)
    2.  [Loading kernel modules.](#org222d60d)
    3.  [The signature](#orgcf5980c)
        1.  [Signature metadata.](#org0746dac)
4.  [Version support table](#orgf3aca76)
5.  [Source](#org619928d)
6.  [How the kernel loads the module.](#org7504faa)
7.  [Failure modes.](#org59e62e1)
8.  [Adding a second signature to the keychain for third party modules:](#org8317702)
9.  [Creating a public and private key](#org950203f)
10. [Enrolling the key into the MOK keychain.](#org13dfc90)
11. [Signing a kernel module](#orgc41e782)
12. [Additional Resources:](#org92dc606)



<a id="org7c35ac3"></a>

# What is a “signed” kernel module?

A digital signature is a method of verifying the authenticity of
digital data.   A valid digital signature can be used to reason that
the ‘signed’ content was created by a known sender and that the data
was not modified between the time of signing and its current state.

Kernel modules are organized, functional sections of code that can be
loaded and removed from the kernel on demand.  A module provides
additional functionality  of the kernel without the need to reboot the
system or recompile the code.

A signed kernel module is a kernel module with a digitial signature
that validates the contents of the module along with the attached
signature belongs to a trusted party in the systems ‘key chain’.


# How is it signed ?


Each kernel module is signed with a industry standard PKCS#7 standard
(https://tools.ietf.org/html/rfc5652).   Modules that are built when
the kernel is compiled by the operating system vendor are signed at
build time, with the ‘hash’ specified at build time by the directive
CONFIG_MODULE_SIG_HASH.  Each module can only be signed once by a
dsingle signer, additional signatures are ignored.
The signature is appended to the file along with the string “~Module
signature appended~” at the end of the file.   This allows for easy
confirmation of the signing process by using the ‘strings’ tool to
find the above string in an uncompressed kernel module.
$ strings ecryptfs.ko | tail -n 1
~Module signature appended~
This signature in the file is consulted by the kernel and validated
during the module loading process. The number of cryptographic hash
algorithms has increased over time, a module can be signed by a single
algorithm.
The supported hash algorithms for a release can be found in the
kernels build configuration file, along with other signing related
options.
$ grep CONFIG_MODULE_SIG_HASH  ~/rhel-8-kernel/redhat/configs/*config
| sort| uniq
CONFIG_MODULE_SIG_HASH="sha256"
From this you can see that Red Hat Enterprise Linux 8 defaults to
sha256 and only supports sha256 signed kernel modules. These options
are used at build time and runtime of the kernel that is being built.
When the kernel  is built the key used to sign the modules is compiled
into the kernel (the vmlinuz) file for use when validating module
signatures.




<a id="org76eda05"></a>

# Kernel modules information.


<a id="orge79c53b"></a>

## Module location

Kernel modules provided by the operating system vendors are located in the
root or subdirectory of the default search path (of /lib/modules/(\`uname -a\`)
).  There is provision for third party modules to exist within this directory
that are able to override operating system vendor defaults by using the
'updates' or 'extras' sub-directories.

Modules can be loaded from outside this tree, the complex iteractions of
searching and priority is documented in the depmod and depmod.d man pages.


<a id="org222d60d"></a>

## Loading kernel modules.

Modules can be loaded manually using the insmod/modprobe but also the kernel
can load modules on demand to meet attached hardware requirements or
protocols. The three (that i know of) protocols are:

-   Network Protocol use.
-   Hotplugged hardware.
-   Filesystem

Each of these events can fire off a userspace helper which can load a
module. This userspace helper consults the modules.dep file created by
depmod to locate the relevant module to meet the kernels request.


<a id="orgcf5980c"></a>

## The signature


<a id="org0746dac"></a>

### Signature metadata.

The /sbin/modinfo program can inspect details about the kernel module.  The  

    # modinfo mwifiex.ko.xz
    filename: /lib/modules/4.18.0-193.el8.x86_64/kernel/drivers/net/wireless/marvell/mwifiex/mwifiex.ko.xz
    license:        GPL v2
    version:        1.0
    description:    Marvell WiFi-Ex Driver version 1.0
    author:         Marvell International Ltd.
    rhelversion:    8.2
    srcversion:     D69796288134CDB287FEF82
    depends:        cfg80211
    intree:         Y
    name:           mwifiex
    vermagic:       4.18.0-193.el8.x86_64 SMP mod_unload modversions 
    sig_id:         PKCS#7
    signer:         Red Hat Enterprise Linux kernel signing key
    sig_key:        42:A4:B8:EB:D4:F1:21:1D:CA:0B:B6:66:62:38:61:FA:0B:90:31:59
    sig_hashalgo:   sha256
    signature:      7B:A1:37:3D:44:86:1A:99:19:64:B2:1C:96:A7:5E:8F:4D:47:52:F9:
    DE:1F:6F:81:6E:CE:FB:DB:F9:D6:6C:97:AC:58:59:BB:D6:7E:D1:F5:
    46:E4:5D:0D:9C:77:F9:DD:DD:2A:F6:8B:6F:56:AC:49:55:06:1F:7B:
    03:C3:4B:D9:9F:D1:65:6C:B4:DF:E6:0A:26:98:1E:53:E3:8C:79:FB:
    0C:FF:58:E6:61:05:B9:F2:33:3A:87:4B:7B:68:1D:DB:18:DC:18:1E:
    17:F0:1D:23:5E:DF:C9:F4:65:37:40:8A:42:62:1F:33:C2:FC:98:4C:
    D4:73:81:3A:72:2A:7B:5F:0B:9F:4F:C0:A3:38:82:AD:7A:A5:CA:A6:
    04:04:F3:7E:09:23:32:5D:B1:BA:D6:B1:FC:E2:20:0B:AF:ED:1D:85:
    D3:F1:E8:60:C1:F0:38:46:D3:C5:33:A9:CB:F0:4E:EF:D9:1F:1C:7E:
    5B:D5:C6:8E:97:57:85:4A:38:48:6B:06:FF:68:42:EB:B1:F3:7A:D0:
    5B:32:4F:BC:A2:B9:04:D7:D0:04:74:72:66:00:72:E1:FC:49:B2:91:
    8F:05:A7:BC:E6:38:17:BE:60:B1:E1:47:D1:CB:DA:8C:7E:B2:5E:B5:
    7D:2A:37:A0:06:1D:2F:1C:88:86:82:01:57:02:75:B3:D8:D4:82:3D:
    D7:76:13:FC:B1:2B:A8:E4:3B:DC:D2:F8:F4:6E:9F:7D:CC:90:1D:34:
    AC:FB:D5:38:A4:E7:38:72:08:4B:1F:7C:5E:47:78:28:C4:FE:DB:70:
    00:ED:DC:D1:A9:4A:BE:42:CE:1C:17:98:BF:E8:F0:C5:77:B0:A0:03:
    95:E0:8E:F1:60:61:8B:A7:48:6E:51:D8:49:F7:94:CB:3C:BC:45:F9:
    81:3C:62:2A:98:0D:77:F0:23:3B:D6:5A:B2:B6:17:2F:C3:75:3F:45:
    AC:6B:CA:35:FF:E1:A9:65:02:18:15:00:AC:68:8F:96:03:0B:CB:CB:
    A4:5E:FC:24
    parm:           reg_alpha2:charp

The signature itself is at the tail end of the file, using the hex editor xxd
you can see it.

    0008d650: 0101 0500 0482 0180 7ba1 373d 4486 1a99  ........{.7=D... <-- STARTS HERE ON 7BA1
    0008d660: 1964 b21c 96a7 5e8f 4d47 52f9 de1f 6f81  .d....^.MGR...o.
    0008d670: 6ece fbdb f9d6 6c97 ac58 59bb d67e d1f5  n.....l..XY..~..
    0008d680: 46e4 5d0d 9c77 f9dd dd2a f68b 6f56 ac49  F.]..w...*..oV.I
    0008d690: 5506 1f7b 03c3 4bd9 9fd1 656c b4df e60a  U..{..K...el....
    0008d6a0: 2698 1e53 e38c 79fb 0cff 58e6 6105 b9f2  &..S..y...X.a...
    0008d6b0: 333a 874b 7b68 1ddb 18dc 181e 17f0 1d23  3:.K{h.........#
    0008d6c0: 5edf c9f4 6537 408a 4262 1f33 c2fc 984c  ^...e7@.Bb.3...L
    0008d6d0: d473 813a 722a 7b5f 0b9f 4fc0 a338 82ad  .s.:r*{_..O..8..
    0008d6e0: 7aa5 caa6 0404 f37e 0923 325d b1ba d6b1  z......~.#2]....
    0008d6f0: fce2 200b afed 1d85 d3f1 e860 c1f0 3846  .. ........`..8F
    0008d700: d3c5 33a9 cbf0 4eef d91f 1c7e 5bd5 c68e  ..3...N....~[...
    0008d710: 9757 854a 3848 6b06 ff68 42eb b1f3 7ad0  .W.J8Hk..hB...z.
    0008d720: 5b32 4fbc a2b9 04d7 d004 7472 6600 72e1  [2O.......trf.r.
    0008d730: fc49 b291 8f05 a7bc e638 17be 60b1 e147  .I.......8..`..G
    0008d740: d1cb da8c 7eb2 5eb5 7d2a 37a0 061d 2f1c  ....~.^.}*7.../.
    0008d750: 8886 8201 5702 75b3 d8d4 823d d776 13fc  ....W.u....=.v..
    0008d760: b12b a8e4 3bdc d2f8 f46e 9f7d cc90 1d34  .+..;....n.}...4
    0008d770: acfb d538 a4e7 3872 084b 1f7c 5e47 7828  ...8..8r.K.|^Gx(
    0008d780: c4fe db70 00ed dcd1 a94a be42 ce1c 1798  ...p.....J.B....
    0008d790: bfe8 f0c5 77b0 a003 95e0 8ef1 6061 8ba7  ....w.......`a..
    0008d7a0: 486e 51d8 49f7 94cb 3cbc 45f9 813c 622a  HnQ.I...<.E..<b*
    0008d7b0: 980d 77f0 233b d65a b2b6 172f c375 3f45  ..w.#;.Z.../.u?E
    0008d7c0: ac6b ca35 ffe1 a965 0218 1500 ac68 8f96  .k.5...e.....h..
    0008d7d0: 030b cbcb a45e fc24 0000 0200 0000 0000  .....^.$........   <-- ENDS HERE ON FC24
    0008d7e0: 0000 0268 7e4d 6f64 756c 6520 7369 676e  ...h~Module sign
    0008d7f0: 6174 7572 6520 6170 7065 6e64 6564 7e0a  ature appended~.

There is an additional text string "`Module signature appended`" also at the
end of the file, which does not seem to serve a purpose other than a simple
identifier to determine if the module signature is included.

Some implementations of kernel module signing had included it as part of the
'ELF' section tables but this appears to have been deprecated in favour of
the simpler appending to the file.


<a id="orgf3aca76"></a>

# Version support table

The first implementation of signing kernel modules appeared in Red Hat
Enterprise Linux 5.  This was available and enabled in Enterprise Linux before
it was available in Fedora and other distributions.

Kernel module signature verification is not enabled by default but can be
enabled by booting the kernel with an addition parameter as shown below:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Version</th>
<th scope="col" class="org-left">Kernel boot parameter</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">Red Hat Enterprise Linux 5</td>
<td class="org-left">enforcemodulesig=1</td>
</tr>


<tr>
<td class="org-left">Red Hat Enterprise Linux 6</td>
<td class="org-left">enforcedmodulesign=1</td>
</tr>


<tr>
<td class="org-left">Red Hat Enterprise Linux 7</td>
<td class="org-left">`module.sig_enforce=1`</td>
</tr>


<tr>
<td class="org-left">Red Hat Enterprise Linux 8</td>
<td class="org-left">`module.sig_enforce=1`</td>
</tr>
</tbody>
</table>

For releases with full 'secureboot' support, (7 and later), module signature
verification is required unless explicitly stated by inverting the above kernel
boot parameter.

When IMA is enabled, kernel module signing support is enforced.


<a id="org619928d"></a>

# Source


<a id="org7504faa"></a>

# How the kernel loads the module.

The kernel has two entry paths of loading a module.  The init\_module()
function was the traditional path 

These system call functions are: init\_module() and  finit\_module(). They
both perform the same essential function, finit takes an FD instead of a
path to the module.

[This may be useful if you have some kind of selinux policy on loading
modules that are labeled ?]

An overview of the function calls in the 'useful' codepath.

    init_module() 
     -> load_module() 
      -> module_sig_check()  <-- checks to see if it has a sig
        -> mod_verify_sig()   <--- verify the signature.
          -> verify_pkcs7_signature() <-- chcks to see if its valid pkcs7
           -> pkcs7_verify_one()  <- checks a single signature (from the list)
            -> public_key_verify_signature() <- actual crypto done here.

There is provision for the secondary keychain (The comments here don't 
seem to match the actual code), this is changed in later versions.

    mod_verify_sig() {
    
            /*
          * Check signature using built-in trusted keys and, if configured,
          * secondary trusted keys.
          */
         err =  verify_pkcs7_signature(mod, modlen, mod + modlen, sig_len,
                                       VERIFY_USE_SECONDARY_KEYRING,
                                       VERIFYING_MODULE_SIGNATURE,
                                       NULL, NULL);
         if (IS_ENABLED(CONFIG_INTEGRITY_PLATFORM_KEYRING) && err) {
                 /*
                  * Check signature using platform trusted keys. This does
                  * not consider the built-in keys, so must be done separately
                  * from above, if possible and necessary.
                  */
                 err =  verify_pkcs7_signature(mod, modlen, mod + modlen,
                                               sig_len,
                                               VERIFY_USE_PLATFORM_KEYRING,
                                               VERIFYING_MODULE_SIGNATURE,
                                               NULL, NULL);
         }
         return err;
    
    
    }

From initial research this appears to be the ".builtin\_trusted\_keys"
keyring. But the Secondary keyring can also be built if configured at 
build time.  (This is not the case in RHEL systems).

This secondary keychain must also be trusted by a signer in the primary
keychain, so.. its not simple.

Listing the primary keys:

    # keyctl list %:.builtin_trusted_keys 

These keys will only show when booted in secureboot mode with secureboot in
a reputable state.


<a id="org59e62e1"></a>

# Failure modes.

The kernel module signature check 'fails closed' leaving it up to the admin
controlled parameter to decide on the behavior.

This is on the decided in module\_sig\_check: 

    static int module_sig_check(struct load_info *info, int flags) {
    
      err = mod_verify_sig(mod, info);
    
      switch(err) {
    
        case 0: /* module okay to load */
           return 0;
    
        case -ENODATA: /* Loading of unsigned module */
           goto decide;
    
        case -ENOPKG:  /* Unknown crypto on module */
           goto decide;
    
        case -ENOKEY:  /* unavailable key (not in current chain */
           goto decide;
    
        decide:
          if (is_module_sig_enforced()) {
                    pr_notice("%s: %s is rejected\n", info->name, reason);
                    return -EKEYREJECTED;
          }
    
          return security_locked_down(LOCKDOWN_MODULE_SIGNATURE);
    
          /* All other errors are fatal, including nomem, unparseable */
    
        default:
          return err;
    
      }
    }  

The code also heavily defaults to the 'lockdown' mode state.


<a id="org8317702"></a>

# Adding a second signature to the keychain for third party modules:

If the system is not UEFI-based or if UEFI Secure Boot is not
enabled, then only the keys that are embedded in the kernel are loaded onto the
system key ring and you have no ability to augment that set of keys without
rebuilding the kernel and signing all kernel modules with your own key.

However, if you do have secureboot as an option.

Secureboot has a provision for adding 'additional' keys to the 'platform'
keyring, it uses a Machine Owner Key (MOK) to add additional keys to the UEFI
secure boot database, adding them to 'system' keyring for use.

The Red Hat Enterprise Linux boot process uses the shim.efi, MokManager.efi,
grubx64.efi and each of these supports the "MOK" style keyring addition.

Once a key has been added to generated and added to the via mokutil, on the
next reboot the user will required to input a passphrase at the physical
console (the same that was generated when the key was created).

This allows local users to be able to add keys to the system keychain that
are able to be used to validate signatures of kernel modules.


<a id="org950203f"></a>

# Creating a public and private key

Create a file configuration\_file.config  with the following contents,
modifying O and CN options.

    [ req ]
    default_bits = 4096
    distinguished_name = req_distinguished_name
    prompt = no
    string_mask = utf8only
    x509_extensions = myexts
    
    [ req_distinguished_name ]
    O = Organization
    CN = Organization signing key
    emailAddress = E-mail address
    
    [ myexts ]
    basicConstraints=critical,CA:FALSE
    keyUsage=digitalSignature
    subjectKeyIdentifier=hash
    authorityKeyIdentifier=keyid
    EOF

From this file use openssl to generate a public and private key pairs which can
be used to sign the kernel module and also enrolled in the systems "MOK" keychain.

    # openssl req -x509 -new -nodes -utf8 -sha256 -days 36500 -batch -config configuration_file.config -outform DER  -out public_key.der \ > -keyout  private_key.priv

The openssl command should create two files, public\_key.der and
private\_key.priv.


<a id="org13dfc90"></a>

# Enrolling the key into the MOK keychain.

    # mokutil --import public_key.der

You will be asked to enter and confirm a password for this MOK enrollment
request.

Reboot the machine.

The shim.efi will notice that there is a pending MOK enrollment and start
MokManager.efi to complete the enrollment.  The password used during the
certificate generation process will need to be entered at the console during
the early-boot stage to confirm that this key is to be enrolled.

This public key will now be in the MOK list and be added to the system key ring
on all future boots (until cleared) while secureboot is enabled.

For example the "Wades own very special kmod v01" singing key:

    # keyctl list %:.system_keyring
    6 keys in keyring:
    ...asymmetric: Red Hat Enterprise Linux Driver Update Program (key 3): bf57f3e87...
    
    ...asymmetric: Red Hat Secure Boot (CA key 1): 4016841644ce3a810408050766e8f8a29...
    ...asymmetric: Microsoft Corporation UEFI CA 2011: 13adbf4309bd82709c8cd54f316ed...
    ...asymmetric: Microsoft Windows Production PCA 2011: a92902398e16c49778cd90f99e...
    ...asymmetric: Red Hat Enterprise Linux kernel signing key: 4249689eefc77e95880b...
    ...asymmetric: Red Hat Enterprise Linux kpatch signing key: 4d38fd864ebe18c5f0b7...
    ...asymmetric: Wades own very special kmod v01 signing key: c4ae92e16da94228cd9e...


<a id="orgc41e782"></a>

# Signing a kernel module

Before the module can be loaded it must be signed, there is a sign-file
script included in the kernel source ./scripts/ directory which provides 
compatible a compatible signing technique that is able to be used for 'out of
tree' built kernel modules.  An example of singing my\_module

    perl /usr/src/kernels/$(uname -r)/scripts/sign-file sha256 private_key.priv public_key.der my_module.ko

After the signature has been applied, the modinfo command should show the
newly applied signature in its output.

Note:  The signing process does not need to be on the machine where the
module will be loaded.  Module signing keys should be adequately secured with best
practices for public/private keys.


<a id="org92dc606"></a>

# Additional Resources:

[Red Hat guide for Secure
boot](<https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/kernel_administration_guide/chap-documentation-kernel_administration_guide-working_with_kernel_modules#sect-signing-kernel-modules-for-secure-boot>) 

[Adding a secondary sign to a Out of Tree kernel module](<https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/kernel_administration_guide/chap-documentation-kernel_administration_guide-working_with_kernel_modules#sect-signing-kernel-modules-for-secure-boot>)

[The kernel security subsystem manual (keyring subsection)](<https://mchehab.fedorapeople.org/kernel_docs_pdf/security.pdf>)

[Secondary trusted keyring ( SECONDARY\_TRUSTED\_KEYRING )](<https://lore.kernel.org/patchwork/patch/665795/>)

