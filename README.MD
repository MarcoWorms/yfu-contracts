Modified ERC721 from OpenZeppelin, to attend the following:

- Add a fixed limit for total copies minted (can't be changed after deployed)
- Copies minted cost a fixed price (can't be changed after deployed)
- wallets with the DEFAULT_ADMIN_ROLE can add/remove wallets for below roles
- wallets with the DEFAULT_ADMIN_ROLE role can freeze/unfreeze all tokens transferability
- in prod the DEFAULT_ADMIN_ROLE will be owned only by "YFI story multisig"

Testing checklist for [YFUtechne.sol](./YFUtechne.sol) reviewers:

- [ ] Deploy contract in testnet
- [ ] Mint until the max limit and make sure `msg.value` = mint price 
- [ ] `freeze_transfers` should not allow any transfer to happen but should allow `mint` to happen
- [ ] `unfreeze_transfers` should work
- [ ] `set_base_uri` should work
- [ ] `set_deposit_address` should work
- [ ] `DEFAULT_ADMIN_ROLE` should have getters to return its bytes32role value
- [ ] Deployer address can use `grantRole` to give roles
- [ ] Deployer address can use `renouceRole` to remove own roles
- [ ] Deployer address can use `revokeRole` to remove roles form others
- [ ] TokenURI returns an IPFS address based on `_baseURI` + token ID 
- [ ] `approve` and `setApprovalForAll` should allow other addresses to call transfers methods for your tokens (when transfers aren't frozen and contract isn't paused)

Todos before prod:
- find a IPFS to host all metadata .jsons for prod (pinata free plan can't handle this for exmaple)
- change `depositAddress` to YFI story multisig address
- coordinate deploy with YFI story multisig signers
- change MAX_SUPPLY and PRICE to match the project's needs
