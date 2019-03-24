## Adversarial Design for the Open Web

*Web Capabilities* are authorization to perform a set of HTTP requests. They are modeled after [capability security models](https://en.wikipedia.org/wiki/Capability-based_security) [emphasis added]:

> Capabilities achieve their objective of improving system security by being used in place of forgeable references. A forgeable reference (for example, a path name) identifies an object, but does not specify which access rights are appropriate for that object and the user program which holds that reference. Consequently, any attempt to access the referenced object must be validated by the operating system, based on the ambient authority of the requesting program, typically via the use of an access control list (ACL). Instead, in a system with capabilities, the mere fact that a user program possesses that capability entitles it to use the referenced object in accordance with the rights that are specified by that capability. ***In theory, a system with capabilities removes the need for any access control list or similar mechanism*** by giving all entities all and only the capabilities they will actually need.

Put another way, capabilities provide *intrinsic authorization* and reduce the overall surface area for attackers; thus capabilities provide stronger security.

Web capabilities are self-contained, and therefore may appear to be more complex to implement than current, popular authorization schemes (even if that can be minimized by libraries).  However, Web capabilities greatly reduce the implementation effort for interface owners due to their smaller surface area.  That is, you don't need to weave brittle ACL checks throughout your codebase.

Web capabilities address the tension between two design goals: providing robust security and participating in the Open Web.

### **Web Capabilities are Adversarial**

In distributed systems like the Web, [you can't trust the network](https://en.wikipedia.org/wiki/Fallacies_of_distributed_computing).  So Web capabilities aim to be thorough and adversarial in the evaluation of a request.  

Through the use of robust digital signing, Web capabilities give us a way to check identity (importantly, providing *both* authentication and [non-repudiation](https://en.wikipedia.org/wiki/Non-repudiation)) and guard against request tampering.  We can prove that a particular person sent a particular HTTP request with a particular set of URL, header, and body properties.

Web capabilities also obey the [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege).  The null state for a recipient is to have *no* capability to do anything.  Any permission must be granted explicitly. 

For these reasons, Web capabilities out-class current, popular alternatives.  Consider these:

- **Basic** 
Sends base64 encoded username and password in the `authorization` header. Uses no cryptographic methods (relies on TLS). Passwords are hard for humans to remember and manage, attackers have gotten really good at guessing them, and validating them requires privileged access that can be exploited.
- **Digest**
Sends a hash of username and password in the `authorization` header, in conjunction with a nonce specified by the server. While superficially more secure than Basic (provided a robust hashing algorithm is used), Digest still fundamentally relies on passwords and is flawed for the same reasons.
- **Bearer / OAuth**
Sends a high-entropy value in the `authorization` header.  OAuth is a popular standard that uses the Bearer scheme to substitute Basic and implement delegation between applications – all while avoiding writing cryptographic implementations within client applications. Often, OAuth sessions are initiated with username-password login – which, again, is flawed.  Though not a requirement, Bearer tokens are usually coarse-grained.  That grants permissions on a variety of requests like a password, making the implementation vulnerable to phishing and replay attacks.  The fact that OAuth is commonly used for delegation compounds its flaws, encouraging HX that spreads broad permissions.

The above, most common alternatives are built on passwords, do not guard against request tampering, and require a central server as a source of truth.  Web capabilities are adversarial, and have none of these vulnerabilities.

### But Also Designed for the Open Web

The goal of HTTP and other Web specifications is to [Create More Web](https://www.pandastrike.com/posts/20151019-create-more-web/). That is, respect distributed architecture to foster the accumulation of value (via network effects) in the Web, an ecosystem we all share, including your interfaces. 

Web capabilities align with the Open Web – providing the primitives to construct a web of trust, woven into the Web itself.   Consider an API handling a request containing a capability assertion.  We are concerned with two objectives:

1. Rigorously verifying the internal consistency of the assertion
2. Checking a public key registry to confirm the involved parties have not revoked their participation.

Neither of those objectives requires privileged access:  ****(1) contemplates data *within* the assertion, while (2) is a check on *public* data.

That's a huge win because it fosters decentralization.  That's reflected in the entity names, issuer-recipient rather than server-client.  We can put the verification flow anywhere, like within an intermediary (such as an edge cache for proxy server).  In fact, it is *more* secure to verify requests outside of the main API process space. If an attacker manages to trigger an unexpected code path, they are less likely to have access to sensitive data.

Web capabilities can even be verified in a system owned entirely by a third party.  And future versions of the specification will support delegation, with similar public verification properties.

All together, Web capabilities offer a more flexible, more robust alternative to current schemes. Web capabilities may appear more complex than username-password schemes, but the latter impose security and opportunity costs that were taken for granted until now.

## The Capability Document

A Capability is a simple document describing an allowed action. Web Capabilities describe an HTTP request.

### Capability Document

Unsupported in version 1.0:

- `once` and `expiration`
- providing more than one use key.

### Example

For example, this capability allows Leia to update or delete her dashes:

    methods:
    - PUT
    - PATCH
    - DELETE
    - OPTIONS  # necessary for CORS
    template: "<https://api.dashkite.com/dashes/leia/{id}>"
    recipient: "RFfBy/1mioLtrsxk2CifDz/V3N4TauSca+xlwNN+wEI="
    use:
    - "XL9Jjv8cOs0TrNOJLhQ0eQbNeE7n67Zk//iToaB7UpA="

Through the use of URL templates specified in [RFC 6570](https://tools.ietf.org/html/rfc6570), you can describe a set of HTTP requests on a collection of resources in an API. Web capabilities support flexible permission specification. Specify coarse-grained access with parameterization, or restrict the recipient to a single URL and HTTP method combination.

A Web capability includes at least two public signing keys. One belonging to the recipient and one assigned by the issuer as a use key pair. Together, they grant flexible public key registry control. The use key pair allows for the revocation of the individual capability, while the recipient key pair allows for the revocation all capabilities associated with a recipient.

Unsupported in version 1.0: per-use keys also support N-time use capabilities (by providing N keys and setting `once` to true).

## Introducing Panda-Capability

Capabilities work as a security model by using the power of digital signatures; however, for every Web capability, there are at least 3 pairs of signing keys to consider. And because Web capabilities can be fine-grained, an application developer will likely need to deal with dozens of key pairs and their resultant cryptographic products.

We developed Panda-Capability to manage this complexity with a high-level interface. In the examples that follow, we will lay out a Web Capability spec and its high-level execution via the Panda-Capability interface.

## Issuing to the Recipient: Grants and Directories

Alone, a Web capability is a mere description of an action. It is given force when digitally signed by the issuer to create a *grant*.

The capability within a grant contains only public keys (fields `publicUse` and `recipient`). So alongside a grant, the issuer needs to bundle the matching use key pair(s).

Because Web capabilities can be fine-grained, we will end up with a collection of grants and their corresponding use key pairs. Panda-Capability has a container class called a `Directory` [to](http://directory.to) mange them.  

Grants are organized by URL template and HTTP method in a 2-D dictionary.  Together, they reference a given grant and its corresponding use key pair(s).  You can lookup an entry directly with `directory[<URL Template>][<HTTP Method>]`, but in practice you will use Panda-Capability's `lookup` function (see below).

The `Directory` class also has methods to support serialization and hydration.

### Directory Entry

### Example: Issuer

The DashKite API issues a directory containing some grants for Leia with  `issue`, a Panda-Capability function.  `issue` accepts an array of capability stubs along with the API's and Leia's signing keys. Use key pairs are generated for each capability automatically.

    import {confidential} from "panda-confidential"
    import PandaCapability from "panda-capability"
    
    Confidential = confidential()
    {issue} = PandaCapability Confidential
    
    leiaDirectory = await issue apiSignatureKeyPair, leiaPublicSignatureKey, [
          template: "/profiles/leia/dashes"
          methods: ["OPTIONS", "POST"]
        ,
          template: "/profiles/leia/dashes/{id}"
          methods: ["OPTIONS", "GET", "PUT", "DELETE"]
      ]
    
    # directories are 2-D dictionaries, but in practice we use the function `lookup`.
    {useKeyPairs, grant} = leiaDirectory["/profiles/leia/dashes"]["POST"]

The issuer signs each capability, creating a set of grants organized in a directory.

In theory, the issuer could issue a grant for every resource at the moment of its creation. The resulting directory with a single entry could then be placed into the `capability` response header. This is similar to the use of the `location` header on `201 Created` responses.

However, our current approach is for the issuer to use URL templates and anticipate the creation of future, specific resources. 

1. Because Leia's directory contains whole use key pairs, we consider a directory private and ideally the issuer should not store this entity.  We also recommend employing encryption for transport and storage.
2. Establishing the directory as an API resource provides a convenient structure for the recipient to refresh their directory and public key registry (revoking the old keys) at will.  This is also useful for establishing device authorization flows.  

Since the directory refresh endpoint requires authorization, we need a bootstrapping flow.  We use the `capability` header in the response to the HTTP request that establishes the recipient's identity within the issuer's API.  The recipient gets a directory with only one entry, the capability to refresh their directory.  

### Example: Recipient

In the DashKite API, we can use the Panda-Confidential interface to ready Leia's directory for transport:

    {SharedKey, Message, encrypt} = Confidential
    
    key = SharedKey.create apiEncryptionKeyPair.privateKey, leiaPublicEncryptionKey
    
    envelope = await encrypt key,
      Message.from "utf8", leiaDirectory.to "utf8"
    
    # The directory is now suitable to be sent to Leia's device as a response body.
    responseBody = envelope.to "base64"

In Leia's device, she can decrypt and store the directory using the Panda-Confidential and Panda-Capability interfaces. Remember that the directory is secret, ideally not stored by the issuer, and should be encrypted when stored.

    import {confidential} from "panda-confidential"
    import PandaCapability from "panda-capability"
    
    Confidential = confidential()
    {SharedKey, Envelope, decrypt, Message} = Confidential
    {Directory} = PandaCapability Confidential
    
    # API request resulting in a fetch of Leia's encrypted directory.
    serializedEnvelope = await fetchMyDirectory()
    
    key = SharedKey.create myEncryptionKeyPair.privateKey, apiPublicEncryptionKey
    
    message = decrypt key,
      Envelope.from "base64", serializedEnvelope
    
    # Leia now has an instantiated directory of her grants.
    directory = Directory.from "bytes", message.to "bytes"
    
    # Encrypt when storing.
    key = SharedKey.create myEncryptionKeyPair
    toLocalStorage await encrypt key, Message.from "bytes", directory.to "bytes"

## Exercising a Grant

For the recipient to exercise a capability it must first be granted by the issuer. So, as a shorthand, we say the recipient exercises a grant. The steps to exercise a grant include:

1. Looking up the grant from the directory.
2. Creating an *assertion*, which includes the grant.
3. Signing the assertion with the recipient's key pair and use key pair to finalize.
4. Setting the `Authorization` request header.

### Creating Assertions

As a dictionary, the recipient could directly lookup a grant based on a URL template and HTTP method, ex: `directory[<template>][<method>]`.

In practice, we don't want to directly use a grant. We instead add parameters that add specificity to our authorization and a nonce to mitigate replay attacks. The recipient assembles a document that includes:

The recipient then signs the document twice:  

1. With the use key pair
2. With the recipient's key pair

This forms an *assertion*.

To summarize: the recipient exercises a grant from their directory to form an assertion of their capability. 

> Note: Remember that a Web capability include multiple signing keys for flexible public key registry control.  See the section describing the capability document for more information.

### Set The `Authorization` Header

The assertion is Base64 encoded and added to the request `Authorization` header, using the `capability` authorization type. This makes it available for inspection and validation.

## Panda-Capability Manages Complexity

Panda-Capability's interface is designed to keep application developers from worrying too much about the tedium of juggling signing keys and their products

### Example

Leia wants to make an authorized request to delete an existing dash with the ID `DeathStarExhaust`. 

    {lookup, exercise} = PandaCapability Confidential
    
    # Client looks up the relevant grant from Leia's directory, matching using
    # only the URL. (URL could come from panda-sky-client)
    methods = lookup directory, "/profiles/leia/dashes/foobardashID"
    
    # Client then uses the HTTP method to get the directory entry.
    {grant, useKeyPairs} = methods.DELETE
    
    # Client specifies the parameters for the grant
    parameters =
      url:
        id: "DeathStarExhaust"
    
    # Client exercises the grant using Leia's signature key pair and the
    # grant it just looked up. Yields an Assertion, another
    # Panda-Capability container class.
    assertion = exercise mySignatureKeyPair, useKeyPairs, grant, parameters
    
    # When the client forms the HTTP request, it just needs to serialize the
    # assertion and place into the Authorization header.
    request =
      url: "/profiles/alice/dashes/DeathStarExhaust"
      method: "DELETE"
      headers:
        authorization: "Capability #{assertion.to "base64"}"

Given a URL and HTTP method, Panda-Capability lets the application developer easily lookup the appropriate grant and then exercise it to create an assertion with the robust authority of the issuer and recipient digital signatures.

## Verification

Consider an API handling a request containing a capability assertion.  We are concerned with two objectives:

1. Rigorously verifying the internal consistency of the assertion
2. Checking a public key registry to confirm the involved parties have not revoked their participation.

Neither of those objectives requires privileged access: (1) contemplates data *within* the assertion, while (2) is a check on *public* data.

In fact, the verification flow can occur outside of the issuer API; either within an intermediary (such as an edge cache for proxy server), or within a system belonging entirely to a third party.

Panda-Capability provides a simple interface to perform (1).  It confirms:

- the request matches the signatures from issuer, recipient, and use key pairs
- the listed signatories correspond to the signatures
- the request parameters match the actual request
- the timestamp used as a nonce is within the +/- 30 second tolerance.

Panda-Capability leaves (2) up to the implementer.  You must go to the relevant public key registry and perform a lookup to confirm that the key pairs involved have not been revoked.

### Example

The `DELETE` request from Leia makes its way to the API for verification.

    {parse, challenge} = PandaCapability Confidential
    
    fail = (message) ->
      console.warn message
    	throw new Unauthorized message
    
    handler = (request) ->
    	# Objective 1: Signature Validity Check
    	try
    	  assertion = parse request
    	  challenge request, assertion
    	catch e
    	   console.warn e
    	   throw new Unauthorized()
    
      # Objective 2: Public Key Revocation Check
      claim = assertion.publicKeys
      registry = await fetchRegistry()
    
      fail "issuer key does not match" unless claim.issuer == apiSignaturePublicKey
      fail "invalid use key" unless registry.has claim.use
      fail "invalid recipient key" unless registry.has claim.recipient
