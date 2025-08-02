# Signing behaviour

Mastodon has extended the ActivityPub objects to include a PublicKey. This is to enable it to sign the requests used to
distribute status updates out to followers.

![A sequence diagram showing the conversation when a Mastodon server commnunicates an activity to another server](SigningBehaviourSequence)

## How is the signature created

Mastodon selects particular elements from the request and builds a signature for those using the key for the `Person`
(Actor in Mastodon documentation) originating the status.

HTTP header looks like: -
```
Signature: keyId="https://my.example.com/actor#main-key",headers="(request-target) host date",signature="Y2FiYW...IxNGRiZDk4ZA=="
```
The three parts in this signature are:-
 * keyId - URL to the public key of the Person
 * headers - The headers used as source data for the signature
 * signature - SH256 hash of the headers which is signed using the private key of the Person and then base64 encoded

For POST requests, an additional header is added which is a SHA256 of the request body. This is stored in `Digest` 
header which is then included in the signature.

